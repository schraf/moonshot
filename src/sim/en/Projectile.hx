package sim.en;

import Entity.EntityTypeFlags;

class Projectile extends Entity {
	static var SIZE = 10;
	var pos: h2d.col.Point;

	public function new(x: Float, y: Float, dx: Float, dy: Float) {
		super(0, 0);

		this.typeFlags |= EntityTypeFlags.PROJECTILE;

		this.pos = new h2d.col.Point(x, y);
		this.dx = dx;
		this.dy = dy;

		var color = new h3d.Matrix();
		color.colorSet(0xD04B38, 0.8);

		spr.set(Assets.fx, "fxCircle");
		spr.setCenterRatio(0.5, 0.5);
		spr.filter = new h2d.filter.Group([
			new h2d.filter.ColorMatrix(color),
			new h2d.filter.Glow(0xD04B38, 0.2)
		]);
		setScale(SIZE / spr.tile.width);
		setPosPixel(this.pos.x, this.pos.y);
	}

	override function update() {
		this.pos.x += this.dx;
		this.pos.y += this.dy;
		setPosPixel(this.pos.x, this.pos.y);

		for (entity in Entity.ALL) {
			if (entity.collider != null) {
				if (entity.collider.contains(this.pos)) {
					entity.onCollision(this);
					destroy();
				}
			}
		}
	}
}
