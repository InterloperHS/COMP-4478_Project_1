package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;

class MenuState extends FlxUIState {
	override public function create() {
		FlxG.mouse.unload();
		FlxG.camera.zoom = 1;
		_xml_id = "menu_ui";

		// Reset registry if needed
		Reg.resetReg();

		// Load saved data
		if (FlxG.save.data.SPEED != null)
			Reg.SPEED = FlxG.save.data.SPEED;

		super.create();
	}

	// Override this function to handle events from the UI
	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "play": FlxG.switchState(new PlayState());
						case "story": FlxG.switchState(new Laboratory());
						case "options": openSubState(new OptionsState());
						case "help": openSubState(new HelpState(FlxColor.BLACK));
						case "rules": openSubState(new RulesState(FlxColor.BLACK));
					}
			}
		}
	}
}
