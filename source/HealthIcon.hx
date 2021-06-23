package;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		/*switch (char)
		{
			case 'tricky':
				loadGraphic(Paths.image('icons/icon-tricky'), true, 150, 150);
			case 'trickyMask':
				loadGraphic(Paths.image('icons/icon-tricky-mask'), true, 150, 150);
			case 'trickyH':
				loadGraphic(Paths.image('icons/icon-tricky-hell'), true, 150, 150);
			case 'exTricky':
				loadGraphic(Paths.image('icons/icon-ex-tricky'), true, 150, 150);
			default:
				loadGraphic(Paths.image('icons/icon-${char}'), true, 150, 150);
		}*/
		loadGraphic(Paths.image('icons/icon-${char}'), true, 150, 150);

		antialiasing = true;
		animation.add(char, [0, 1], 0, false, isPlayer);

		animation.play(char);
		antialiasing = true;
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
