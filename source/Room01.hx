package;

import flixel.math.FlxPoint;
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

class Room01 extends FlxState
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
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var doorGroup:FlxTypedGroup<Door>;

	var spawnEnemyX:Array<Float> = [];
	var spawnEnemyY:Array<Float> = [];
	var spawnAmmoX:Array<Float> = [];
	var spawnAmmoY:Array<Float> = [];

	override public function create()
	{		
		//Load the map data from the Ogmo3 file with the current level data
		map = new FlxOgmo3Loader(AssetPaths.compproject1V2__ogmo, AssetPaths.map01__json);

		//Show the hitboxes of game objects
		FlxG.debugger.drawDebug = true;

		//Load in the tilemap from the tilemap image
		walls = map.loadTilemap(AssetPaths.dungeon_tiles__png, "walls");
		walls.follow();
		//Setting tilemap collision properties
		tilePropertySetting(walls);
		add(walls);

		//Generate a new random key
		random = new FlxRandom();

		//Create the player and add them to the screen
		player = new Player(FlxG.width/2, FlxG.height/2);
		add(player);

		//Change Camera
		FlxG.camera.follow(player, TOPDOWN);

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

		//Create 10 enemies off screen
		enemies = new FlxTypedGroup(10);
		for(i in 0...10){
			enemy = new FlxSprite(-200,-200);
			enemy.makeGraphic(10,10, FlxColor.RED);
			enemy.exists = false;
			enemies.add(enemy);
		}
		add(enemies);
		
		//Create 10 ammo boxes off screen
		ammoBoxes = new FlxTypedGroup(10);
		for(i in 0...10){
			ammoBox = new FlxSprite(-200,-200);
			ammoBox.makeGraphic(10,10, FlxColor.BLUE);
			ammoBox.exists = false;
			ammoBoxes.add(ammoBox);
		}
		add(ammoBoxes);

		//Doors group
		doorGroup = new FlxTypedGroup();
		add(doorGroup);

		//Entity Placement
		map.loadEntities(placeEntities, "entities");

		super.create();
	}

	var angle:Int;
	var xDist:Float;
	var yDist:Float;
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
		FlxG.overlap(bullets, enemies, killEnemies);
		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);

		//Respawn a testing enemy
		if(enemies.countLiving() < 1){
			var enemy:FlxSprite = enemies.recycle();
			var spawnID = random.int(0, spawnEnemyX.length-1);
			enemy.x = spawnEnemyX[spawnID];
			enemy.y = spawnEnemyY[spawnID];
		}

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
		if(bullet.y < 0 || bullet.y > FlxG.stage.width || bullet.x < 0 || bullet.x > FlxG.stage.width){
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
			case 1:
				FlxG.switchState(new Room01());
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
		var anyTiles:Array<Int> = [116,117,118,119,120,231,232,233,369,370,371, 14,15,16,17,18,19, 38,39,40,41,42,43, 62,63,64,65,66,67];
		for(i in anyTiles){
			theTilemap.setTileProperties(i, ANY);
		}
	}
}
