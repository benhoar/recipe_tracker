require_relative './inventory.rb'
require_relative './cookbook.rb'
require_relative './ingredient.rb'

# inventory = Inventory.new
# inventory.add("juice")

# cookbook = CookBook.new
# cookbook.add("penis juice")
# puts cookbook.get_recipe("penis juice")

# puts "Restocking penis"
# inventory.update_stock("penis", true)
# puts cookbook.get_recipe("penis juice")

# puts "Removing penis from stock"
# inventory.update_stock("penis", false)
# puts cookbook.get_recipe("penis juice")

# inventory = Inventory.new
# inventory.update_stock("eggs", false)
# inventory.add("penis juice", false, "penis juice soup")
# inventory.add("tofu", false, "mapo tofu")

# 1. add/remove inventory without recipe source #FUNCTIONING
   # inventory = Inventory.new
   # puts "1 #{inventory.add("clams")}"
   # puts "2 #{inventory.find("mushroom")}"
   # puts "3 #{inventory.find("anal beads") ? "found" : "not found"}"
   # puts "4 #{inventory.delete("clams")}"
   # puts "5 #{inventory.add("clams")}"
   # puts "6 #{inventory.add("clams")}"
   # inventory.update_stock("mushroom", false)
   # puts "7 #{inventory.find("mushroom")}"
   # inventory.update_stock("mushroom", true)
   # puts "8 #{inventory.find("mushroom")}"
   # inventory.delete("mushroom")
   # puts "9 #{inventory.find("mushroom") ? "found" : "not found"}"
   # inventory.add("mushroom")
   # inventory.update_stock("mushroom", false)


# 2. add ingredient with recipe source #FUNCTIONING
   # inventory = Inventory.new
   # inventory.add("weiner", false, "hot dogs")
   # puts inventory.find("weiner")
   # inventory.add("weiner")
   # inventory.delete("weiner")
   # inventory.add("weiner", true, "hot dogs")
   # puts inventory.find("weiner")

# 3. add recipe without existing ingredients #FUNCTIONING
   # cookbook = CookBook.new
   # cookbook.add("burger")
   # puts cookbook.remove("burger")
   # puts cookbook.get_recipe("burger")
   # cookbook.add("burger")
   # puts cookbook.get_recipe("butts") ? "butts!" : "not found"

# 3a. update ingredient "meat" of burger both directions #FUNCTIONING
   # inventory = Inventory.new
   # cookbook = CookBook.new
   # cookbook.add("burger")
   # inventory.update_stock("meat", true)
   # puts cookbook.get_recipe("burger")
   # inventory.update_stock("meat", true)
   # puts cookbook.get_recipe("burger")
   # inventory.update_stock("meat", false)
   # puts cookbook.get_recipe("burger")

# 4. add recipe with existing ingredients #FUNCTIONING
   # cookbook = CookBook.new
   # cookbook.add("burger")
   # cookbook.add("cheese burger")
   # puts cookbook.get_recipe("burger")
   # puts cookbook.get_recipe("cheese burger")
   # inventory = Inventory.new
   # inventory.update_stock("cheese", true)
   # puts cookbook.get_recipe("cheese burger")
   # inventory.update_stock("cheese", false)
   # puts cookbook.get_recipe("cheese burger")
   # inventory.update_stock("meat", true)

# 5. update to in stock an ingredient with associated recipes #FUNCTIONING
   # inventory = Inventory.new
   # inventory.update_stock("cheese", true)

# 6. update to out of stock an ingredient with associated recipes #FUNCTIONING
   # inventory = Inventory.new
   # inventory.update_stock("mushroom", false)

# 4 Issue Resolution
   # CASE 1: Adding an ingredient in isolation: FUNCTIONING
   # CASE 2: Adding an ingredient from a recipe: FUNCTIONING
   # CASE 3: Updating an ingredients recipe list: NOT FUNCTIONING
