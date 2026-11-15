package mobile.objects;

class VSliceBackButton extends TouchButton
{
	public var callback:Void->Void;

	public function new(?x:Float = 0, ?y:Float = 0, ?callback:Void->Void):Void
	{
		super(x, y);
		this.callback = callback;

		frames = Paths.getSparrowAtlas("mainmenu/backButton");
		animation.addByIndices('idle', 'back', [0], "", 24, false);
		animation.addByIndices('pressed', 'back', [5], "", 24, false);
		animation.addByIndices('confirm', 'back', [
			6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
		], "", 24, false);
		animation.play('idle');

		scale.set(0.7, 0.7);
		updateHitbox();
		statusIndicatorType = NONE;
		alpha = 0.9;

		onDown.callback = () -> animation.play('pressed');
		onOut.callback = () -> animation.play('idle');
		onUp.callback = () ->
		{
			animation.play('confirm');
			HapticUtil.vibrate(0, 0.05, 0.5);
			if (callback != null) callback();
		};
	}
}
