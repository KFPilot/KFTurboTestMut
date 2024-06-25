class KFTurboTestMut extends Mutator;

var const byte MAX_HeadHitboxes;
var const float TIME_ClearDelay;

var array<PTHeadHitbox> HeadHitboxes;
var int numPlayers, hitboxCount;
var float gameSpeed, timeClearedZeds, timeClearedLevel;
var bool bWaitClearZeds, bWaitClearLevel, bDrawHitboxes;

replication {
	reliable if (Role == ROLE_Authority)
		numPlayers, gameSpeed, bWaitClearZeds, bWaitClearLevel;
}

static function class<DamageType> GetDamageType(Weapon W) {
	local class<WeaponFire> FireClass;
	
	if (W == None) {
		return None;
	}
	
	FireClass = W.default.FireModeClass[0];
	if (class<KFMeleeFire>(FireClass) != None) {
		return class<KFMeleeFire>(FireClass).default.HitDamageClass;
	}
	else if (class<InstantFire>(FireClass) != None) {
		return class<InstantFire>(FireClass).default.DamageType;
	}
	else if (class<BaseProjectileFire>(FireClass) != None && FireClass.default.ProjectileClass != None) {
		if (class<LAWProj>(FireClass.default.ProjectileClass) != None) {
			return class<LAWProj>(FireClass.default.ProjectileClass).default.ImpactDamageType;
		}
		
		return FireClass.default.ProjectileClass.default.MyDamageType;
	}
	
	return None;
}

static function bool DealsMeleeDamage(Weapon W) {
	local class<DamageType> DmgClass;
	
	DmgClass = static.GetDamageType(W);
	
	return class<DamTypeMelee>(DmgClass) != None;
}

static function bool IsRequiredWeapon(Inventory W) {
	return KFWeapon(W) != None && (Knife(W) != None || Single(W) != None || Frag(W) != None || Syringe(W) != None || Welder(W) != None);
}

function float HealthModifer(float hpScale) {
	return 1.0 + (numPlayers - 1) * hpScale;
}

function PostBeginPlay() {
	local PTGameType GT;
	local PTGameRules GR;
		
	Super.PostBeginPlay();
		
	GT = PTGameType(Level.Game);
	if (GT == None) {
		Level.ServerTravel("?game=KFTurboTestMut.PTGameType", true);
	}
	else {
		GR = Spawn(class'PTGameRules');
		GR.Mut = Self;
		if (GT.GameRulesModifiers == None) {
			GT.GameRulesModifiers = GR;
		}
		else {
			GT.GameRulesModifiers.AddGameRules(GR);
		}
		
		GT.HUDType = string(class'PTHUD');
	
		if (!ClassIsChildOf(GT.PlayerControllerClass, class'KFTTPlayerController')) {
			GT.PlayerControllerClass = class'KFTTPlayerController';
			GT.PlayerControllerClassName = string(class'KFTTPlayerController');
		}
	}
}

function bool ReplaceActorClass(out class<Actor> MC) {
    local class<KFMonstersCollection> MColl;
    local string MCName, LeftPart, RigthPart;
    local byte i, l;
       
    if (class'KFGameType'.default.MonsterCollection == None) {
            return false;
    }
       
    MColl = class'KFProGameType'.default.MonsterCollection;
       
    if(MC == None || InStr(MC, "Boss") != -1) {
        MCName = "KFTurboTestMut.ZombieTestBoss";
        if (Divide(MColl.default.EndGameBossClass, "_", LeftPart, RigthPart)) {
            MCName $= "_" $ RigthPart;
        }
               
        MC = class<KFMonster>(DynamicLoadObject(MCName, class'Class'));
        return true;
    }
       
    for (i = 0; i < class'KFProGameType'.default.MonsterCollection.default.StandardMonsterClasses.length; i++) {
        MCName = MColl.default.StandardMonsterClasses[i].MClassName;
            l = Min(Len(MCName), Len(string(MC)));
            if (Left(MCName, l) ~= Left(string(MC), l)) {
                MC = class<KFMonster>(DynamicLoadObject(MCName, class'Class'));
                return true;
            }
    }
       
    return false;
}
function bool CheckReplacement(Actor Other, out byte bSuperRelevant) {
	local KFMonster Zed;
	local float newHp, newHeadHp;
	local byte i;
	
	Zed = KFMonster(Other);
	if (Zed != None) {
		newHp = Zed.health / Zed.NumPlayersHealthModifer() * HealthModifer(Zed.PlayerCountHealthScale);
		newHeadHp = Zed.headHealth / Zed.NumPlayersHeadHealthModifer() * HealthModifer(Zed.PlayerNumHeadHealthScale);
		Zed.health = newHp;
		Zed.healthMax = newHp;
		Zed.headHealth = newHeadHp;
		if (numPlayers > 1 && Level.Game.numPlayers == 1) {
			Zed.MeleeDamage /= 0.75;
			Zed.spinDamConst /= 0.75;
			Zed.spinDamRand /= 0.75;
			Zed.screamDamage /= 0.75;
		}
		
		AddHitbox(Zed);
	}
	else if (Other.IsA('KFTTPlayerController')) {
		KFTTPlayerController(Other).Mut = Self;
	}
	else if (Other.IsA('Pickup')) {
		if (Other.IsA('FirstAidKit')) {
			FirstAidKit(Other).respawnTime = 0.5;
			FirstAidKit(Other).respawnEffectTime = 0.0;
			FirstAidKit(Other).healingAmount = 666;
		}
		else if (Other.IsA('Vest')) {
			Vest(Other).respawnTime = 0.5;
			Vest(Other).respawnEffectTime = 0.0;
		}
	}
	else if (Other.IsA('NoZedUseTriggerP')) {
		NoZedUseTrigger(Other).Message = Repl(NoZedUseTrigger(Other).Message, "Press 'E'", "Press 'USE'");
	}
	else if (Other.IsA('ScriptedTrigger')) {
		for (i = 0; i < ScriptedTrigger(Other).Actions.length; i++) {
			if (ACTION_SpawnActor(ScriptedTrigger(Other).Actions[i]) != None) {
				ReplaceActorClass(ACTION_SpawnActor(ScriptedTrigger(Other).Actions[i]).ActorClass);
			}
		}
	}
	
	return Super.CheckReplacement(Other, bSuperRelevant);
}

function ModifyPlayer(Pawn Other) {
	if (KFHumanPawn(Other) != None && KFHumanPawn(Other).PlayerReplicationInfo != None) {
		KFHumanPawn(Other).PlayerReplicationInfo.score = 50000;
	}
	
	Super.ModifyPlayer(Other);
}

function NotifyLogout(Controller Exiting) {
	local PTGameType GT;
	
	GT = PTGameType(Level.Game);
	if (GT != None && GT.numPlayers == 0 && GT.numSpectators == 0) {
		ClearZeds();
		ClearLevel();
	}
	
	Super.NotifyLogout(Exiting);
}

simulated function Tick(float DeltaTime) {
	local PlayerController PC;
	
	PC = Level.GetLocalPlayerController();
	if (PC != None) {
		PC.Player.InteractionMaster.AddInteraction("KFTurboTestMut.PTInteraction", PC.Player);
		Disable('Tick');
	}
}

function Timer() {
	if (bWaitClearZeds && Level.timeSeconds - timeClearedZeds > TIME_ClearDelay) {
		bWaitClearZeds = false;
	}

	if (bWaitClearLevel && Level.timeSeconds - timeClearedLevel > TIME_ClearDelay) {
		bWaitClearLevel = false;
	}
	
	if (!bWaitClearZeds && !bWaitClearLevel) {
		SetTimer(0.00, false);
	}
}

/* HITBOXES */

function AddHitbox(KFMonster Zed) {
	local PTHeadHitbox NewHitbox;
	
	NewHitbox = Spawn(class'KFTurboTestMut.PTHeadHitbox', Zed);
	if (NewHitbox != None) {
		NewHitbox.Mut = Self;
		HeadHitboxes[HeadHitboxes.length] = NewHitbox;
		CheckHitboxes();
	}
}

function RemoveHitbox(PTHeadHitbox Hitbox) {
	local byte i;
	
	for (i = HeadHitboxes.Length - 1; i >= 0; i--) {
		if (HeadHitboxes[i] == Hitbox) {
			HeadHitboxes.Remove(i, 1);
			break;
		}
	}
	
	CheckHitboxes();
}

function CheckHitboxes() {
	local Controller C;
	
	if (HeadHitboxes.length >= MAX_HeadHitboxes) {
		if (bDrawHitboxes) {
			bDrawHitboxes = false;
			for (C = Level.ControllerList; C != None; C = C.NextController) {
				CheckPlayerHitboxes(KFTTPlayerController(C));
			}
		}
	}
	else {
		CheckDrawHitboxes();
	}
}

function CheckPlayerHitboxes(KFTTPlayerController Sender) {
	if (Sender != None) {
		if (HeadHitboxes.length >= MAX_HeadHitboxes) {
			if (Sender.bDrawHitboxes) {
				Sender.ClientMessage("WARNING: Head hitboxes will be shown only when the number of zeds alive is less than" @ MAX_HeadHitboxes);
			}
		}
		else {
			CheckDrawHitboxes();
		}
	}
}

function CheckDrawHitboxes() {
	local Controller C;
	local bool bNewDrawHitboxes;
	
	bNewDrawHitboxes = false;
	for (C = Level.ControllerList; C != None; C = C.NextController) {
		if (KFTTPlayerController(C) != None) {
			if (KFTTPlayerController(C).bDrawHitboxes) {
				bNewDrawHitboxes = true;
				break;
			}
		}
	}
	
	if (bDrawHitboxes != bNewDrawHitboxes) {
		bDrawHitboxes = bNewDrawHitboxes;
	}
}

/* COMMANDS */

function string GetPlayerName(PlayerController Sender) {
	if (Sender == None) {
		return "Someone";
	}
	else {
		return Sender.GetHumanReadableName();
	}
}

function SetHealth(PlayerController Sender, int newNumPlayers) {
	local int i;
	
	i = Clamp(newNumPlayers, 1, 99);
	if (numPlayers == i) {
		Sender.ClientMessage("Health already scaled to" @ numPlayers @ "player(s)");
	}
	else {
		numPlayers = i;
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "scaled health to" @ numPlayers @ "player(s)");
	}
}

function SetGameSpeed(PlayerController Sender, float newSpeed) {
	local float f;

	f = FClamp(newSpeed, 0.1, 1.0);
	if (gameSpeed == f) {
		Sender.ClientMessage("Speed already set to" @ gameSpeed);
	}
	else {
		gameSpeed = f;
		Level.Game.SetGameSpeed(gameSpeed);
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "set the game speed to" @ gameSpeed);
	}
}

function ClearZeds(optional PlayerController Sender) {
	local KFMonster TrashMonster;
	
	if (!bWaitClearZeds) {
		forEach DynamicActors(class'KFMonster', TrashMonster) {
			TrashMonster.Destroy();
		}

		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "removed all zeds");
		
		timeClearedZeds = Level.timeSeconds;
		bWaitClearZeds = true;
		if (!bWaitClearLevel) {
			SetTimer(1.00, true);
		}
	}
}

function ClearLevel(optional PlayerController Sender) {
	local Pawn TrashPawn;
	local KFWeaponPickup TrashPickup;
	local Projectile TrashProjectile;
	local BossHPNeedle TrashNeedle;
	local KFDoorMover KFDM;
	local Controller C;
	
	if (!bWaitClearLevel) {
		forEach DynamicActors(class'Pawn', TrashPawn) {
			if (TrashPawn.Controller == None) {
				TrashPawn.Destroy();
			}
		}
		
		forEach DynamicActors(class'KFWeaponPickup', TrashPickup) {
			if (KFHumanPawn(TrashPickup.Owner) == None) {
				TrashPickup.Destroy();
			}
		}
			
		forEach DynamicActors(class'Projectile', TrashProjectile) {
			TrashProjectile.Destroy();
		}
		
		forEach DynamicActors(class'BossHPNeedle', TrashNeedle) {
			TrashNeedle.Destroy();
		}
		
		foreach DynamicActors(class'KFDoorMover', KFDM) {
			if (KFDM.bDoorIsDead) {
				KFDM.RespawnDoor();
			}
			else {
				KFDM.SetWeldStrength(0.0);
				if (KFDM.MyTrigger != None) {
					KFDM.MyTrigger.WeldStrength = 0;
				}
			}
		}

		for (C = Level.ControllerList; C != None; C = C.NextController) {
			if (KFTTPlayerController(C) != None) {
				KFTTPlayerController(C).ClientClearLevel();
				KFTTPlayerController(C).ClientForceCollectGarbage();
			}
		}
		
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "cleaned up the level");
		
		timeClearedLevel = Level.timeSeconds;
		bWaitClearLevel = true;
		if (!bWaitClearZeds) {
			SetTimer(1.00, true);
		}
	}
}

function ForceRadial(PlayerController Sender) {
	local ZombieBoss LevelBoss;
	local byte bossCount;

	forEach DynamicActors(class'ZombieBoss', LevelBoss) {
		if (!LevelBoss.IsInState('RadialAttack')) {
			LevelBoss.GotoState('RadialAttack');
			bossCount++;
		}
	}
	
	if (bossCount > 0) {
		Level.Game.Broadcast(Level.Game, GetPlayerName(Sender) @ "forced radial attack for" @ bossCount @ "Patriarch(s)");
	}
	else {
		Sender.ClientMessage("No Patriarchs found");
	}
}

defaultproperties
{
     MAX_HeadHitboxes=32
     TIME_ClearDelay=10.000000
     NumPlayers=6
     GameSpeed=1.000000
     bAddToServerPackages=True
     GroupName="KFPerkTest"
     FriendlyName="PerkTest"
     Description="Adds features to help players practice."
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
