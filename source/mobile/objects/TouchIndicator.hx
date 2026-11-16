
package mobile.objects;

#if TOUCH_CONTROLS_ALLOWED
import openfl.Lib;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.events.TouchEvent;

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

	function onTouchBegin(e:TouchEvent):Void press(e.touchPointID, e.stageX, e.stageY);
	function onTouchMove(e:TouchEvent):Void move(e.touchPointID, e.stageX, e.stageY);
	function onTouchEnd(e:TouchEvent):Void release(e.touchPointID);

	function onMouseDown(e:MouseEvent):Void
	{
		if (hasActiveTouch()) return;
		press(MOUSE_ID, e.stageX, e.stageY);
	}

	function onMouseMove(e:MouseEvent):Void
	{
		if (e.buttonDown) move(MOUSE_ID, e.stageX, e.stageY);
	}

	function onMouseUp(e:MouseEvent):Void release(MOUSE_ID);

	function hasActiveTouch():Bool
	{
		for (id => mark in marks)
			if (id != MOUSE_ID && mark.held) return true;
		return false;
	}

	function press(id:Int, x:Float, y:Float):Void
	{
		if (!ClientPrefs.data.touchIndicator) return;

		var mark = marks.get(id);

		if (mark == null)
		{
			mark = new Mark();
			marks.set(id, mark);
			addChild(mark.display);
		}

		mark.held = true;
		mark.age = 0;
		mark.fade = 0;
		mark.display.x = x;
		mark.display.y = y;
		mark.display.visible = true;
		mark.display.alpha = 1;
	}

	function move(id:Int, x:Float, y:Float):Void
	{
		var mark = marks.get(id);
		if (mark == null || !mark.held) return;

		mark.display.x = x;
		mark.display.y = y;
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

				var t = Math.min(1, mark.age / POP_TIME);
				var s = 0.6 + 0.4 * (1 - (1 - t) * (1 - t));

				mark.display.scaleX = mark.display.scaleY = s;
				mark.display.alpha = 1;
			}
			else
			{
				mark.fade += dt;

				var t = Math.min(1, mark.fade / FADE_TIME);

				mark.display.alpha = 1 - t;
				mark.display.scaleX = mark.display.scaleY = 1 + 0.35 * t;

				if (t >= 1) dead.push(id);
			}
		}

		for (id in dead)
		{
			var mark = marks.get(id);

			if (mark != null && mark.display.parent != null)
				removeChild(mark.display);

			marks.remove(id);
		}

		if (!ClientPrefs.data.touchIndicator)
			for (id => mark in marks)
				mark.held = false;
	}
}

private class Mark
{
	public var display:Sprite;
	public var held:Bool = true;
	public var age:Float = 0;
	public var fade:Float = 0;

	public function new()
	{
		display = new Sprite();

		var circle = new Shape();
		circle.graphics.beginFill(0x6666E1, 0.32);
		circle.graphics.lineStyle(3, 0x6666E1, 0.95);
		circle.graphics.drawCircle(0, 0, 30);
		circle.graphics.endFill();

		display.addChild(circle);
		display.mouseEnabled = false;
	}
}
#end
