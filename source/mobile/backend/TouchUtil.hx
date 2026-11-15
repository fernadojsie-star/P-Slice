

package mobile.backend;

import flixel.FlxObject;
import flixel.input.touch.FlxTouch;

/**
 * ...
 * @author: Karim Akra
 *
 * On the browser build the player can use either a finger or a mouse (desktop browsers, or
 * phones that deliver mouse events), so every query here also looks at the mouse when
 * compiling for html5.
 */
class TouchUtil
{
	public static var pressed(get, never):Bool;
	public static var justPressed(get, never):Bool;
	public static var justReleased(get, never):Bool;
	public static var released(get, never):Bool;
	public static var touch(get, never):FlxTouch;

	public static function overlaps(object:FlxObject, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		for (touch in FlxG.touches.list)
			if (touch.overlaps(object, camera ?? object.camera))
				return true;

		#if html5
		if (FlxG.mouse.overlaps(object, camera ?? object.camera))
			return true;
		#end

		return false;
	}

	public static function overlapsComplex(object:FlxObject, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		var cameras:Array<FlxCamera> = camera != null ? [camera] : object.cameras;

		@:privateAccess
		for (cam in cameras)
		{
			for (touch in FlxG.touches.list)
				if (object.overlapsPoint(touch.getWorldPosition(cam, object._point), true, cam))
					return true;

			#if html5
			if (object.overlapsPoint(FlxG.mouse.getWorldPosition(cam, object._point), true, cam))
				return true;
			#end
		}

		return false;
	}

	/**
	 * True if the pointer that was just released (finger or mouse) is over `object`.
	 */
	public static function releasedOver(object:FlxObject, ?camera:FlxCamera):Bool
	{
		if (object == null)
			return false;

		for (touch in FlxG.touches.list)
			if (touch.justReleased && touch.overlaps(object, camera ?? object.camera))
				return true;

		#if html5
		if (FlxG.mouse.justReleased && FlxG.mouse.overlaps(object, camera ?? object.camera))
			return true;
		#end

		return false;
	}

	@:noCompletion
	private static function get_pressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.pressed)
				return true;

		#if html5
		if (FlxG.mouse.pressed)
			return true;
		#end

		return false;
	}

	@:noCompletion
	private static function get_justPressed():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justPressed)
				return true;

		#if html5
		if (FlxG.mouse.justPressed)
			return true;
		#end

		return false;
	}

	@:noCompletion
	private static function get_justReleased():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.justReleased)
				return true;

		#if html5
		if (FlxG.mouse.justReleased)
			return true;
		#end

		return false;
	}

	@:noCompletion
	private static function get_released():Bool
	{
		for (touch in FlxG.touches.list)
			if (touch.released)
				return true;

		#if html5
		if (FlxG.mouse.released)
			return true;
		#end

		return false;
	}

	@:noCompletion
	private static function get_touch():FlxTouch
	{
		for (touch in FlxG.touches.list)
			if (touch != null)
				return touch;

		return FlxG.touches.getFirst();
	}
}
