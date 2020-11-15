
class Background extends h2d.Layers
{
	public static var STAR_DENSITY = 0.0001;
	public static var STAR_SIZE_THRESHOLD = 0.3; // smaller = more small stars
	public static var STAR_SMALL_SCALE = 0.5;
	public static var STAR_LARGE_SCALE = 1.0;

	public function addStars(bounds: h2d.col.Bounds) {
		var numberOfStars = Math.ceil(bounds.width * bounds.height * STAR_DENSITY);

		for (i in 0...numberOfStars) {
			var star = Assets.tiles.getBitmap("fxCircle0", this);
			star.x = Math.random() * bounds.width + bounds.xMin;
			star.y = Math.random() * bounds.height + bounds.yMin;

			if (Math.random() < STAR_SIZE_THRESHOLD) {
				star.scale(STAR_LARGE_SCALE);
			} else {
				star.scale(STAR_SMALL_SCALE);
			}
		}
	}

	public function addMoon(x: Float, y: Float, scale: Float) {
		var moon = Assets.tiles.getBitmap("moon", this);
		moon.x = x;
		moon.y = y;
		moon.scale(scale);
	}
}
