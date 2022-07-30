require 'aws-sdk-dynamodb'

class IngredientDB

   def initialize()
      Aws.config.update(region: 'us-west-1')
      @table_name = 'Ingredients'
      @client = Aws::DynamoDB::Client.new
   end

   def add(item)
      table_item = {table_name: @table_name}
      table_item[:item] = item
      puts table_item
      @client.put_item(table_item)
      return true
   rescue StandardError => e
      puts "Error adding #{item["ingredient"]}: #{e.message}"
      return false
   end

   def get_ingredient(query)
      query[:table_name] = @table_name
      return @client.query(query).items[0]
   rescue StandardError => e
      puts "Error finding item: #{e.message}"
      return nil
   end

   def delete(ingredient)
      table_item = {table_name: @table_name}
      table_item[:key] = {:ingredient => ingredient}
      @client.delete_item(table_item)
      return true
   rescue StandardError => e
      puts "Error removing #{ingredient}: #{e.message}"
      return false
   end

   def update(item)
      item[:table_name] = @table_name
      @client.update_item(item)
      return true
   rescue StandardError => e
      puts "Error updating #{ingredient}: #{e.message}"
      return false
   end

   private 

   attr_accessor :table_name
   attr_accessor :client

end