package;

import haxe.io.Float32Array;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.math.FlxRandom;
import flixel.math.FlxAngle;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;

class PlayState extends FlxState
{
	//Enemy related variables
	var bullets:FlxTypedGroup<FlxSprite>;
	var bullets2:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var bigEnemies:FlxTypedGroup<FlxSprite>;
	var rangedEnemies:FlxTypedGroup<FlxSprite>;
	var enemy:Enemy;
	var enemy2:FlxSprite;
	var rangedEnemy:FlxSprite;
	var spawnEnemyX:Array<Float> = [];
	var spawnEnemyY:Array<Float> = [];
	var spawnEnemyType:Array<Int> = [];
	var rangeX:Array<Float> = [];
	var rangeY:Array<Float> = [];
	var rangeCanFire:Array<Bool> = [];
	var enemyHealthBars:FlxTypedGroup<FlxBar>;
	var enemyHealth:FlxBar;

	var roomID:Int = 0;	
	var random:FlxRandom;
	var ammoNum:Int;
	var ammoBoxes:FlxTypedGroup<FlxSprite>;
	var ammoBox:FlxSprite;
	var spawnAmmoX:Array<Float> = [];
	var spawnAmmoY:Array<Float> = [];
	var player:Player;
	var ammoText:FlxText;
	var pHealthBar:FlxBar;
	var grpWalls:FlxTypedGroup<FlxSprite> = null;
	var timer:FlxTimer;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var doorGroup:FlxTypedGroup<Door>;

	var timerStart:Bool = false;
	var timerStart2:Bool = false;
	var maxTimerCounter:Float = 0.25;
	var moving:Bool = false;
	var attackRan:Int;

	var uiCamera:FlxCamera;
	var hud:HUD;
	var levelText:FlxText;
	override public function create()
	{
		//Change the mouse cursor to a crosshair
		FlxG.mouse.load("assets/images/crosshair.png", 0.075, -8, -10);

		//Load the map data from the Ogmo3 file with the current level data
		map = new FlxOgmo3Loader(AssetPaths.compproject1V2__ogmo, AssetPaths.map00__json);

		//Show the hitboxes of game objects
		//FlxG.debugger.drawDebug = true;

		//Load in the tilemap from the tilemap image
		walls = map.loadTilemap(AssetPaths.dungeon_tiles__png, "walls");
		walls.follow();
		//Setting tilemap collision properties
		tilePropertySetting(walls);
		add(walls);
		//Generate a new random key
		random = new FlxRandom();

		//Create a new timer
		timer = new FlxTimer();

		//Create the player and add them to the screen
		player = new Player(FlxG.width/2, FlxG.height/2);
		player.health = Reg.PLAYERHEALTH;
		add(player);

		//Create the bullets group and set ammo
		ammoNum = Reg.AMMO;
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

		//Doors group
		doorGroup = new FlxTypedGroup();
		add(doorGroup);

		//Generates the enemy's bullets
		bullets2 = new FlxTypedGroup(10);
		for(i in 0...numBullets){
			var enemyBul = new FlxSprite(-100,-100);
			enemyBul.makeGraphic(15, 10, FlxColor.ORANGE);
			enemyBul.exists = false;
			bullets2.add(enemyBul);
		}
		add(bullets2);

		//Create 10 ammo boxes off screen
		ammoBoxes = new FlxTypedGroup(10);
		add(ammoBoxes);

		//Entity Placement
		map.loadEntities(placeEntities, "entities");
		spawnEnemies();
		spawnAmmo();

		//Make the camera follow the player and overlay the HUD
		FlxG.camera.setSize(320, 240);
		FlxG.game.scaleX = 2;
		FlxG.game.scaleY = 2;
		FlxG.camera.follow(player, TOPDOWN, 1);
		hud = new HUD(player);
		add(hud);

		super.create();
	}

	var angle:Float;
	var xDist:Float;
	var yDist:Float;
	var enemyDistX:Float;
	var enemyDistY:Float;
	var enemyAngle:Int;
	//calculates the enemies projectiles
	var enemyProjectileDistX:Float;
	var enemyProjectileDistY:Float;
	var enemyProjectileAngle:Float;
	var rangedX:Array<Float>;
	var rangedY:Array<Float>;
	override public function update(elapsed:Float)
	{	
		//Calculate the angle of the mouse relative to the player
		angle = FlxAngle.angleBetweenMouse(player, true);

		//Player & enemy collisions with the tilemap walls
		FlxG.collide(player, walls);
		FlxG.collide(enemies, walls);
		FlxG.collide(bigEnemies, walls);

		//Player overlay detection for doors
		FlxG.overlap(player, doorGroup, onEncounterDoor);

		if(FlxG.mouse.justPressed && ammoNum > 0){
			//Create a new bullet at the player and point it the same angle of the player
			ammoNum--;
			Reg.AMMO = ammoNum;
			
			//Calculate y diff and x diff of the mouse and player
			yDist = FlxG.mouse.y - player.y;
			xDist = FlxG.mouse.x - player.x;
			
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
		FlxG.overlap(bullets, bigEnemies, killEnemies);
		FlxG.overlap(bullets, rangedEnemies, killEnemies);

		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);

		//Check if player is touching an enemy
		FlxG.overlap(player, enemies, hurtPlayer);
		FlxG.overlap(player, bigEnemies, hurtPlayer);

		//Update the ammo display text
		hud.updateHUD(ammoNum);
		
		//Start the timer for shooting
		if(timerStart2 == false){
			shootTimer(new FlxTimer());
		}

		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);

		//Check if player is hit by enemy bullet
		FlxG.overlap(player, bullets2, hurtPlayerRanged);

		super.update(elapsed);
	}

	public function outOfBounds(bullet:FlxObject){
		//If the bullet is out of bounds, kill it
		if(bullet.y < 0 || bullet.y > FlxG.stage.height || bullet.x < 0 || bullet.x > FlxG.stage.width){
			bullet.kill();
		}
	}

	public function killEnemies(bullet:FlxObject, e:FlxSprite){
		//If a bullet hits an enemy, kill the bullet and enemy
		bullet.kill();
		
		//Decrease enemy health, and kill if they have no health
		e.health-=25;
		if(e.health<=0){
			e.kill();
			Reg.ENEMIES[roomID]--;
		}

		//Check if position matches any of the ranged spots
		if(rangeCanFire.length > 0){
			for(i in 0...(rangeCanFire.length)){
				if((rangeX[i]-0.5) <= e.x && e.x <= (rangeX[i]+0.5)){
					if((rangeY[i]-0.5) <= e.y && e.y <= (rangeY[i]+0.5)){
						//Make sure that ranged enemy cannot shoot again
						rangeCanFire[i] = false;
					}
				}
			}
		}
	}

	public function hurtPlayer(p:Player, e:FlxObject){
		//Flash the camera so the player knows they were hit
		FlxG.camera.flash(FlxColor.WHITE,1);
		//Make the player and enemy knockback from each other
		FlxG.collide(p,e);
		//If they were not already just hit, subtract health and check if they should be killed
		if(!FlxFlicker.isFlickering(p)){
			p.health -=25;
			Reg.PLAYERHEALTH = p.health;
			if(p.health<=0){
				p.kill();
			}
		}
		//Flicker the Player sprite to give player "immunity" for a frew seconds
		FlxFlicker.flicker(p); 
	}

	public function hurtPlayerRanged(p:Player, b:FlxObject){
		//Flash the camera so the player knows they were hit
		FlxG.camera.flash(FlxColor.WHITE,1);

		//If they were not already just hit, subtract health and check if they should be killed
		if(!FlxFlicker.isFlickering(p)){
			p.health -=25;
			Reg.PLAYERHEALTH = p.health;
			if(p.health<=0){
				p.kill();
			}
		}

		b.kill();
		//Flicker the Player sprite to give player "immunity" for a frew seconds
		FlxFlicker.flicker(p);
	}

	public function addAmmo(ammo:FlxObject, p:FlxSprite){
		//If the player touches an ammo box, kill it and increase their ammo by 5
		ammo.kill();
		ammoNum+=5;
		Reg.AMMO = ammoNum;
	}

	public function destroyBullets(b:FlxSprite, w:FlxTilemap){
		//Destroy the bullet
		b.kill();
	}

	public function spawnEnemies(){
		//Create enemy group and enemy health bar group
		enemyHealthBars = new FlxTypedGroup(spawnEnemyX.length);
		enemies = new FlxTypedGroup(spawnEnemyX.length);
		bigEnemies = new FlxTypedGroup(spawnEnemyX.length);
		rangedEnemies = new FlxTypedGroup(spawnEnemyX.length);
		add(enemies);
		add(bigEnemies);
		add(rangedEnemies);
		add(enemyHealthBars);

		//Check if there are enemies to spawn from registry
		if(Reg.ENEMIES[roomID] != 0){
			//Check to see if we have less enemies killed in this room already
			var spawnAmount:Int = (Reg.ENEMIES[roomID] < spawnEnemyX.length) ? Reg.ENEMIES[roomID] : spawnEnemyX.length;
			Reg.ENEMIES[roomID] = spawnAmount;

			//Create as many enemies and health bars as there are spawning locations
			for(i in 0...(spawnAmount)){
				//Check which enemy type the spawner is
				switch(spawnEnemyType[i]){
					//Normal Enemies
					case 0:
						enemy = new Enemy(-200,-200, player, 20);
						enemy.makeGraphic(10,10, FlxColor.RED);
						enemy.exists = true;
						enemy.health = 100;
						enemies.add(enemy);
					//Ranged Enemies
					case 1:
						enemy = new Enemy(-200,-200, player, 0);
						enemy.makeGraphic(10,10, FlxColor.YELLOW);
						enemy.exists = true;
						enemy.health = 20;
						rangedEnemies.add(enemy);
						rangeX.push(spawnEnemyX[i]);
						rangeY.push(spawnEnemyY[i]);
						rangeCanFire.push(true);
					//Large Enemies
					case 2:
						enemy = new Enemy(-200,-200, player, 10);
						enemy.makeGraphic(40,40, FlxColor.GREEN);
						enemy.exists = true;
						enemy.health = 240;
						bigEnemies.add(enemy);
						
				}

				enemyHealth = new FlxBar(enemy.x,enemy.y,LEFT_TO_RIGHT,100,10,enemy,"health", 0, enemy.health, false);
				enemyHealth.exists = true;
				enemyHealth.killOnEmpty = true;

				//Set the enemy health bar to follow the enemy we just spawned
				enemyHealth.setParent(enemy, "health", true, Std.int(enemyHealth.width/2 - enemy.width/2) * -1 , -12);

				//enemies.add(enemy);
				enemyHealthBars.add(enemyHealth);

				//Set enemy to the i spawn location
				enemy.x = spawnEnemyX[i];
				enemy.y = spawnEnemyY[i];
			}
		}
	}

	public function spawnAmmo(){
		//Create ammo box group
		ammoBoxes = new FlxTypedGroup(spawnAmmoX.length);
		add(ammoBoxes);
		//Create as many ammo boxes as there are spawning locations
		for(i in 0...spawnAmmoX.length){
			ammoBox = new FlxSprite(-200,-200);
			ammoBox.makeGraphic(10,10, FlxColor.BLUE);
			ammoBox.exists = true;
			ammoBoxes.add(ammoBox);

			//Set the ammo box to the i spawn location
			ammoBox.x = spawnAmmoX[i];
			ammoBox.y = spawnAmmoY[i];
		}
		
	}

	public function deleteEnemyBullet(b:FlxObject, p:FlxSprite){
		b.kill();
	}

	//timers for the enemies to shoot
	function shootTimer(Timer:FlxTimer) : Void{
		timerStart2 = true;
		Timer.start(2, shootTimerStop);
	}
	function shootTimerStop(Timer:FlxTimer) : Void{
		//Check if there are any range enemies that can fire
		if(rangeX.length > 0){
			for(i in 0...rangeX.length){
				if(rangeCanFire[i]){
					//Create a bullet that will shoot towards the player
					enemyProjectileDistX = player.x - rangeX[i];
					enemyProjectileDistY = player.y - rangeY[i];

					var enemyBullet:FlxSprite = bullets2.recycle();
					enemyProjectileAngle= Std.int(Math.atan(enemyProjectileDistY/enemyProjectileDistX) * 57.2957795);
					
					enemyBullet.x = rangeX[i];
					enemyBullet.y = rangeY[i];
					enemyBullet.angle = enemyProjectileAngle;
					var speed = 200;
					var distance = Math.sqrt((enemyProjectileDistX * enemyProjectileDistX) + (enemyProjectileDistY * enemyProjectileDistY));
					enemyBullet.velocity.y = (enemyProjectileDistY / distance) * speed;
					enemyBullet.velocity.x = (enemyProjectileDistX / distance) * speed;
				}
			}
		}
		timerStart2 = false;
	}

	//Function to place entities that were on the entity layer in the Ogmo file
	public function placeEntities(entity:EntityData){
		//Entity switch cases
		switch(entity.name){
			//Positioning a player entity
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
				spawnEnemyType.push(entity.values.enemyType);
			case "ammoSpawn":
				spawnAmmoX.push(entity.x);
				spawnAmmoY.push(entity.y);
		}
		
	}

	//Function to call when the player encounters a door
	public function onEncounterDoor(player:Dynamic, door:Dynamic){
		//Set entrance value
		Reg.ENTRY = door.stateEntranceID;

		//Determines which state to go to
		switch(door.stateDestID){
			case 0:
				FlxG.switchState(new PlayState());
			case 1:
				FlxG.switchState(new Room01());
			case 2:
				FlxG.switchState(new Room02());
			case 3:
				FlxG.switchState(new Room03());
			case 4:
				FlxG.switchState(new Room04());
			case 5:
				FlxG.switchState(new Room05());
		}
	}

	//Function to call for setting tile properties
	public function tilePropertySetting(theTilemap:FlxTilemap){
		//For anything that doesn't have a tile, make it a wall in any direction
		theTilemap.setTileProperties(0, ANY);

		//Default everything else to have no collision
		for(i in 1...552){
			theTilemap.setTileProperties(i, NONE);
		}

		//Setting things to not be able to collide in any direction
		var anyTiles:Array<Int> = [116,117,118,119,120, 185,186,187, 208,209,210, 138,139,140, 231,232,233, 369,370,371, 13,14,15,16,17,18, 36,37,38,39,40,41, 58,59,60,61,62,63,64,65,66, 82,83,84,85,86,87, 105,106,107,108,109,110, 128,129,130,131,132,133];
		for(i in anyTiles){
			theTilemap.setTileProperties(i, ANY);
		}

		//Setting things for the left side
		var leftTiles:Array<Int> = [1, 24, 47, 70, 93];
		for(i in leftTiles){
			theTilemap.setTileProperties(i, LEFT);
		}

		//Setting things for the right side
		var rightTiles:Array<Int> = [5, 28, 51, 74, 97];
		for(i in rightTiles){
			theTilemap.setTileProperties(i, RIGHT);
		}
	}
}