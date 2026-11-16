package mobile.backend;

/**
 * How the player drives the menus on touch devices (the main menu, options...).
 *
 * - `Touch`   : V-Slice style. Tap and swipe directly on the screen, plus a back button.
 * - `Buttons` : classic P-Slice style. On-screen D-pad / A / B / C buttons.
 *
 * Gameplay (hitbox) and Freeplay's extra buttons are not affected by this setting.
 */
class MenuControls
{
	public static var touchMode(get, never):Bool;

	@:noCompletion
	private static inline function get_touchMode():Bool
		return ClientPrefs.data.menuControls != 'Buttons';
}
