package;

import flixel.util.FlxAxes;
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
        playButton = new FlxButton(0, 0, "Play", clickPlay);
        playButton.screenCenter(FlxAxes.X);
        playButton.y = (FlxG.height/2) - (playButton.height/2) - 16;
        add(playButton);
        
        optionsButton = new FlxButton(0, 0, "Options", clickOptions);
        optionsButton.screenCenter(FlxAxes.X);
        optionsButton.y = (FlxG.height/2) - (optionsButton.height/2) + 16;
        add(optionsButton);

        super.create();
    }
    function clickPlay() {
        FlxG.switchState(new PlayState());
    }
    function clickOptions() {
        FlxG.switchState(new OptionsState());
    }
}