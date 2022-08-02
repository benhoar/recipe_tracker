require_relative './inventory.rb'
require_relative './cookbook.rb'
require_relative './ingredient.rb'
require 'set'

def pp(item)
   if !item
      puts "no item"
      return
   end
   item.each_pair do | key, res |
      print "  #{key}: #{res} "
   end
   puts
end

#1. Inventory tester # FUNCTIONING
   # inventory = Inventory.new
   # # add ingredients in stock and out of stock
   # puts "BLOCK 1:"
   # inventory.add("turkey", true)
   # inventory.add("celery", false)
   # pp(inventory.find("turkey"))
   # pp(inventory.find("celery"))
   # # add existing ingredient
   # puts "BLOCK 2:"
   # inventory.add("turkey")
   # # add existing ingredient that is already in stock
   # puts "BLOCK 3:"
   # inventory.add("turkey", true)
   # # add existing ingredient that is out of stock
   # puts "BLOCK 4:"
   # inventory.add("celery", false)
   # # add existing ingredient with first source recipe
   # puts "BLOCK 5:"
   # inventory.add("cream", false, "whipped cream")
   # pp(inventory.find("cream"))
   # # add existing ingredient with additional source recipe
   # puts "BLOCK 6:"
   # inventory.add("cream", false, "ice cream")
   # pp(inventory.find("cream"))
   # # find an ingredient that does not exist
   # puts "BLOCK 7:"
   # pp(inventory.find("jalapeno"))
   # # update stock of ingredient that does not exist
   # puts "BLOCK 8:"
   # inventory.update_stock("jalapeno", true)
   # inventory.update_stock("habanero", false)
   # pp(inventory.find("jalapeno"))
   # pp(inventory.find("habanero"))
   # # update stock of that ingredient to false
   # puts "BLOCK 9:"
   # inventory.update_stock("jalapeno", false)
   # pp(inventory.find("jalapeno"))
   # # update stock of that ingredeient to true
   # puts "BLOCK 10:"
   # inventory.update_stock("jalapeno", true)
   # pp(inventory.find("jalapeno"))
   # # check for stock of ingredient
   # puts "BLOCK 11:"
   # puts inventory.in_stock("jalapeno")
   # # delete recipe
   # puts "END BLOCK"
   # inventory.delete("celery")
   # inventory.delete("turkey")
   # inventory.delete("jalapeno")
   # inventory.delete("habanero")
   # inventory.delete("cream")

#2. Cookbook tester # FUNCTIONING
   # cookbook = CookBook.new
   # # add recipe that does not exist and does exist
   # puts "BLOCK 1:"
   # cookbook.add("tacos")
   # cookbook.add("tacos")
   # pp(cookbook.get_recipe("tacos"))
   # # update recipe
   # puts "BLOCK 2:"
   # cookbook.update_recipe("tacos")
   # pp(cookbook.get_recipe("tacos"))
   # puts
   # # update recipe ingredients
   # puts "BLOCK 3:"
   # cookbook.update_recipe("tacos")
   # pp(cookbook.get_recipe("tacos"))
   # # update recipe that doesn't exist
   # puts "BLOCK 4:"
   # cookbook.update_recipe("lasagna")
   # # udpate recipe with no changes
   # puts "BLOCK 5:"
   # cookbook.update_recipe("tacos")
   # pp(cookbook.get_recipe("tacos"))
   # # delete recipes
   # cookbook.remove("tacos")

#3. Aggregate tester # FUNCTIONING
   # inventory = Inventory.new
   # cookbook = CookBook.new
   # # add recipe
   # cookbook.add("cheese burger")
   # cookbook.add("burger")
   # pp(cookbook.get_recipe("cheese burger"))
   # # update recipe   
   # cookbook.update_recipe("cheese burger") # add ingredients
   # pp(cookbook.get_recipe("cheese burger"))
   # cookbook.update_recipe("cheese burger") # remove ingredients
   # pp(cookbook.get_recipe("cheese burger"))
   # cookbook.update_recipe("cheese burger") # add and remove ingredients at once
   # pp(cookbook.get_recipe("cheese burger"))
   # # update stock of items in recipe
   # inventory.update_stock("meat", true)
   # pp(cookbook.get_recipe("cheese burger"))
   # inventory.update_stock("bun", true)
   # pp(cookbook.get_recipe("cheese burger"))
   # inventory.update_stock("meat", false)
   # pp(cookbook.get_recipe("cheese burger"))
   # cookbook.remove("cheese burger")
   # cookbook.remove("burger")

#4. Ingredient updating/manipulation # FUNCTIONING
   # cookbook = CookBook.new
   # inventory = Inventory.new
   # cookbook.add("pb & j")
   # pp(cookbook.get_recipe("pb & j"))
   # cookbook.update_recipe("pb & j") #add
   # pp(cookbook.get_recipe("pb & j"))
   # puts inventory.find("honey")
   # cookbook.update_recipe("pb & j") #remove
   # pp(cookbook.get_recipe("pb & j"))
   # puts inventory.find("honey")
   # cookbook.update_recipe("pb & j") #remove all
   # pp(cookbook.get_recipe("pb & j"))
   # puts inventory.find("peanut butter")
   # puts inventory.find("jelly")
   # puts inventory.find("bread")
   # cookbook.update_recipe("pb & j") #restore og recipe
   # pp(cookbook.get_recipe("pb & j"))
   # inventory.update_stock("bread", true)
   # inventory.update_stock("jelly", true)
   # pp(cookbook.get_recipe("pb & j"))
   # inventory.update_stock("bread", false)
   # inventory.update_stock("jelly", false)
   # inventory.update_stock("peanut butter", false)
   # inventory.update_stock("peanut butter", false)
   # pp(cookbook.get_recipe("pb & j"))
   # inventory.update_stock("peanut butter", true)
   # inventory.update_stock("jelly", true)
   # inventory.update_stock("bread", true)
   # cookbook.update_recipe("pb & j")
   # pp(cookbook.get_recipe("pb & j"))

testSet = Set.new([1, 2, 3])
puts testSet.to_s
puts testSet.to_s[8..-3]