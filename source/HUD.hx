package;

import flixel.ui.FlxBar;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class HUD extends FlxTypedGroup<FlxSprite> {
	var background:FlxSprite;
	var ammoText:FlxText;
	var pHealthBar:FlxBar;

	public function new(player:Player) {
		super();
		// Create background for UI overlay
		background = new FlxSprite().makeGraphic(FlxG.camera.width, 20, FlxColor.BLACK);
		background.setPosition(0, FlxG.camera.height - background.height);
		// Create display text for the ammo
		ammoText = new FlxText(0, background.y, 100, "Ammo: 0", 16);
		ammoText.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		ammoText.setFormat(null, 16, FlxColor.WHITE, FlxTextAlign.LEFT);
		// Create player health bar that is linked to the player health sent in the new() constructor
		pHealthBar = new FlxBar(FlxG.camera.width - 210, FlxG.camera.height - 24, LEFT_TO_RIGHT, 200, 20, player, "health", 0, 100, false);

		add(background);
		add(ammoText);
		add(pHealthBar);
		// Have all the HUD sprites follow the camera
		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
	}

	// Update the ammo on the HUD
	public function updateHUD(ammo:Int) {
		ammoText.text = "Ammo: " + Std.string(ammo);
	}
}
