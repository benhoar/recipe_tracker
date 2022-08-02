require_relative './inventory.rb'
require_relative './cookbook.rb'
require_relative './ingredient.rb'

def short_print(item)
   recipe = item["recipe"]
   ingredients = item["ingredients"].to_s[8..-3]
   cost = item["cost"]
   puts "#{recipe} #{cost}: #{ingredients}"
end

def long_print(item)
   puts "#{item["recipe"]}"
   item.each_key do | key |
      if key == "ingredients"
         puts "#{key}: #{item["ingredients"].to_s[8..-3]}"
      elsif key != "recipe"
         puts "#{key}: #{item[key]}"
      end
   end
end

def run_me()
   inventory = Inventory.new
   cookbook = CookBook.new
   while true
      puts "\nWhat would you like to do?\n"
      print "(0) Show me what is ready to cook now!\n" \
           "(1) Add a recipe\n" \
           "(2) Update a recipe\n" \
           "(3) Remove a recipe\n" \
           "(4) Find a recipe\n" \
           "(5) Restock an ingredient\n" \
           "(6) Unstock an ingredient\n" \
           "(7) Check for ingredient\n" \
           "(8) Delete an ingredient (ONLY USE FOR MISPELLINGS/NOT TO UNSTOCK) \n"
      print "Enter Choice: " 
      x = gets.chomp
      puts
      case x
      when "0"
         puts "Here are your ready to cook meals!"
         cookbook.ready_to_cook.each do | r |
            short_print(r)
         end
      when "1"
         print "Enter name of recipe to add: "
         recipe = gets.chomp.downcase
         puts cookbook.add(recipe)
      when "2"
         print "Enter name of recipe to update: "
         recipe = gets.chomp.downcase
         puts cookbook.update_recipe(recipe)
      when "3"
         print "Enter name of recipe to remove: "
         recipe = gets.chomp.downcase
         puts cookbook.remove(recipe)
      when "4"
         print "Enter name of recipe to find: "
         recipe = gets.chomp.downcase
         long_print(cookbook.get_recipe(recipe))
      when "5"
         print "Enter ingredient to restock: "
         ingredient = gets.chomp.downcase
         puts inventory.update_stock(ingredient, true)
      when "6"
         print "Enter ingredient un-stock: "
         ingredient = gets.chomp.downcase
         puts inventory.update_stock(ingredient, false)
      when "7"
         print "What ingredient are we looking for: "
         ingredient = gets.chomp.downcase
         puts inventory.in_stock(ingredient) ? "IN STOCK" : "OUT OF STOCK"
      when "8"
         print "Enter ingredient to delete: "
         recipe = gets.chomp.downcase
         puts inventory.delete(recipe)
      else
         puts "Goodbye."
         break
      end
   end
end

run_me if $PROGRAM_NAME == __FILE__