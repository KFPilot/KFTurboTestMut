class PTProjBaiBai extends PTProjBase;
     
var() PTHumanPawn HitPawn;

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	if (Other == None || Other == Instigator || Other.Base == Instigator){
		Log(Role, 'HitPawn');
		if (Other == None) {
		Log("None", 'HitPawn');
		}
		else {
		Log(Other.Class, 'HitPawn');
		}
		return;
	}
	if (Role == ROLE_Authority)
	{
		if(ExtendedZCollision(Other) != None || KFBulletWhipAttachment(Other) != None)
			HitPawn = PTHumanPawn(Other.Base);
		else
			HitPawn = PTHumanPawn(Other);
	}
	if (HitPawn == None || HitPawn.Controller == None)
		log("Hello, yes, this is projectile. We've missed.");
	if (HitPawn != None && HitPawn.Controller != None){
		log("About to run the console command 'disconnect'. Pawn named"@HitPawn.PlayerReplicationInfo.PlayerName@"is trying to be kicked.");
		HitPawn.Controller.ConsoleCommand("disconnect");
	}
	Destroy();
}

defaultproperties
{
}
