package;

import flixel.FlxG;
import flixel.FlxState;

class PlayState extends FlxState {
    override public function create():Void {
        FlxG.switchState(new Room(0, AssetPaths.map00__json));
    }
}