class NPSBDP_UIArmory_PromotionHero extends UIArmory_PromotionHero config(PromotionUIMod);

struct CustomClassAbilitiesPerRank
{
	var name ClassName;
	var int AbilitiesPerRank;
};

var config bool APRequiresTrainingCenter;

var config array<CustomClassAbilitiesPerRank> ClassAbilitiesPerRank;

//Override functions
simulated function InitPromotion(StateObjectReference UnitRef, optional bool bInstantTransition)
{
	local UIArmory_PromotionHeroColumn Column;
	local XComGameState_Unit Unit; // bsg-nlong (1.25.17): Used to determine which column we should start highlighting

	// If the AfterAction screen is running, let it position the camera
	AfterActionScreen = UIAfterAction(Movie.Stack.GetScreen(class'UIAfterAction'));
	if (AfterActionScreen != none)
	{
		bAfterActionPromotion = true;
		PawnLocationTag = AfterActionScreen.GetPawnLocationTag(UnitRef, "Blueprint_AfterAction_HeroPromote");
		CameraTag = GetPromotionBlueprintTag(UnitRef);
		DisplayTag = name(GetPromotionBlueprintTag(UnitRef));
	}
	else
	{
		CameraTag = string(default.DisplayTag);
		DisplayTag = default.DisplayTag;
	}

	// Don't show nav help during tutorial, or during the After Action sequence.
	bUseNavHelp = class'XComGameState_HeadquartersXCom'.static.IsObjectiveCompleted('T0_M2_WelcomeToArmory') || Movie.Pres.ScreenStack.IsInStack(class'UIAfterAction');

	super.InitArmory(UnitRef, , , , , , bInstantTransition);
	
	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn0';
	Column.InitPromotionHeroColumn(0);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn1';
	Column.InitPromotionHeroColumn(1);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn2';
	Column.InitPromotionHeroColumn(2);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn3';
	Column.InitPromotionHeroColumn(3);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn4';
	Column.InitPromotionHeroColumn(4);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn5';
	Column.InitPromotionHeroColumn(5);
	Columns.AddItem(Column);

	Column = Spawn(class'UIArmory_PromotionHeroColumn', self);
	Column.MCName = 'rankColumn6';
	Column.InitPromotionHeroColumn(6);
	Columns.AddItem(Column);

	PopulateData();

	DisableNavigation(); // bsg-nlong (1.25.17): This and the column panel will have to use manual naviation, so we'll disable the navigation here

	MC.FunctionVoid("AnimateIn");

	// bsg-nlong (1.25.17): Focus a column so the screen loads with an ability highlighted
	if( `ISCONTROLLERACTIVE )
	{
		Unit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));
		if( Unit != none )
		{
			m_iCurrentlySelectedColumn = m_iCurrentlySelectedColumn;
		}
		else
		{
			m_iCurrentlySelectedColumn = 0;
		}

		Columns[m_iCurrentlySelectedColumn].OnReceiveFocus();
	}
	// bsg-nlong (1.25.17): end
}

function bool CanPurchaseAbility(int Rank, int Branch, name AbilityName)
{
	local XComGameState_Unit UnitState;
	local int AbilityRanks; //Rank is 0 indexed but AbilityRanks is not. This means a >= comparison requies no further adjustments
	local Name ClassName;

	UnitState = GetUnit();
	AbilityRanks = 2;
	ClassName = UnitState.GetSoldierClassTemplateName();

	if( HasCustomAbilitiesPerRank(ClassName) )
	{
		AbilityRanks = GetCustomAbilitiesPerRank(ClassName);
	}

	//Don't allow non hero units to purchase abilities with AP without a training center
	if(UnitState.HasPurchasedPerkAtRank(Rank) && !UnitState.IsResistanceHero() && !CanSpendAP())
	{
		return false;
	}
		
	//Don't allow non hero units to purchase abilities on the xcom perk row before getting a rankup perk
	if(!UnitState.HasPurchasedPerkAtRank(Rank) && !UnitState.IsResistanceHero() && Branch >= AbilityRanks )
	{
		return false;
	}

	//Normal behaviour
	return (Rank < UnitState.GetRank() && CanAffordAbility(Rank, Branch) && UnitState.MeetsAbilityPrerequisites(AbilityName));
}

function int GetAbilityPointCost(int Rank, int Branch)
{
	local XComGameState_Unit UnitState;
	local array<SoldierClassAbilityType> AbilityTree;
	local bool bPowerfulAbility;
	local int AbilityRanks; //Rank is 0 indexed but AbilityRanks is not. This means a >= comparison requies no further adjustments
	local Name ClassName;

	UnitState = GetUnit();
	AbilityTree = UnitState.GetRankAbilities(Rank);	
	bPowerfulAbility = (class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilities.Find(AbilityTree[Branch].AbilityName) != INDEX_NONE);
	AbilityRanks = 2;
	ClassName = UnitState.GetSoldierClassTemplateName();
	
	if( HasCustomAbilitiesPerRank(ClassName) )
	{
		AbilityRanks = GetCustomAbilitiesPerRank(ClassName);
	}

	if (!UnitState.IsResistanceHero())
	{
		if (!UnitState.HasPurchasedPerkAtRank(Rank) && Branch < AbilityRanks)
		{
			// If this is a base game soldier with a promotion available, ability costs nothing since it would be their
			// free promotion ability if they "bought" it through the Armory
			return 0;
		}
		else if (bPowerfulAbility && Branch >= AbilityRanks)
		{
			// All powerful shared AWC abilities for base game soldiers have an increased cost, 
			// excluding any abilities they have in their normal progression tree
			return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
		}
	}

	// All Colonel level abilities for Faction Heroes and any powerful XCOM abilities have increased cost for Faction Heroes
	if (UnitState.IsResistanceHero() && (bPowerfulAbility || (Rank >= 6 && Branch < 3)))
	{
		return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}
	
	return class'X2StrategyGameRulesetDataStructures'.default.AbilityPointCosts[Rank];
}

//New functions
simulated function string GetPromotionBlueprintTag(StateObjectReference UnitRef)
{
	local int i;
	local XComGameState_Unit UnitState;

	for(i = 0; i < AfterActionScreen.XComHQ.Squad.Length; ++i)
	{
		if(AfterActionScreen.XComHQ.Squad[i].ObjectID == UnitRef.ObjectID)
		{
			UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AfterActionScreen.XComHQ.Squad[i].ObjectID));
			
			if (UnitState.IsGravelyInjured())
			{
				return AfterActionScreen.UIBlueprint_PrefixHero_Wounded $ i;
			}
			else
			{
				return AfterActionScreen.UIBlueprint_PrefixHero $ i;
			}						
		}
	}

	return "";
}

function bool CanSpendAP()
{
	if(APRequiresTrainingCenter == false)
		return true;
	
	return `XCOMHQ.HasFacilityByName('RecoveryCenter');
}

function bool HasCustomAbilitiesPerRank(name ClassName)
{
	local int i;

	`log("NPSBDP: Starting Custom class Search");
	`log(ClassAbilitiesPerRank.Length);

	for(i = 0; i < ClassAbilitiesPerRank.Length; ++i)
	{
		`log("NPSBDP: ");
		`log(ClassAbilitiesPerRank[i].ClassName);
				
		if(ClassAbilitiesPerRank[i].ClassName == ClassName)
		{
			`log("NPSBDP: Returning true");
			return true;
		}
	}

	`log("NPSBDP: Returning false");
	return false;
}

function int GetCustomAbilitiesPerRank(name ClassName)
{
	local int i;

	for(i = 0; i < ClassAbilitiesPerRank.Length; ++i)
	{
		if(ClassAbilitiesPerRank[i].ClassName == ClassName)
		{
			return ClassAbilitiesPerRank[i].AbilitiesPerRank;
		}
	
	}
	return 2;
}