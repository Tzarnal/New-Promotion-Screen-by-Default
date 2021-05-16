//---------------------------------------------------------------------------------------
//  FILE:    X2EventListener_PromotionScreenOverrides.uc
//  AUTHOR:  Peter Ledbrook
//  PURPOSE: Provides the event listeners that replace the standard (vanilla)
//           promotion screens with the Community Promotion Screen.
//---------------------------------------------------------------------------------------
class X2EventListener_PromotionScreenOverrides extends X2EventListener config(PromotionUIMod);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateListeners()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'PromotionScreenListeners');
	Template.AddCHEvent('OverridePromotionBlueprintTagPrefix', OverridePromotionBlueprintTagPrefix, ELD_Immediate);
	Template.AddCHEvent('OverridePromotionUIClass', OverridePromotionUIClass, ELD_Immediate);
	Template.RegisterInStrategy = true;

	return Template;
}

static function EventListenerReturn OverridePromotionBlueprintTagPrefix(
    Object EventData,
    Object EventSource,
    XComGameState GameState,
    Name InEventID,
    Object CallbackData)
{
	local XComLWTuple Tuple;
	local XComGameState_Unit UnitState;
	local UIAfterAction AfterActionScreen;

	Tuple = XComLWTuple(EventData);
    if (Tuple == none)
    {
        return ELR_NoInterrupt;
    }

	UnitState = XComGameState_Unit(Tuple.Data[0].o);
	if (UnitState == none)
	{
		return ELR_NoInterrupt;
    }

    AfterActionScreen = UIAfterAction(EventSource);
	if (AfterActionScreen == none)
	{
		return ELR_NoInterrupt;
    }

    if ((UnitState.IsPsiOperative() && ShouldOverridePsiPromotionScreen()) ||
            (UnitState.IsResistanceHero() && ShouldOverrideHeroPromotionScreen()) ||
            (!UnitState.IsPsiOperative() && !UnitState.IsResistanceHero() && ShouldOverrideStandardPromotionScreen()))
    {
        Tuple.Data[1].s = UnitState.IsGravelyInjured() ?
                AfterActionScreen.UIBlueprint_PrefixHero_Wounded :
                AfterActionScreen.UIBlueprint_PrefixHero;
    }

    return ELR_NoInterrupt;
}

static function EventListenerReturn OverridePromotionUIClass(
    Object EventData,
    Object EventSource,
    XComGameState GameState,
    Name InEventID,
    Object CallbackData)
{
    local XComLWTuple Tuple;
    local CHLPromotionScreenType ScreenType;

	Tuple = XComLWTuple(EventData);
    if (Tuple == none)
    {
        return ELR_NoInterrupt;
    }

    ScreenType = CHLPromotionScreenType(Tuple.Data[0].i);

    if ((ScreenType == eCHLPST_PsiOp && ShouldOverridePsiPromotionScreen()) ||
            (ScreenType == eCHLPST_Hero && ShouldOverrideHeroPromotionScreen()) ||
            (ScreenType == eCHLPST_Standard && ShouldOverrideStandardPromotionScreen()))
    {
        Tuple.Data[1].o = class'NPSBDP_UIArmory_PromotionHero';
    }

    return ELR_NoInterrupt;
}

static private function bool ShouldOverridePsiPromotionScreen()
{
    return class'NewPromotionScreenByDefault_PromotionScreenListener'.default.IgnoreClassNames.Find('UIArmory_PromotionPsiOp') == INDEX_NONE;
}

static private function bool ShouldOverrideHeroPromotionScreen()
{
    return class'NewPromotionScreenByDefault_PromotionScreenListener'.default.IgnoreClassNames.Find('UIArmory_PromotionHero') == INDEX_NONE;
}

static private function bool ShouldOverrideStandardPromotionScreen()
{
    return class'NewPromotionScreenByDefault_PromotionScreenListener'.default.IgnoreClassNames.Find('UIArmory_Promotion') == INDEX_NONE;
}
