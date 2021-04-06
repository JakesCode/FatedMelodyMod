package;

import flixel.tweens.FlxEase;
import openfl.utils.Object;
import LevelData.LevelRootObject;
import haxe.format.JsonParser;
#if desktop
import Discord.DiscordClient;
#end
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

class LevelSelectState extends MusicBeatState
{
	var weekData:Array<Dynamic> = [
		['intro']
	];
	var curPosition:Int = 0;
	var levelProgression:Array<String> = [
		"intro",
		"location-2",
		"location-3"
	];
	var levelData:Map<String, Map<String, String>> = new Map<String, Map<String, String>>();
	var grpLocations:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var grpLevelInfo:FlxGroup = new FlxGroup();

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var curDifficulty:Int = 1;

	var showDifficultySelect:Bool = false;

	var bfSprite = new HealthIcon('bf');

	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('menu'));
		}

		persistentUpdate = persistentDraw = true;

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		// var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGGreen'));
		add(bg);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		levelData.set("intro", ["name" => "Intro", "levelPos" => "1/1"]);
		levelData.set("location-2", ["name" => "Location Two", "levelPos" => "1/2"]);
		levelData.set("location-3", ["name" => "Location Three", "levelPos" => "1/3"]);
		
		if(!FlxG.save.data.progress) {
			FlxG.save.data.progress = [true, true, false];
			FlxG.save.flush();
		}

		var dot_frames = Paths.getSparrowAtlas("dot");

		bfSprite.screenCenter();
		bfSprite.setPosition(bfSprite.x, bfSprite.y - 100);
		FlxTween.tween(bfSprite, {y: bfSprite.y + 10}, 0.5, {ease: FlxEase.quadInOut, type: PINGPONG});	
		add(bfSprite);

		for (i in 0...levelProgression.length)
		{
			var level = levelData.get(levelProgression[i]);
			trace(level);

			var dotSpr:FlxSprite = new FlxSprite((FlxG.width / 2 - 30) + (((i * 60) + 200 * i)), (FlxG.height / 2) - 30);
			dotSpr.frames = dot_frames;
			dotSpr.animation.addByPrefix("dot_wiggle", "dot");
			if(i == 0) {
				dotSpr.animation.play("dot_wiggle");
			}
			dotSpr.antialiasing = true;
			dotSpr.setGraphicSize(60, 60);
			dotSpr.updateHitbox();
			dotSpr.ID = i;
			dotSpr.screenCenter(Y);
			
			if(i < levelProgression.length - 1) {
				var lineGraphic = "line";
				if(!FlxG.save.data.progress[i + 1]) lineGraphic = "line_broken";

				var connectingLine:FlxSprite = new FlxSprite(dotSpr.x, dotSpr.y).loadGraphic(Paths.image(lineGraphic));
				grpLocations.add(connectingLine);
				connectingLine.setPosition((dotSpr.x + dotSpr.width) - 25);
				connectingLine.updateHitbox();
				connectingLine.screenCenter(Y);
				connectingLine.antialiasing = true;
			}

			grpLocations.add(dotSpr);
		}

		
		var lvlName = new Alphabet(0, 0, levelData.get(levelProgression[0]).get("name"), true, false);
		grpLevelInfo.add(lvlName);
		lvlName.setPosition(0, FlxG.height - 100);
		lvlName.screenCenter(X);

		var lvlPos = new Alphabet(0, 0, levelData.get(levelProgression[0]).get("levelPos"), false, false);
		grpLevelInfo.add(lvlPos);
		lvlPos.setPosition(0, FlxG.height - 170);
		lvlPos.screenCenter(X);

		var whiteBG:FlxSprite = new FlxSprite(0, FlxG.height - 200).makeGraphic(FlxG.width, 200);
		whiteBG.color = 0xFFFFFF;
		whiteBG.alpha = 0.8;
		add(whiteBG);

		// Difficulty Indicators //
		difficultySelectors = new FlxGroup();
		difficultySelectors.visible = showDifficultySelect;
		add(difficultySelectors);

		var difficultySelectorsBg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 125);
		difficultySelectorsBg.color = 0x000000;
		difficultySelectorsBg.alpha = 0.8;
		difficultySelectors.add(difficultySelectorsBg);

		sprDifficulty = new FlxSprite(0, 0);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.screenCenter(X);
		sprDifficulty.updateHitbox();
		difficultySelectors.add(sprDifficulty);
		sprDifficulty.setPosition(sprDifficulty.x + 15, difficultySelectorsBg.height / 2 - (sprDifficulty.height / 2));
		sprDifficulty.animation.play('easy');
		
		leftArrow = new FlxSprite(sprDifficulty.x - 150, sprDifficulty.y + (sprDifficulty.height / 2) - 45);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);
		
		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 70, sprDifficulty.y + (sprDifficulty.height / 2) - 45);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);
		
		changeDifficulty();
		add(grpLevelInfo);
		add(grpLocations);

		super.create();
	}

	override function update(elapsed:Float)
	{
		// lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		// scoreText.text = "WEEK SCORE:" + lerpScore;

		// txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		// txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// difficultySelectors.visible = weekUnlocked[curWeek];

		// grpLocks.forEach(function(lock:FlxSprite)
		// {
		// 	lock.y = grpWeekText.members[lock.ID].y;
		// });

		if(!showDifficultySelect) {
			if (controls.LEFT_P)
			{
				changeSelection(-1);
			}
	
			if (controls.RIGHT_P)
			{
				changeSelection(1);
			}
		} else {
			if (controls.LEFT_P)
			{
				changeDifficulty(-1);
			}
	
			if (controls.RIGHT_P)
			{
				changeDifficulty(1);
			}
		}

		// if (!movedBack)
		// {
		// 	if (!selectedWeek)
		// 	{
		// 		if (controls.UP_P)
		// 		{
		// 			changeWeek(-1);
		// 		}

		// 		if (controls.DOWN_P)
		// 		{
		// 			changeWeek(1);
		// 		}

		// 		if (controls.RIGHT)
		// 			rightArrow.animation.play('press')
		// 		else
		// 			rightArrow.animation.play('idle');

		// 		if (controls.LEFT)
		// 			leftArrow.animation.play('press');
		// 		else
		// 			leftArrow.animation.play('idle');

		// 		if (controls.RIGHT_P)
		// 			changeDifficulty(1);
		// 		if (controls.LEFT_P)
		// 			changeDifficulty(-1);
		// 	}

		// 	
		// }

		if (controls.ACCEPT)
		{
			if(!showDifficultySelect && !stopSpamming)
			{
				showDifficultySelect = true;
				difficultySelectors.visible = true;	
			} else {
				selectLevel();
			}
		}

		if (controls.BACK)
		{
			if(showDifficultySelect && !stopSpamming) {
				showDifficultySelect = false;
				difficultySelectors.visible = false;
			} else {
				FlxG.switchState(new TitleState());
			}
		}

		super.update(elapsed);
	}

	function selectLevel()
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('tapeStop'));
		FlxTween.tween(bfSprite, {y: 0 - bfSprite.height}, 1, {ease: FlxEase.elasticInOut, type: ONESHOT});
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			bfSprite.visible = false;
			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyPlaylist = weekData[curPosition];
			PlayState.isStoryMode = true;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.campaignScore = 0;

			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}

	// function selectWeek()
	// {
	// 	if (weekUnlocked[curWeek])
	// 	{
	// 		if (stopspamming == false)
	// 		{
	// 			FlxG.sound.play(Paths.sound('confirmMenu'));

	// 			grpWeekText.members[curWeek].startFlashing();
	// 			grpWeekCharacters.members[1].animation.play('bfConfirm');
	// 			stopspamming = true;
	// 		}

	// 		PlayState.storyPlaylist = weekData[curWeek];
	// 		PlayState.isStoryMode = true;
	// 		selectedWeek = true;

	// 		var diffic = "";

	// 		switch (curDifficulty)
	// 		{
	// 			case 0:
	// 				diffic = '-easy';
	// 			case 2:
	// 				diffic = '-hard';
	// 		}

	// 		PlayState.storyDifficulty = curDifficulty;

	// 		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
	// 		PlayState.storyWeek = curWeek;
	// 		PlayState.campaignScore = 0;
	// 		new FlxTimer().start(1, function(tmr:FlxTimer)
	// 		{
	// 			LoadingState.loadAndSwitchState(new PlayState(), true);
	// 		});
	// 	}
	// }

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		// sprDifficulty.y = leftArrow.y - 15;
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {alpha: 1}, 0.07);
	}

	// var lerpScore:Int = 0;
	// var intendedScore:Int = 0;

	var stopSpamming:Bool = false;
	function changeSelection(change:Int = 0):Void
	{
		if(curPosition + change >= 0 && curPosition + change <= levelProgression.length-1 && !stopSpamming) {
			if(FlxG.save.data.progress[curPosition + change]) {
				stopSpamming = true;
				curPosition += change;
				for (item in grpLocations.members) {
					// item.setPosition(item.x - 200, item.y);
					FlxTween.tween(item, {x: change == 1 ? item.x - 260 : item.x + 260}, 0.5, {ease: FlxEase.quintInOut, type: ONESHOT});
					item.animation.stop();
					if(item.ID >= 0) {
						// ID has been set, so must be a dot //
						if(item.ID == curPosition) {
							new FlxTimer().start(0.4, function(tmr:FlxTimer)
							{
								stopSpamming = false;
								item.animation.play("dot_wiggle");
								updateText();
							});
						} 
					}
				}
			}
		}

		// if(change == 1) {
		// 	for (item in grpLocations.members) {
		// 		// item.setPosition(item.x - 200, item.y);
		// 		FlxTween.tween(item, {x: item.x - 260}, 0.5, {ease: FlxEase.quadInOut, type: ONESHOT});	
		// 	}
		// } else if (change == -1) {
		// 	for (item in grpLocations.members) {
		// 		FlxTween.tween(item, {x: item.x + 260}, 0.5, {ease: FlxEase.quadInOut, type: ONESHOT});	
		// 	}
		// }

		// var bullShit:Int = 0;

		// for (item in grpLocations.members)
		// {
		// 	item.targetY = bullShit - curWeek;
		// 	if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
		// 		item.alpha = 1;
		// 	else
		// 		item.alpha = 0.6;
		// 	bullShit++;
		// }

		// FlxG.sound.play(Paths.sound('scrollMenu'));

		// updateText();
	}

	function updateText()
	{
		var levelInfo:Map<String, String> = levelData.get(levelProgression[curPosition]);
		grpLevelInfo.clear();

		var newLvlName = new Alphabet(0, 0, levelInfo["name"], true, false);
		grpLevelInfo.add(newLvlName);
		newLvlName.setPosition(0, FlxG.height - 100);
		newLvlName.screenCenter(X);

		var newLvlPos = new Alphabet(0, 0, levelInfo["levelPos"], false, false);
		grpLevelInfo.add(newLvlPos);
		newLvlPos.setPosition(0, FlxG.height - 170);
		newLvlPos.screenCenter(X);

	}
}