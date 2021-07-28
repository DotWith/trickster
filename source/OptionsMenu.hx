package;

import Controls.Control;
import Options;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.Lib;

class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss."),
			#if desktop
			new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (1 = Chart dependent)"),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
		]),
		new OptionCategory("Appearance", [
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar.")
		]),
		new OptionCategory("Misc", [
			#if desktop
			new FPSOption("Toggle the FPS Counter"),
			#end
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty.")
		]),

		new OptionCategory("Saves and Data", [
			//new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			//new ResetSettings("Reset ALL your settings. This is irreversible!")
		])
	];

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<OptionText>;

	public static var versionShit:FlxText;

	public var currentOptions:Array<FlxText> = [];

	var targetY:Array<Float> = [];

	var currentSelectedCat:OptionCategory;

	var menuShade:FlxSprite;

	var offsetPog:FlxText;

	override function create()
	{
		var bg:FlxSprite = new FlxSprite(-10, -10).loadGraphic(Paths.image('menu/freeplay/RedBG', 'clown'));
		add(bg);
		var hedge:FlxSprite = new FlxSprite(-810, -335).loadGraphic(Paths.image('menu/freeplay/hedge', 'clown'));
		hedge.setGraphicSize(Std.int(hedge.width * 0.65));
		add(hedge);
		var shade:FlxSprite = new FlxSprite(-205, -100).loadGraphic(Paths.image('menu/freeplay/Shadescreen', 'clown'));
		shade.setGraphicSize(Std.int(shade.width * 0.65));
		add(shade);
		var bars:FlxSprite = new FlxSprite(-225, -395).loadGraphic(Paths.image('menu/freeplay/theBox', 'clown'));
		bars.setGraphicSize(Std.int(bars.width * 0.65));
		add(bars);

		for (i in 0...options.length)
		{
			var text:FlxText = new FlxText(125, (95 * i) + 100, 0, options[i].getName(), 34);
			text.color = FlxColor.fromRGB(255, 0, 0);
			text.setFormat("tahoma-bold.ttf", 60, FlxColor.RED);
			add(text);
			currentOptions.push(text);

			targetY[i] = i;

			trace('option king ');
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
		}

		currentDescription = "none";

		currentOptions[0].color = FlxColor.WHITE;

		offsetPog = new FlxText(125, 600, 0, "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription, 3);
		offsetPog.setFormat("tahoma-bold.ttf", 42, FlxColor.RED);
		add(offsetPog);

		menuShade = new FlxSprite(-1350, -1190).loadGraphic(Paths.image("menu/freeplay/Menu Shade", "clown"));
		menuShade.setGraphicSize(Std.int(menuShade.width * 0.7));
		add(menuShade);

		super.create();
	}

	var isCat:Bool = false;

	function resyncVocals():Void
	{
		MusicMenu.Vocals.pause();

		FlxG.sound.music.play();
		MusicMenu.Vocals.time = FlxG.sound.music.time;
		MusicMenu.Vocals.play();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (MusicMenu.Vocals != null)
		{
			if (MusicMenu.Vocals.playing)
			{
				if (FlxG.sound.music.time > MusicMenu.Vocals.time + 20 || FlxG.sound.music.time < MusicMenu.Vocals.time - 20)
					resyncVocals();
			}
		}

		if (controls.BACK && !isCat)
			FlxG.switchState(new MainMenuState());
		else if (controls.BACK)
		{
			isCat = false;
			for (i in currentOptions)
				remove(i);
			currentOptions = [];
			for (i in 0...options.length)
			{
				var text:FlxText = new FlxText(125, (95 * i) + 100, 0, options[i].getName(), 34);
				text.color = FlxColor.fromRGB(255, 0, 0);
				text.setFormat("tahoma-bold.ttf", 60, FlxColor.RED);
				add(text);
				currentOptions.push(text);
			}
			remove(menuShade);
			add(menuShade);

			curSelected = 0;
			currentOptions[curSelected].color = FlxColor.WHITE;

			changeSelection(curSelected);
		}
		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);

		if (isCat)
		{
			if (currentSelectedCat.getOptions()[curSelected].getAccept())
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.pressed.RIGHT)
					{
						currentSelectedCat.getOptions()[curSelected].right();
						currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
					}
					if (FlxG.keys.pressed.LEFT)
					{
						currentSelectedCat.getOptions()[curSelected].left();
						currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
					}
				}
				else
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						currentSelectedCat.getOptions()[curSelected].right();
						currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
					}
					if (FlxG.keys.justPressed.LEFT)
					{
						currentSelectedCat.getOptions()[curSelected].left();
						currentOptions[curSelected].text = currentSelectedCat.getOptions()[curSelected].getDisplay();
					}
				}
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
						FlxG.save.data.offset += 0.1;
					if (FlxG.keys.justPressed.LEFT)
						FlxG.save.data.offset -= 0.1;
				}
				else if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;

				offsetPog.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
			}
		}
		else
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.RIGHT)
					FlxG.save.data.offset += 0.1;
				else if (FlxG.keys.pressed.LEFT)
					FlxG.save.data.offset -= 0.1;
			}
			else if (FlxG.keys.justPressed.RIGHT)
				FlxG.save.data.offset += 0.1;
			else if (FlxG.keys.justPressed.LEFT)
				FlxG.save.data.offset -= 0.1;

			offsetPog.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset,2) + " - Description - " + currentDescription;
		}

		if (controls.RESET)
			FlxG.save.data.offset = 0;

		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound("confirm", 'clown'));
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].press())
				{
					// select thingy and redo itself
					for (i in currentOptions)
						remove(i);
					currentOptions = [];
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						// clear and redo everything else
						var option:Option = currentSelectedCat.getOptions()[i];

						trace(option.getDisplay());

						var text:FlxText = new FlxText(125, (95 * i) + 100, 0, option.getDisplay(), 34);
						text.color = FlxColor.fromRGB(255, 0, 0);
						text.setFormat("tahoma-bold.ttf", 60, FlxColor.RED);
						add(text);
						currentOptions.push(text);
					}
					remove(menuShade);
					add(menuShade);
					trace('done');
					currentOptions[curSelected].color = FlxColor.WHITE;
				}
			}
			else
			{
				currentSelectedCat = options[curSelected];
				isCat = true;
				for (i in currentOptions)
					remove(i);
				currentOptions = [];
				for (i in 0...currentSelectedCat.getOptions().length)
				{
					// clear and redo everything else
					var option:Option = currentSelectedCat.getOptions()[i];

					trace(option.getDisplay());

					var text:FlxText = new FlxText(125, (95 * i) + 100, 0, option.getDisplay(), 34);
					text.color = FlxColor.fromRGB(255, 0, 0);
					text.setFormat("tahoma-bold.ttf", 60, FlxColor.RED);
					add(text);
					currentOptions.push(text);
				}
				remove(menuShade);
				add(menuShade);
				curSelected = 0;
				currentOptions[curSelected].color = FlxColor.WHITE;
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end

		FlxG.sound.play(Paths.sound("Hover", 'clown'));

		currentOptions[curSelected].color = FlxColor.fromRGB(255, 0, 0);

		curSelected += change;

		if (curSelected < 0)
			curSelected = currentOptions.length - 1;
		if (curSelected >= currentOptions.length)
			curSelected = 0;

		currentOptions[curSelected].color = FlxColor.WHITE;

		var bullShit:Int = 0;
	}
}
