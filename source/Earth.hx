package;
import flixel.FlxSprite;
import flixel.animation.FlxAnimation;
import flixel.FlxState;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.path.FlxPath;



class Earth extends FlxState
{
var points:Array<FlxPoint> = [new FlxPoint(1, 200), new FlxPoint(1, 250), new FlxPoint(250, 200), new FlxPoint(250, 250)];

var timePassed:Float = 0;
    //define sprite var
     var randomX:Float;
     var randomY:Float;
     var exp:FlxSprite = new FlxSprite();
     var exp1:FlxSprite = new FlxSprite();
     var exp2:FlxSprite = new FlxSprite();
	 var mySprite:FlxSprite = new FlxSprite();
	 var boy:FlxSprite = new FlxSprite();
     var boy1:FlxSprite = new FlxSprite();
     var arrow:FlxSprite = new FlxSprite();
     var boy2:FlxSprite = new FlxSprite();
	 var zom:FlxSprite = new FlxSprite();
	 var zom1:FlxSprite = new FlxSprite();
	 var zom2:FlxSprite = new FlxSprite();
	 var zom3:FlxSprite = new FlxSprite();
	 var zom4:FlxSprite = new FlxSprite();
	 var zom5:FlxSprite = new FlxSprite();
	 var zom6:FlxSprite = new FlxSprite();
	 var zom7:FlxSprite = new FlxSprite();
     var light:FlxSprite = new FlxSprite();
     var Stext:FlxText = new FlxText(0, 0, FlxG.width, "Quick! Get in the building with your keys!");
     var rip:FlxSprite = new FlxSprite();
     var rip1:FlxSprite = new FlxSprite();
     var zombies:FlxGroup = new FlxGroup();
     var exps:FlxGroup = new FlxGroup();
 


	override public function create()
	{


var background:FlxSprite = new FlxSprite();
background.loadGraphic("assets/images/bg1.jpg");
resizeImage(background,640,480,0,0);
add(background);




       //load spritesheet with frame size
        mySprite.loadGraphic("assets/images/ali2.png",true,502,502);   
        mySprite.animation.add("walk", [0, 1], 8,true);
        mySprite.animation.add("jump", [1,2, 3,4,5,1], 30,false);
        resizeImage(mySprite,120,108,700,203);



        boy.loadGraphic("assets/images/boy.png",true,130,199);   
        boy.animation.add("walkingboy", [0, 1, 2, 3, 4, 5,6,7], 12,true);
        resizeImage(boy,30,40,474,282);
        add(boy);
       // boy.animation.play("walkingboy");

        boy1.loadGraphic("assets/images/boy.png",true,130,199);   
        boy1.animation.add("walkingboy", [0, 1, 2, 3, 4, 5,6,7], 8,true);
        resizeImage(boy1,30,40,400,350);
        add(boy1);
        boy1.animation.play("walkingboy");



        boy2.loadGraphic("assets/images/boy.png",true,130,199);   
        boy2.animation.add("walkingboy", [0, 1, 2, 3, 4, 5,6,7], 8,true);
        resizeImage(boy2,30,40,350,350);
        add(boy2);
        boy2.scale.x=-0.2;
        boy2.animation.play("walkingboy");


        arrow.loadGraphic("assets/images/arrow.png",true,228,228);   
        arrow.animation.add("arrow", [0, 1, 2], 6,true);
        resizeImage(arrow,50,50,33,220);
   
        arrow.animation.play("arrow");

        //load spritesheet with frame size
        exp1.loadGraphic("assets/images/exp.png",true,148,211);   
        exp1.animation.add("exp1", [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17], 9,true);
       // exp1.animation.add("exp1", [1,2, 3,4,5,1], 30,false);
        resizeImage(exp1,100,150,500,350);

               //load spritesheet with frame size
        exp.loadGraphic("assets/images/exp.png",true,148,211);   
        exp.animation.add("exp", [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17], 9,true);
          resizeImage(exp,100,150,420,300);

               //load spritesheet with frame size
        exp2.loadGraphic("assets/images/exp.png",true,148,211);   
        exp2.animation.add("exp2", [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17], 9,true);
      //  exp2.animation.add("exp2", [1,2, 3,4,5,1], 30,false);
        resizeImage(exp2,100,150,100,2300);



        zom.loadGraphic("assets/images/zom.png",true,128,128);
        zom.animation.add("zomwalk", [0, 1, 2, 3], 4,true); 
        resizeImage(zom,30,30,200,390);

        zom1.loadGraphic("assets/images/zom.png",true,128,128);
        zom1.animation.add("zomwalk1", [4, 5, 6, 7],4,true);
        resizeImage(zom1,30,30,100,370);

        zom2.loadGraphic("assets/images/zom.png",true,128,128);
        zom2.animation.add("zomwalk2", [8, 9, 10, 11], 4,true);
        resizeImage(zom2,30,30,250,4200);

        zom3.loadGraphic("assets/images/zom.png",true,128,128);
        zom3.animation.add("zomwalk3", [12, 13, 14, 15],4,true);
         resizeImage(zom3,30,30,300,350);

        zom4.loadGraphic("assets/images/zom.png",true,128,128);
        zom4.animation.add("zomwalk4", [0, 1, 2, 3],4,true); 
      resizeImage(zom4,30,30,190,410);

        zom5.loadGraphic("assets/images/zom.png",true,128,128);
        zom5.animation.add("zomwalk5", [4, 5, 6, 7],4,true);
      resizeImage(zom5,30,30,400,400);


        zom6.loadGraphic("assets/images/zom.png",true,128,128);
        zom6.animation.add("zomwalk6", [8, 9, 10, 11],4,true);
        resizeImage(zom6,30,30,450,360);

        zom7.loadGraphic("assets/images/zom.png",true,128,128);
        zom7.animation.add("zomwalk7", [12, 13, 14, 15], 4,true);
        resizeImage(zom7,30,30,160,320);


        //rip png whe appear when the boy die
        rip.loadGraphic("assets/images/rip.png");
        rip.setPosition(320, 300);
        rip.visible = false;
        add(rip);


        //rip png whe appear when the boy die
        rip1.loadGraphic("assets/images/rip.png");
        rip1.setPosition(320, 300);
        rip1.visible = false;
        add(rip1);


       
        zombies.add(zom);
        zombies.add(zom1);
        zombies.add(zom2);
        zombies.add(zom3);
        zombies.add(zom4);
        zombies.add(zom5);
        zombies.add(zom6);
        zombies.add(zom7);
        zom.visible=false;
        zom1.visible=false;
        zom2.visible=false;
        zom3.visible=false;
        zom4.visible=false;
        zom5.visible=false;
        zom6.visible=false;
        zom7.visible=false;

        exps.add(exp);
        resizeImage(exp,100,150,350,350);
        exps.add(exp);
        resizeImage(exp,100,150,200,350);
        exps.add(exp);
        resizeImage(exp,100,150,150,350);
        exps.add(exp);

     


light.loadGraphic("assets/images/th.png",true,525,700);
light.animation.add("start", [1, 0, 2, 3], 6,true);
resizeImage(light,60,120,730,277);
light.animation.play("start");

Stext.setFormat(null, 16, 0xffffff, "center", 0x000000);

add(light);      
add(mySprite);
//add(exp);
add(zom);
add(zom1);
add(zom2);
add(zom3);
add(zom4);
add(zom5);
add(zom6);
add(zom7);






mySprite.animation.play("walk");

zom.animation.play("zomwalk");
zom1.animation.play("zomwalk1");
zom2.animation.play("zomwalk2");
zom3.animation.play("zomwalk3");
zom4.animation.play("zomwalk4");
zom5.animation.play("zomwalk5");
zom6.animation.play("zomwalk6");
zom7.animation.play("zomwalk7");



}



//public function for resizing
	public static function resizeImage(image:FlxSprite, w:Float,h:Float,px:Float,py:Float):Void
{
        image.height = h;
        image.width = w;
        image.scale.x = image.width / image.frameWidth;
        image.scale.y = image.height / image.frameHeight;

        image.offset.set(w, h);
        image.setPosition(px, py);
        image.updateHitbox();
}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);


timePassed += FlxG.elapsed;






if(timePassed >= 1)
{
 light.velocity.x -= 40;
 mySprite.velocity.x -= 40;



timePassed-=2;

for (zombie in zombies.members)
{
	
    try
    {
        
        var flxSprite:FlxSprite = cast zombie;
 
        randomX = 1 + (Math.random() * (622 - 1));
        randomY = 316 + (Math.random() * (447 - 316));

        
         var tween:FlxTween = FlxTween.tween(flxSprite, { x: randomX, y: randomY }, 2);

if(flxSprite.velocity.x>0){
        
        flxSprite.scale.x = 1 * flxSprite.scale.x;
    }
else{

        flxSprite.scale.x = -1 * flxSprite.scale.x;

}

if(flxSprite.visible &&  flxSprite.overlaps(boy1)){
	boy1.kill();
resizeImage(rip,30,30,boy1.x,boy1.y);
     rip.visible = true;
}

if(flxSprite.visible &&  flxSprite.overlaps(boy2)){
    boy2.kill();
resizeImage(rip1,30,30,boy2.x,boy2.y);
     rip1.visible = true;
}
    }
    catch (e:Dynamic)
    {
        // handle error here
    }
}

    }







var point:FlxPoint = new FlxPoint(exp.x-20, exp.y);
var point1:FlxPoint = new FlxPoint(exp1.x-20, exp1.y);
var point2:FlxPoint = new FlxPoint(exp2.x-20, exp2.y+100);
var point3:FlxPoint = new FlxPoint(boy1.x,boy2.y);
var point4:FlxPoint = new FlxPoint(boy2.x, boy2.y);

if (light.overlapsPoint(point, true)){
 add(exp);
 exp.animation.play("exp");
}


if (light.overlapsPoint(point1, true)){
   
 add(exp1);
 exp1.animation.play("exp1");
}

if (light.overlapsPoint(point2, true)){
  
 add(exp2);
 exp2.animation.play("exp2");
}

if (light.overlapsPoint(point3, true)){
  if(boy1.alive)
var tween:FlxTween = FlxTween.tween(boy1, { x: -100, y: boy1.y+50 }, 10);
}

if (light.overlapsPoint(point4, true)){
  if(boy2.alive)
var tween:FlxTween = FlxTween.tween(boy2, { x: 700, y: boy2.y+50 }, 10);
}



















if(mySprite.x < FlxG.worldBounds.left)
{
        add(Stext);
        add(arrow);
        zom.visible = true;
        zom1.visible = true;
        zom2.visible = true;
        zom3.visible = true;
        zom4.visible = true;
        zom5.visible = true;
        zom6.visible = true;
        zom7.visible = true;
 





if (FlxG.keys.enabled){

    //move by the key board arrows
        if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
        {
   
           // change boy direction to left

             boy.scale.x =0.2;
            //play animation
            boy.animation.play("walkingboy");
            if(boy.alive)
            boy.x -= 2;
           

   
        }

        if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
        {
            // change boy direction to right
           boy.scale.x= -0.2;

            //play animation
               boy.animation.play("walkingboy");
            boy.x += 2;
        
          
        }
        if (FlxG.keys.pressed.UP || FlxG.keys.pressed.W)
        {
        
            //boy.y -= 2;
        }
        if (FlxG.keys.pressed.DOWN || FlxG.keys.pressed.S)
        {
          
           // boy.y += 2;
        }


         if (FlxG.keys.pressed.SPACE)
        {
      
   
             
        }



      //  if mouse left click presed , id the boy not alive, revive him and hide the text
          if (FlxG.mouse.justPressed)
        {
            if(boy.alive==false){
            boy.setPosition(10, 180);

            boy.revive();
           
            rip.visible = false;
            }
        }

               if (FlxG.keys.pressed.R)
        {
            FlxG.resetState();
        }
         if (FlxG.keys.pressed.ESCAPE)
        {
            // TODO: add pause menu
            FlxG.switchState(new MenuState());
        }

}


var targetPoint:FlxPoint = new FlxPoint(51, 294);

// Check if the boy sprite overlaps the target point
if (boy.overlapsPoint(targetPoint)) {
   boy.kill();
   for (zombie in zombies.members)
{
    
    try
    {
        
        var flxSprite:FlxSprite = cast zombie;
 
        
         var tween:FlxTween = FlxTween.tween(flxSprite, { x: 51, y: 294 }, 1.5);

if(flxSprite.velocity.x>0){
        
        flxSprite.scale.x = 1 * flxSprite.scale.x;
    }
else{

        flxSprite.scale.x = -1 * flxSprite.scale.x;

}

if(flxSprite.overlapsPoint(targetPoint)){
flxSprite.kill();
FlxG.switchState(new PlayState());
}
    }
    catch (e:Dynamic)
    {
        // handle error here
    }
}

}
}

if(boy.y < FlxG.worldBounds.top)
{
 FlxG.resetState();}


	}
}










