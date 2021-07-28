package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class CharacterSetting
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	public var scale(default, null):Float;
	public var flipped(default, null):Bool;

	public function new(x:Int = 0, y:Int = 0, scale:Float = 1.0, flipped:Bool = false)
	{
		this.x = x;
		this.y = y;
		this.scale = scale;
		this.flipped = flipped;
	}
}

class MenuCharacter extends FlxSprite
{
    private static var settings:Map<String, CharacterSetting> = [
        'bf' => new CharacterSetting(0, 0, 0.76, true),
		'tricky' => new CharacterSetting(-120, -155, 0.76),
		'jebus' => new CharacterSetting(),
		'sanford' => new CharacterSetting(4000, 4999),
		'deimos' => new CharacterSetting(2000, 2999),
		'hank' => new CharacterSetting(5000, 5999),
		'auditor' => new CharacterSetting(6000, 6999),
		'mag' => new CharacterSetting(7000, 7999),
		'sus' => new CharacterSetting(0, 35, 0.76)
	];

    private var flipped:Bool = false;
	// questionable variable name lmfao
	private var goesLeftNRight:Bool = false;
	private var danceLeft:Bool = false;
	private var character:String = '';

    public function new(x:Int, y:Int, scale:Float, flipped:Bool)
    {
        super(x, y);
        this.flipped = flipped;

		if (FlxG.save.data.antialiasing)
		{
        	antialiasing = true;
		}

		switch (character)
		{
			case 'bf':
				frames = Paths.getSparrowAtlas("menu/MenuBF/MenuBF", "clown");

				animation.addByPrefix('idle', 'BF idle menu', 24, false);

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_bf", "clown"), 0);

			case 'tricky':
				frames = Paths.getSparrowAtlas("menu/MenuTricky/MenuTricky", "clown");

				animation.addByPrefix('idle', 'menutricky');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_tricky", "clown"), 0);

			case 'jebus':
				frames = Paths.getSparrowAtlas("menu/Jebus/Menu_jebus", "clown");

				animation.addByPrefix('idle', 'Jebus');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_jebus", "clown"), 0);

			case 'hank':
				frames = Paths.getSparrowAtlas("menu/Hank/Hank_Menu", "clown");

				animation.addByPrefix('idle', 'Hank');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_hank", "clown"), 0);
			
			case 'deimos':
				frames = Paths.getSparrowAtlas("menu/Deimos/Deimos_Menu", "clown");

				animation.addByPrefix('idle', 'Deimos');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_deimos", "clown"), 0);

			case 'auditor':
				frames = Paths.getSparrowAtlas("menu/Auditor/Auditor", "clown");

				animation.addByPrefix('idle', 'Auditor');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_auditor", "clown"), 0);

			case 'mag':
				frames = Paths.getSparrowAtlas("menu/Torture/Mag_Agent_Torture_Menu", "clown");

				animation.addByPrefix('idle', 'Mag Agent Torture');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_torture", "clown"), 0);

			case 'sanford':
				frames = Paths.getSparrowAtlas("menu/Sanford/Menu_Sanford", "clown");

				animation.addByPrefix('idle', 'Sanford');

				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music("nexus_sanford", "clown"), 0);
		}
		/*frames = Paths.getSparrowAtlas("random_menu_UI_characters");

		animation.addByPrefix('bf', 'BF idle menu', 24, false);
		animation.addByPrefix('auditor', 'Auditor');
		animation.addByPrefix('tricky', 'Tricky Idle menu');*/

        setGraphicSize(Std.int(width * scale));
		updateHitbox();
    }

    public function setCharacter(character:String):Void
    {
		var sameCharacter:Bool = character == this.character;
		this.character = character;

        if (!sameCharacter) {
			bopHead(true);
		}

		var setting:CharacterSetting = settings[character];
		offset.set(setting.x, setting.y);
		setGraphicSize(Std.int(width * setting.scale));
		flipX = setting.flipped != flipped;
    }

	public function bopHead(LastFrame:Bool = false):Void
	{
		if (character == 'gf' || character == 'spooky')
		{
			danceLeft = !danceLeft;

			if (danceLeft)
				animation.play(character + "-left", true);
			else
				animation.play(character + "-right", true);
		}
		else
		{
			// no spooky nor girlfriend so we do da normal animation
			if (animation.name == "bfConfirm")
				return;
			animation.play(character, true);
		}
		if (LastFrame)
		{
			animation.finish();
		}
	}
}
