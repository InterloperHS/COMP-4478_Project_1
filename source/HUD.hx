package;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class HUD extends FlxTypedGroup<FlxSprite> {
    var background:FlxSprite;
    var healthCounter:FlxText;
    var ammoCounter:FlxText;

    public function new() {
        super();
        healthCounter = new FlxText(16, 0, 100, "Health: 100");
        ammoCounter = new FlxText(16, healthCounter.height+16, 100, "Ammo: 100");
        add(healthCounter);
        add(ammoCounter);
    }
    public function updateHUD(health:Int, ammo:Int) {
        healthCounter.text = "Health: " + health;
        ammoCounter.text = "Ammo: " + ammo;
    }
}