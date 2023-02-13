package;

import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;
import flixel.addons.ui.FlxUIState;

class MenuState extends FlxUIState {
    
	override public function create() {
		_xml_id = "menu_ui";
		//Reset registry if needed
        Reg.resetReg();
		super.create();
	}

	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
                        case "play": FlxG.switchState(new PlayState());
                        //case "play_story": FlxG.switchState(new Laboratory());
                        case "options": openSubState(new OptionsState(FlxColor.BLACK));
                        case "help": openSubState(new HelpState(FlxColor.BLACK));
					}
			}
		}
	}
}