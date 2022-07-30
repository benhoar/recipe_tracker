require 'aws-sdk-dynamodb'
require 'json'
require './inventory'
require './recipe.rb'

class CookBook

   def add(recipe)
      item = {}
      item["recipe"] = recipe
      if get_recipe(recipe)
         puts "Recipe already exists"
         return
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
   
      puts "\nFill Out Other Categories to Include, Leave Blank if Skipping: " 
      addtnal_attr.each do | key, prompt |
         print prompt
         res = gets.chomp.downcase
         if key == "ingredients"
            hold = res.split(", ")
            res = Set[]
            hold.each do | ing |
               res.add(ing)
            end
         end
         if res.length != 0
            item[key] = res
         end
      end

      item[:missing_ingredients] = ingredient_adder(item["ingredients"], recipe)
   
      added = RecipesDB.new.add(item)
      puts "#{item["recipe"]} was added to cookbook"
      return added
   end

   def remove(recipe)
      cur = get_recipe(recipe)
      if cur
         remove_from_ingredients_recipes(recipe, cur["ingredients"])
      end
      return RecipesDB.new.delete(recipe)
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
   
      res = RecipesDB.new.get_recipe(query_condition)
      return res ? res : nil
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
   
      attributes = Set["ingredients", "origin", "speed", "notes", "link", "cost"]
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
            attributes.delete(att)
            update_exp += "#{att} = :#{attr_alias}, "
            if att == "ingredients"
               att_upd = update_ingredients(table_item, recipe)
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
         end
      end
      
      table_item[:update_expression] = update_exp[0, update_exp.length-2]
      table_item[:key] = { "recipe": recipe }
      table_item[:expression_attribute_values] = exp_attr_vals
      table_item[:return_values] = "UPDATED_NEW"
      RecipesDB.new.update(table_item)

   end

   def update_availability(recipe, moreAvailable)
      res = get_recipe(recipe)
      curVal = res["missing_ingredients"]
      newVal = moreAvailable ? curVal - 1 : curVal + 1
      table_item = {}
      table_item[:key] = { "recipe": recipe }
      table_item[:update_expression] = "SET missing_ingredients = :i"
      table_item[:expression_attribute_values] = {":i" => newVal}
      table_item[:return_values] = "UPDATED_NEW"
      RecipesDB.new.update(table_item)
   end

   private

   def ingredient_adder(ingredients, recipe)
      inventory = Inventory.new
      missing_ingredients = ingredients.length
      ingredients.each do | ing |
         inventory.add(ing, false, recipe)
      end
      ingredients.each do | ing |
         if inventory.in_stock(ing)
            missing_ingredients -= 1
         end
      end
      return missing_ingredients
   end

   def alter_ingredients(ingredients, x)
      if x == "1"
         while true
            print "  Enter Ingredient: "
            ing = gets.chomp
            if ing == ""
               break
            end
            ingredients.delete(ing)
         end
      else
         while true
            print "  Enter Ingredient: "
            ing = gets.chomp
            if ing == ""
               break
            end
            ingredients.add(ing)
         end
      end
   end

   def update_ingredients(table_item, recipe)
      print "Would you like to add to (0), remove from (1), or replace (2) the recipe?: "
      ingredients = get_recipe(recipe)["ingredients"].clone
      x = gets.chomp
      if x == "0" or x == "1"
         while x == "0" or x == "1"
            alter_ingredients(ingredients, x)
            print "Would you like to make any more changes (0 to add, 1 to remove)?: "
            x = gets.chomp
         end
      elsif x == "2"
         print "  New ingredients: "
         res = gets.chomp
         hold = res.split(", ")
         res = Set[]
         hold.each do | ing |
            res.add(ing)
         end
         ingredients = res
      else
         puts "Invalid input"
      end
      return ingredients
   end

   def remove_from_ingredients_recipes(recipe, ingredients)
      ingredients.each do | ingredient |
         inventory = Inventory.new
         inventory.remove_recipe(recipe, ingredient)
      end
   end

end