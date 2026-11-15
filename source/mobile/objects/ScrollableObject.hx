package mobile.objects;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxRect;
#if TOUCH_CONTROLS_ALLOWED
import flixel.util.FlxSignal;
import flixel.FlxObject;

class ScrollableObject extends TouchZone {
    public var onFullScroll(default,never):FlxTypedSignal<(delta:Int)->Void> = new FlxTypedSignal();
    public var onPartialScroll(default,never):FlxTypedSignal<(delta:Float) ->Void> = new FlxTypedSignal();
    public var onFullScrollSnap(default,never):FlxSignal = new FlxSignal();
    public var onTap(default,never):FlxSignal = new FlxSignal();

    private var isDragging:Bool = false;
    private var isTapping:Bool = false;
    private var lastYPos:Float = 0;
    private var partialScrollTracker:Float = 0;
    private var scrollScale:Float = 0;
    private var clickButton:FlxObject;

    public function new(scrollScale:Float,x:Float, y:Float, width:Float, height:Float,clickButton:FlxObject) {
        this.scrollScale = scrollScale;
        this.clickButton = clickButton;
        super(x,y,width,height);
    }
    override function update(elapsed:Float) {
        super.update(elapsed);
        var curDelta = getDeltaY();
        //MusicBea
        if (pointerJustPressedOnThis())
        {
            isDragging = false;
            isTapping = true;
        }
        else if (pointerJustReleased()) {
            if(isTapping){
                if(clickButton.camera == null || clickButton.camera.scroll != null){
                    if(TouchUtil.releasedOver(clickButton, clickButton.camera)) onTap.dispatch();
                }
                isTapping = false;
            }
            else if(isDragging) {
                onFullScrollSnap.dispatch();
                isDragging = false;
                var curDpad = Controls.instance.isInSubstate ? MusicBeatSubstate.instance.touchPad : MusicBeatState.getState().touchPad;
                if(curDpad != null) curDpad.active = true;
            }
            else return;
            
            partialScrollTracker = 0;
        }
        else if(pointerPressed() && (Math.abs(curDelta)) > 3)
            {
                if(isTapping){
                    isDragging = true;
                var curDpad = Controls.instance.isInSubstate ? MusicBeatSubstate.instance.touchPad : MusicBeatState.getState().touchPad;
                if(curDpad != null) curDpad.active = false;
                    isTapping = false;
                }
                else if(!isDragging) return;
                // What we moved now
                var dragMove = curDelta*scrollScale;

                partialScrollTracker += dragMove;
                onPartialScroll.dispatch(dragMove);

                if((Math.abs(Math.round(partialScrollTracker))) >= 1){
                    // We have a full scroll
                    var fullScroll = Math.round(partialScrollTracker);
                    partialScrollTracker -= fullScroll;
                    onFullScroll.dispatch(fullScroll);
                }
            }
    }

    // Phones & browsers use touches (browsers also accept the mouse). Desktop builds use the mouse only.
    private inline function pointerJustPressedOnThis():Bool {
        #if (mobile || html5)
        return TouchUtil.justPressed && TouchUtil.overlaps(this);
        #else
        return FlxG.mouse.justPressed && FlxG.mouse.overlaps(this,this.camera);
        #end
    }
    private inline function pointerJustReleased():Bool {
        #if (mobile || html5)
        return TouchUtil.justReleased;
        #else
        return FlxG.mouse.justReleased;
        #end
    }
    private inline function pointerPressed():Bool {
        #if mobile
        return TouchUtil.pressed || FlxG.mouse.pressed;
        #elseif html5
        return TouchUtil.pressed;
        #else
        return FlxG.mouse.pressed;
        #end
    }
    private function getjustPressed():FlxTouch
        {
            for (touch in FlxG.touches.list)
                if (touch.justReleased)
                    return touch;
    
            return null;
        }
    private function getDeltaY():Float {
        #if (mobile || html5)
        var first = FlxG.touches.getFirst();
        if(first != null) {
            var delta = first.viewY - lastYPos;
            lastYPos = first.viewY;
            return delta;
        }
        #if html5
        // no finger down -> the player is using a mouse
        return FlxG.mouse.deltaViewY;
        #else
        return 0;
        #end
        #else
        return FlxG.mouse.deltaViewY;
        #end
    }
}
#end
