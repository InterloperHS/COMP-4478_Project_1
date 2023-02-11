package;

import flixel.util.FlxSave;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(320, 280, MenuState));
	}
}
