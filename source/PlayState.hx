package;

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
import flixel.tile.FlxTilemap;
import flixel.util.FlxTimer;

class PlayState extends FlxState
{
	//var player:FlxSprite;
	var bullets:FlxTypedGroup<FlxSprite>;
	var enemies:FlxTypedGroup<FlxSprite>;
	var enemy:FlxSprite;
	var enemy2:FlxSprite;
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
  var uiCamera:FlxCamera;
	var hud:HUD;
	var levelText:FlxText;

	override public function create()
	{		
    //Change the mouse cursor to a crosshair
		FlxG.mouse.load("assets/images/crosshair.png", 0.12, -18, -18);

	  var timerStart:Bool = false;
	  var maxTimerCounter:Float = 0.25;
    
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

		//Create a new timer
		timer = new FlxTimer();

		//Create the player and add them to the screen
		player = new Player(FlxG.width/2, FlxG.height/2);
		player.health = 100;
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

		//Create 10 enemies off screen
		enemies = new FlxTypedGroup(10);
		for(i in 0...10){
			enemy = new FlxSprite(-200,-200);
			enemy.makeGraphic(10,10, FlxColor.RED);
			enemy.exists = false;
			enemies.add(enemy);
			enemy2 = new FlxSprite(-200,-200);
			enemy2.makeGraphic(40,40, FlxColor.GREEN);
			enemy2.exists = false;
			enemies.add(enemy2);
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

		FlxG.overlap(bullets, enemies, killEnemies); 

		//Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);
		//Check if player is touching an enemy
		FlxG.overlap(player, enemies, hurtPlayer);
		//Check if bullets are touching walls
		FlxG.collide(bullets, walls, destroyBullets);

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
	}
	
	//controls the basic movement of the enemy towards the player
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
	
	//timers used so that ais only change direction every 1/4th of a second
	function timerFunction(Timer:FlxTimer) : Void{
			timerStart = true;
			Timer.start(0.25, timerStop);
	}
	function timerStop(Timer:FlxTimer) : Void{
		timerStart = false;
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
		//Create as many enemies and health bars as there are spawning locations
		for(i in 0...(spawnEnemyX.length)){
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