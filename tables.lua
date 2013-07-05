--Other mods can use this table to check player's specialty levels
specialties = {}
specialties.players = {}
specialties.tools = {}

--The GUI used to display the skills of each specialty
specialties.skills = {}
specialties.skills["miner"] = {menu="button[4.5,1;3,0.5;healpick;(100)Heal Pick]"..
			"button[4.5,1.5;3,0.5;upgradepick;(200)Upgrade Pick]"..
			"button[4.5,2;3,0.5;superheatpick;(500)Super Heat]"..
			"list[current_player;pick;5.5,0;1,1;]",
					specials={{name="superheat", description="Super Heat"}},
					tool="pick"}
specialties.skills["lumberjack"] = {menu="button[4.5,1;3,0.5;healaxe;(100)Heal Axe]"..
			"button[4.5,1.5;3,0.5;upgradeaxe;(200)Upgrade Axe]"..
			"button[4.5,2;3,0.5;superheataxe;(500)Super Heat]"..
			"button[4.5,2.5;3,0.5;felleraxe;(750)Feller]"..
			"list[current_player;axe;5.5,0;1,1;]",
					specials={{name="superheat", description="Super Heat"},
							  {name="feller",    description="Feller"}},
					tool="axe"}
specialties.skills["digger"] = {menu="button[4.5,1;3,0.5;healshovel;(100)Heal Shovel]"..
			"button[4.5,1.5;3,0.5;upgradeshovel;(200)Upgrade Shovel]"..
			"button[4.5,2;3,0.5;superheatshovel;(500)Super Heat]"..
			"list[current_player;shovel;5.5,0;1,1;]",
					specials={{name="superheat", description="Super Heat"}},
					tool="shovel"}
specialties.skills["builder"] = {menu="button[4.5,1;3,0.5;grantfast;(600)Move Fast]"..
			"button[4.5,1.5;3,0.5;grantfly;(800)Flying]",
					specials={}, tool=""}
if(minetest.get_modpath("farming") ~= nil or minetest.get_modpath("farming") ~= "") then
specialties.skills["farmer"] = {menu="button[4.5,1;3,0.5;healhoe;(100)Heal Hoe]"..
			"button[4.5,1.5;3,0.5;upgradehoe;(200)Upgrade Hoe]"..
			"button[4.5,2;3,0.5;greenthumb;(500)Green Thumb]"..
			"list[current_player;hoe;5.5,0;1,1;]",
					specials={{name="greenthumb", description="Green Thumb"}},
					tool="hoe"}
end

specialties.hoewear = {}
specialties.hoewear["wood"] = 30
specialties.hoewear["stone"] = 90
specialties.hoewear["steel"] = 200
specialties.hoewear["bronze"] = 220

--Amount to heal each type of tool
--mod support
specialties.healAmount = {}
specialties.healAmount["default:pick_wood"] = 40000
specialties.healAmount["default:pick_stone"] = 30000
specialties.healAmount["default:pick_steel"] = 20000
specialties.healAmount["default:pick_bronze"] = 17000
specialties.healAmount["default:pick_mese"] = 10000
specialties.healAmount["default:pick_diamond"] = 8000
specialties.healAmount["default:axe_wood"] = 40000
specialties.healAmount["default:axe_stone"] = 30000
specialties.healAmount["default:axe_steel"] = 20000
specialties.healAmount["default:axe_bronze"] = 17000
specialties.healAmount["default:axe_mese"] = 10000
specialties.healAmount["default:axe_diamond"] = 8000
specialties.healAmount["default:shovel_wood"] = 40000
specialties.healAmount["default:shovel_stone"] = 30000
specialties.healAmount["default:shovel_steel"] = 20000
specialties.healAmount["default:shovel_bronze"] = 17000
specialties.healAmount["default:shovel_mese"] = 10000
specialties.healAmount["default:shovel_diamond"] = 8000
specialties.healAmount["moreores:pick_bronze"] = 20000
specialties.healAmount["moreores:pick_silver"] = 32000
specialties.healAmount["moreores:pick_gold"] = 40000
specialties.healAmount["moreores:pick_mithril"] = 14000
specialties.healAmount["moreores:axe_bronze"] = 20000
specialties.healAmount["moreores:axe_silver"] = 32000
specialties.healAmount["moreores:axe_gold"] = 40000
specialties.healAmount["moreores:axe_mithril"] = 14000
specialties.healAmount["moreores:shovel_bronze"] = 20000
specialties.healAmount["moreores:shovel_silver"] = 32000
specialties.healAmount["moreores:shovel_gold"] = 40000
specialties.healAmount["moreores:shovel_mithril"] = 14000
specialties.healAmount["farming:hoe_wood"] = 40000
specialties.healAmount["farming:hoe_stone"] = 30000
specialties.healAmount["farming:hoe_steel"] = 20000
specialties.healAmount["farming:hoe_bronze"] = 20000

--List of tools that can be upgraded into a better one
--mod support
specialties.upgradeTree = {}
specialties.upgradeTree["default:pick_wood"] = "default:pick_stone"
specialties.upgradeTree["default:pick_stone"] = "default:pick_steel"
specialties.upgradeTree["default:pick_steel"] = "default:pick_bronze"
specialties.upgradeTree["default:pick_bronze"] = "default:pick_mese"
specialties.upgradeTree["default:pick_mese"] = "default:pick_diamond"
specialties.upgradeTree["default:axe_wood"] = "default:axe_stone"
specialties.upgradeTree["default:axe_stone"] = "default:axe_steel"
specialties.upgradeTree["default:axe_steel"] = "default:axe_bronze"
specialties.upgradeTree["default:axe_bronze"] = "default:axe_mese"
specialties.upgradeTree["default:axe_mese"] = "default:axe_diamond"
specialties.upgradeTree["default:shovel_wood"] = "default:shovel_stone"
specialties.upgradeTree["default:shovel_stone"] = "default:shovel_steel"
specialties.upgradeTree["default:shovel_steel"] = "default:shovel_bronze"
specialties.upgradeTree["default:shovel_bronze"] = "default:shovel_mese"
specialties.upgradeTree["default:shovel_mese"] = "default:shovel_diamond"
specialties.upgradeTree["moreores:pick_bronze"] = "moreores:pick_silver"
specialties.upgradeTree["moreores:pick_silver"] = "moreores:pick_gold"
specialties.upgradeTree["moreores:pick_gold"] = "moreores:pick_mithril"
specialties.upgradeTree["moreores:shovel_bronze"] = "moreores:shovel_silver"
specialties.upgradeTree["moreores:shovel_silver"] = "moreores:shovel_gold"
specialties.upgradeTree["moreores:shovel_gold"] = "moreores:shovel_mithril"
specialties.upgradeTree["moreores:axe_bronze"] = "moreores:axe_silver"
specialties.upgradeTree["moreores:axe_silver"] = "moreores:axe_gold"
specialties.upgradeTree["moreores:axe_gold"] = "moreores:axe_mithril"
specialties.upgradeTree["farming:hoe_wood"] = "farming:hoe_stone"
specialties.upgradeTree["farming:hoe_stone"] = "farming:hoe_steel"
specialties.upgradeTree["farming:hoe_steel"] = "farming:hoe_bronze"

--List of amounts used to calculate the xp required for transfer
specialties.transferAmount = {}
-- Cooking adds 5 for the coal used
--specialties.transferAmount[""] = 
specialties.transferAmount["default:dirt"] = 1
specialties.transferAmount["default:cobble"] = 1
specialties.transferAmount["default:mossycobble"] = 2
specialties.transferAmount["default:stone"] = 6
specialties.transferAmount["default:gravel"] = 2
specialties.transferAmount["default:sand"] = 2
specialties.transferAmount["default:sandstone"] = 8
specialties.transferAmount["default:desert_sand"] = 2
specialties.transferAmount["default:glass"] = 7
specialties.transferAmount["default:papyrus"] = 1
specialties.transferAmount["default:paper"] = 3
specialties.transferAmount["default:book"] = 9
specialties.transferAmount["default:bookshelf"] = 51
specialties.transferAmount["default:stick"] = 1
specialties.transferAmount["default:fence_wood"] = 3
specialties.transferAmount["default:wood"] = 4
specialties.transferAmount["default:tree"] = 16
specialties.transferAmount["default:torch"] = 2
specialties.transferAmount["default:sign_wall"] = 25
specialties.transferAmount["default:ladder"] = 7
specialties.transferAmount["default:coal_lump"] = 5
specialties.transferAmount["default:iron_lump"] = 5
specialties.transferAmount["default:steel_ingot"] = 10
specialties.transferAmount["default:steelblock"] = 90
specialties.transferAmount["default:mese"] = 60
specialties.transferAmount["default:clay"] = 36
specialties.transferAmount["default:clay_lump"] = 9
specialties.transferAmount["default:clay_brick"] = 14
specialties.transferAmount["default:brick"] = 56
specialties.transferAmount["default:chest"] = 32
specialties.transferAmount["default:chest_locked"] = 42
specialties.transferAmount["default:furnace"] = 8
specialties.transferAmount["default:rail"] = 4
specialties.transferAmount["default:apple"] = 3
specialties.transferAmount["default:dry_shrub"] = 1
