package;

import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

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
		var enemyDistX:Float = this.x - target.x;
		var enemyDistY:Float = this.y - target.y;

		var enemyDist = Math.sqrt((enemyDistX * enemyDistX) + (enemyDistY * enemyDistY));
		velocity.y = (enemyDistY / enemyDist) * -speed;
		velocity.x = (enemyDistX / enemyDist) * -speed;
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
