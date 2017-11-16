Default New Promotion Screen
=============

## Description
This is the code repo for the XCom 2 mod of the same name that can be found on the Steam [Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1124609091&searchtext=). 


## Mod Description
War of the chosen has two promotion interfaces. The old and trusted two column one and the slick new horizontal one that you get for Resistance Heroes and from the Training Centre. This mod eliminates the use of the old promotion interface for visual consistency.

You must have built a Training Centre in order to buy abilities with points. Without it it will simply allow you to select rankup abilities.

As a consequence SPARKs can now buy extra skills with XCom AP like a normal soldier could. They don't gain a line of XCom Abilities though.

Psi Operatives keep their old upgrade screen because they have their own unique promotion system.

## Compatibility
This mod overrides UIArmory_PromotionHero and will almost certainly not work with any other mod that overrides it.

## Configuration
You can edit the XComPromotionUIMod.ini file to change some options.
* Setting APRequiresTrainingCenter to false will let you spend AP on abilities without needing to build a Training Center
* Setting RevealAllAbilities to true will show you abilities that would normally be hidden because a soldier lacks the ranks.

## Custom Classes
This mod will try to look at a class' ability data and try to switch between 1, 2 or 3 abilities per rank automatically. However if that is not enough or not working as you need it you can manually override this behaviour with a .ini setting. Additionally you can change the cost of specific perks for a class.

Read [this topic](http://steamcommunity.com/workshop/filedetails/discussion/1124609091/1474221865191529084/) for details.

## Extension to the vanilla promotion screen
* Support for more than 4 ranks through scrollbar
* Support for the 8th rank (Brigadier)

## License and Github
This mods code is available under the MIT license on [Github](https://github.com/Xesyto/New-Promotion-Screen-by-Default)
