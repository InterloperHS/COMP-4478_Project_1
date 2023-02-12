package;

import flixel.FlxSprite;
import flixel.FlxG;

class EnemyBullet extends FlxSprite
{
	var shooter:Enemy;
	var target:Player;
    var speed:Float = 300;

    public function new(x:Float = 0, y:Float = 0, shtr:Enemy, targ:Player)
    {
    	shooter = shtr;
    	target = targ;
        super(x,y);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
    }

    public function enemyShoot(){
    	if(shooter.alive){
            var enemyDistX:Float = shooter.x - target.x;
            var enemyDistY:Float = shooter.y - target.y;

            var enemyProjectileAngle:Float = Std.int(Math.atan(enemyDistX/enemyDistY) * 57.2957795);
			var enemyDist = Math.sqrt((enemyDistX*enemyDistX) + (enemyDistY*enemyDistY));

            this.x = shooter.x;
            this.y = shooter.y;
            this.angle = enemyProjectileAngle;

            var speed = 300;
            var distance = Math.sqrt((enemyDistX * enemyDistX) + (enemyDistY * enemyDistY));

			velocity.y = (enemyDistY / enemyDist) * -speed;
			velocity.x = (enemyDistX / enemyDist) * -speed;
        }
    }
}