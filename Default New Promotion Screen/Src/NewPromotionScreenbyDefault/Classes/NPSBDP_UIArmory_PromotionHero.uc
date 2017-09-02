class NPSBDP_UIArmory_PromotionHero extends UIArmory_PromotionHero config(PromotionUIMod);

struct CustomClassAbilitiesPerRank
{
	var name ClassName;
	var int AbilitiesPerRank;
};

struct CustomClassAbilityCost
{
	var name ClassName;
	var name AbilityName;
	var int AbilityCost;
};

var config bool APRequiresTrainingCenter;

var config array<CustomClassAbilitiesPerRank> ClassAbilitiesPerRank;
var config array<CustomClassAbilityCost> ClassCustomAbilityCost;

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
	
	UnitState = GetUnit();
	AbilityRanks = GetAbilitiesPerRank(UnitState);

	//Emulate Resistance Hero behaviour
	if(AbilityRanks == 0)
	{		
		return (Rank < UnitState.GetRank() && CanAffordAbility(Rank, Branch) && UnitState.MeetsAbilityPrerequisites(AbilityName));
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
	local int AbilityCost;

	UnitState = GetUnit();
	AbilityTree = UnitState.GetRankAbilities(Rank);	
	bPowerfulAbility = (class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilities.Find(AbilityTree[Branch].AbilityName) != INDEX_NONE);
	AbilityRanks = 2;
	ClassName = UnitState.GetSoldierClassTemplateName();	
	AbilityRanks = GetAbilitiesPerRank(UnitState);


	//Default ability cost
	AbilityCost = class'X2StrategyGameRulesetDataStructures'.default.AbilityPointCosts[Rank];

	//Powerfull ability override ( 25 AP )
	if(bPowerfulAbility)
	{
		AbilityCost = class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}

	//Custom Class Ability Cost Override
	if( HasCustomAbilityCost(ClassName, AbilityTree[Branch].AbilityName) )
	{
		AbilityCost = GetCustomAbilityCost(ClassName, AbilityTree[Branch].AbilityName);
	}

	if (!UnitState.IsResistanceHero() && AbilityRanks != 0)
	{
		if (!UnitState.HasPurchasedPerkAtRank(Rank) && Branch < AbilityRanks)
		{
			// If this is a base game soldier with a promotion available, ability costs nothing since it would be their
			// free promotion ability if they "bought" it through the Armory
			return 0;
		}
		/*else if (bPowerfulAbility && Branch >= AbilityRanks)
		{
			// All powerful shared AWC abilities for base game soldiers have an increased cost, 
			// excluding any abilities they have in their normal progression tree
			return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
		}*/
	}

	// All Colonel level abilities for emulated Faction Heroes and any powerful XCOM abilities have increased cost for Faction Heroes
	if (AbilityRanks == 0 && (bPowerfulAbility || (Rank >= 6 && Branch < 3)))
	{
		return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}

	// All Colonel level abilities for Faction Heroes and any powerful XCOM abilities have increased cost for Faction Heroes
	if (UnitState.IsResistanceHero() && (bPowerfulAbility || (Rank >= 6 && Branch < 3)))
	{
		return class'X2StrategyGameRulesetDataStructures'.default.PowerfulAbilityPointCost;
	}
	
	return AbilityCost;
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

function int GetAbilitiesPerRank(XComGameState_Unit UnitState)
{
	local Name ClassName;
    local int AbilitiesPerRank, RankIndex;
	local bool bAWC;
	local X2SoldierClassTemplate ClassTemplate;

	ClassName = UnitState.GetSoldierClassTemplateName();	

	if( HasCustomAbilitiesPerRank(ClassName) )
	{
		return GetCustomAbilitiesPerRank(ClassName);
	}

	ClassTemplate = UnitState.GetSoldierClassTemplate();
	bAWC = ClassTemplate.bAllowAWCAbilities;

	for(RankIndex = 1; RankIndex < ClassTemplate.GetMaxConfiguredRank(); RankIndex++)
	{
		if(ClassTemplate.GetAbilitySlots(RankIndex).Length > AbilitiesPerRank)
		{
			AbilitiesPerRank = ClassTemplate.GetAbilitySlots(RankIndex).Length;
		}
	}
	
	if(bAWC && AbilitiesPerRank == 4)
	{
		return 3;
	}

	return AbilitiesPerRank;
}

function bool HasCustomAbilitiesPerRank(name ClassName)
{
	local int i;

	for(i = 0; i < ClassAbilitiesPerRank.Length; ++i)
	{				
		if(ClassAbilitiesPerRank[i].ClassName == ClassName)
		{
			return true;
		}
	}

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

function bool HasCustomAbilityCost(name ClassName, name AbilityName)
{
	local int i;

	for(i = 0; i < ClassCustomAbilityCost.Length; ++i)
	{				
		if(ClassCustomAbilityCost[i].ClassName == ClassName && ClassCustomAbilityCost[i].AbilityName == AbilityName)
		{
			return true;
		}
	}

	return false;
}

function int GetCustomAbilityCost(name ClassName, name AbilityName)
{
	local int i;

	for(i = 0; i < ClassCustomAbilityCost.Length; ++i)
	{
		if(ClassCustomAbilityCost[i].ClassName == ClassName && ClassCustomAbilityCost[i].AbilityName == AbilityName)
		{
			return ClassCustomAbilityCost[i].AbilityCost;
		}
	
	}
	return 10;
}