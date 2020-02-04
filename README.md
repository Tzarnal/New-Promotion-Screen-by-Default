Community Promotion Screen
=============

## Description
This is the code repository for the XCOM 2 Community Promotion Screen mod, which is an updated and backwards-compatible version of the fantastic [New Promotion Screen by Default](https://github.com/Xesyto/New-Promotion-Screen-by-Default) created by Xesyto.

## Mod Description
XCOM 2 War of the Chosen has two promotion interfaces. The old and trusted two column one and the slick new horizontal one that you get for Resistance Heroes and from the Training Centre. This mod replaces the standard promotion screen for normal soldiers with the new-look screen.

You must have built a Training Centre in order to buy abilities with points. Without it, the new promotion screen will only allow you to select abilities on rank up (promotion).

As a consequence SPARKs can now buy extra skills with XCom AP like a normal soldier could. They don't gain a line of XCom Abilities, though.

Psi Operatives keep their old upgrade screen because they have their own unique promotion system.

## Compatibility
This mod overrides UIArmory_PromotionHero via a hook provided by the [WOTC Community Highlander](https://x2communitycore.github.io/X2WOTCCommunityHighlander/). Other mods can override this mod by specifying a lower priority for their event listener.

## Configuration
You can edit the XComPromotionUIMod.ini file to change some options.
* Setting `APRequiresTrainingCenter` to `false` will let you spend AP on abilities without needing to build a Training Center
* Setting `RevealAllAbilities` to `true` will show you abilities that would normally be hidden because a soldier lacks the ranks.

## Custom Classes
This mod will try to look at a class' ability data and try to switch between 1, 2 or 3 abilities per rank automatically. However if that is not enough or not working as you need it you can manually override this behaviour with a .ini setting. Additionally you can change the cost of specific perks for a class.

Read [this topic](http://steamcommunity.com/workshop/filedetails/discussion/1124609091/1474221865191529084/) for details.

## Extension to the vanilla promotion screen
* Support for more than 4 ranks through scrollbar
* Support for the 8th rank (Brigadier)

## License and Github
This mod's code is available under the MIT license on [GitHub](https://github.com/X2CommunityCore/New-Promotion-Screen-by-Default)
