name = "DsMMO"
author = "Jodli Developement"

description = "Inspired by McMMO for Minecraft. This mod adds a levelup system for certain actions. The more often you do an action, the more perks you will receive from it.\n\nThis is a server-only mod which means no fancy UI but other users don't need to download anything as long as the server-admin has this mod activated.\n\nRepository and help:\nhttps://github.com/JodliDev/DsMMO"
forumthread = ""
server_filter_tags = {"Character", "Utility"}

version = "1.2.5"

api_version = 10
dont_starve_compatible = false
reign_of_giants_compatible = true
dst_compatible = true

all_clients_require_mod = false
client_only_mod = false


icon_atlas = "modicon.xml"
icon = "modicon.tex"


function d(name, label)
	return {
		name = name,
		label = label,
		hover = "You can change this setting at any time. Player- or mod-data will not be affected by this",
		options =
		{
			{description = "On",	data = true,	hover = "Enable"},
			{description = "Off",	data = false,	hover = "Player will not be able to perform this ritual"}
		},
		default = true,
	}
end
function option_range(min, max, incr, default, hover)
	hover = hover or "Default is " ..default
	local a = {}
	local k=1
	
	--we have to do some magic because lua doesnt seem to be very percise with float numbers
	default = default*10
	for i=min*10, max*10, incr*10 do
		a[k] = {description=(i==default) and (i/10) .." (Default)" or (i/10), data=i/10, hover=hover}
		k = k+1
	end
	return a
end

function empty_line()
	return {
		name = "",
		options = {{description = "", data = 0}},
		default=0
	}
end

function title(title)
	return {
		name = "",
		label = title,
		options = {{description = "", data = 0}},
		default=0
	}
end



configuration_options = {
	title("GENERAL"),
	{
		name = "start_message",
		label = "Enable start-message",
		hover = "On startup a message about the additional client version is displayed in the chat.",
		options = 
		{
			{description = "Enabled",	data = true,	hover = "Display the message"},
			{description = "Disabled",	data = false,	hover = "Don't display the message"}
		},
		default = 2,
	},
	{
		name = "penalty_divide",
		label = "Penalty",
		hover = "On death all exp will be divided by this number",
		options = option_range(1.1, 3, 0.1, 2),
		default = 2,
	},
	{
		name = "level_up_rate",
		label = "Exp-gain",
		hover = "After each level-up, the needed Exp for the next level up will be multiplied by this number",
		options = option_range(1.1, 3, 0.1, 1.5),
		default = 1.5,
	},
	empty_line(),
	title("SKILLS"),
	
	d("fireflies",			"Ghosty fireflies"),
	d("hungry_attack",		"Hungry fighter"),
	d("self_cannibalism",	"Self-cannibalism"),
	d("attack",				"Explosive touch"),
	d("attacked",			"Beetaliation"),
	d("fertilize",			"Double the shit"),
	d("harvest",			"Plant another day"),
	d("dig",				"Treasure hunter"),
	
	empty_line(),
	title("RITUALS"),
	
	d("amulet",				"Ritual of death"),
	d("deerclops_eyeball",	"Ritual of a new life"),
	
	d("molehill",			"Ritual of mole infestation"),
	d("shovel",				"Ritual of mole attraction"),
	d("pitchfork",			"Ritual of roman streets"),
	
	d("coontail",			"Ritual of pussy love"),
	d("cave_banana_cooked",	"Ritual of dumb monkeys"),
	d("pond",				"Ritual of dry humping"),
	d("fish",				"Ritual of splishy splashy"),
	d("walrus_camp",		"Ritual of arctic fishing"),
	d("walrus_tusk",		"Ritual of whalers feast"),
	d("houndstooth",		"Ritual of puppy love"),
	d("batwing",			"Ritual of... I am Batman!"),
	d("batcave",			"Ritual of robins fate"),
	d("pigskin",			"Ritual of Aquarius"),
	d("armorsnurtleshell",	"Ritual of escargot"),
	d("tallbirdegg",		"Ritual of Saurons bird"),
	d("firepit",			"Ritual of the pigable flame"),
	d("skeleton_player",	"Ritual of rerevival"),
	d("campfire",			"Ritual of homing flame"),
	
	d("berries",			"Ritual of redness"),
	d("berries_juicy",		"Ritual of red juiciness"),
	d("cave_banana",		"Ritual of bananana"),
	d("livinglog",			"Ritual of magic mushrooms"),
	
	d("twigs",				"Ritual of the longest Twig"),
	d("cutgrass",			"Ritual of reggae dreams"),
	d("lightbulb",			"Ritual of shiny balls"),
	d("cutreeds",			"Ritual of Poe")
}