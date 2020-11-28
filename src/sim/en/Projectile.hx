package en.sim;

class Projectile extends Entity {
	static var SIZE = 20;

	public function new(x: Float, y: Float, dx: Float, dy: Float) {
		super(0, 0);

		this.dx = dx;
		this.dy = dy;

		spr.set(Assets.fx, "lineDir");
		spr.setCenterRatio(0.5, 0.5);
		// spr.rotation = angle + Math.PI * 0.5;
		setScale(SIZE / spr.tile.width);
		setPosPixel(x, y);
	}

	override function update() {
		var x = centerX + this.dx;
		var y = centerY + this.dy;
		setPosPixel(x, y);
	}
}
