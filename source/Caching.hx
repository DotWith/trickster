#if sys
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Exception;
import lime.app.Application;
import openfl.display.BitmapData;
import openfl.utils.Assets;

using StringTools;

#if cpp
import sys.FileSystem;
import sys.io.File;
#end
#if windows
import Discord.DiscordClient;
#end

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var madnessLogo:FlxSprite;

	public static var bitmapData:Map<String, FlxGraphic>;

	var images = [];
	var music = [];
	var charts = [];

	override function create()
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0, 0);

		bitmapData = new Map<String, FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300, 0, "Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		madnessLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('menu/Mainlogo', 'clown'));
		madnessLogo.x -= madnessLogo.width / 2;
		madnessLogo.y -= madnessLogo.height / 2 + 100;
		text.y -= madnessLogo.height / 2 - 125;
		text.x -= 170;
		madnessLogo.setGraphicSize(Std.int(madnessLogo.width * 0.6));

		madnessLogo.alpha = 0;

		#if cpp
		if (FlxG.save.data.cacheImages)
		{
			trace("caching images...");

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
				images.push(i);
			}
		}

		trace("caching music...");

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
		{
			music.push(i);
		}
		#end

		toBeDone = Lambda.count(images) + Lambda.count(music);

		var bar = new FlxBar(10, FlxG.height - 50, FlxBarFillDirection.LEFT_TO_RIGHT, FlxG.width, 40, null, "done", 0, toBeDone);
		bar.color = FlxColor.PURPLE;

		add(bar);

		add(madnessLogo);
		add(text);

		trace('starting caching..');

		#if cpp
		// Update Thread.

		sys.thread.Thread.create(() ->
		{
			while (!loaded)
			{
				if (toBeDone != 0 && done != toBeDone)
				{
					var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100, 2) / 100;
					madnessLogo.alpha = alpha;
					text.alpha = alpha;
					text.text = "Loading... (" + done + "/" + toBeDone + ")";
				}
			}
		});

		// Cache Thread.

		sys.thread.Thread.create(() ->
		{
			cache();
		});
		#end

		super.create();
	}

	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
	}

	function cache()
	{
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			var replaced = i.replace(".png", "");
			var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
			trace('id ' + replaced + ' file - assets/shared/images/characters/' + i + ' ${data.width}');
			var graph = FlxGraphic.fromBitmapData(data);
			graph.persist = true;
			graph.destroyOnNoUse = false;
			bitmapData.set(replaced, graph);
			done++;
		}

		for (i in music)
		{
			FlxG.sound.cache(Paths.inst(i));
			FlxG.sound.cache(Paths.voices(i));
			trace("cached " + i);
			done++;
		}

		trace("Finished caching...");

		loaded = true;

		trace(Assets.cache.hasBitmapData('GF_assets'));

		FlxG.switchState(new TitleState());
	}
}
#end
