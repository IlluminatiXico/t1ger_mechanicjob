Config = {}

Config.ESXSHAREDOBJECT = 'esx:getSharedObject'
Config.ItemLabelESX	= false	-- set to false if your ESX vers. doesn't support this

-- Buttons:
Config.KeyToManageShop			= 38		-- Default: [E]
Config.KeyToBuyMechShop			= 38		-- Default: [E]		
Config.KeyToPushPickUpObjs 		= 244		-- Set key to push or pick up/place props in prop emotes
Config.KeyToMechActionMenu 		= 167		-- Default: [F6]

-- General Settings:
Config.PurchasableMechBlip 	    = true		-- Blip to show mechanic shops forsale
Config.PayMechShopWithCash		= true		-- Set to false to pay mech shop with bank
Config.RecieveSoldMechShopCash	= true		-- Set to false to receive bank money on sale of drug lab
Config.SellPercent				= 0.75		-- Means player gets 75% in return from original paid price

-- Vehicle Damage Snippet:
Config.UseKMH 					= true		-- Set to false to use MPH system for calculations with speed.
Config.SlashTires				= true		-- Set to false to disable slashing random tires, upon vehicle collision. 
Config.EngineDisable			= true		-- Set to false to disable engine being disabled, upon vehicle collision.
Config.WaitCountForHealth		= 30		-- Set amount of seconds to wait, until health part damage effects applies to vehicle.
Config.AmountPartsDamage		= 3			-- Set amount of parts to take damage, upon crash. Default; 3 parts.
Config.DegradeValue = {min = 5, max = 25}	-- Set min and max degrade value, upon crash. 5 is 0.5, 25 is 2.5. Between 0 and 100.

Config.MechanicShops = {
	[1] = {	
		price = 125000,
		menuPos = {548.54,-172.16,54.48},
		storage = {548.74,-182.44,54.48},
		workbench = {548.91,-188.26,54.48},
		lifts = {
			[1] = {
				entry = {540.02,-176.92,54.48,271.14},
				pos = {546.13,-176.83,54.48,89.67},
				control = {543.19,-174.8,54.48,179.55},
				marker = {enable = true, drawDist = 6.0, type = 36, scale = {x = 0.4, y = 0.4, z = 0.4}, color = {r = 240, g = 52, b = 52, a = 100}},
				minValue = 53.89, maxValue = 55.68,
				currentVeh = nil,
				inUse = false
			},
		},
	},
	[2] = { 
		menuPos = {-347.57,-133.33,39.01},
		price = 265000,
		storage = {-344.76,-128.03,39.01},
		workbench = {-343.54,-140.11,39.01},
		lifts = {
			[1] = {
				entry = {-332.07,-134.81,39.01,162.45},
				pos = {-330.91,-131.66,39.01,161.73},
				control = {-328.8,-132.53,39.36,67.39},
				marker = {enable = true, drawDist = 8.0, type = 36, scale = {x = 0.4, y = 0.4, z = 0.4}, color = {r = 240, g = 52, b = 52, a = 100}},
				minValue = 38.37, maxValue = 40.17,
				currentVeh = nil,
				inUse = false
			},
		},
	},
}

-- Blip Settings:
Config.BlipSettings = { enable = true, sprite = 446, display = 4, scale = 0.65 } 

-- Marker settings::
Config.MarkerSettings = { enable = true, drawDist = 10.0, type = 20, scale = {x = 0.7, y = 0.7, z = 0.7}, color = {r = 240, g = 52, b = 52, a = 100} }

-- Repair Kit:
Config.RepairKits = {
	[1] = { label = "Repair Kit", item = "repairkit", chanceToKeep = 70, repairTime = 5000, progbar = Lang['repairing_veh_kit'] },
	[2] = { label = "Adv Reapir Kit", item = "advancedrepairkit", chanceToKeep = 95, repairTime = 3500, progbar = Lang['repairing_veh_kit'] },
}

-- Item name for carjack:
Config.CarJackItem = "lockpick"

-- BODY PARTS FOR VEHICLE REPAIR:
Config.BodyParts = {
	[1] = {item = "car_door", prop = "prop_car_door_01", pos = {0.0, 0.0, 0.0}, rot = {0.0, 0.0, 0.0}},
	[2] = {item = "car_hood", prop = "prop_car_bonnet_01", pos = {0.0, 0.0, 0.0}, rot = {0.0, 0.0, 0.0}},
	[3] = {item = "car_trunk", prop = "prop_car_bonnet_02", pos = {0.0, 0.0, 0.0}, rot = {0.0, 0.0, 0.0}},
	[4] = {item = "car_wheel", prop = "prop_wheel_03", pos = {0.0, 0.0, 0.0}, rot = {0.0, 0.0, 0.0}},
}

-- CRAFTING PART:
Config.CraftTime = 4		-- set time in seconds, to craft item.

Config.Workbench = {
	[1] = {
		label = "Door", item = "car_door", 
		recipe = { [1] = {id = 2, qty = 5}, [2] = {id = 1, qty = 2}, [3] = {id = 4, qty = 4}, [4] = {id = 5, qty = 2} }
	},
	[2] = {
		label = "Hood", item = "car_hood", 
		recipe = { [1] = {id = 2, qty = 3}, [2] = {id = 4, qty = 2}, [3] = {id = 5, qty = 1} }
	},
	[3] = {
		label = "Trunk", item = "car_trunk", 
		recipe = { [1] = {id = 2, qty = 2}, [2] = {id = 1, qty = 1}, [3] = {id = 4, qty = 2}, [4] = {id = 3, qty = 1}, [5] = {id = 5, qty = 1} }
	},
	[4] = {
		label = "Wheel", item = "car_wheel", 
		recipe = { [1] = {id = 2, qty = 5}, [2] = {id = 1, qty = 8} }
	},
}

-- Materials used throughout the script:
Config.Materials = {
	[1] = {label = "Rubber", item = "rubber"},
	[2] = {label = "Scrap Metal", item = "metalscrap"},
	[3] = {label = "Electric Scrap", item = "electronickit"},
	[4] = {label = "Plastic", item = "plastic"},
	[5] = {label = "Glass", item = "glass"},
	[6] = {label = "Aluminium", item = "aluminum"},
	[7] = {label = "Copper", item = "copper"},
	[8] = {label = "Steel", item = "steel"}
}

-- Available Health Parts to repair and required materials and amounts:
Config.HealthParts = {
	[1] = { label = "Brakes", degName = "brakes", materials =       { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[2] = { label = "Radiator", degName = "radiator", materials =   { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[3] = { label = "Clutch", degName = "clutch", materials =               { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[4] = { label = "Transmission", degName = "transmission", materials =   { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[5] = { label = "Electronics", degName = "electronics", materials = { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[6] = { label = "Drive Shaft", degName = "driveshaft", materials = { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[7] = { label = "Fuel Injector", degName = "fuelinjector", materials = { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
	[8] = { label = "Engine", degName = "engine", materials = { [1] = { id = 1, qty = 3 }, [2] = { id = 2, qty = 2 } } },
}

-- NPC Jobs Position:
Config.NPC_RepairJobs = {
	[1] = { pos = {879.88,-33.99,78.76,238.22}, inUse = false, ped = "s_m_y_dealer_01"},
	[2] = { pos = {1492.09,758.45,77.45,288.26}, inUse = false, ped = "s_m_y_dealer_01"},
	[3] = { pos = {387.67,-767.56,29.29,358.94}, inUse = false, ped = "s_m_y_dealer_01"},
	[4] = { pos = {-583.75,-239.55,36.08,33.14}, inUse = false, ped = "s_m_y_dealer_01"},
}

Config.Payout = math.random(250, 400)

-- Vehicle scrambler for npc jobs:
Config.RepairVehicles = {"sultan", "blista", "glendale", "exemplar"}

-- Prop Emotes:
Config.PropEmotes = {
	["prop_roadcone02a"] = {label = "Road Cone", model = "prop_roadcone02a", bone = 28422, pos = {0.6,-0.15,-0.1}, rot = {315.0,288.0,0.0}},
	["prop_cs_trolley_01"] = {label = "Tool Trolley", model = "prop_cs_trolley_01", bone = 28422, pos = {-0.1,-0.6,-0.85}, rot = {-180.0,-165.0,90.0}},
	["prop_tool_box_04"] = {label = "Tool Box", model = "prop_tool_box_04", bone = 28422, pos = {0.4,-0.1,-0.1}, rot = {315.0,288.0,0.0}},
	["prop_engine_hoist"] = {label = "Engine Hoist", model = "prop_engine_hoist", bone = 28422, pos = {0.0,-0.5,-1.3}, rot = {-195.0,-180.0,180.0}}
}

-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999
-- ilAn#9999

