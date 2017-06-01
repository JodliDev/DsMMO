name = "DsMMO"
author = "Jodli Developement"

description = "Inspired by McMMO for Minecraft. This mod adds a levelup system for certain actions. The more often you do an action, the more perks you will receive from it"
forumthread = ""
server_filter_tags = {"Character", "Utility"}

version = "1.0"

api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
clients_only_mod = false


icon_atlas = "modicon.xml"
icon = "modicon.tex"



configuration_options =
{
	{
		name = "deerclops_eyeball",
		label = "Ritual of a new life",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "molehill",
		label = "Ritual of mole infestation",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "shovel",
		label = "Ritual of mole attraction",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "pitchfork",
		label = "Ritual of roman streets",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "twigs",
		label = "Ritual of the longest Twig",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "cutgrass",
		label = "Ritual of reggae dreams",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "coontail",
		label = "Ritual of pussy love",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "walrus_camp",
		label = "Ritual of arctic fishing",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "walrus_tusk",
		label = "Ritual of whalers feast",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "tallbirdegg",
		label = "Ritual of Saurons bird",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "firepit",
		label = "Ritual of the pigable flame",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "skeleton_player",
		label = "Ritual of rerevival",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "campfire",
		label = "Ritual of homing flame",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "berries",
		label = "Ritual of redness",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "berries_juicy",
		label = "Ritual of red juiciness",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "cave_banana_cooked",
		label = "Ritual of dumb monkeys",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "cave_banana",
		label = "Ritual of bananana",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "lightbulb",
		label = "Ritual of shiny balls",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "fish",
		label = "Ritual of splishy splashy",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	},
	{
		name = "cutreeds",
		label = "Ritual of Poe",
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	}
}