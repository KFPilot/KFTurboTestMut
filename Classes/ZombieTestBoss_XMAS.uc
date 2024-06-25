class ZombieTestBoss_XMAS extends ZombieTestBoss_STANDARD;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_Xmas.uax
#exec OBJ LOAD FILE=KF_Specimens_Trip_XMAS_T.utx

simulated function CloakBoss()
{
	local Controller C;
	local int Index;

    if( bZapped )
    {
	   return;
    }

	if ( bSpotted )
	{
		Visibility = 120;

		if ( Level.NetMode==NM_DedicatedServer )
		{
			Return;
		}

		Skins[0] = Finalblend'KFX.StalkerGlow';
		Skins[1] = Finalblend'KFX.StalkerGlow';
		bUnlit = true;

		return;
	}

	Visibility = 1;
	bCloaked = true;

	if ( Level.NetMode!=NM_Client )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			if ( C.bIsPlayer && C.Enemy==Self )
			{
				C.Enemy = None; // Make bots lose sight with me.
			}
		}
	}

	if( Level.NetMode==NM_DedicatedServer )
	{
		Return;
	}

	Skins[1] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';
	Skins[0] = Shader'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_santa_invisible_shdr';

	if(PlayerShadow != none)
	{
		PlayerShadow.bShadowActive = false;
	}

	Projectors.Remove(0, Projectors.Length);
	bAcceptsProjectors = false;
	SetOverlayMaterial(FinalBlend'KF_Specimens_Trip_T.patriarch_fizzle_FB', 1.0, true);

	if ( FRand() < 0.10 )
	{
		Index = Rand(Level.Game.NumPlayers);

		for ( C = Level.ControllerList; C != none; C = C.NextController )
		{
			if ( PlayerController(C) != none )
			{
				if ( Index == 0 )
				{
					PlayerController(C).Speech('AUTO', 8, "");
					break;
				}

				Index--;
			}
		}
	}
}

function PatriarchKnockDown()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

state KnockDown
{
	function bool ShouldChargeFromDamage()
	{
		return false;
	}

Begin:
	if ( Health > 0 )
	{
		Sleep(GetAnimDuration('KnockDown'));
		CloakBoss();
		PlaySound(sound'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_SaveMe', SLOT_Misc, 2.0,,500.0);

		if ( KFGameType(Level.Game).FinalSquadNum == SyringeCount )
		{
		   KFGameType(Level.Game).AddBossBuddySquad();
		}

		GotoState('Escaping');
	}
	else
	{
	   GotoState('');
	}
}

static simulated function PreCacheMaterials(LevelInfo myLevel)
{
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.gatling_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_T.gatling_D');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_T.PatGungoInvisible_cmb');

	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb');
	myLevel.AddPrecacheMaterial(Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa_env_cmb');
	myLevel.AddPrecacheMaterial(Texture'KF_Specimens_Trip_XMAS_T.patriarch_Santa_Diff');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible');
	myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_invisible_gun');
    myLevel.AddPrecacheMaterial(Material'KF_Specimens_Trip_T.patriarch_fizzle_FB');
 }

defaultproperties
{
     RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_FireRocket'
     MiniGunFireSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_GunfireLoop'
     MiniGunSpinSound=Sound'KF_BasePatriarch_xmas.Attack.Kev_MG_TurbineFireLoop'
     MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Impale'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_HitPlayer_Fist'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Jump'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_Death'
     MenuName="Christmas Patriarch"
     AmbientSound=SoundGroup'KF_EnemiesFinalSnd_Xmas.Patriarch.Kev_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_Xmas.SantaClause_Patriarch'
     Skins(0)=Combiner'KF_Specimens_Trip_XMAS_T.patriarch_Santa.patriarch_Santa_cmb'
     Skins(1)=Combiner'KF_Specimens_Trip_XMAS_T.gatling_cmb'
}
