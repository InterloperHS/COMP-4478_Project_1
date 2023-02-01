package;

import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxPoint;

class Player extends FlxSprite{

    static inline var SPEED:Float = 100;
    public function new(x:Float=0, y:Float=0){
        //Create a constructor for the Player class
        super(x,y);
        makeGraphic(20,20, FlxColor.WHITE);
        drag.x = drag.y = 800;
        
    }

    function updateMovement(){
        //Set variables that store which direction the player wants to go based on keys pressed
        var up:Bool = FlxG.keys.anyPressed([W]);
        var down:Bool = FlxG.keys.anyPressed([S]);
        var left:Bool = FlxG.keys.anyPressed([A]);
        var right:Bool = FlxG.keys.anyPressed([D]);

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