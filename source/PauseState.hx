package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;

class PauseState extends FlxUISubState {
	override public function new(BGColor:FlxColor) {
		super(BGColor);
	}

	override public function create() {
		FlxG.camera.zoom = 1;
		_xml_id = "pause_ui";
		super.create();
	}

	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "stop": FlxG.switchState(new MenuState());
						case "options": openSubState(new OptionsState(0x6703378B));
						case "back": {
								FlxG.camera.zoom = 2;
								close();
							}
					}
			}
		}
	}
}
