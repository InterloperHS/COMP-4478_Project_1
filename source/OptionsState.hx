package;

import flixel.FlxCamera;
import flixel.FlxSubState;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

//** Sourced from https://github.com/HaxeFlixel/flixel-demos/blob/dev/Tutorials/TurnBasedRPG/source/OptionsState.hx **/
class OptionsState extends FlxSubState {
	// define our screen elements
	var titleText:FlxText;
	var speedBar:FlxBar;
	var speedText:FlxText;
	var speedAmountText:FlxText;
	var speedDownButton:FlxButton;
	var speedUpButton:FlxButton;
	var clearDataButton:FlxButton;
	var backButton:FlxButton;
	var speed:Int;

	override public function new(BGColor:FlxColor) {
		super(BGColor);
	}

	override public function create():Void {
		// Get player movement speed from the save file or
		// use a default value of 5
		if (FlxG.save.data.speed != null) {
			speed = FlxG.save.data.speed;
		} else {
			speed = 5;
		}

		// setup and add our objects to the screen
		titleText = new FlxText(0, 20, 0, "Options", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		speedText = new FlxText(0, titleText.y + titleText.height + 10, 0, "Speed", 8);
		speedText.alignment = CENTER;
		speedText.screenCenter(FlxAxes.X);
		add(speedText);

		speedDownButton = new FlxButton(8, speedText.y + speedText.height + 2, "-", clickSpeedDown);
		add(speedDownButton);

		speedUpButton = new FlxButton(FlxG.width - 4 - speedDownButton.width, speedDownButton.y, "+", clickSpeedUp);
		add(speedUpButton);

		speedBar = new FlxBar(speedDownButton.x + speedDownButton.width + 4, speedDownButton.y, LEFT_TO_RIGHT,
			Std.int(FlxG.width - 4 * 5 - speedDownButton.width * 2), Std.int(speedUpButton.height), null, null, 5, 20);
		speedBar.createFilledBar(0xff464646, FlxColor.WHITE, true, FlxColor.WHITE);
		add(speedBar);

		speedAmountText = new FlxText(0, 0, 200, Std.string(speed), 8);
		speedAmountText.alignment = CENTER;
		speedAmountText.borderStyle = FlxTextBorderStyle.OUTLINE;
		speedAmountText.borderColor = 0xff464646;
		speedAmountText.y = speedBar.y + (speedBar.height / 2) - (speedAmountText.height / 2);
		speedAmountText.screenCenter(FlxAxes.X);
		add(speedAmountText);

		backButton = new FlxButton(0, 0, "Back", clickBack);
		backButton.x = (FlxG.width / 2) - (backButton.width / 2);
		backButton.y = FlxG.height - 28;
		add(backButton);

		// update the speed bar to show the current speed level
		updateSpeed();

		FlxG.camera.zoom = 1;
		super.create();
	}

	/**
	 * The user clicked the back button - close our save object, and go back to the MenuState
	 */
	function clickBack() {
		FlxG.save.data.speed = speed;
		FlxG.save.flush();
		FlxG.camera.zoom = 2;
		close();
	}

	/**
	 * The user clicked the down button for speed - we reduce the speed by 5 and update the bar
	 */
	function clickSpeedDown() {
		if (speed > 5) {
			speed -= 5;
		}
		updateSpeed();
	}

	/**
	 * The user clicked the up button for speed - we increase the speed by 5 and update the bar
	 */
	function clickSpeedUp() {
		if (speed < 20) {
			speed += 5;
		}
		updateSpeed();
	}

	/**
	 * Whenever we want to show the value of speed, we call this to change the bar and the amount text
	 */
	function updateSpeed() {
		speedBar.value = speed;
		speedAmountText.text = Std.string(speed);
	}
}
