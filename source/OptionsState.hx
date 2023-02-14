package;

import flixel.addons.ui.FlxUIBar;
import flixel.addons.ui.FlxUISubState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsState extends FlxUISubState {
	var speedValue:FlxText;

	override public function new() {
		super(FlxColor.BLACK);
	}

	override public function create():Void {
		_xml_id = "options_ui";
		super.create();
		// var speedBar:FlxUIBar = cast _ui.getAsset("speed_bar");
		var speedBar = new FlxUIBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.camera.viewWidth - 160), 32, Reg, "SPEED", 5, 20, true);
		speedBar.setPosition(FlxG.camera.viewWidth / 2 - speedBar.width / 2, _ui.getAsset("speed_down").y);
		speedBar.set_style({
			filledColors: null,
			emptyColors: null,
			chunkSize: null,
			gradRotation: null,
			filledColor: 0xFFFFFFFF,
			emptyColor: 0xFF000000,
			borderColor: 0xFF242424,
			filledImgSrc: null,
			emptyImgSrc: null
		});
		add(speedBar);
		speedValue = _ui.getFlxText("speed_value");
		speedValue.text = Std.string(Reg.SPEED);
		speedValue.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		add(speedValue);
	}

	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "back": {
								FlxG.save.data.SPEED = Reg.SPEED;
								FlxG.save.flush();
								close();
							}
						case "speed_down": {
								if (Reg.SPEED - 5 >= 5)
									Reg.SPEED -= 5;
								speedValue.text = Std.string(Reg.SPEED);
							}
						case "speed_up": {
								if (Reg.SPEED + 5 <= 20)
									Reg.SPEED += 5;
								speedValue.text = Std.string(Reg.SPEED);
							}
					}
			}
		}
	}
}
