package;

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
	override public function create()
	{
		FlxG.mouse.load("assets/images/crosshair.png", 0.12, -18, -18);

		

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

		timer = new FlxTimer();

		//Create the player and add them to the screen
		player = new Player(FlxG.width/2, FlxG.height/2);
		player.health = 100;
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

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
		add(enemyHealthBars);

		//Create 10 ammo boxes off screen
		ammoBoxes = new FlxTypedGroup(10);
		for(i in 0...10){
			ammoBox = new FlxSprite(-200,-200);
			ammoBox.makeGraphic(10,10, FlxColor.BLUE);
			ammoBox.exists = false;
			ammoBoxes.add(ammoBox);
		}
		add(ammoBoxes);

		//Ammo display
		ammoText = new FlxText(0,FlxG.height-24,FlxG.width, "Ammo: " + ammoNum, 16);
		ammoText.setFormat(null,16,FlxColor.WHITE,FlxTextAlign.LEFT);
		add(ammoText);

		pHealthBar = new FlxBar(FlxG.width - 210, FlxG.height -24,LEFT_TO_RIGHT,200,20,player,"health", 0, 100, false);
		add(pHealthBar);

		//Entity Placement
		map.loadEntities(placeEntities, "entities");

		super.create();
	}

	var angle:Float;
	var xDist:Float;
	var yDist:Float;

	override public function update(elapsed:Float)
	{	
		
		
		//Calculate the cotangent to find the angle of the mouse relative to the player
		//and then convert it from radians to degrees.
		angle = FlxAngle.angleBetweenMouse(player, true);

		//Player collisions with the tilemap walls
		FlxG.collide(player, walls);

		if(FlxG.mouse.justPressed && ammoNum > 0){
			//Create a new bullet at the player and point it the same angle of the player
			ammoNum--;
			
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
		//bullets.forEachAlive(outOfBounds);
		FlxG.overlap(bullets, enemies, killEnemies);
		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);
		
		FlxG.overlap(player, enemies, hurtPlayer);
		
		//Respawn a testing enemy
		if(enemies.countLiving() < 1){
			var enemy:FlxSprite = enemies.recycle();
			var eHealth:FlxBar = enemyHealthBars.recycle();

			//enemy.x = random.int(10,FlxG.width);
			//enemy.y = random.int(10,FlxG.height);

			//Set the enemy health bar to follow the enemy we just spawned
			eHealth.setParent(enemy, "health", true, Std.int(eHealth.width/2 - enemy.width/2) * -1 , -12);

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
		//Update the ammo display text
		ammoText.text = "Ammo: " + Std.string(ammoNum);

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
		trace(e.health);
		
		//
		e.health-=25;
		if(e.health<=0){
			e.kill();
		}
	}

	public function hurtPlayer(p:Player, e:FlxObject){
		trace(p.health);
		FlxG.camera.flash(FlxColor.WHITE,1);
		
		FlxG.collide(p,e);
		if(!FlxFlicker.isFlickering(p)){
			p.health -=25;
			if(p.health<=0){
				p.kill();
			}
		}
		FlxFlicker.flicker(p); 
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
					//var doorTemp = new Door(entity.values.stateDestID, entity.values.destEntrID);
					//Set its position
					//doorTemp.setPosition(entity.x+4, entity.y+4);
					//Add it to the door group
					//doorGroup.add(doorTemp);
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