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
		background = new FlxSprite().makeGraphic(Std.int(FlxG.camera.viewWidth), Std.int(32 / FlxG.camera.zoom), FlxColor.BLACK);
		background.setPosition(FlxG.camera.viewLeft, FlxG.camera.viewBottom - background.height);
		// Create display text for the ammo
		ammoText = new FlxText(0, 0, 0, "Ammo: 0", Std.int(16 / FlxG.camera.zoom));
		ammoText.setPosition(background.x + 16 / FlxG.camera.zoom, background.y + background.height / 2 - ammoText.height / 2);
		ammoText.setBorderStyle(SHADOW, FlxColor.GRAY, 1 / FlxG.camera.zoom, 1);
		ammoText.setFormat(null, Std.int(16 / FlxG.camera.zoom), FlxColor.WHITE, FlxTextAlign.LEFT);
		// Create player health bar that is linked to the player health sent in the new() constructor
		pHealthBar = new FlxBar(ammoText.x + ammoText.width + 16 / FlxG.camera.zoom, ammoText.y, LEFT_TO_RIGHT, Std.int(200 / FlxG.camera.zoom),
			Std.int(ammoText.height), player, "health", 0, 100, false);

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
