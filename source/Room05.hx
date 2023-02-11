package;

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

class Room05 extends FlxState
{
	//var player:FlxSprite;
	var bullets:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var enemy:FlxSprite;
	var random:FlxRandom;
	var ammoNum:Int;
	var ammoBoxes:FlxTypedGroup<FlxSprite>;
	var ammoBox:FlxSprite;
	var player:Player;
	var ammoText:FlxText;
	var pHealthBar:FlxBar;
	var enemyHealthBars:FlxTypedGroup<FlxBar>;
	var enemyHealth:FlxBar;
	var grpWalls:FlxTypedGroup<FlxSprite> = null;
	var timer:FlxTimer;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var doorGroup:FlxTypedGroup<Door>;

	var spawnEnemyX:Array<Float> = [];
	var spawnEnemyY:Array<Float> = [];
	var spawnAmmoX:Array<Float> = [];
	var spawnAmmoY:Array<Float> = [];
	var roomID:Int = 5;

	var uiCamera:FlxCamera;
	var hud:HUD;
	var levelText:FlxText;
	override public function create()
	{
		//Change the mouse cursor to a crosshair
		FlxG.mouse.load("assets/images/crosshair.png", 0.12, -18, -18);

		//Load the map data from the Ogmo3 file with the current level data
		map = new FlxOgmo3Loader(AssetPaths.compproject1V2__ogmo, AssetPaths.map05__json);

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

		//Entity Placement
		map.loadEntities(placeEntities, "entities");
		spawnEnemies();
		spawnAmmo();

		//Make the camera follow the player and overlay the HUD
		FlxG.camera.follow(player, TOPDOWN, 1);
		hud = new HUD(player);
		add(hud);

		super.create();
	}

	var angle:Float;
	var xDist:Float;
	var yDist:Float;

	override public function update(elapsed:Float)
	{	
		//Calculate the angle of the mouse relative to the player
		angle = FlxAngle.angleBetweenMouse(player, true);

		//Player collisions with the tilemap walls
		FlxG.collide(player, walls);
		FlxG.collide(enemies, walls);

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
		FlxG.overlap(bullets, enemies, killEnemies); 
		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);
		//Check if player is touching an enemy
		FlxG.overlap(player, enemies, hurtPlayer);
		//Check if bullets are touching walls
		//FlxG.collide(bullets, walls, destroyBullets);

		//Update the ammo display text
		hud.updateHUD(ammoNum);

		super.update(elapsed);
	}

	public function outOfBounds(bullet:FlxObject){
		//If the bullet is out of bounds, kill it
		if(bullet.y < 0 || bullet.y > FlxG.height || bullet.x < 0 || bullet.x > FlxG.width){
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

		add(enemies);
		add(enemyHealthBars);
		//If there are enemies to spawn from registry
		if(Reg.ENEMIES[roomID] != 0){
			//Check to see if we have less enemies killed in this room already
			var spawnAmount:Int = (Reg.ENEMIES[roomID] < spawnEnemyX.length) ? Reg.ENEMIES[roomID] : spawnEnemyX.length;
			Reg.ENEMIES[roomID] = spawnAmount;

			//Create as many enemies and health bars as there are spawning locations
			for(i in 0...(spawnAmount)){
				enemy = new FlxSprite(-200,-200);
				enemy.makeGraphic(10,10, FlxColor.RED);
				enemy.exists = true;
				enemy.health = 100;

				enemyHealth = new FlxBar(enemy.x,enemy.y,LEFT_TO_RIGHT,100,10,enemy,"health", 0, 100, false);
				enemyHealth.exists = true;
				enemyHealth.killOnEmpty = true;

				//Set the enemy health bar to follow the enemy we just spawned
				enemyHealth.setParent(enemy, "health", true, Std.int(enemyHealth.width/2 - enemy.width/2) * -1 , -12);

				enemies.add(enemy);
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
		var anyTiles:Array<Int> = [116,117,118,119,120, 185,186,187, 208,209,210, 231,232,233, 369,370,371, 13,14,15,16,17,18, 37,38,39,40,41,42, 61,62,63,64,65,66];
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