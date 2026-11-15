package mobile.objects.grid;

class BackButton extends GridTile
{
	public function new(host:GridButtons, callback:() -> Void)
	{
		super(host, callback);

		frames = Paths.getSparrowAtlas("mainmenu/backButton");
		animation.addByIndices('idle', 'back', [0], "", 24, false);
		animation.addByIndices('selected', 'back', [5], "", 24, false);
		animation.addByIndices('confirm', 'back', [
			6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
		], "", 24, false);
		statusIndicatorType = NONE;
		scale.set(0.7, 0.7);
		updateHitbox();
	}
	override function playHoverAnim()
	{
		animation.play('selected');
		updateHitbox();
		centerOrigin();
	}
	override function playIdleAnim()
	{
		animation.play('idle');
		updateHitbox();
		centerOrigin();
	}
	override function playSelectedAnim()
	{
		host.hideButtons();
		FlxTween.cancelTweensOf(this);
		HapticUtil.vibrate(0, 0.05, 0.5);
		animation.play('confirm');
		animation.onFinish.addOnce(function(name:String)
		{
			if (name != 'confirm') return;
			callback();
		});
	}
}
