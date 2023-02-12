package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState
{
    var playButton:FlxButton;
    var optionsButton:FlxButton;
    override public function create() {
        super.create();

        playButton = new FlxButton(0, 0, "Play", clickPlay);
        playButton.x = (FlxG.width / 2) - (playButton.width/2);
        playButton.y = (FlxG.height/2) - (playButton.height/2) - 10;
        add(playButton);
       
        optionsButton = new FlxButton(0, 0, "Options", clickOptions);
        optionsButton.x = (FlxG.width / 2) - (optionsButton.width/2);
        optionsButton.y = (FlxG.height/2) - (optionsButton.height/2) + 10;
        add(optionsButton);
    }
    function clickPlay() {
        FlxG.switchState(new Laboratory());
    }
    function clickOptions() {
        FlxG.switchState(new OptionsState());
    }
}