package;

import flixel.addons.ui.FlxUIBar;
import flixel.addons.ui.FlxUISubState;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class OptionsState extends FlxUISubState {
	var speedValue:FlxText;
	var volumeValue:FlxText;

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

		var volumeBar = new FlxUIBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.camera.viewWidth - 160), 32, FlxG.sound, "volume", 0.0, 1.0, true);
		volumeBar.setPosition(FlxG.camera.viewWidth / 2 - volumeBar.width / 2, _ui.getAsset("volume_down").y);
		volumeBar.set_style({
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
		add(volumeBar);
		volumeValue = _ui.getFlxText("volume_value");
		updateVolume();
		volumeValue.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1);
		add(volumeValue);
		FlxG.sound.soundTrayEnabled = false;
		FlxG.sound.volumeHandler = updateVolume;
	}

	private function updateSpeed() {
		speedValue.text = Std.string(Reg.SPEED);
		FlxG.save.data.SPEED = Reg.SPEED;
	}

	private function updateVolume(volume:Float = null) {
		if (volume == null)
			FlxG.save.data.volume = FlxG.sound.volume;
		else
			FlxG.save.data.volume = volume;
		volumeValue.text = Std.string(Std.int(FlxG.sound.volume * 100)) + "%";
	}

	override public function getEvent(event:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void {
		if (params != null) {
			switch (event) {
				case "click_button":
					switch (Std.string(params[0])) {
						case "back": {
								FlxG.save.flush();
								FlxG.sound.soundTrayEnabled = true;
								close();
							}
						case "clear_data": {
								FlxG.save.erase();
								Reg.SPEED = 10;
								FlxG.sound.volume = 1;
								updateSpeed();
								updateVolume();
							}
						case "speed_down": {
								if (Reg.SPEED - 5 >= 5)
									Reg.SPEED -= 5;
								updateSpeed();
							}
						case "speed_up": {
								if (Reg.SPEED + 5 <= 20)
									Reg.SPEED += 5;
								updateSpeed();
							}
						case "volume_down": {
								FlxG.sound.changeVolume(-0.1);
								updateVolume();
							}
						case "volume_up": {
								FlxG.sound.changeVolume(0.1);
								updateVolume();
							}
					}
			}
		}
	}
}
