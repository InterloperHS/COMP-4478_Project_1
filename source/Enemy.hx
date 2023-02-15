package;

import flixel.math.FlxAngle;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class Enemy extends FlxSprite {
	var target:Player;
	var speed:Float;
	var numBullets:Int = 5;
	var bullets:FlxTypedGroup<FlxSprite>;

	public function new(x:Float = 0, y:Float = 0, play:Player, spd:Float, enemyType:String) {
		super(x, y);

		// The enemy wants to get the player
		target = play;
		speed = spd;

		// Set the enemy's graphic based on the type
		switch (enemyType) {
			default:
			case "normal":
				loadGraphic(AssetPaths.zombie__png, true, 16, 16);
				setGraphicSize(16, 16);
				setSize(8, 8);
				offset.x = 4;
				offset.y = 4;
			case "ranged":
				loadGraphic(AssetPaths.zombie_f__png, true, 16, 16);
				setGraphicSize(16, 16);
				setSize(8, 8);
				offset.x = 4;
				offset.y = 4;
			case "large":
				loadGraphic(AssetPaths.zombie__png, true, 16, 16);
				setGraphicSize(32, 32);
				setSize(16, 16);
				offset.x = 4;
				offset.y = 4;
		}
		createAnimations();
	}

	private function createAnimations() {
		// Create the walk animations
		animation.add("walkD", [0, 1, 2, 3], 5, true);
		animation.add("walkDL", [4, 5, 6, 7], 5, true);
		animation.add("walkL", [8, 9, 10, 11], 5, true);
		animation.add("walkUL", [12, 13, 14, 15], 5, true);
		animation.add("walkU", [16, 17, 18, 19], 5, true);
		animation.add("walkDR", [20, 21, 22, 23], 5, true);
		animation.add("walkR", [24, 25, 26, 27], 5, true);
		animation.add("walkUR", [28, 29, 30, 31], 5, true);

		// Create the idle animations
		animation.add("idleD", [0], 5, true);
		animation.add("idleDL", [4], 5, true);
		animation.add("idleL", [8], 5, true);
		animation.add("idleUL", [12], 5, true);
		animation.add("idleU", [16], 5, true);
		animation.add("idleDR", [20], 5, true);
		animation.add("idleR", [24], 5, true);
		animation.add("idleUR", [28], 5, true);
	}

	override public function update(elapsed:Float):Void {
		if (speed != 0)
			enemyMovement();
		super.update(elapsed);
	}

	function enemyMovement() {
		// var enemyDistX:Float = this.x - target.x;
		// var enemyDistY:Float = this.y - target.y;
		// var enemyDist = Math.sqrt((enemyDistX * enemyDistX) + (enemyDistY * enemyDistY));
		// velocity.y = (enemyDistY / enemyDist) * -speed;
		// velocity.x = (enemyDistX / enemyDist) * -speed;

		// Angle between the enemy and the player
		var moveAngle = FlxAngle.angleBetween(this, target, true);
		var moveDirection:String = "D";
		// Set direction based on orientation from player to mouse
		if (moveAngle > -157.5 && moveAngle <= -112.5) {
			moveDirection = "UL";
		} else if (moveAngle > -112.5 && moveAngle <= -67.5) {
			moveDirection = "U";
		} else if (moveAngle > -67.5 && moveAngle <= -22.5) {
			moveDirection = "UR";
		} else if (moveAngle > -22.5 && moveAngle <= 22.5) {
			moveDirection = "R";
		} else if (moveAngle > 22.5 && moveAngle <= 67.5) {
			moveDirection = "DR";
		} else if (moveAngle > 67.5 && moveAngle <= 112.5) {
			moveDirection = "D";
		} else if (moveAngle > 112.5 && moveAngle <= 157.5) {
			moveDirection = "DL";
		} else if ((moveAngle > 157.5 && moveAngle <= 180) || (moveAngle > -180 && moveAngle <= -157.5)) {
			moveDirection = "L";
		}
		velocity.setPolarDegrees(speed, moveAngle);

		// Set the animation to idle by default, change to walk if the enemy is moving
		var action = "idle";
		if ((velocity.x != 0 || velocity.y != 0) && touching == NONE) {
			action = "walk";
		}
		animation.play(action + moveDirection);
	}

}
