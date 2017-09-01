class NewPromotionScreenByDefault_PromotionScreenListener extends UIScreenListener;

// This event is triggered after a screen is initialized. This is called after
// the visuals (if any) are loaded in Flash.
event OnInit(UIScreen Screen)
{			
	local UIArmory_Promotion OriginalPromotionUI;
	local UIArmory_PromotionHero HeroPromotionUI;
	local StateObjectReference UnitBeingPromoted;
	local UIAfterAction AfterActionUI;
			
	if (UIArmory_Promotion(Screen) == none || UIArmory_PromotionHero(Screen) != none || UIArmory_PromotionPsiOp(Screen) != none)
	{		
		return;
	}
		
	//Don't block the tutorial
	if(!class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory') )
	{		
		return;
	}
		
	//Remove original screen	
	Screen.Movie.Stack.Pop(Screen);
	
	//Convert Values
	OriginalPromotionUI = UIArmory_Promotion(Screen);
	UnitBeingPromoted = OriginalPromotionUI.UnitReference;
	
	//Create new screen		
	HeroPromotionUI = Screen.Movie.Pres.Spawn(class'UIArmory_PromotionHero' );		
	Screen.Movie.Stack.Push(HeroPromotionUI, Screen.Movie.Pres.Get3DMovie());	
	HeroPromotionUI.InitPromotion(UnitBeingPromoted);

	//Fix Post mission walkup 		
	AfterActionUI = UIAfterAction(`SCREENSTACK.GetFirstInstanceOf(class'UIAfterAction'));
	
	if( AfterActionUI != none )
	{
		//AfterActionUI.MovePawns();
		MovePawns(AfterActionUI, UnitBeingPromoted);
	}		
}

function MovePawns(UIAfterAction AfterActionUI,StateObjectReference UnitBeingPromoted)
{	
	local int i;
	local XComUnitPawn UnitPawn, GremlinPawn;
	local PointInSpace PlacementActor;

	for(i = 0; i < AfterActionUI.XComHQ.Squad.Length; ++i)
	{
		PlacementActor = AfterActionUI.GetPlacementActor(AfterActionUI.GetPawnLocationTag(AfterActionUI.XComHQ.Squad[i], AfterActionUI.m_strPawnLocationSlideawayIdentifier));
		UnitPawn = AfterActionUI.UnitPawns[i];

		if(UnitPawn != none && PlacementActor != none)
		{
			UnitPawn.SetLocation(PlacementActor.Location);
			GremlinPawn = `HQPRES.GetUIPawnMgr().GetCosmeticPawn(eInvSlot_SecondaryWeapon, UnitPawn.ObjectID);
			if(GremlinPawn != none)
				GremlinPawn.SetLocation(PlacementActor.Location);
		}
	}
	
}

event OnReceiveFocus(UIScreen Screen);
event OnLoseFocus(UIScreen Screen);
event OnRemoved(UIScreen Screen);

defaultproperties
{	
	//Listening to any Promotion Screens
	ScreenClass = none;
}