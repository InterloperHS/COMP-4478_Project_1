package;

import flixel.util.FlxColor;
import flixel.FlxState;
import flixel.FlxSprite;

class Door extends FlxSprite {
	// Door variables
	var stateDestID:Int;
	var stateEntranceID:Int;

	// Parameters x,y are positions to place the door
	// Parameter state is the destination state the door will lead to
	// Parameter entranceID is the spawn ID that the player will go to in the destination
	public function new(dest:Int, entranceID:Int = 0) {
		super(0, 0);
		stateDestID = dest;
		stateEntranceID = entranceID;

		// Make the temp door graphic
		makeGraphic(16, 16, FlxColor.TRANSPARENT);

		// Set hitbox of door
		// 8x8 box in the middle of the door graphic in map
		setSize(8, 8);
		offset.set(4, 4);
	}
}
