package;

import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.math.FlxRandom;

class PlayState extends FlxState
{
	//var player:FlxSprite;
	var bullets:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var enemy:FlxSprite;
	var random:FlxRandom;
	override public function create()
	{
		super.create();
		//Generate a new random key
		random = new FlxRandom();

		timer = new FlxTimer();

		//Create the player and add them to the screen
		player = new FlxSprite(FlxG.width/2, FlxG.height/2);
		player.makeGraphic(20,20, FlxColor.WHITE);
		add(player);

		//Create the bullets group
		var numBullets:Int = 10;
		bullets = new FlxTypedGroup(numBullets);

		//Generate the (numBullets) number of bullets off screen
		var sprite:FlxSprite;
		for(i in 0...numBullets){
			sprite = new FlxSprite(-100,-100);
			sprite.makeGraphic(8,2);
			sprite.exists = false;
			bullets.add(sprite);
		}
		add(bullets);

		//Create 10 enemies off screen
		enemyHealthBars = new FlxTypedGroup(10);
		enemies = new FlxTypedGroup(10);
		for(i in 0...10){
			enemy = new FlxSprite(-200,-200);
			enemy.makeGraphic(10,10, FlxColor.RED);
			enemy.exists = false;
			enemy.health = 100;

			enemyHealth = new FlxBar(enemy.x,enemy.y,LEFT_TO_RIGHT,100,10,enemy,"health", 0, 100, false);
			enemyHealth.exists = false;
			enemyHealth.killOnEmpty = true;

			enemies.add(enemy);
			enemyHealthBars.add(enemyHealth);

		}
		add(enemies);
	}

	var angle:Float;
	var xDist:Float;
	var yDist:Float;

	override public function update(elapsed:Float)
	{	
		//Calculate y diff and x diff of the mouse and player
		yDist = FlxG.mouse.y - player.y;
		xDist = FlxG.mouse.x - player.x;
		//Calculate the cotangent to find the angle of the mouse relative to the player
		//and then convert it from radians to degrees.
		angle = Std.int(Math.atan(yDist/xDist) * 57.2957795);
		player.angle = angle;

		if(FlxG.keys.justPressed.SPACE){
			//Create a new bullet at the player and point it the same angle of the player
			var bullet:FlxSprite = bullets.recycle();
			bullet.x = player.x;
			bullet.y = player.y;
			bullet.angle = angle;

			//Set the speed of the bullet and normalize the vector to have an even speed
			//and then set the x and y velocities accordingly
			var speed = 500;
			var dist = Math.sqrt((xDist*xDist) + (yDist*yDist));

			bullet.velocity.y =(yDist / dist) * speed;
			bullet.velocity.x =(xDist / dist) * speed;
		}
		
		//Check if the bullets are out of bounds or touching an enemy
		bullets.forEachAlive(outOfBounds);
		FlxG.overlap(bullets, enemies, killEnemies);

		//Respawn a testing enemy
		if(enemies.countLiving() < 1){
			var enemy:FlxSprite = enemies.recycle();
			enemy.x = random.int(10,FlxG.width);
			enemy.y = random.int(10,FlxG.height);
		}
		
		//Respawn an ammo box
		if(ammoBoxes.countLiving() < 1){
			var ammo:FlxSprite = ammoBoxes.recycle();
			ammo.x = random.int(10,FlxG.width);
			ammo.y = random.int(10,FlxG.height);
		}
		//Update the ammo display text
		ammoText.text = "Ammo: " + Std.string(ammoNum);

		//Respawn an ammo box
		if(ammoBoxes.countLiving() < 1){
			var ammo:FlxSprite = ammoBoxes.recycle();
			var spawnID = random.int(0, spawnAmmoX.length-1);
			ammo.x = spawnAmmoX[spawnID];
			ammo.y = spawnAmmoY[spawnID];
		}
		trace(ammoNum);
		super.update(elapsed);
	}

	public function outOfBounds(bullet:FlxObject){
		//If the bullet is out of bounds, kill it
		if(bullet.y < 0 || bullet.y > FlxG.height || bullet.x < 0 || bullet.x > FlxG.width || /*FlxG.collide(bullet, walls)*/){
			bullet.kill();
		}

	}

	public function killEnemies(bullet:FlxObject, e:FlxSprite){
		//If a bullet hits an enemy, kill the bullet and enemy
		bullet.kill();
		e.kill();
	}
}