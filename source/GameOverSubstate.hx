package;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
class GameOverSubstate extends MusicBeatSubstate{
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var stageSuffix:String = "";
	public function new(x:Float, y:Float){
		var daStage = TrackMap.curMap;
		var daBf:String = '';
		switch (PlayState.SONG.player1){ // BF Skins Deaths
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}
		super();
		Conductor.songPosition = 0;
		bf = new Boyfriend(x, y, daBf);
		add(bf);
		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);
		FlxG.sound.play(Paths.sound('lose/fnf_loss_sfx' + stageSuffix, 'character'));
		Conductor.changeBPM(100);
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;
		bf.playAnim('firstDeath');
	}
	override function update(elapsed:Float){
		super.update(elapsed);
		if (controls.ACCEPT)
			endThisShit();
		if (controls.BACK){
			PlayState.death = 0;
			FlxG.sound.music.stop();
			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
		}
		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
			FlxG.sound.playMusic(Paths.music('lose/gameOver' + stageSuffix, 'character'));
		if (FlxG.sound.music.playing)
			Conductor.songPosition = FlxG.sound.music.time;
	}
	override function beatHit(){
		super.beatHit();
		FlxG.log.add('beat');
	}
	var isEnding:Bool = false;
	function endThisShit():Void{
		if (!isEnding){
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('lose/gameOverEnd' + stageSuffix, 'character'));
			new FlxTimer().start(0.7, function(tmr:FlxTimer){
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function(){
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
