package mobile.objects;

#if TOUCH_CONTROLS_ALLOWED
import mikolka.funkin.utils.HapticUtil;

/**
 * V-Slice style "back" button used by the menus when Menu Controls is set to Touch.
 *
 * Uses the `mainmenu/backButton` atlas when it exists. If the atlas is missing it falls back to a
 * simple drawn button so the game never crashes because of a missing asset.
 */
class VSliceBackButton extends TouchButton
{
	public var callback:Void->Void;

	var hasAtlas:Bool = false;

	public function new(?x:Float = 0, ?y:Float = 0, ?callback:Void->Void):Void
	{
		super(x, y);
		this.callback = callback;

		hasAtlas = Paths.fileExists('images/mainmenu/backButton.xml', TEXT) && Paths.fileExists('images/mainmenu/backButton.png', IMAGE);

		if (hasAtlas)
		{
			frames = Paths.getSparrowAtlas('mainmenu/backButton');
			animation.addByIndices('idle', 'back', [0], "", 24, false);
			animation.addByIndices('pressed', 'back', [5], "", 24, false);
			animation.addByIndices('confirm', 'back', [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22], "", 24, false);
			animation.play('idle');
			scale.set(0.7, 0.7);
			updateHitbox();
		}
		else
		{
			makeGraphic(150, 80, 0xFF6666E1);
			updateHitbox();
		}

		scrollFactor.set(); // never scroll away with the camera
		statusIndicatorType = NONE;
		alpha = 0.9;

		onDown.callback = () ->
		{
			if (hasAtlas) animation.play('pressed');
			else alpha = 1;
		};
		onOut.callback = () ->
		{
			if (hasAtlas) animation.play('idle');
			else alpha = 0.9;
		};
		onUp.callback = () ->
		{
			if (hasAtlas) animation.play('confirm');
			HapticUtil.vibrate(0, 0.05, 0.5);
			if (this.callback != null) this.callback();
		};
	}
}
#end
