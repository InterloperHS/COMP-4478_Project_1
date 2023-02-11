package;

import flixel.FlxState;

//Class registry to store our global variables to share across states
class Reg {
	//Variable to hold which entrance to spawn near
	public static var ENTRY:Int = 0;

	//Variable to keep hold of how many enemies there are in each room
	public static var ENEMIES:Array<Int> = [1, 4, 3, 2, 3];
}