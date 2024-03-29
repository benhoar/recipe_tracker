require 'aws-sdk-dynamodb'
require 'json'
require './inventory'
require './recipe.rb'

class CookBook

   attr_accessor :dbcaller
   
   def initialize()
      @dbcaller = RecipesDB.new
   end

   def add(recipe)
      item = {}
      item["recipe"] = recipe
      if get_recipe(recipe)
         puts "Recipe already exists"
         return false
      end
   
      addtnal_attr = {
         "category" => "  Category: ",
         "ingredients" => "  Ingredients: ",
         "origin" => "  Type of Cuisine: ",
         "speed" => "  Speed of Preparation: ",
         "link" => "  Recipe Link: ",
         "notes" => "  Extra Notes: ",
         "cost" => "  Cost: "
      }
   
      puts "Enter other information for #{recipe}, Leave Blank if Skipping: " 
      addtnal_attr.each do | key, prompt |
         print prompt
         res = gets.chomp.downcase
         if key == "ingredients"
            res = Set.new(res.split(", "))
         end
         if res.length != 0
            item[key] = res
         end
      end

      ingredient_adder(item["ingredients"], recipe)
      item[:missing_ingredients] = missing_ingredients(item["ingredients"])
   
      added = @dbcaller.add(item)
      puts "#{item["recipe"]} was added to cookbook"
      return added
   end

   def remove(recipe)
      cur = get_recipe(recipe)
      if cur
         remove_from_ingredients_recipes(recipe, cur["ingredients"])
      end
      return @dbcaller.delete(recipe)
   end

   def get_recipe(recipe)
      attr_vals = {":recipe" => recipe}
      key_conds = "#rc = :recipe"
   
      query_condition = {
         # provides specific val for parition key or primary key
         key_condition_expression: key_conds,
         # below exists for protected names that interfere w attr names (name is protected - error if not aliased)
         expression_attribute_names: {"#rc" => "recipe"},
         # replaces variables in key_cond_exp with actual values at runtime
         expression_attribute_values: attr_vals,
         #projection_expression: "#nm, speed, ingredients, category"
      }
   
      res = @dbcaller.get_recipe(query_condition)
      return res ? res : nil
   end

   def ready_to_cook()
      return @dbcaller.has_all_ingredients
   end

   def update_recipe(recipe)
      res = get_recipe(recipe)
      if res == nil
         print "Recipe not found!\nWould you like to add it? (Y/N): "
         if gets.chomp == "Y"
            add(recipe)
         end
         return
      end
   
      attributes = Set["ingredients", "origin", "speed", "notes", "link", "cost", "category"]
      update_exp = "SET "
      i = 0
      exp_attr_vals = {}
      while !attributes.empty?
         attr_alias = "v#{i}"
         print "Which attribute would you like to update?: "
         att = gets.chomp.downcase
         if att == ""
            break
         end
         if attributes.include? att
            update_exp += "#{att} = :#{attr_alias}, "
            if att == "ingredients"
               att_upd = update_ingredients(res)
               missing_count = missing_ingredients(att_upd)
               exp_attr_vals[":mi"] = missing_count
               update_exp += "#{"missing_ingredients"} = :mi, "
            else 
               print "Please, input the updated value: "
               att_upd = gets.chomp
            end
            exp_attr_vals[":#{attr_alias}"] = att_upd 
            i += 1
         else
            print "Please select from list: "
            attributes.each do | a |
               print "#{a} "
            end
            puts
         end
      end
      if update_exp.length == 4
         puts "no updates made"
         return
      end

      table_item = {}
      table_item[:update_expression] = update_exp[0, update_exp.length-2]
      table_item[:key] = { "recipe": recipe }
      table_item[:expression_attribute_values] = exp_attr_vals
      table_item[:return_values] = "UPDATED_NEW"
      @dbcaller.update(table_item)

   end

   def update_availability(recipe, moreAvailable)
      res = get_recipe(recipe)
      curVal = res["missing_ingredients"]
      newVal = moreAvailable ? curVal - 1 : curVal + 1
      newVal = newVal < 0 ? 0 : newVal
      table_item = {}
      table_item[:key] = { "recipe": recipe }
      table_item[:update_expression] = "SET missing_ingredients = :i"
      table_item[:expression_attribute_values] = {":i" => newVal}
      table_item[:return_values] = "UPDATED_NEW"
      @dbcaller.update(table_item)
   end

   private

   def missing_ingredients(ingredients)
      count = ingredients.length
      inventory = Inventory.new
      ingredients.each do | ing |
         if inventory.in_stock(ing)
            count -= 1
         end
      end
      return count
   end

   def ingredient_adder(ingredients, recipe)
      inventory = Inventory.new
      ingredients.each do | ing |
         inventory.add(ing, false, recipe)
      end
      return 
   end

   def alter_ingredients(ingredients, x, recipe)
      if x == "1"
         to_remove = nil
         print "\nEnter ingredients to remove (\"replace\" to remove all): "
         input = gets.chomp.downcase
         if input == "replace"
            to_remove = ingredients.clone
            ingredients.clear()
         else
            to_remove = Set.new(input.split(', '))
            to_remove.each do | ing |
               if !ingredients.include? ing
                  puts "#{ing} is not in the recipe!"
                  to_remove.delete(ing)
               else 
                  ingredients.delete(ing)
               end
            end
         end
         if to_remove.empty?
            return ingredients
         end
         remove_from_ingredients_recipes(recipe, to_remove) #
      else
         print "\nEnter ingredients to add: "
         input = gets.chomp.downcase
         to_add = Set.new(input.split(', '))
         ingredients = ingredients.union(to_add)
         if to_add.empty?
            return ingredients
         end
         ingredient_adder(to_add, recipe) #
      end
      return ingredients
   end

   def update_ingredients(recipe_item)
      ingredients = recipe_item["ingredients"].clone
      print "Would you like to add to (0), remove from (1) the recipe? "
      x = gets.chomp
      while x == "0" or x == "1"
         if ingredients.empty? and x=="1"
            puts "You must add to the recipe."
            x="0"
         end
         ingredients = alter_ingredients(ingredients, x, recipe_item["recipe"])
         if ingredients.empty?
            x="0"
            puts "The recipe is empty, please add ingredients."
         else
            print "Would you like to make any more changes (0 to add, 1 to remove)?: "
            x = gets.chomp
         end
      end
      return ingredients
   end

   def remove_from_ingredients_recipes(recipe, ingredients)
      if !ingredients
         return
      end
      ingredients.each do | ingredient |
         inventory = Inventory.new
         inventory.remove_recipe(recipe, ingredient)
      end
   end

end