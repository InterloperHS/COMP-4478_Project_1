package;

import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.util.FlxTimer;
import flixel.ui.FlxBar;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.math.FlxRandom;
import flixel.math.FlxAngle;
import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.system.FlxSound;

class Room extends FlxState {
	// Enemy related variables
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

	var roomID:Int;
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

	var helpButton:FlxButton;
	var pauseButton:FlxButton;
	var uiCamera:FlxCamera;
	var hud:HUD;
	var levelText:FlxText;

	var angle:Float;
	var xDist:Float;
	var yDist:Float;
	var enemyDistX:Float;
	var enemyDistY:Float;
	var enemyAngle:Int;
	// calculates the enemies projectiles
	var enemyProjectileDistX:Float;
	var enemyProjectileDistY:Float;
	var enemyProjectileAngle:Float;
	var rangedX:Array<Float>;
	var rangedY:Array<Float>;

	var enemyHurtSound:FlxSound;
	var enemyKillSound:FlxSound;
	var enemyShootSound:FlxSound;
	var playerShootSound:FlxSound;
	var playerHurtSound:FlxSound;
	var ammoSound:FlxSound;
	var doorSound:FlxSound;
	var ambientCaveMusic:FlxSound;

	override public function new(roomID:Int, mapPath:String) {
		this.roomID = roomID;
		// Load the map data from the Ogmo3 file with the current level data
		this.map = new FlxOgmo3Loader(AssetPaths.compproject1V2__ogmo, mapPath);
		super();
	}

	override public function create() {
		// Change the mouse cursor to a crosshair
		FlxG.mouse.load("assets/images/crosshair.png", 0.12, -18, -18);

		// Show the hitboxes of game objects
		// FlxG.debugger.drawDebug = true;

		// Load in the tilemap from the tilemap image
		walls = map.loadTilemap(AssetPaths.dungeon_tiles__png, "walls");
		walls.follow();
		// Setting tilemap collision properties
		tilePropertySetting(walls);
		add(walls);
		// Generate a new random key
		random = new FlxRandom();

		//Load sounds
		enemyHurtSound = FlxG.sound.load(AssetPaths.shoot__wav);
		enemyKillSound = FlxG.sound.load(AssetPaths.kill__wav);
		enemyShootSound = FlxG.sound.load(AssetPaths.enemyshoot__wav);
		playerHurtSound = FlxG.sound.load(AssetPaths.playhurt__wav);
		playerShootSound = FlxG.sound.load(AssetPaths.playshoot__wav);
		ammoSound = FlxG.sound.load(AssetPaths.ammopick__wav);
		
		doorSound = FlxG.sound.load(AssetPaths.enterdoor__wav);
		doorSound.persist = true;

		//Play ambience
		ambientCaveMusic = FlxG.sound.load(AssetPaths.dungeon_air_6983__ogg);
		ambientCaveMusic.play();
		

		// Create a new timer
		timer = new FlxTimer();

		// Create the player and add them to the screen
		player = new Player(FlxG.width / 2, FlxG.height / 2);
		player.health = Reg.PLAYERHEALTH;
		add(player);

		// Create the bullets group and set ammo
		ammoNum = Reg.AMMO;
		var numBullets:Int = 10;
		bullets = new FlxTypedGroup(numBullets);

		// Generate the (numBullets) number of bullets off screen
		var sprite:FlxSprite;
		for (i in 0...numBullets) {
			sprite = new FlxSprite(-100, -100);
			sprite.makeGraphic(8, 2,0xffc88033);
			sprite.exists = false;
			bullets.add(sprite);
		}
		add(bullets);

		// Doors group
		doorGroup = new FlxTypedGroup();
		add(doorGroup);

		// Generates the enemy's bullets
		bullets2 = new FlxTypedGroup(10);
		for (i in 0...numBullets) {
			var enemyBul = new FlxSprite(-100, -100);
			enemyBul.makeGraphic(15, 10, FlxColor.ORANGE);
			enemyBul.exists = false;
			bullets2.add(enemyBul);
		}
		add(bullets2);

		// Create 10 ammo boxes off screen
		ammoBoxes = new FlxTypedGroup(10);
		add(ammoBoxes);

		// Entity Placement
		map.loadEntities(placeEntities, "entities");
		spawnEnemies();
		spawnAmmo();

		// Zoom camera and follow player
		FlxG.camera.zoom = 2;
		FlxG.camera.follow(player, TOPDOWN_TIGHT, 1);

		// Help button to show controls
		helpButton = new FlxButton(0, 0, null, function() {
			openSubState(new HelpState(0x6703378B));
		});
		helpButton.loadGraphic(AssetPaths.help_question__png, true, 16, 16);
		helpButton.setGraphicSize(Std.int(32 / FlxG.camera.zoom), Std.int(32 / FlxG.camera.zoom));
		helpButton.updateHitbox();
		helpButton.setPosition(FlxG.camera.viewRight - helpButton.width - 16 / FlxG.camera.zoom, FlxG.camera.viewTop + 16 / FlxG.camera.zoom);
		add(helpButton);

		// Pause button to pause the game
		pauseButton = new FlxButton(0, 0, null, function() {
			openSubState(new PauseState(0x6703378B));
		});
		pauseButton.loadGraphic(AssetPaths.pause_button__png, true, 16, 16);
		pauseButton.setGraphicSize(Std.int(32 / FlxG.camera.zoom), Std.int(32 / FlxG.camera.zoom));
		pauseButton.updateHitbox();
		pauseButton.setPosition(helpButton.x, helpButton.y + helpButton.height);
		add(pauseButton);

		// overlay the HUD
		hud = new HUD(player);
		add(hud);

		super.create();
	}

	override public function onFocusLost() {
		var pauseState = new PauseState(0x6703378B);
		pauseState.closeCallback = backButton;
		openSubState(pauseState);
		super.onFocusLost();
	}

	override function openSubState(SubState:FlxSubState) {
		remove(hud);
		remove(helpButton);
		remove(pauseButton);
		SubState.closeCallback = backButton;
		super.openSubState(SubState);
	}

	private function backButton() {
		FlxG.camera.zoom = 2;
		add(hud);
		add(helpButton);
		add(pauseButton);
		// player.updateSpeed();
	}

	override public function update(elapsed:Float) {
		// Calculate the angle of the mouse relative to the player
		angle = FlxAngle.angleBetweenMouse(player, true);

		// Player & enemy collisions with the tilemap walls
		FlxG.collide(player, walls);
		FlxG.collide(enemies, walls);
		FlxG.collide(bigEnemies, walls);

		// Player overlay detection for doors
		FlxG.overlap(player, doorGroup, onEncounterDoor);

		if (FlxG.mouse.justPressed && ammoNum > 0) {
			// Create a new bullet at the player and point it the same angle of the player
			ammoNum--;
			Reg.AMMO = ammoNum;

			// Calculate y diff and x diff of the mouse and player
			yDist = FlxG.mouse.y - player.y;
			xDist = FlxG.mouse.x - player.x;

			var bullet:FlxSprite = bullets.recycle();
			bullet.x = player.x;
			bullet.y = player.y;
			bullet.angle = angle;

			// Set the speed of the bullet and normalize the vector to have an even speed
			// and then set the x and y velocities accordingly
			var speed = 500;
			var dist = Math.sqrt((xDist * xDist) + (yDist * yDist));

			bullet.velocity.y = (yDist / dist) * speed;
			bullet.velocity.x = (xDist / dist) * speed;

			//Play sound
			playerShootSound.play();
		}

		// Check if the bullets are out of bounds or touching an enemy
		bullets.forEachAlive(outOfBounds);
		bullets2.forEachAlive(outOfBounds);
		FlxG.overlap(bullets, enemies, killEnemies);
		FlxG.overlap(bullets, bigEnemies, killEnemies);
		FlxG.overlap(bullets, rangedEnemies, killEnemies);

		// Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);

		// Check if player is touching an enemy
		FlxG.collide(player, enemies, hurtPlayer);
		FlxG.overlap(player, bigEnemies, hurtPlayer);

		// Update the ammo display text
		hud.updateHUD(ammoNum);

		// Start the timer for shooting
		if (timerStart2 == false) {
			shootTimer(new FlxTimer());
		}

		// Check if player is touching an ammo box
		FlxG.overlap(ammoBoxes, player, addAmmo);

		// Check if player is hit by enemy bullet
		FlxG.overlap(player, bullets2, hurtPlayerRanged);

		super.update(elapsed);
	}

	public function outOfBounds(bullet:FlxObject) {
		// If the bullet is out of bounds, kill it
		if (bullet.y < 0 || bullet.y > FlxG.height || bullet.x < 0 || bullet.x > FlxG.width) {
			bullet.kill();
		}
	}

	public function killEnemies(bullet:FlxObject, e:FlxSprite) {
		// If a bullet hits an enemy, kill the bullet and enemy
		bullet.kill();

		// Decrease enemy health, and kill if they have no health
		e.health -= 25;
		if (e.health <= 0) {
			e.kill();
			enemyKillSound.play();
			Reg.ENEMIES[roomID]--;
		}
		else{
			enemyHurtSound.play();
		}

		// Check if position matches any of the ranged spots
		if (rangeCanFire.length > 0) {
			for (i in 0...(rangeCanFire.length)) {
				if ((rangeX[i] - 0.5) <= e.x && e.x <= (rangeX[i] + 0.5)) {
					if ((rangeY[i] - 0.5) <= e.y && e.y <= (rangeY[i] + 0.5)) {
						// Make sure that ranged enemy cannot shoot again
						rangeCanFire[i] = false;
					}
				}
			}
		}

		// Check the win condition after killing this enemy
		checkWin();
	}

	// Function for checking the win condition. "Killing every enemy"
	public function checkWin() {
		// Check the win condition after killing the enemy
		if (Reg.ENEMIES[roomID] == 0) {
			var winCon:Bool = true;
			// Go through each enemy count
			for (i in 0...(Reg.ENEMIES.length)) {
				// If any are not 0, the win condition is false
				if (Reg.ENEMIES[i] != 0)
					winCon = false;
			}
			if (winCon) {
				FlxG.switchState(new GameOverState(WIN));
			}
		}
	}

	public function hurtPlayer(p:Player, e:FlxObject) {
		// If they were not already just hit, subtract health and check if they should be killed
		if (!FlxFlicker.isFlickering(p)) {
			// Play hurt sound
			playerHurtSound.play();
			// Flash the camera so the player knows they were hit
			FlxG.camera.flash(FlxColor.RED, 1);
			// Flicker the Player sprite to give player "immunity" for a frew seconds
			FlxFlicker.flicker(p);
			p.health -= 25;
			Reg.PLAYERHEALTH = p.health;
			if (p.health <= 0) {
				p.kill();
				FlxG.switchState(new GameOverState(LOSE));
			}
		}
	}

	public function hurtPlayerRanged(p:Player, b:FlxObject) {
		// Flash the camera so the player knows they were hit
		FlxG.camera.flash(FlxColor.RED, 1);

		// If they were not already just hit, subtract health and check if they should be killed
		if (!FlxFlicker.isFlickering(p)) {
			// Play hurt sound
			playerHurtSound.play();
			p.health -= 25;
			Reg.PLAYERHEALTH = p.health;
			if (p.health <= 0) {
				p.kill();
				FlxG.switchState(new GameOverState(LOSE));
			}
		}

		b.kill();
		// Flicker the Player sprite to give player "immunity" for a frew seconds
		FlxFlicker.flicker(p);
	}

	public function addAmmo(ammo:FlxObject, p:FlxSprite) {
		// If the player touches an ammo box, kill it and increase their ammo by 5
		ammo.kill();
		ammoSound.play();
		ammoNum += 5;
		Reg.AMMO = ammoNum;
	}

	public function destroyBullets(b:FlxSprite, w:FlxTilemap) {
		// Destroy the bullet
		b.kill();
	}

	public function spawnEnemies() {
		// Create enemy group and enemy health bar group
		enemyHealthBars = new FlxTypedGroup(spawnEnemyX.length);
		enemies = new FlxTypedGroup(spawnEnemyX.length);
		bigEnemies = new FlxTypedGroup(spawnEnemyX.length);
		rangedEnemies = new FlxTypedGroup(spawnEnemyX.length);
		add(enemies);
		add(bigEnemies);
		add(rangedEnemies);
		add(enemyHealthBars);

		// Check if there are enemies to spawn from registry
		if (Reg.ENEMIES[roomID] != 0) {
			// Check to see if we have less enemies killed in this room already
			var spawnAmount:Int = (Reg.ENEMIES[roomID] < spawnEnemyX.length) ? Reg.ENEMIES[roomID] : spawnEnemyX.length;

			// Create as many enemies and health bars as there are spawning locations
			for (i in 0...(spawnAmount)) {
				// Check which enemy type the spawner is
				switch (spawnEnemyType[i]) {
					// Normal Enemies
					case 0:
						enemy = new Enemy(-200, -200, player, 20, "normal");
						enemy.exists = true;
						enemy.health = 100;
						enemies.add(enemy);
					// Ranged Enemies
					case 1:
						enemy = new Enemy(-200, -200, player, 0, "ranged");
						enemy.exists = true;
						enemy.health = 20;
						rangedEnemies.add(enemy);
						rangeX.push(spawnEnemyX[i]);
						rangeY.push(spawnEnemyY[i]);
						rangeCanFire.push(true);
					// Large Enemies
					case 2:
						enemy = new Enemy(-200, -200, player, 10, "large");
						enemy.exists = true;
						enemy.health = 240;
						bigEnemies.add(enemy);
				}

				enemyHealth = new FlxBar(enemy.x, enemy.y, LEFT_TO_RIGHT, Std.int(75 / FlxG.camera.zoom), Std.int(10 / FlxG.camera.zoom), enemy, "health", 0,
					enemy.health, false);
				enemyHealth.exists = true;
				enemyHealth.killOnEmpty = true;

				// Set the enemy health bar to follow the enemy we just spawned
				enemyHealth.setParent(enemy, "health", true, Std.int(enemyHealth.width / 2 - enemy.width / 2) * -1, -18);

				// enemies.add(enemy);
				enemyHealthBars.add(enemyHealth);

				// Set enemy to the i spawn location
				enemy.x = spawnEnemyX[i];
				enemy.y = spawnEnemyY[i];
			}
		}
	}

	public function spawnAmmo() {
		// Create ammo box group
		ammoBoxes = new FlxTypedGroup(spawnAmmoX.length);
		add(ammoBoxes);
		// Create as many ammo boxes as there are spawning locations
		for (i in 0...spawnAmmoX.length) {
			ammoBox = new FlxSprite(-200, -200);
			ammoBox.loadGraphic("assets/images/ammosprite.png", true, 13, 16);
		ammoBox.animation.add("aimate", [0, 1,2,3,2,1,0], 8, true);


			ammoBox.exists = true;
			ammoBoxes.add(ammoBox);

			// Set the ammo box to the i spawn location
			ammoBox.x = spawnAmmoX[i];
			ammoBox.y = spawnAmmoY[i];
			ammoBox.animation.play("aimate");
		}
	}


	public function deleteEnemyBullet(b:FlxObject, p:FlxSprite) {
		b.kill();
	}

	// timers for the enemies to shoot
	function shootTimer(Timer:FlxTimer):Void {
		timerStart2 = true;
		Timer.start(2, shootTimerStop);
	}

	function shootTimerStop(Timer:FlxTimer):Void {
		// Check if there are any range enemies that can fire
		if (rangeX.length > 0) {
			for (i in 0...rangeX.length) {
				if (rangeCanFire[i]) {
					enemyShootSound.play();
					// Create a bullet that will shoot towards the player
					enemyProjectileDistX = player.x - rangeX[i];
					enemyProjectileDistY = player.y - rangeY[i];

					var enemyBullet:FlxSprite = bullets2.recycle();
					enemyProjectileAngle = Std.int(Math.atan(enemyProjectileDistY / enemyProjectileDistX) * 57.2957795);

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

	// Function to place entities that were on the entity layer in the Ogmo file
	public function placeEntities(entity:EntityData) {
		// Entity switch cases
		switch (entity.name) {
			// Positioning a player entity
			case "playerSpawnLocation":
				// Spawn player elsewhere if ENTRY is not 0
				// This will occur if the player entered a door
				// It's expected to be near a door
				if (entity.values.entranceID == Reg.ENTRY) {
					player.setPosition(entity.x + 4, entity.y + 4);
				}
			case "door":
				// Spawn a door that will have the destination ID and entrance ID
				var doorTemp = new Door(entity.values.stateDestID, entity.values.destEntrID);
				// Set its position
				doorTemp.setPosition(entity.x + 4, entity.y + 4);
				// Add it to the door group
				doorGroup.add(doorTemp);
			case "enemySpawn":
				// Push the x and y coords of each enemy spawn location to their arrays
				spawnEnemyX.push(entity.x);
				spawnEnemyY.push(entity.y);
				spawnEnemyType.push(entity.values.enemyType);
			case "ammoSpawn":
				spawnAmmoX.push(entity.x);
				spawnAmmoY.push(entity.y);
		}
	}

	// Function to call when the player encounters a door
	public function onEncounterDoor(player:Dynamic, door:Dynamic) {
		// Set entrance value
		Reg.ENTRY = door.stateEntranceID;

		// Play sound
		doorSound.play();

		// Determines which state to go to
		switch (door.stateDestID) {
			case 0:
				FlxG.switchState(new Room(0, AssetPaths.map00__json));
			case 1:
				FlxG.switchState(new Room(1, AssetPaths.map01__json));
			case 2:
				FlxG.switchState(new Room(2, AssetPaths.map02__json));
			case 3:
				FlxG.switchState(new Room(3, AssetPaths.map03__json));
			case 4:
				FlxG.switchState(new Room(4, AssetPaths.map04__json));
			case 5:
				FlxG.switchState(new Room(5, AssetPaths.map05__json));
		}
	}

	// Function to call for setting tile properties
	public function tilePropertySetting(theTilemap:FlxTilemap) {
		// For anything that doesn't have a tile, make it a wall in any direction
		theTilemap.setTileProperties(0, ANY);

		// Default everything else to have no collision
		for (i in 1...552) {
			theTilemap.setTileProperties(i, NONE);
		}

		// Setting things to not be able to collide in any direction
		var anyTiles:Array<Int> = [
			116, 117, 118, 119, 120, 185, 186, 187, 208, 209, 210, 138, 139, 140, 231, 232, 233, 369, 370, 371, 13, 14, 15, 16, 17, 18, 36, 37, 38, 39, 40,
			41, 58, 59, 60, 61, 62, 63, 64, 65, 66, 82, 83, 84, 85, 86, 87, 105, 106, 107, 108, 109, 110, 128, 129, 130, 131, 132, 133
		];
		for (i in anyTiles) {
			theTilemap.setTileProperties(i, ANY);
		}

		// Setting things for the left side
		var leftTiles:Array<Int> = [1, 24, 47, 70, 93];
		for (i in leftTiles) {
			theTilemap.setTileProperties(i, LEFT);
		}

		// Setting things for the right side
		var rightTiles:Array<Int> = [5, 28, 51, 74, 97];
		for (i in rightTiles) {
			theTilemap.setTileProperties(i, RIGHT);
		}
	}
}
