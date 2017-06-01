# ![DsMMO](./modicon.png)

The purpose of this mod is to reward players for every action they do. You will get experience for several actions and over time get level ups that let you learn new skills, rituals and increase the effect rate and chance of skills and rituals that you have already learned.
But be careful. Every time you die, you loose half of your experience.

The lore says that all skills and rituals have a 50 percent better chance to be successful during a full moon...



# Rituals
Rituals are a way of sacrificing items to build rare structures or performing useful actions.

## Conducting a ritual
* Place all the needed items on the ground (**but don't use stacked items or you will loose them**)
* They don't need to be placed in any specific order or arrangement but there is always a middle piece that needs to be near to all the other ingredients.
* When you have laid out all the needed items, **inspect** the middle piece (you may have to **force inspect**. You can set its key command in the settings).


# Skills
Skills give you bonuses when you conduct an action.
The higher your level in the matching DsMMO-action, the higher is your chance and / or effectiveness of the skill.



# Skill- and ritual-tree:


## CHOP
The higher your CHOP-level, the faster you will be able to chop trees


## MINE
The higher your MINE-level, the faster you will be able to mine stones


## ATTACK
You get experience for: Attacking other player, NPCs or structures and when you are attacked.

### Level 1: Explosive touch
Every attack you deal has a chance of doing extra damage (same damage like of a spear).

### Level 2: Beetaliation
Every time you are attacked, there is a chance that you spawn a bee, that will attack the source that attacked you.


## PLANT

### Level 1: Double the shit
Fertilizing has a chance of being extra effective.

### Level 2: Plant another day
Harvesting crops has a chance of getting double drops. Possible drops are:
With a 50 percent chance: lightbulb, red gem, blue gem
With a 30 percent chance: mandrake, purple gem, cutreeds, slurper pelt, furtuft
With a 20 percent chance: moonrocks, beardhair, yellow gem, orange gem

### Level 3: Ritual of redness
![Recipe](./recipes/berries.png)
![>](./arrow_r.png)
![Recipe](./recipes/berries_outcome.png)

### Level 4: Ritual of red juiciness
![Recipe](./recipes/berries_juicy.png)
![>](./arrow_r.png)
![Recipe](./recipes/berries_juicy_outcome.png)

### Level 6: Ritual of bananana
![Recipe](./recipes/cave_banana.png)
![>](./arrow_r.png)
![Recipe](./recipes/cave_banana_outcome.png)

### Level 8: Ritual of magic mushrooms
![Recipe](./recipes/living_log.png)
![>](./arrow_r.png)
![Recipe](./recipes/living_log_outcome.png)


## DIG

### Level 1: Treasure hunter
Using your shovel for digging has a chance of spawning additional items

### Level 2: Ritual of mole infestation
![Recipe](./recipes/molehill.png)
![>](./arrow_r.png)
![Recipe](./recipes/molehill_outcome.png)

### Level 3: Ritual of mole attraction
![Recipe](./recipes/shovel.png)
![>](./arrow_r.png)
![Recipe](./recipes/shovel_outcome.png)

### Level 5: Ritual of roman streets
![Recipe](./recipes/pitchfork.png)
![>](./arrow_r.png)
![Recipe](./recipes/pitchfork_outcome.png)


## EAT

### Level 3: Self-cannibalism
Exchange DsMMO-experience to completely fill your health, hunger or sanity.
Use this skill with the following chat-command:
```
#dsmmo eat [skill] [health / hunger / sanity]
```
The higher your EAT-skill the less DsMMO-experience is used for healing yourself.

### Level 5: Ritual of death
![Recipe](./recipes/amulet.png)
![>](./arrow_r.png)
![Recipe](./recipes/amulet_outcome.png)

### Level 8: Ritual of a new life
![Recipe](./recipes/deerclops_eyeball.png)
![>](./arrow_r.png)
![Recipe](./recipes/deerclops_eyeball_outcome.png)


## PICK

### Level 1: Ghosty fireflies
As a ghost, haunting evil flowers has a chance to turn into fireflies. The higher your PICK-skill, the higher your chance of succeeding.

### Level 2: Ritual of the longest Twig
![Recipe](./recipes/twigs.png)
![>](./arrow_r.png)
![Recipe](./recipes/twigs_outcome.png)

### Level 3: Ritual of reggae dreams
![Recipe](./recipes/cutgrass.png)
![>](./arrow_r.png)
![Recipe](./recipes/cutgrass_outcome.png)

### Level 5: Ritual of shiny balls
![Recipe](./recipes/lightbulb.png)
![>](./arrow_r.png)
![Recipe](./recipes/lightbulb_outcome.png)

### Level 7: Ritual of Poe
![Recipe](./recipes/cutreeds.png)
![>](./arrow_r.png)
![Recipe](./recipes/cutreeds_outcome.png)


## BUILD

### Level 1: Ritual of pussy love
![Recipe](./recipes/coontail.png)
![>](./arrow_r.png)
![Recipe](./recipes/coontail_outcome.png)

### Level 2: Ritual of splishy splashy
![Recipe](./recipes/fish.png)
![>](./arrow_r.png)
![Recipe](./recipes/fish_outcome.png)

### Level 3: Ritual of dumb monkeys
![Recipe](./recipes/cave_banana_cooked.png)
![>](./arrow_r.png)
![Recipe](./recipes/cave_banana_cooked_outcome.png)

### Level 4: Ritual of arctic fishing
![Recipe](./recipes/walrus_camp.png)
![>](./arrow_r.png)
![Recipe](./recipes/walrus_camp_outcome.png)

### Level 5: Ritual of whalers feast
![Recipe](./recipes/walrus_tusk.png)
![>](./arrow_r.png)
![Recipe](./recipes/walrus_tusk_outcome.png)

### Level 6: Ritual of Saurons bird
![Recipe](./recipes/tallbirdegg.png)
![>](./arrow_r.png)
![Recipe](./recipes/tallbirdegg_outcome.png)

### Level 7: Ritual of the pigable flame
![Recipe](./recipes/firepit.png)
![>](./arrow_r.png)
![Recipe](./recipes/firepit_outcome.png)

### Level 8: Ritual of rerevival
![Recipe](./recipes/skeleton_player.png)
![>](./arrow_r.png)
![Recipe](./recipes/skeleton_player_outcome.png)

### Level 10: Ritual of homing flame
![Recipe](./recipes/campfire.png)
![>](./arrow_r.png)
![Recipe](./recipes/campfire_outcome.png)



# User-commands
User-commands are available for all players. To use them they have to **whispered** into the chat.

## #dsmmo [action]
This command spawns a mini-sign at your current position (which will despawn over time). The sign always shows your last used DsMMO-action and if you examine it, you will be shown your current level, experience and learned skills.
If you specify an action, the mini-sign will show the specified action instead of the last used one.

## #dsmmo list
Lists the levels of all your DsMMO-actions

## #dsmmo eat
See the skill [Self-cannibalism](#Level 3: Self-cannibalism) 



# Admin-commands
Admin-commands are only available if you have remote access to the server-console.

## dsmmo_reset(player_name)
Resets all DsMMO-actions to level 0 for the specified player.
The player has to be online for the command to work properly.

## dsmmo_set(player_name, action, level)
Sets the level of a specific DsMMO-action to the specified level for the specified player.
The player has to be online for the command to work properly.