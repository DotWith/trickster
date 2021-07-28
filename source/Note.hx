package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

using StringTools;

#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var burning:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";
	
	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(_strumTime:Float, _noteData:Int, ?_prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false)
	{
		super();

		if (_prevNote == null)
			_prevNote = this;

		prevNote = _prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		strumTime = _strumTime + FlxG.save.data.offset;
		strumTime = strumTime < 0 ? 0 : strumTime;

		burning = _noteData > 7;
		// if(!isSustainNote) { burning = Std.random(3) == 1; } //Set random notes to burning

		// No held fire notes :[ (Part 1)
		if (isSustainNote && prevNote.burning)
		{
			burning = true;
		}

		noteData = _noteData % 4;

		var daStage:String = PlayState.curStage;

		switch (daStage)
		{
			case 'school' | 'schoolEvil':
				loadGraphic(Paths.image('arrows-pixels'), true, 17, 17);
				if (isSustainNote)
					loadGraphic(Paths.image('arrowEnds'), true, 7, 6);

				for (i in 0...4)
				{
					animation.add(dataColor[i] + 'Scroll', [i + 4]); // Normal notes
					animation.add(dataColor[i] + 'hold', [i]); // Holds
					animation.add(dataColor[i] + 'holdend', [i + 4]); // Tails
				}

				if (burning)
				{
					loadGraphic(Paths.image('NOTE_fire-pixel', "clown"), true, 21, 31);

					animation.add('greenScroll', [6, 7, 6, 8], 8);
					animation.add('redScroll', [9, 10, 9, 11], 8);
					animation.add('blueScroll', [3, 4, 3, 5], 8);
					animation.add('purpleScroll', [0, 1, 0, 2], 8);
					x -= 15;
				}

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

			default:
				frames = Paths.getSparrowAtlas('NOTE_assets');

				for (i in 0...4)
				{
					animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
					animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
					animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
				}

				if (burning)
				{
					if (daStage == 'auditor-hell')
					{
						frames = Paths.getSparrowAtlas('fourth/mech/ALL_deathnotes', "clown");
						animation.addByPrefix('greenScroll', 'Green Arrow');
						animation.addByPrefix('redScroll', 'Red Arrow');
						animation.addByPrefix('blueScroll', 'Blue Arrow');
						animation.addByPrefix('purpleScroll', 'Purple Arrow');
						x -= 165;
					}
					else
					{
						frames = Paths.getSparrowAtlas('NOTE_fire', "clown");
						if (!FlxG.save.data.downscroll)
						{
							animation.addByPrefix('blueScroll', 'blue fire');
							animation.addByPrefix('greenScroll', 'green fire');
						}
						else
						{
							animation.addByPrefix('greenScroll', 'blue fire');
							animation.addByPrefix('blueScroll', 'green fire');
						}
						animation.addByPrefix('redScroll', 'red fire');
						animation.addByPrefix('purpleScroll', 'purple fire');

						if (FlxG.save.data.downscroll)
							flipY = true;

						x -= 50;
					}
				}

				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				if (FlxG.save.data.antialiasing)
				{
					antialiasing = true;
				}
		}

		if (burning)
			setGraphicSize(Std.int(width * 0.86));

		x += swagWidth * noteData;
		animation.play(dataColor[noteData] + 'Scroll');

		// trace(prevNote);

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = 0.6;

			x += width / 2;

			animation.play(dataColor[noteData] + 'holdend');

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				prevNote.animation.play(dataColor[prevNote.noteData] + 'hold');

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * PlayState.SONG.speed;
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// No held fire notes :[ (Part 2)
		if (isSustainNote && prevNote.burning)
		{
			this.kill();
		}

		if (mustPress)
		{
			// The multiplication is so that it's easier to hit them too late, instead of too early
			if (!burning)
			{
				// The * 0.5 is so that it's easier to hit them too late, instead of too early
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5));
			}
			else
			{
				if (PlayState.curStage == 'auditor-hell') // these though, REALLY hard to hit.
				{
					// The * 0.2 is so that it's easier to hit them too late, instead of too early
					canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.3)
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.2)); // also they're almost impossible to hit late!
				}
				else
				{
					// make burning notes a lot harder to accidently hit because they're weirdchamp!
					canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.6)
						&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.4)); // also they're almost impossible to hit late!
				}
			}
			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
