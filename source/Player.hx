package;

import flixel.ui.FlxBar;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;

class Player extends FlxSprite{

    var healthBar:FlxBar;
    static inline var SPEED:Float =100;
    public function new(x:Float=0, y:Float=0){
        //Create a constructor for the Player class
        super(x,y);
        
        //Create the sprite and load the spritesheet
		var spritesheet = new FlxSprite();
		loadGraphic(AssetPaths.walking__png,true, 16, 16);

        setSize(8,8);
        offset.x = 4;
        offset.y = 4;
        drag.x = drag.y = 800;

		//Create the walk animations
		animation.add("walkD", [0,1,2,3], 5, true);
        animation.add("walkDL", [4,5,6,7], 5, true);
        animation.add("walkL", [8,9,10,11], 5, true);
        animation.add("walkUL", [12,13,14,15], 5, true);
        animation.add("walkU", [16,17,18,19], 5, true);
        animation.add("walkUR", [20,21,22,23], 5, true);
        animation.add("walkR", [24,25,26,27], 5, true);
        animation.add("walkDR", [28,29,30,31], 5, true);

        //Create the idle animations
        animation.add("idleD", [0], 5, true);
        animation.add("idleDL", [4], 5, true);
        animation.add("idleL", [8], 5, true);
        animation.add("idleUL",[12], 5, true);
        animation.add("idleU", [16], 5, true);
        animation.add("idleUR", [20], 5, true);
        animation.add("idleR", [24], 5, true);
        animation.add("idleDR", [28], 5, true);
		
    }

    function updateMovement(){ 
        //Set variables that store which direction the player wants to go based on keys pressed
        var up:Bool = FlxG.keys.anyPressed([W, UP]);
        var down:Bool = FlxG.keys.anyPressed([S, DOWN]);
        var left:Bool = FlxG.keys.anyPressed([A, LEFT]);
        var right:Bool = FlxG.keys.anyPressed([D, RIGHT]);

        //Calculate the angle and set a default direction
        var mouseAngle = FlxAngle.angleBetweenMouse(this, true);
        var direction:String = "D";

        //Set direction based on orientation from player to mouse
        if(mouseAngle > -157.5 && mouseAngle <= -112.5){
            direction = "UL";
        }
        else if(mouseAngle >-112.5 && mouseAngle <= -67.5){
            direction = "U";
        }
        else if(mouseAngle >-67.5 && mouseAngle <= -22.5){
            direction = "UR";
        }
        else if(mouseAngle >-22.5 && mouseAngle <= 22.5){
            direction = "R";
        }
        else if(mouseAngle >22.5 && mouseAngle <= 67.5){
            direction = "DR";
        }
        else if(mouseAngle >67.5 && mouseAngle <= 112.5){
            direction = "D";
        }
        else if(mouseAngle >112.5 && mouseAngle <= 157.5){
            direction = "DL";
        }
        else if((mouseAngle >157.5 && mouseAngle <= 180) || (mouseAngle >-180 && mouseAngle <= -157.5)){
            direction = "L";
        }

        //Set the animation to idle by default, change to walk if the player is moving
        var action = "idle";
        if(velocity.x != 0 || velocity.y != 0){
            action = "walk";
        }
        animation.play(action + direction);

        //If one of the keys are pressed
        if(up || down || left || right){
            //Check if keys cancel each other out
            if(up && down){
                up = false;
                down = false;
            }
            if(left && right){
                left = false;
                right = false;
            }  

            //Set the angle for the player based on direction
            var angle:Float = 0;
            if(up){
                angle = -90;
                if(left){
                    angle-= 45;
                }else if(right){
                    angle+= 45;
                }
            }else if(down){
                angle = 90;
                if(left){
                    angle+= 45;
                }else if(right){
                    angle-= 45;
                }
            }else if(left){
                angle = 180;
            }else if(right){
                angle = 0;
            }

            //Set velocity relative to the SPEED var and angle we just calculated
            velocity.setPolarDegrees(SPEED, angle);
            
        }
    }

    override function update(elapsed:Float) {
        updateMovement();
        super.update(elapsed);
    }

}