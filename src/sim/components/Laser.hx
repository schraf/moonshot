package sim.components

class Laser extends h2d.Object {
    var lastFired: Float;
  
    static var COOLDOWN_TIME: Float = 1.5;
    static var RANGE:Float = 400.0;

    public function new (x: Float, y: Float, ?parent: h2d.Object) {
        super(parent);
        this.x = x;
        this.y = y;
        this.lastFired = 0.0;
    }
  
    public function canFireAt (pos: h2d.col.Point): Bool {
        var now = haxe.Timer.stamp();
        
        if ((now - this.lastFired) <= COOLDOWN_TIME) {
            return false;
        }
        
        if (globalToLocal(pos).lengthSq() > RANGE) {
            return false;
        }
        
        return true;
    }
  
    public function resetCooldown () {
        this.lastFired = haxe.Timer.stamp();
    }
}
