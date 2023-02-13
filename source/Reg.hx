package;

// Class registry to store our global variables to share across states
class Reg {
	// Variable to hold which entrance to spawn near
	public static var ENTRY:Int = 0;

	// Variable to keep hold of how many enemies there are in each room
	public static var ENEMIES:Array<Int> = [1, 4, 3, 2, 0, 3];

	// Variable to keep track of ammo the player has
	public static var AMMO:Int = 20;

	// Variable to keep track of health for player
	public static var PLAYERHEALTH:Float = 100;

	// Reset registry to default values
	public static function resetReg() {
		ENEMIES = [1, 4, 3, 2, 0, 3];
		AMMO = 20;
		PLAYERHEALTH = 100;
		ENTRY = 0;
	}
}
