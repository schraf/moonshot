package sim.components;

import box2D.common.math.B2Vec2;

class Laser extends h2d.Object {
	var lastFired: Float;

	static var COOLDOWN_TIME: Float = 1.5;
	static var RANGE:Float = 400.0;

	public function new (x: Float, y: Float, ?parent: h2d.Object) {
		super(parent);
		this.x = x;
		this.y = y;
		this.lastFired = haxe.Timer.stamp();
	}

	public function getWorldPosition() {
		var ship = Game.ME.ship;
		var b2x = (this.x + ship.shipPartSize/2)/100;
		var b2y = (this.y + ship.shipPartSize/2)/100;
		var laserPos = ship.body.getWorldPoint(new B2Vec2(b2x, b2y));
		laserPos.multiply(100);
		return laserPos;
	}

	public function canFireAt(pos: h2d.col.Point): Bool {
		var now = haxe.Timer.stamp();

		if ((now - this.lastFired) <= COOLDOWN_TIME) {
			return false;
		}

		var laserPos = getWorldPosition();
		var dx = laserPos.x - pos.x;
		var dy = laserPos.y - pos.y;

		if (dx*dx + dy*dy > RANGE*RANGE) {
			return false;
		}

		// POLISH: check if facing towards pos

		return true;
	}

	public function resetCooldown () {
		this.lastFired = haxe.Timer.stamp();
	}
}
