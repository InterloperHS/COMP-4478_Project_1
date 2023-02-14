package;

import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;

class Enemy extends FlxSprite {
	var target:Player;
	var speed:Float;
	var numBullets:Int = 5;
	var bullets:FlxTypedGroup<FlxSprite>;

	public function new(x:Float = 0, y:Float = 0, play:Player, spd:Float) {
		// The enemy wants to get the player
		target = play;
		speed = spd;

		// If speed = 0, ranged enemy
		if (speed == 0) {
			// Create some bullets for the enemy
			var bullets = new FlxTypedGroup(numBullets);
			for (i in 0...numBullets) {
				var bullet:FlxSprite = new FlxSprite(-100, -100);
				bullet.makeGraphic(15, 10, FlxColor.ORANGE);
				bullet.exists = false;
				bullets.add(bullet);
			}
		}

		super(x, y);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		if (speed != 0)
			enemyMovement();
		// if(speed == 0) enemyShoot();
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

	function enemyShoot() {
		var enemyDistX:Float = this.x - target.x;
		var enemyDistY:Float = this.y - target.y;

		var enemyProjectileAngle = Std.int(Math.atan(enemyDistX / enemyDistY) * 57.2957795);

		var enemyBullet:FlxSprite = bullets.recycle();
		enemyBullet.x = this.x;
		enemyBullet.y = this.y;
		enemyBullet.angle = enemyProjectileAngle;

		var speed = 300;
		var distance = Math.sqrt((enemyDistX * enemyDistX) + (enemyDistY * enemyDistY));

		enemyBullet.velocity.y = (enemyDistX / distance) * speed;
		enemyBullet.velocity.x = (enemyDistX / distance) * speed;
	}
}
