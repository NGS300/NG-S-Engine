package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

using StringTools;

class TitleState extends MusicBeatState{
	static var initialized:Bool = false;
	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;
	public static var updateVersion:String = '';
	override public function create():Void{
		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		PlayerSettings.init();
		curWacky = FlxG.random.getObject(getIntroTextShit());
		super.create();
		NGio.noLogin(APIStuff.API);
		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		#end
		//FlxG.save.bind('funkin', 'ninjamuffin99');
		PlayerSettings.init();
		ClientSave.data();
		Highscore.load();
		if (FlxG.save.data.weekUnlocked != null){
			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}
		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer){
			startIntro();
		});
		#end
		var http = new haxe.Http("https://raw.githubusercontent.com/NGS300/Ngs-Engine/development/gitEngineVersion.txt");
		http.onData = function (data:String){
			updateVersion = data.split('\n')[0].trim();
			var curVersion:String = MainMenuState.engineVersion.trim();
			trace ('version online: ' + updateVersion + ', your version: ' + curVersion);
			if (updateVersion != curVersion)
				trace('versions arent matching!');
		}	
		http.onError = function (error){
			trace('error: $error');
		}	
		http.request();
		#if desktop
		DiscordClient.initialize();
		Application.current.onExit.add (function (exitCode) {
			DiscordClient.shutdown();
		 });
		#end
	}
	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	function startIntro(){
		if (!initialized){
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;
			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
			FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
		Conductor.changeBPM(102);
		persistentUpdate = true;

		/*var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);*/

		for (i in StateImage.suckAdd){
			add(i);
		}

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('TitleShit/Logos/logoBumpin');
		logoBl.antialiasing = Client.Antialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('TitleShit/gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = Client.Antialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('TitleShit/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = Client.Antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('TitleShit/Logos/NewgroundsLogo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = Client.Antialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
			initialized = true;
	}
	function getIntroTextShit():Array<Array<String>>{
		var fullText:String = Assets.getText(Paths.txt('IntroText', 'config'));
		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];
		for (i in firstArray){
			swagGoodArray.push(i.split('--'));
		}
		return swagGoodArray;
	}
	var transitioning:Bool = false;
	override function update(elapsed:Float){
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.keys.justPressed.F){
			FlxG.fullscreen = !FlxG.fullscreen;
		}
		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;
		if (pressedEnter && !transitioning && skippedIntro){
			titleText.animation.play('press');
			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
			transitioning = true;
			new FlxTimer().start(2, function(tmr:FlxTimer){
				var version:String = "v" + Application.current.meta.get('version');
				if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState){
					FlxG.switchState(new OutdatedSubState());
					trace("NGE " + version.trim());
					trace(NGio.GAME_VER_NUMS.trim());
				}else{
					FlxG.switchState(new MainMenuState());
				}
			});
		}
		if (pressedEnter && !skippedIntro){
			skipIntro();
		}
		super.update(elapsed);
	}
	function createCoolText(textArray:Array<String>){
		for (i in 0...textArray.length){
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}
	function addMoreText(text:String){
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}
	function deleteCoolText(){
		while (textGroup.members.length > 0){
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
	override function beatHit(){
		super.beatHit();
		logoBl.animation.play('bump');
		danceLeft = !danceLeft;
		if (danceLeft)
			gfDance.animation.play('danceRight');
		else
			gfDance.animation.play('danceLeft');
		FlxG.log.add(curBeat);
		switch (curBeat){
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				if (Main.engineMark)
					createCoolText(['NGS Engine', 'by']);
				else
					createCoolText(['In Partnership', 'with']);
			case 7:
				if (Main.engineMark)
					addMoreText('NGS');
				else{
					addMoreText('Newgrounds');
					ngSpr.visible = true;
				}
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Friday');
			case 14:
				addMoreText('Night');
			case 15:
				addMoreText('Funkin');
			case 16:
				skipIntro();
		}
	}
	var skippedIntro:Bool = false;
	function skipIntro():Void{
		if (!skippedIntro){
			remove(ngSpr);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}
