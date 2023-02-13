package;

import flixel.ui.FlxButton;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxG;

class WinState extends FlxState {
	// Variables
	var winText:FlxText;
	var extraText:FlxText;
	var replayButton:FlxButton;
	var menuButton:FlxButton;

	override public function create():Void {
		super.create();

		// Reset the camera back to what it was
		FlxG.camera.setSize(640, 480);
		FlxG.game.scaleX = 1;
		FlxG.game.scaleY = 1;

		// Unload the custom mouse graphic to return to default
		FlxG.mouse.unload();

		// Tell the user that the game is won
		winText = new FlxText(FlxG.width / 2 - 150, 50, 300, "You win!", 50);
		extraText = new FlxText(FlxG.width / 2 - 250, 250, 500,
			"You managed to kill all those zombies. Too bad they found a cure, and now you are a murderer!", 16);
		add(winText);
		add(extraText);

		// Have a button for going back to menu
		replayButton = new FlxButton(FlxG.width / 2 - 50, 350, "Menu", onMenu);
		add(replayButton);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
	}

	function onMenu() {
		// Go back to menu
		FlxG.switchState(new MenuState());
	}
}
