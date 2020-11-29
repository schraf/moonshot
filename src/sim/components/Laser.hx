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
		var laserPos = Game.ME.ship.body.getPosition().copy();
		laserPos.multiply(100);
		var offset = Game.ME.ship.body.getLocalPoint(new B2Vec2(this.x, this.y));
		laserPos.add(offset);
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

		return true;
	}

	public function resetCooldown () {
		this.lastFired = haxe.Timer.stamp();
	}
}
