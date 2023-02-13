package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUISubState;

class HelpState extends FlxUISubState {
	override public function new(BGColor:FlxColor) {
		super(BGColor);
	}

	override public function create() {
		FlxG.camera.zoom = 1;
		_xml_id = "help_ui";
		super.create();
	}

	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "back": close();
					}
			}
		}
	}
}
