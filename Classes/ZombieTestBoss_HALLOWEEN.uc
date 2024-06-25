class ZombieTestBoss_HALLOWEEN extends ZombieTestBoss_STANDARD;

#exec OBJ LOAD FILE=KF_EnemiesFinalSnd_HALLOWEEN.uax

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
		Skins[2] = Finalblend'KFX.StalkerGlow';
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
				C.Enemy = None;
			}
		}
	}

	if( Level.NetMode==NM_DedicatedServer )
	{
		Return;
	}

	Skins[1] = Shader'KF_Specimens_Trip_HALLOWEEN_T.Patriarch.Patriarch_Halloween_Invisible';
	Skins[0] = Shader'KF_Specimens_Trip_T.patriarch_invisible_gun';

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
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_KnockedDown', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchEntrance()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Entrance', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchVictory()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Victory', SLOT_Misc, 2.0,true,500.0);
}

function PatriarchMGPreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_WarnGun', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchMisslePreFire()
{
	PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_WarnRocket', SLOT_Misc, 2.0,true,1000.0);
}

function PatriarchRadialTaunt()
{
	if( NumNinjas > 0 && NumNinjas > NumLumberJacks )
	{
		PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntNinja', SLOT_Misc, 2.0,true,500.0);
	}
	else if( NumLumberJacks > 0 && NumLumberJacks > NumNinjas )
	{
		PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntLumberJack', SLOT_Misc, 2.0,true,500.0);
	}
	else
	{
		PlaySound(SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_TauntRadial', SLOT_Misc, 2.0,true,500.0);
	}
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
		PlaySound(sound'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_SaveMe', SLOT_Misc, 2.0,,500.0);

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

defaultproperties
{
     RocketFireSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_FireRocket'
     MeleeImpaleHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_HitPlayer_Impale'
     MoanVoice=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Talk'
     MeleeAttackHitSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_HitPlayer_Fist'
     JumpSound=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Jump'
     HitSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Pain'
     DeathSound(0)=SoundGroup'KF_EnemiesFinalSnd_HALLOWEEN.Patriarch.Kev_Death'
     MenuName="HALLOWEEN Patriarch"
     AmbientSound=Sound'KF_BasePatriarch_HALLOWEEN.Kev_IdleLoop'
     Mesh=SkeletalMesh'KF_Freaks_Trip_HALLOWEEN.Patriarch_Halloween'
     Skins(1)=Combiner'KF_Specimens_Trip_HALLOWEEN_T.Patriarch.Patriarch_RedneckZombie_CMB'
}
