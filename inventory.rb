require 'aws-sdk-dynamodb'
require './cookbook.rb'
require './ingredient.rb'

class Inventory

   attr_accessor :dbcaller
   
   def initialize()
      @dbcaller = IngredientDB.new
   end

   def add(ingredient, inStock=true, sourceRecipe=nil)
      ingredient_item = find(ingredient)
      if ingredient_item
         handle_existing_item(ingredient_item, inStock, ingredient, sourceRecipe)
         return
      end
      item = {
         "ingredient" => ingredient,
         "inStock" => inStock,
         "recipes" => sourceRecipe ? Set[sourceRecipe] : Set[""]
      }
      added = @dbcaller.add(item)
      puts "#{ingredient} added to table!"
      return added
   end

   def find(ingredient)
      attr_vals = {":ingredient" => ingredient}
      key_conds = "ingredient = :ingredient"
      query_condition = {
         key_condition_expression: key_conds,
         expression_attribute_values: attr_vals,
      }
      res = @dbcaller.get_ingredient(query_condition)
      return res ? res : nil
   end

   def update_stock(ingredient, stockValue)
      ingredient_item = find(ingredient)
      if !ingredient_item
         add(ingredient, stockValue)
         return
      end
      if ingredient_item["inStock"] == stockValue
         return
      end
      update_recipes(ingredient_item["recipes"], stockValue)
      table_item = {}
      table_item[:key] = { "ingredient": ingredient }
      table_item[:update_expression] = "SET inStock = :i"
      table_item[:expression_attribute_values] = {":i" => stockValue}
      table_item[:return_values] = "UPDATED_NEW"
      updated = @dbcaller.update(table_item)
      puts "#{ingredient} updated to #{stockValue ? "in stock" : "out of stock"}"
      return updated
   end

   def in_stock(ingredient)
      item = find(ingredient)
      return item ? item["inStock"] : false
   end

   def delete(ingredient)
      deleted = @dbcaller.delete(ingredient)
      return deleted ? true : false
   end

   def remove_recipe(recipe, ingredient)
      ingredient_item = find(ingredient)
      if !ingredient_item.has_key? "recipes"
         return
      end
      recipes = ingredient_item["recipes"].clone
      recipes.delete(recipe)
      table_item = {}
      table_item[:key] = { "ingredient": ingredient }
      table_item[:update_expression] = "SET recipes=:r"
      table_item[:expression_attribute_values] = { ":r" => recipes.length > 0 ? recipes : Set.new([""])}
      table_item[:return_values] = "UPDATED_NEW"
      return @dbcaller.update(table_item)
   end

   private

   def init_recipes(ingredient, source)
      table_item = {}
      table_item[:key] = { "ingredient": ingredient }
      table_item[:update_expression] = "SET recipes=:r"
      table_item[:expression_attribute_values] = { ":r" => Set[source]}
      table_item[:return_values] = "UPDATED_NEW"
      return @dbcaller.update(table_item)
   end

   def update_recipes(recipes, inStock)
      if !recipes
         return
      end
      cookbook = CookBook.new
      recipes.each do | recipe |
         if recipe != ""
            cookbook.update_availability(recipe, inStock)
         end
      end
   end

   def add_recipe(ingredient_item, sourceRecipe)
      recipes = ingredient_item["recipes"].clone
      if recipes.include? ""
         recipes.delete("")
      end
      recipes.add(sourceRecipe)
      table_item = {}
      table_item[:key] = { "ingredient": ingredient_item["ingredient"] }
      table_item[:update_expression] = "SET recipes=:r"
      table_item[:expression_attribute_values] = { ":r" => recipes}
      table_item[:return_values] = "UPDATED_NEW"
      return @dbcaller.update(table_item)
   end

   def handle_existing_item(ingredient_item, inStock, ingredient, sourceRecipe)
      if sourceRecipe
         if ingredient_item.has_key? "recipes"
            add_recipe(ingredient_item, sourceRecipe)
         else 
            init_recipes(ingredient, sourceRecipe)
         end
      elsif !ingredient_item["inStock"]
         update_stock(ingredient, inStock)
      else
         puts "This item exists and is in stock"
      end
   end

end