require 'aws-sdk-dynamodb'

class RecipesDB

   def initialize()
      Aws.config.update(region: 'us-west-1')
      @table_name = 'Cookbook'
      @client = Aws::DynamoDB::Client.new
   end

   def add(item)
      table_item = {table_name: @table_name}
      table_item[:item] = item
      @client.put_item(table_item)
      return true
   rescue StandardError => e
      puts "Error adding #{item["recipe"]}: #{e.message}"
      return false
   end

   def get_recipe(query)
      query[:table_name] = @table_name
      return @client.query(query).items[0]
   rescue StandardError => e
      puts "Error finding recipe: #{e.message}"
      return nil
   end

   def update(item)
      item[:table_name] = @table_name
      @client.update_item(item)
      return true
   rescue StandardError => e
      puts "Error updating #{item["recipe"]}: #{e.message}"
      return false
   end

   def delete(recipe)
      table_item = {table_name: @table_name}
      table_item[:key] = {:recipe => recipe}
      @client.delete_item(table_item)
      return true
   rescue StandardError => e
      puts "Error removing #{recipe}: #{e.message}"
      return false
   end

   def has_all_ingredients(x=0)
      attr_vals = {":missing_ingredients" => x}
      key_conds = "missing_ingredients = :missing_ingredients"
      
      query_condition = {
         table_name: @table_name,
         index_name: "missing_ingredients-index",
         key_condition_expression: key_conds,
         expression_attribute_values: attr_vals,
      }

      return @client.query(query_condition)[:items]
   rescue StandardError => e
      puts "Something went wrong."
      return nil
   end

private 

attr_accessor :table_name
attr_accessor :client

end