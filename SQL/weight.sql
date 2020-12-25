INSERT INTO `jobs` (name, label) VALUES
	('mechanic', 'Mechanic');

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('mechanic',0,'recrue','Recruit',200,'{}','{}'),
	('mechanic',1,'novice','Novice',300,'{}','{}'),
	('mechanic',2,'experienced','Experienced',400,'{}','{}'),
	('mechanic',3,'chief',"Chief",600,'{}','{}'),
	('mechanic',4,'boss','Boss',1000,'{}','{}');

CREATE TABLE `t1ger_mechanic` (
	`citizenid` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`shopID` INT(11),
	`name` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT "Mechanic Shop",
	`money` INT(11) NOT NULL DEFAULT 0,
	`employees` longtext NOT NULL DEFAULT '[]',
	`storage` longtext NOT NULL DEFAULT '[]',
	PRIMARY KEY (`shopID`)
);

ALTER TABLE owned_vehicles
ADD health longtext NOT NULL DEFAULT '[{"value":100,"part":"electronics"},{"value":100,"part":"fuelinjector"},{"value":100,"part":"brakes"},{"value":100,"part":"radiator"},{"value":100,"part":"driveshaft"},{"value":100,"part":"transmission"},{"value":100,"part":"clutch"}]';

-- Weight
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
('repairkit', 'Repair Kit', 1, 0, 1),
('advrepairkit', 'Adv Repair Kit', 1, 0, 1),
('carjack', 'Car Jack', 1, 0, 1),
('car_hood', 'Car Hood', 1, 0, 1),
('car_trunk', 'Car Trunk', 1, 0, 1),
('car_door', 'Car Door', 1, 0, 1),
('car_wheel', 'Car Wheel', 1, 0, 1),

('scrap_metal', 'Scrap Metal', 0.5, 0, 1),
('rubber', 'Rubber', 0.5, 0, 1),
('plastic', 'Plastic', 0.5, 0, 1),
('electric_scrap', 'Electric Scrap', 0.5, 0, 1),
('glass', 'Glass', 0.5, 0, 1),
('aluminium', 'Aluminium', 0.5, 0, 1),
('copper', 'Copper', 0.5, 0, 1),
('steel', 'Steel', 0.5, 0, 1);