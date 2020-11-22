package sim.en;

class House extends Entity {
	static var SIZE = 25;

	public function new(x, y, angle) {
		super(0, 0);

		Entity.HOUSES.push(this);

		spr.set(Assets.background, "house");
		spr.setCenterRatio(0.5, 0.7);
		spr.rotation = angle + Math.PI * 0.5;
		setScale(SIZE / spr.tile.width);
		setPosPixel(x, y);
	}

	override function dispose() {
		Entity.HOUSES.remove(this);
		super.dispose();
	}

	override function update() {
	}
}
