package mikolka.vslice.ui.mainmenu;

import mikolka.vslice.freeplay.FreeplayState;
import options.OptionsState;
import flixel.FlxBasic;
import flixel.effects.FlxFlicker;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.VsliceOptions;
import flixel.FlxObject;

@:access(mikolka.vslice.ui.MainMenuState)
class DesktopMenuState extends FlxBasic
{
	// V-Slice 0.8.6 desktop order: Story Mode, Freeplay, Options, Credits.
	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'options',
		'credits'
	];

	public static var curSelected:Int = 0;
	var selectedSomethin:Bool = false;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var camFollow:FlxObject;
	var host:MainMenuState;

	public function new(host:MainMenuState)
	{
		super();
		this.host = host;
		host.add(this);

		// V-Slice 0.8.6 uses a fixed 160px vertical rhythm.
		host.bg.scrollFactor.set(0, 0.17);
		host.bg.updateHitbox();
		host.bg.screenCenter();
		host.magenta.scrollFactor.set(0, 0.17);
		host.magenta.updateHitbox();
		host.magenta.screenCenter();

		camFollow = new FlxObject(0, 0, 1, 1);
		host.add(camFollow);

		menuItems = new FlxTypedGroup<FlxSprite>();
		host.add(menuItems);

		final spacing:Float = 160;
		final top:Float = (FlxG.height - (spacing * (menuItems.length + optionShit.length - 1))) / 2;

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, top + (i * spacing));
			menuItem.antialiasing = VsliceOptions.ANTIALIASING;
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.scrollFactor.set(0, 0.4);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
		}

		FlxG.camera.follow(camFollow, null, 0.06);
		changeItem();

		#if TOUCH_CONTROLS_ALLOWED
		host.addTouchPad('UP_DOWN', 'A_B');
		#end
	}

	override function update(elapsed:Float)
	{
		if (!selectedSomethin)
		{
			if (host.controls.UI_UP_P) changeItem(-1);
			if (host.controls.UI_DOWN_P) changeItem(1);

			if (host.controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (host.controls.ACCEPT)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				selectedSomethin = true;

				if (VsliceOptions.FLASHBANG)
					FlxFlicker.flicker(host.magenta, 1.1, 0.15, false);

				FlxFlicker.flicker(menuItems.members[curSelected], 1, 0.06, false, false,
					function(flick:FlxFlicker)
					{
						switch (optionShit[curSelected])
						{
							case 'story_mode':
								MusicBeatState.switchState(new StoryMenuState());
							case 'freeplay':
							{
								host.persistentDraw = true;
								host.persistentUpdate = false;
								FlxTransitionableState.skipNextTransIn = true;
								FlxTransitionableState.skipNextTransOut = true;
								host.openSubState(new FreeplayState());
								host.subStateOpened.addOnce(state ->
								{
									for (item in menuItems.members)
									{
										item.revive();
										item.alpha = 1;
										item.visible = true;
									}
									selectedSomethin = false;
									changeItem(0);
								});
							}
							case 'options':
								host.goToOptions();
							case 'credits':
								MusicBeatState.switchState(new CreditsState());
						}
					});

				for (i in 0...menuItems.members.length)
				{
					if (i == curSelected) continue;
					FlxTween.tween(menuItems.members[i], {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							menuItems.members[i].kill();
						}
					});
				}
			}

			if (#if LEGACY_PSYCH FlxG.keys.anyJustPressed(ClientPrefs.keyBinds.get('debug_1').filter(s -> s != -1)) #else host.controls.justPressed('debug_1') #end)
			{
				selectedSomethin = true;
				FlxTransitionableState.skipNextTransIn = false;
				FlxTransitionableState.skipNextTransOut = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
		}
		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		if (menuItems.length == 0) return;
		if (huh != 0) FlxG.sound.play(Paths.sound('scrollMenu'));

		menuItems.members[curSelected].animation.play('idle');
		menuItems.members[curSelected].updateHitbox();
		menuItems.members[curSelected].screenCenter(X);

		curSelected += huh;
		if (curSelected >= menuItems.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuItems.length - 1;

		menuItems.members[curSelected].animation.play('selected');
		menuItems.members[curSelected].centerOffsets();
		menuItems.members[curSelected].screenCenter(X);

		camFollow.setPosition(menuItems.members[curSelected].getGraphicMidpoint().x,
			menuItems.members[curSelected].getGraphicMidpoint().y);
	}
}
