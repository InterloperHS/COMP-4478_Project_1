package;

import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;

// The game state class that extends FlxState
class Space extends FlxState {
	var ali:FlxSprite = new FlxSprite();
	var ali1:FlxSprite = new FlxSprite();
	var voiager:FlxSprite = new FlxSprite();
	var expVo:FlxSprite = new FlxSprite();
	var cd:FlxSprite = new FlxSprite();
	var background:FlxSprite = new FlxSprite();

	private var tutorialModal:FlxSprite;
	private var tutorialText:FlxText;
	private var tutorialArray:Array<String>;
	private var tutorialIndex:Int;

	override public function create():Void {
		super.create();

		// create an instance of FlxCamera
		// add the camera to the list of cameras in FlxG
		var camera:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 0);

		camera.scroll.x = 0;
		camera.scroll.y = 0;
		camera.width = FlxG.width;
		camera.height = FlxG.height;
		FlxG.cameras.add(camera);

		// Create tutorial modal
		tutorialModal = new FlxSprite(FlxG.width / 2 - 150, FlxG.height / 2 - 100);
		tutorialModal.makeGraphic(300, 100, 0xAA333333);

		// Create tutorial text
		tutorialText = new FlxText(tutorialModal.x + 10, tutorialModal.y + 10, 280, "");
		tutorialText.setFormat(null, 16, 0xFFFFFFFF, "center");
		tutorialText.y = 1;
		tutorialModal.y = 1;

		// Create tutorial array
		tutorialArray = [
			"Alien ship: Everything seems to be stable while travelling in space.",
			"Oh my God, there is a strange space object rapidly approaching our friends' spacecraft!",
			"It completely destroyed their spacecraft!",
			"Look, there's a disc moving from the remains, let's see what is it.",
			"It seems that there are aliens on a planet called 'Earth'",
			"They look dangerous, they destroyed our friends' spaceship and we must avenge them.",
			"We have their planet's address, let's go"
		];
		tutorialIndex = 0;
		tutorialText.text = tutorialArray[tutorialIndex];

		background.loadGraphic("assets/images/bg.png");
		Earth.resizeImage(background, 640, 480, 0, 0);

		add(background);

		ali.loadGraphic("assets/images/ali2.png", true, 502, 502);
		ali.animation.add("ali", [0, 1], 4, true);
		Earth.resizeImage(ali, 70, 60, 410, 250);
		ali.animation.play("ali");
		add(ali);

		ali1.loadGraphic("assets/images/ali2.png", true, 502, 502);
		ali1.animation.add("ali1", [0, 1], 4, true);
		Earth.resizeImage(ali1, 50, 40, 410, 170);
		ali1.animation.play("ali1");
		add(ali1);

		voiager.loadGraphic("assets/images/voiager.png");
		Earth.resizeImage(voiager, 50, 40, -500, 170);
		add(voiager);

		cd.loadGraphic("assets/images/cd.png");

		expVo.loadGraphic("assets/images/expVo.png", true, 192, 192);
		expVo.animation.add("ex", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19], 5, false);
		Earth.resizeImage(expVo, 100, 100, 504, 203);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		add(tutorialModal);
		add(tutorialText);
		if (tutorialIndex >= tutorialArray.length) {
			remove(tutorialModal);
			remove(tutorialText);
			FlxG.switchState(new Earth());
		}

		if (FlxG.mouse.justPressed) {
			// tutorial slides when mouse pree
			tutorialIndex++;
			if (tutorialIndex < tutorialArray.length) {
				tutorialText.text = tutorialArray[tutorialIndex];

				if (tutorialIndex == 2) {
					var tween:FlxTween = FlxTween.tween(voiager, {x: 200, y: 200}, 1);
					var tween:FlxTween = FlxTween.tween(ali1, {x: 200, y: 200}, 1);
					tween.onComplete = function(t:flixel.tweens.FlxTween):Void {
						// do something when the tween completes

						if (voiager.overlaps(ali1)) {
							expVo.setPosition(voiager.x, voiager.y);
							add(expVo);
							expVo.animation.play("ex");
							ali1.kill();
							voiager.kill();
						}
					}
				}

				if (tutorialIndex == 4) {
					Earth.resizeImage(cd, 15, 15, 235, 220);
					add(cd);
					var tween2:FlxTween = FlxTween.tween(cd, {
						x: 100,
						y: 250,
						height: cd.height + 30,
						width: cd.width + 30
					}, 2);
					var tween3:FlxTween = FlxTween.tween(ali, {
						x: 100,
						y: 250,
						height: cd.height + 30,
						width: cd.width + 30
					}, 2);
				}

				if (tutorialIndex == 5) {
					cd.kill();
					ali.scale.x = 2;
					ali.scale.y = 2;
				}
			}

			// when the array of tutorail slides ends, remove the tutorial and shot the ball
			else {
				remove(tutorialModal);
				remove(tutorialText);
			}
		}

		// move by the key board arrows
		if (FlxG.keys.pressed.LEFT) {
			camera.scroll.x = ali1.x - camera.width / 2;
			camera.scroll.y = ali1.y - camera.height / 2;
			camera.width = Std.int(FlxG.width / 2);
			camera.height = Std.int(FlxG.height / 2);
		}

		if (FlxG.keys.pressed.R) {
			FlxG.resetState();
		}
	}
}
