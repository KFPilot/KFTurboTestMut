class ZombieTestBoss extends ZombieBoss_STANDARD;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation) {
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}

defaultproperties
{
}
