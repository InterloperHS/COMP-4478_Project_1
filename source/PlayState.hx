package;

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
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	//var player:FlxSprite;
	var bullets:FlxTypedGroup<FlxSprite>;
	var bullets2:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var enemies2:FlxTypedGroup<FlxSprite>;
	var enemies3:FlxTypedGroup<FlxSprite>;
	var enemy:FlxSprite;
	var enemy2:FlxSprite;
	var rangedEnemy:FlxSprite;
	var random:FlxRandom;
	var ammoNum:Int;
	var ammoBoxes:FlxTypedGroup<FlxSprite>;
	var ammoBox:FlxSprite;
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var doorGroup:FlxTypedGroup<Door>;
	var spawnEnemyX:Array<Float> = [];
	var spawnEnemyY:Array<Float> = [];
	var spawnAmmoX:Array<Float> = [];
	var spawnAmmoY:Array<Float> = [];
	var timerStart:Bool = false;
	var timerStart2:Bool = false;
	var moving:Bool = false;
	var attackRan:Int;

	override public function create()
	{		

		//Load the map data from the Ogmo3 file with the current level data
		map = new FlxOgmo3Loader(AssetPaths.compproject1__ogmo, AssetPaths.map001__json);

		//Load in the tilemap from the tilemap image
		walls = map.loadTilemap(AssetPaths.temptiles__png, "walls");
		walls.follow();
		//Set the behaviour of each tile in the tilemap
		walls.setTileProperties(1, NONE); //Floor, no collison
		walls.setTileProperties(2, ANY); //Wall in any direction
		walls.setTileProperties(3, NONE); //Door
		add(walls);

		//Generate a new random key
		random = new FlxRandom();

		//Create the player and add them to the screen
		player = new Player(FlxG.width/2, FlxG.height/2);
		add(player);

		//Create the bullets group and set ammo
		ammoNum = 20;
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

		//generates the enemies bullets for the ranged enemies
		var sprite2:FlxSprite;
		var numBullets2:Int = 10;
		bullets2 = new FlxTypedGroup(numBullets2);
		for(i in 0...numBullets2){
			sprite2 = new FlxSprite(-100,-100);
			sprite2.makeGraphic(15, 10, FlxColor.ORANGE);
			sprite2.exists = false;
			bullets2.add(sprite2);
		}
		add(bullets2);
		//Create 10 enemies off screen
		enemies = new FlxTypedGroup(10);
		for(i in 0...10){
			enemy = new FlxSprite(-200,-200);
			enemy.makeGraphic(10,10, FlxColor.RED);
			enemy.exists = false;
			enemies.add(enemy);
		}
		//create 10 large enemies
		add(enemies);
		enemies2 = new FlxTypedGroup(10);
		for(i in 0...10){
			enemy2 = new FlxSprite(-200,-200);
			enemy2.makeGraphic(40,40, FlxColor.GREEN);
			enemy2.exists = false;
			enemies2.add(enemy2);
		}
		//create 10 ranged enemies
		add(enemies2);
		enemies3 = new FlxTypedGroup(10);
		for(i in 0...10){
			rangedEnemy = new FlxSprite(-200,-200);
			rangedEnemy.makeGraphic(10,10, FlxColor.YELLOW);
			rangedEnemy.exists = false;
			enemies3.add(rangedEnemy);
		}
		add(enemies3);

		
		//Create 10 ammo boxes off screen
		ammoBoxes = new FlxTypedGroup(10);
		for(i in 0...10){
			ammoBox = new FlxSprite(-200,-200);
			ammoBox.makeGraphic(10,10, FlxColor.BLUE);
			ammoBox.exists = false;
			ammoBoxes.add(ammoBox);
		}
		add(ammoBoxes);

		//Entity Placement
		map.loadEntities(placeEntities, "entities");

		super.create();
	}

	var angle:Int;
	var xDist:Float;
	var yDist:Float;
	var enemyDistX:Float;
	var enemyDistY:Float;
	var enemyAngle:Int;
	override public function update(elapsed:Float)
	{	

		//Calculate y diff and x diff of the mouse and player
		yDist = FlxG.mouse.y - player.y;
		xDist = FlxG.mouse.x - player.x;
		//Calculate the cotangent to find the angle of the mouse relative to the player
		//and then convert it from radians to degrees.
		angle= Std.int(Math.atan(yDist/xDist) * 57.2957795);
		player.angle = angle;

		//Player collisions with the tilemap walls
		FlxG.collide(player, walls);
		FlxG.collide(enemy, walls);
		FlxG.collide(enemy2, walls);


		//Player overlay detection for doors
		FlxG.overlap(player, doorGroup, onEncounterDoor);

		if(FlxG.keys.justPressed.SPACE && ammoNum > 0){
			//Create a new bullet at the player and point it the same angle of the player
			ammoNum--;
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
		bullets2.forEachAlive(outOfBounds);
		FlxG.overlap(bullets, enemies, killEnemies);
		FlxG.overlap(bullets, enemies2, killEnemies);
		FlxG.overlap(bullets, enemies3, killEnemies);
		FlxG.overlap(bullets2, player, deleteEnemyBullet);
		if(timerStart == false){
			enemyMovement(enemy, player, 50);
			enemyMovement(enemy2, player, 25);
			timerFunction(new FlxTimer());
		}

		//calculates the enemies projectiles
		var enemyProjectileDistX:Float;
		var enemyProjectileDistY:Float;
		var enemyProjectileAngle:Float;
		if(timerStart2 == false){
			enemyProjectileDistX = player.x - rangedEnemy.x;
			enemyProjectileDistY = player.y - rangedEnemy.y;

			enemyProjectileAngle= Std.int(Math.atan(enemyProjectileDistY/enemyProjectileDistX) * 57.2957795);
			rangedEnemy.angle = enemyProjectileAngle;

			var enemyBullet:FlxSprite = bullets2.recycle();
			enemyBullet.x = rangedEnemy.x;
			enemyBullet.y = rangedEnemy.y;
			enemyBullet.angle = enemyProjectileAngle;

			var speed = 300;
			var distance = Math.sqrt((enemyProjectileDistX * enemyProjectileDistX) + (enemyProjectileDistY * enemyProjectileDistY));

			enemyBullet.velocity.y = (enemyProjectileDistY / distance) * speed;
			enemyBullet.velocity.x = (enemyProjectileDistX / distance) * speed;

			
			shootTimer(new FlxTimer());
		}
		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);
		FlxG.overlap(bullets2, player, addAmmo);

		//Respawn a testing enemy
		if(enemies.countLiving() < 1){
			enemy = enemies.recycle();
			var spawnID = random.int(0, spawnEnemyX.length-1);
			enemy.x = spawnEnemyX[spawnID];
			enemy.y = spawnEnemyY[spawnID];
		}
		if(enemies2.countLiving() < 1){
			enemy2 = enemies2.recycle();
			var spawnID = random.int(0, spawnEnemyX.length-1);
			enemy2.x = spawnEnemyX[spawnID];
			enemy2.y = spawnEnemyY[spawnID];
		}
		if(enemies3.countLiving() < 1){
			rangedEnemy = enemies3.recycle();
			var spawnID = random.int(0, spawnEnemyX.length-1);
			rangedEnemy.x = spawnEnemyX[spawnID];
			rangedEnemy.y = spawnEnemyY[spawnID];
		}
		//Respawn an ammo box
		if(ammoBoxes.countLiving() < 1){
			var ammo:FlxSprite = ammoBoxes.recycle();
			var spawnID = random.int(0, spawnAmmoX.length-1);
			ammo.x = spawnAmmoX[spawnID];
			ammo.y = spawnAmmoY[spawnID];
		}
		//trace(ammoNum);

		super.update(elapsed);
	}

	public function outOfBounds(bullet:FlxObject){
		//If the bullet is out of bounds, kill it
		if(bullet.y < 0 || bullet.y > FlxG.height || bullet.x < 0 || bullet.x > FlxG.width || FlxG.collide(bullet, walls)){
			bullet.kill();
		}

	}

	public function killEnemies(bullet:FlxObject, e:FlxSprite){
		//If a bullet hits an enemy, kill the bullet and enemy
		bullet.kill();
		e.kill();
	}

	public function addAmmo(ammo:FlxObject, p:FlxSprite){
		//If the player touches an ammo box, kill it and increase their ammo by 5
		ammo.kill();
		ammoNum+=5;
	}

	public function deleteEnemyBullet(b:FlxObject, p:FlxSprite){
		b.kill();
	}

	//calculates where the enemy should move
	public function enemyMovement(e:FlxSprite, p:FlxSprite, speed:Float){
			if(e.x != p.x && e.y != p.y && timerStart == false){
				timerStart = false;
				enemyDistX = e.x - p.x;
				enemyDistY = e.y - p.y;
				enemyAngle = Std.int(Math.atan(enemyDistX/enemyDistY) * 57.2957795);
				e.angle = angle;
				var enemyDist = Math.sqrt((enemyDistX*enemyDistX) + (enemyDistY*enemyDistY));
				e.velocity.y = (enemyDistY / enemyDist) * -speed;
				e.velocity.x = (enemyDistX / enemyDist) * -speed;
			}
	}

	//timers for the basic movement
	function timerFunction(Timer:FlxTimer) : Void{
			timerStart = true;
			Timer.start(0.25, timerStop);
	}
	function timerStop(Timer:FlxTimer) : Void{
		timerStart = false;
	}

	//timers for the enemies to shoot
	function shootTimer(Timer:FlxTimer) : Void{
			timerStart2 = true;
			Timer.start(2, shootTimerStop);
	}
	function shootTimerStop(Timer:FlxTimer) : Void{
		timerStart2 = false;
	}

	//Function to place entities that were on the entity layer in the Ogmo file
	public function placeEntities(entity:EntityData){
		//Entity switch cases
		switch(entity.name){
			//Positioning a player entity
			case "player":
				//Player placement to default location
				player.setPosition(entity.x+4, entity.y+4);
			case "playerSpawnLocation":
				//Spawn player elsewhere if ENTRY is not 0
				//This will occur if the player entered a door
				//It's expected to be near a door
				if (entity.values.entranceID == Reg.ENTRY){
					player.setPosition(entity.x+4, entity.y+4);
				}
			case "door":
				//Spawn a door that will have the destination ID and entrance ID
				var doorTemp = new Door(entity.values.stateDestID, entity.values.destEntrID);
				//Set its position
				doorTemp.setPosition(entity.x+4, entity.y+4);
				//Add it to the door group
				doorGroup.add(doorTemp);
			case "enemySpawn":
				//Push the x and y coords of each enemy spawn location to their arrays
				spawnEnemyX.push(entity.x);
				spawnEnemyY.push(entity.y);
			case "ammoSpawn":
				spawnAmmoX.push(entity.x);
				spawnAmmoY.push(entity.y);
			//default:
		}
	}

	//Function to call when the player encounters a door
	public function onEncounterDoor(player:Dynamic, door:Dynamic){
		//Set entrance value
		Reg.ENTRY = door.stateEntranceID;

		//Determines which state to go to
		switch(door.stateDestID){
			case 2:
				//FlxG.switchState(new Room002());
			case 3:
				//FlxG.switchState(new Room003());
		}
	}
}
