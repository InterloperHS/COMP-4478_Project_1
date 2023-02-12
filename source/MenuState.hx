package;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.FlxState;

class MenuState extends FlxState
{
    var playStoryButton:FlxButton;
    var playButton:FlxButton;
    var optionsButton:FlxButton;
    var titleText:FlxText;
    var descriptionText:FlxText;
    var controlsText:FlxText;

    override public function create() {
        super.create();

        //Set up the title of the game
        titleText = new FlxText(FlxG.width/2-300, 50, 600, "Zombie Topdown Shooter", 37);
        add(titleText);

        //Tell the player what this game is
        descriptionText = new FlxText(FlxG.width/2-250, 150, 500, "A zombie invasion has appeared after aliens discovered our planet! It's your job to defeat them and make sure that they don't escape their biggest target, the dungeon building!", 14);
        add(descriptionText);

        //Tell the player the controls
        controlsText = new FlxText(FlxG.width/2-250, 250, 500, "Controls are as follows. Arrow keys or WASD for movement. Use your mouse to aim your gun and shoot with the left mouse button!", 13);
        add(controlsText);

        playButton = new FlxButton(0, 0, "Play Story", clickPlayStory);
        playButton.x = (FlxG.width / 2) - (playButton.width/2);
        playButton.y = (FlxG.height/2) - (playButton.height/2) + 100;
        add(playButton);

        playButton = new FlxButton(0, 0, "Skip to Game", clickPlay);
        playButton.x = (FlxG.width / 2) - (playButton.width/2);
        playButton.y = (FlxG.height/2) - (playButton.height/2) + 130;
        add(playButton);
       
        optionsButton = new FlxButton(0, 0, "Options", clickOptions);
        optionsButton.x = (FlxG.width / 2) - (optionsButton.width/2);
        optionsButton.y = (FlxG.height/2) - (optionsButton.height/2) + 160;
        add(optionsButton);
    }
    function clickPlayStory() {
        FlxG.switchState(new Laboratory());
    }
    function clickPlay() {
        FlxG.switchState(new PlayState());
    }
    function clickOptions() {
        FlxG.switchState(new OptionsState());
    }
}