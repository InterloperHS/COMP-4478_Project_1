


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


// The game state class that extends FlxState
class Laboratory extends FlxState
{
     var ast:FlxSprite = new FlxSprite();
     var ast1:FlxSprite = new FlxSprite();
     var mouth:FlxSprite = new FlxSprite(); 
     var mouth1:FlxSprite = new FlxSprite(); 
     var background:FlxSprite = new FlxSprite();



    private var tutorialModal:FlxSprite;
    private var tutorialText:FlxText;
    private var tutorialArray:Array<String>;
    private var tutorialIndex:Int;



    override public function create():Void
    {
        super.create();

background.loadGraphic("assets/images/lab.jpg");
Earth.resizeImage(background,640,480,0,0);
add(background);








        // Create tutorial modal
        tutorialModal = new FlxSprite(FlxG.width/2-150, FlxG.height/2-100);
        tutorialModal.makeGraphic(300, 100, 0xAA333333);
        
        
        // Create tutorial text
        tutorialText = new FlxText(tutorialModal.x + 10, tutorialModal.y + 10, 280, "");
        tutorialText.setFormat(null, 16, 0xFFFFFFFF, "center");
        tutorialText.y=1;
        tutorialModal.y=1;

        
        // Create tutorial array
        tutorialArray = [
            "Hello Professor Mohammad, I heard we lost connection with the space prob Voyager 1, is that true?",
            "Hello Professor Sam, unfortunately that is true.\nIt has traveled nearly 22 billion km since its launch in 1977.",
            "I hope that connection returns soon, or the prob reachs an advanced space civilization and give them information about us.",
            "We have put many phonetic codes in several languages, as we have put the Earth's position in relation to our galaxy.",
               
        ];
        tutorialIndex = 0;
        tutorialText.text = tutorialArray[tutorialIndex];
        








    ast.loadGraphic("assets/images/prof1.png");   
      
     Earth.resizeImage(ast,130,350,270,160);
  
    add(ast);

    ast1.loadGraphic("assets/images/prof2.png");   
      
     Earth.resizeImage(ast1,130,350,390,120);
  
    add(ast1);



       //load spritesheet with frame size
        mouth.loadGraphic("assets/images/mouth.png",true,75,58);   
        mouth.animation.add("talk", [0, 1, 2, 3, 4, 5,6,7,8], 8,false);
        Earth.resizeImage(mouth,15,10,445,241);
          add(mouth);
        


            //load spritesheet with frame size
        mouth1.loadGraphic("assets/images/mouth.png",true,75,58);   
        mouth1.animation.add("talk", [0, 1, 2, 3, 4, 5,6,7,8], 8,false);
        Earth.resizeImage(mouth1,15,10,335,266);
          add(mouth1);
          mouth1.animation.play("talk");


   /*
        ali1.loadGraphic("assets/images/ali2.png",true,502,502);   
        ali1.animation.add("ali1", [0, 1], 4,true);
     PlayState.resizeImage(ali1,50,40,410,170);
     ali1.animation.play("ali1");
    add(ali1);

     voiager.loadGraphic("assets/images/voiager.png");   
     PlayState.resizeImage(voiager,50,40,-500,170);
     add(voiager);

       cd.loadGraphic("assets/images/cd.png");   
    




        expVo.loadGraphic("assets/images/expVo.png",true,192,192);   
        expVo.animation.add("ex", [0, 1, 2, 3, 4, 5,6,7,8,9,10,11,12,13,14,15,16,17,18,19], 5,false);
        PlayState.resizeImage(expVo,100,100,504,203);
       

*/
}










    override public function update(elapsed:Float)
    {
        super.update(elapsed);
if(tutorialIndex==0)
      mouth.animation.play("talk");





 add(tutorialModal);
        add(tutorialText);
          if (tutorialIndex >= tutorialArray.length) {
     

           remove(tutorialModal);
            remove(tutorialText);

    }




        
        if (FlxG.keys.pressed.R)
        {
            FlxG.resetState();
        }     









if (FlxG.mouse.justPressed)
        {

           
            //tutorial slides when mouse pree
            tutorialIndex++;
            if (tutorialIndex < tutorialArray.length) {
                 tutorialText.text = tutorialArray[tutorialIndex];

        if(tutorialIndex%2==0){
            mouth.animation.play("talk");
                } 
                else{
                   mouth1.animation.play("talk"); 
                }
}

            //when the array of tutorail slides ends, remove the tutorial and shot the ball
            else {
            remove(tutorialModal);
            remove(tutorialText);
            FlxG.switchState(new Space());
        }




}




}
    }