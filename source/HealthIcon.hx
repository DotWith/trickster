package;

import flixel.FlxG;
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
		
		switch (char)
		{
			case 'tricky':
				loadGraphic(Paths.image('icons/icon-tricky'), true, 150, 150);
			case 'tricky-mask':
				loadGraphic(Paths.image('icons/icon-tricky-mask'), true, 150, 150);
			case 'tricky-hell':
				loadGraphic(Paths.image('icons/icon-tricky-hell'), true, 150, 150);

				y -= 25;
			case 'tricky-ex':
				loadGraphic(Paths.image('icons/icon-tricky-ex'), true, 150, 150);
			case 'bf':
				loadGraphic(Paths.image('icons/icon-bf'), true, 150, 150);
			default:
				loadGraphic(Paths.image('icons/icon-face'), true, 150, 150);
		}

		animation.add(char, [0, 1], 0, false, isPlayer);

		animation.play(char);
		
		if (FlxG.save.data.antialiasing)
		{
			antialiasing = true;
		}
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
