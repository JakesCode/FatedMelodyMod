package;

import js.html.Screen;
import lime.ui.WindowAttributes;
import openfl.display.Window;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var introText:Alphabet;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var introTextArray:Array<String> = ["ookiiani presents"];
	var introElements:FlxGroup = new FlxGroup();

	override public function create():Void
	{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end

		PlayerSettings.init();

		// curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		FlxG.save.bind('funkin-mod', 'playerdata');

		Highscore.load();

		// if (FlxG.save.data.weekUnlocked != null)
		// {
		// 	// FIX LATER!!!
		// 	// WEEK UNLOCK PROGRESSION!!
		// 	// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

		// 	if (StoryMenuState.weekUnlocked.length < 4)
		// 		StoryMenuState.weekUnlocked.insert(0, true);

		// 	// QUICK PATCH OOPS!
		// 	if (!StoryMenuState.weekUnlocked[0])
		// 		StoryMenuState.weekUnlocked[0] = true;
		// }

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end

		#if desktop
		DiscordClient.initialize();
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;

	function startIntro()
	{
		if (!initialized)
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('intro'), 0.7);

			// FlxG.sound.music.fadeIn(4, 0, 0.7);
		}

		Conductor.changeBPM(140);
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		textGroup = new FlxGroup();
		add(textGroup);

		createCoolText(introTextArray);

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfOutline');
		gfDance.animation.addByPrefix("dance", "GF Dancing Beat outline", 24);
		gfDance.animation.play("dance");
		gfDance.antialiasing = true;
		gfDance.alpha = 0.3;
		introElements.add(gfDance);
		gfDance.updateHitbox();

		logoBl = new FlxSprite(FlxG.width / 2 - 469.5, 25);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 15);
		logoBl.animation.play('bump');
		introElements.add(logoBl);
		logoBl.setGraphicSize(Math.floor(logoBl.width / 2), Math.floor(logoBl.height / 2));
		logoBl.updateHitbox();
		logoBl.setPosition(0, 0);
		logoBl.screenCenter(X);
		FlxTween.tween(logoBl, {y: logoBl.y + 15}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		
		var modLogo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('dlc'));
		introElements.add(modLogo);
		modLogo.setGraphicSize(Math.floor(modLogo.width / 2), Math.floor(modLogo.height / 2));
		modLogo.updateHitbox();
		modLogo.setPosition(FlxG.width / 2 + 75, 160);
		modLogo.antialiasing = true;
		modLogo.angle = -25;
		FlxTween.tween(modLogo, {y: modLogo.y + 15}, 0.8, {ease: FlxEase.quadInOut, type: PINGPONG});
		
		
		// var modName = new Alphabet(0, 0, "Fated Melody Mod", true, false);
		// introElements.add(modName);
		// modName.setPosition(FlxG.width / 2 - (modName.width / 2), 310);
		
		var pressEnter = new Alphabet(0, 0, "Press Enter", true, false);
		introElements.add(pressEnter);
		pressEnter.setPosition(FlxG.width / 2 - (pressEnter.width / 2), 500);
		FlxTween.tween(pressEnter, {alpha: 0.5}, 0.5, {ease: FlxEase.elasticInOut, type: PINGPONG});
		
		
		// titleText = new FlxSprite(125, 500);
		// titleText.frames = Paths.getSparrowAtlas('titleEnter');
		// titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		// titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		// titleText.antialiasing = true;
		// titleText.animation.play('idle');
		// titleText.updateHitbox();
		// introElements.add(titleText);
		
		add(introElements);
		introElements.visible = false;

		// var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		// logo.screenCenter();
		// logo.antialiasing = true;
		// // add(logo);

		// // FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// // FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		// credGroup = new FlxGroup();
		// add(credGroup);
		// textGroup = new FlxGroup();

		// blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// credGroup.add(blackScreen);

		// credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		// credTextShit.screenCenter();

		// // credTextShit.alignment = CENTER;

		// credTextShit.visible = false;

		// ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		// add(ngSpr);
		// ngSpr.visible = false;
		// ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		// ngSpr.updateHitbox();
		// ngSpr.screenCenter(X);
		// ngSpr.antialiasing = true;

		// FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)pressedEnter = true;
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('tapeStop'), 0.7);
			FlxG.sound.playMusic(Paths.music('menu'), 0.7);
			Conductor.changeBPM(75);

			transitioning = true;
			// FlxG.sound.music.stop();

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Check if version is outdated

				var version:String = "v" + Application.current.meta.get('version');

				trace(version);

				FlxG.switchState(new LevelSelectState());
			});
		}

		if (pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		textGroup.clear();
		for (i in 0...textArray.length)
		{
			var creditStr:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			creditStr.screenCenter(X);
			creditStr.y += (i * 60) + 150;
			textGroup.add(creditStr);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add(curBeat);
		trace(curBeat);

		switch (curBeat)
		{
			case 4:
				introTextArray = ["A mod for", "Friday Night Funkin"];
				createCoolText(introTextArray);
			case 8:
				introTextArray = ["With thanks to:", "ninjamuffin99", "PhantomArcade3K", "Evilsk8r", "Kawaisprite", "", "(For the original game!)"];
				createCoolText(introTextArray);
			case 12:
				introTextArray = ["Additional art", "and designs by", "", "Avery", "(Thank u!)"];
				createCoolText(introTextArray);
			// case 3:
			// 	addMoreText('present');
			// // credTextShit.text += '\npresent...';
			// // credTextShit.addText();
			// case 4:
			// 	deleteCoolText();
			// // credTextShit.visible = false;
			// // credTextShit.text = 'In association \nwith';
			// // credTextShit.screenCenter();
			// case 5:
			// 	createCoolText(['In association', 'with']);
			// case 7:
			// 	addMoreText('newgrounds');
			// 	ngSpr.visible = true;
			// // credTextShit.text += '\nNewgrounds';
			// case 8:
			// 	deleteCoolText();
			// 	ngSpr.visible = false;
			// // credTextShit.visible = false;

			// // credTextShit.text = 'Shoutouts Tom Fulp';
			// // credTextShit.screenCenter();
			// case 9:
			// 	createCoolText([curWacky[0]]);
			// // credTextShit.visible = true;
			// case 11:
			// 	addMoreText(curWacky[1]);
			// // credTextShit.text += '\nlmao';
			// case 12:
			// 	deleteCoolText();
			// // credTextShit.visible = false;
			// // credTextShit.text = "Friday";
			// // credTextShit.screenCenter();
			// case 13:
			// 	addMoreText('Friday');
			// // credTextShit.visible = true;
			// case 14:
			// 	addMoreText('Night');
			// // credTextShit.text += '\nNight';
			// case 15:
			// 	addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(textGroup);
			introElements.visible = true;
			skippedIntro = true;
		}
	}
}
