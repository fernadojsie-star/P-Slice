package mobile.objects;

#if TOUCH_CONTROLS_ALLOWED
import openfl.Lib;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

/**
 * Draws a small ring under every finger (and under the mouse while the button is held).
 *
 * It lives in the OpenFL display list *above* the Flixel game, so it is never affected by
 * Flixel cameras, state switches or the scale mode. It reads raw stage coordinates, which means
 * it keeps working correctly in fullscreen.
 */
class TouchIndicator extends Sprite
{
	static inline var MOUSE_ID:Int = -1;
	static inline var FADE_TIME:Float = 0.22;
	static inline var POP_TIME:Float = 0.12;

	var marks:Map<Int, Mark> = new Map();
	var lastTime:Int = 0;

	public function new()
	{
		super();
		mouseEnabled = false;
		mouseChildren = false;

		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	function onAdded(_):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		var stage = Lib.current.stage;

		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin, false, 1000);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, 1000);
		stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd, false, 1000);

		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 1000);
		stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 1000);
		stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 1000);

		lastTime = Lib.getTimer();
		addEventListener(Event.ENTER_FRAME, onFrame);
	}

	// ---------- input ----------
	function onTouchBegin(e:TouchEvent):Void
		press(e.touchPointID, e.stageX, e.stageY);

	function onTouchMove(e:TouchEvent):Void
		move(e.touchPointID, e.stageX, e.stageY);

	function onTouchEnd(e:TouchEvent):Void
		release(e.touchPointID);

	function onMouseDown(e:MouseEvent):Void
	{
		// OpenFL can mirror the primary finger as a mouse event - don't draw it twice.
		if (hasActiveTouch())
			return;
		press(MOUSE_ID, e.stageX, e.stageY);
	}

	function onMouseMove(e:MouseEvent):Void
	{
		if (e.buttonDown)
			move(MOUSE_ID, e.stageX, e.stageY);
	}

	function onMouseUp(e:MouseEvent):Void
		release(MOUSE_ID);

	function hasActiveTouch():Bool
	{
		for (id => mark in marks)
			if (id != MOUSE_ID && mark.held)
				return true;
		return false;
	}

	// ---------- marks ----------
	function press(id:Int, x:Float, y:Float):Void
	{
		if (!ClientPrefs.data.touchIndicator)
			return;

		var mark = marks.get(id);
		if (mark == null)
		{
			mark = new Mark();
			marks.set(id, mark);
			addChild(mark.shape);
		}
		mark.held = true;
		mark.age = 0;
		mark.fade = 0;
		mark.shape.x = x;
		mark.shape.y = y;
		mark.shape.visible = true;
		draw(mark);
	}

	function move(id:Int, x:Float, y:Float):Void
	{
		var mark = marks.get(id);
		if (mark == null || !mark.held)
			return;
		mark.shape.x = x;
		mark.shape.y = y;
	}

	function release(id:Int):Void
	{
		var mark = marks.get(id);
		if (mark != null && mark.held)
		{
			mark.held = false;
			mark.fade = 0;
		}
	}

	function radius():Float
	{
		var h = Lib.current.stage.stageHeight;
		return Math.max(22, h * 0.045);
	}

	function draw(mark:Mark):Void
	{
		var r = radius();
		var g = mark.shape.graphics;
		g.clear();
		g.beginFill(0xFFFFFF, 0.18);
		g.lineStyle(Math.max(2, r * 0.12), 0xFFFFFF, 0.85);
		g.drawCircle(0, 0, r);
		g.endFill();
		g.lineStyle();
		g.beginFill(0xFFFFFF, 0.9);
		g.drawCircle(0, 0, Math.max(2.5, r * 0.12));
		g.endFill();
	}

	function onFrame(_):Void
	{
		var now = Lib.getTimer();
		var dt = (now - lastTime) / 1000;
		lastTime = now;

		var dead:Array<Int> = [];
		for (id => mark in marks)
		{
			if (mark.held)
			{
				mark.age += dt;
				// little "pop" when the finger lands
				var t = Math.min(1, mark.age / POP_TIME);
				var s = 0.6 + 0.4 * (1 - (1 - t) * (1 - t));
				mark.shape.scaleX = mark.shape.scaleY = s;
				mark.shape.alpha = 1;
			}
			else
			{
				mark.fade += dt;
				var t = Math.min(1, mark.fade / FADE_TIME);
				mark.shape.alpha = 1 - t;
				mark.shape.scaleX = mark.shape.scaleY = 1 + 0.35 * t;
				if (t >= 1)
					dead.push(id);
			}
		}

		for (id in dead)
		{
			var mark = marks.get(id);
			if (mark.shape.parent != null)
				removeChild(mark.shape);
			marks.remove(id);
		}

		// preference turned off while rings were visible
		if (!ClientPrefs.data.touchIndicator)
			for (id => mark in marks)
				mark.held = false;
	}
}

private class Mark
{
	public var shape:Shape = new Shape();
	public var held:Bool = true;
	public var age:Float = 0;
	public var fade:Float = 0;

	public function new() {}
}
#end
