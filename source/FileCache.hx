package;

import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import sys.FileSystem;
import sys.io.File;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class FileCache extends MusicBeatState
{
    var toBeDone = 0;
    var done = 0;

    var text:FlxText;
    var kadeLogo:FlxSprite;
    var bg:FlxSprite;

	override function create()
	{
        FlxG.mouse.visible = false;

        FlxG.worldBounds.set(0,0);

        text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
        text.size = 34;
        text.alignment = FlxTextAlign.CENTER;
        text.alpha = 0;

        kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
        kadeLogo.x -= kadeLogo.width / 2;
        kadeLogo.y -= kadeLogo.height / 2 + 100;
        text.y -= kadeLogo.height / 2 - 125;
        text.x -= 170;
        kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));

        kadeLogo.alpha = 0;

        bg = new FlxSprite(0, 0).loadGraphic(Paths.image('loading'));
        bg.setGraphicSize(Std.int(bg.width * 1));
        bg.updateHitbox();

        bg.alpha = 0;

        //add(kadeLogo);
        //add(text);
        add(bg);

        trace('starting caching..');
        
        sys.thread.Thread.create(() -> {
            cache();
        });


        super.create();
    }

    var calledDone = false;

    override function update(elapsed) 
    {

        if (toBeDone != 0 && done != toBeDone)
        {
            var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
            bg.alpha = alpha;
            kadeLogo.alpha = alpha;
            text.alpha = alpha;
            text.text = "Loading... (" + done + "/" + toBeDone + ")";
        }

        super.update(elapsed);
    }


    function cache()
    {

        var images = [];
        var music = [];

        trace("caching images...");
          
        #if !android
        for (i in Hsys.readDirectory("assets/shared/images/characters"))
        {
            if (!i.endsWith(".png"))
                continue;
            images.push(i);
        }
        #end
          
        trace("caching music...");

        for (i in HSys.readDirectory("assets/songs"))
        {
            music.push(i);
        }

        toBeDone = Lambda.count(images) + Lambda.count(music);

        trace("LOADING: " + toBeDone + " OBJECTS.");

        #if !android
        for (i in images)
        {
            var replaced = i.replace(".png","");
            FlxG.bitmap.add(Paths.image("characters/" + replaced,"shared"));
            trace("cached " + replaced);
            done++;
        }
        #end
          
        for (i in music)
        {
            FlxG.sound.cache(Paths.inst(i));
            FlxG.sound.cache(Paths.voices(i));
            trace("cached " + i);
            done++;
        }

        trace("Finished caching...");

        FlxG.switchState(new TitleState());
    }

}
