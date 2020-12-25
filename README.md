**###### T1GER_MECHANICJOB MODIFIED BY JERICOFX#3512**

------------

if you think that my time deserve a coffe

buymeacoff.ee/jericofx

------------

Take from the original resource and modified to work with Qbus based servers, almost everything is working like:

- Menu with command so you can Bind it.
- Buy, Rename, Shell shop
- Lift
- Crafting etc etc...


https://streamable.com/72f96d

To install this resource you need:

if you use a Custom based QBCore like me just change RSCore to .........


MenuV from Tigo https://github.com/ThymonA/menuv

Run this SQL code : 
> CREATE TABLE t1ger_mechanic ( citizenid varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL, shopID INT(11), name varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT "Mechanic Shop", money INT(11) NOT NULL DEFAULT 0, employees longtext NOT NULL DEFAULT '[]', storage longtext NOT NULL DEFAULT '[]', PRIMARY KEY (shopID) );
ALTER TABLE player_vehicles ADD health longtext NOT NULL DEFAULT '[{"value":100,"part":"electronics"},{"value":100,"part":"fuelinjector"},{"value":100,"part":"brakes"},{"value":100,"part":"radiator"},{"value":100,"part":"driveshaft"},{"value":100,"part":"transmission"},{"value":100,"part":"clutch"}]';

this will add a Heath table to the player_vehicles
- Need to add the items to the Share.lua

1. 	["car_door"] 		 			 = {["name"] = "car_door", 						["label"] = "Car Door", 				["weight"] = 5000, 		["type"] = "item", 		["image"] = "c4.png", 					["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A door from a car, no idea what you can do..."},

1. "car_hood"] 		 			 = {["name"] = "car_hood", 						["label"] = "Car Hood", 				["weight"] = 5000, 		["type"] = "item", 		["image"] = "c4.png", 					["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A Hood from a car, no idea what you can do..."},
	
1. ["car_trunk"] 		 			 = {["name"] = "car_trunk", 					["label"] = "Car Trunk", 				["weight"] = 5000, 		["type"] = "item", 		["image"] = "c4.png", 					["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A Trunk from a car, no idea what you can do..."},
	
1. ["car_wheel"] 					 = {["name"] = "car_wheel", 					["label"] = "Car Wheel", 				["weight"] = 5000, 		["type"] = "item", 		["image"] = "c4.png", 					["unique"] = false, 	["useable"] = true, 	["shouldClose"] = true,	   ["combinable"] = nil,   ["description"] = "A Wheel from a car, no idea what you can do..."},
	


No copyright, but aprecciate if you give me credit for the work, it take me a lot of time to make it work.
Know Issues:

- Sometimes a restart resource is requeried to "recognize owner"

------------

- I dont know if is a MenuV error or mine but if you craft, deposit money, or store items you need to close the menu and re-open to see the change (cannot be exploited because is the menu who doest update the value.)

REMEMMBER THIS IS A WORK IN PROGRESS SO EXPECT SOME BUGS
