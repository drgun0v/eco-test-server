Config = {}

Config.Language = "en"

Config.MenuPosition = "left"
Config.MenuPositions = {
	right = {x = 1450, y = 80},
	left = {x = 0, y = 80}--{x = 0, y = 200}
}

Config.Translation = {
    en = {
        back = "Back",
        select = "Select",
        none = "Nothing",
        menu_header = "Elevator",
        menu_title = "CHOOSE FLOOR",
        notification = "Press ~INPUT_CONTEXT~ to use elevator",
        same_floor = "You're already on this floor"
    }
}

Config.Elevators = {
		{
		label = 'La Puerta Apartments 1_1',
		floors = {
			{coords = vector4(-460.76879882812,-924.14959716797,28.102849960327, 89.54), label = 'Lobby'},
			{coords = vector4(-451.97125244141,-933.34240722656,47.617900848389, 89.54), label = 'Floor 1'},
			{coords = vector4(-451.97125244141,-933.34240722656,58.61344909668, 89.54), label = 'Floor 2'},
			{coords = vector4(-451.97125244141,-933.34240722656,69.613418579102, 89.54), label = 'Floor 3'},
			{coords = vector4(-451.97125244141,-933.34240722656,80.613082885742, 89.54), label = 'Floor 4'},
			{coords = vector4(-451.97125244141,-933.34240722656,91.613677978516, 89.54), label = 'Floor 5'},
			{coords = vector4(-451.97125244141,-933.34240722656,102.61270904541, 89.54), label = 'Floor 6'},
			{coords = vector4(-451.97125244141,-933.34240722656,108.11304473877, 89.54), label = 'Floor 7'},	
			{coords = vector4(-442.45294189453,-950.04333496094,20.690057754517, 89.54), label = 'Garage'},								
		}
	},
		{
		label = 'La Puerta Apartments 1_2',
		floors = {
			{coords = vector4(-460.86248779297,-928.14581298828,28.102830886841, 89.54), label = 'Lobby'},
			{coords = vector4(-452.02249145508,-937.4391479492,47.617900848389, 89.54), label = 'Floor 1'},
			{coords = vector4(-452.02249145508,-937.4391479492,58.61344909668, 89.54), label = 'Floor 2'},
			{coords = vector4(-452.02249145508,-937.4391479492,69.613418579102, 89.54), label = 'Floor 3'},
			{coords = vector4(-452.02249145508,-937.4391479492,80.613082885742, 89.54), label = 'Floor 4'},
			{coords = vector4(-452.02249145508,-937.4391479492,91.613677978516, 89.54), label = 'Floor 5'},
			{coords = vector4(-452.02249145508,-937.4391479492,102.61270904541, 89.54), label = 'Floor 6'},
			{coords = vector4(-452.02249145508,-937.4391479492,108.11304473877, 89.54), label = 'Floor 7'},	
			{coords = vector4(-442.48391723633,-954.12817382812,20.690172195435, 89.54), label = 'Garage'},								
		}
	},
		{
		label = 'La Puerta Apartments 2_1',
		floors = {
			{coords = vector4(-478.44989013672,-1040.0222167969,24.305946350098, 0.94), label = 'Lobby'},
			{coords = vector4(-487.78771972656,-1048.8828125,43.821258544922, 0.94), label = 'Floor 1'},
			{coords = vector4(-487.81130981445,-1048.8828125,54.817264556885, 0.94), label = 'Floor 2'},
			{coords = vector4(-487.81130981445,-1048.8828125,65.816802978516, 0.94), label = 'Floor 3'},
			{coords = vector4(-487.81130981445,-1048.8828125,76.817008972168, 0.94), label = 'Floor 4'},
			{coords = vector4(-487.81539916992,-1048.8828125,87.816711425781, 0.94), label = 'Floor 5'},
			{coords = vector4(-487.81539916992,-1048.8828125,98.816856384277, 0.94), label = 'Floor 6'},
			{coords = vector4(-487.81539916992,-1048.8828125,104.32563781738, 0.94), label = 'Floor 7'},								
		}
	},
		{
		label = 'La Puerta Apartments 2_2',
		floors = {
			{coords = vector4(-482.54229736328,-1039.9588623047,24.306211471558, 0.94), label = 'Lobby'},
			{coords = vector4(-491.83053588867,-1048.7374267578,43.821258544922, 0.94), label = 'Floor 1'},
			{coords = vector4(-491.83053588867,-1048.7374267578,54.817264556885, 0.94), label = 'Floor 2'},
			{coords = vector4(-491.83053588867,-1048.7374267578,65.816802978516, 0.94), label = 'Floor 3'},
			{coords = vector4(-491.83053588867,-1048.7374267578,76.817008972168, 0.94), label = 'Floor 4'},
			{coords = vector4(-491.83053588867,-1048.7374267578,87.816711425781, 0.94), label = 'Floor 5'},
			{coords = vector4(-491.83053588867,-1048.7374267578,98.816856384277, 0.94), label = 'Floor 6'},
			{coords = vector4(-491.83053588867,-1048.7374267578,104.32563781738, 0.94), label = 'Floor 7'},								
		}
	},
}

Config.ActivateRadius = 2.5