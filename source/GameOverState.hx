package;

import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

// A simple enum for whether the game was won or lost
enum WinLoseState {
	WIN;
	LOSE;
}

// The game over screen. Displays a message based on
// whether the player won or lost
class GameOverState extends FlxUIState {
	var winState:WinLoseState = LOSE;

	override public function new(winState:WinLoseState) {
		super();
		this.winState = winState;
	}

	override function create() {
		FlxG.mouse.unload();
		FlxG.camera.zoom = 1;
		_xml_id = "game_over";
		super.create();
		switch (winState) {
			case WIN:
				_ui.getFlxText("title").text = "You Win!";
				_ui.getFlxText("description").text = "You managed to kill all those zombies. Too bad they found a cure, and now you are a murderer!";
			default:
			case LOSE:
				_ui.getFlxText("title").text = "Game Over!";
				_ui.getFlxText("description").text = "Unfortunately, you died. You were our last hope and now the zombies will take over the planet!";
		}
	}

	// Click events for buttons
	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "replay": FlxG.switchState(new MenuState());
					}
			}
		}
	}
}
