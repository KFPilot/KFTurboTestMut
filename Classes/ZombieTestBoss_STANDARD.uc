class ZombieTestBoss_STANDARD extends ZombieTestBoss;

function Died(Controller Killer, class<DamageType> damageType, Vector HitLocation) {
	Super(ZombieBossBase).Died(Killer, damageType, HitLocation);
}

defaultproperties
{
}
