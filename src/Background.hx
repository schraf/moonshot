import dn.Rand;

class Background extends h2d.Layers
{
	public static var NUMBER_OF_STARS = 16;
	public static var SIZE_THRESHOLD = 0.3; // smaller = more small stars
	public static var SMALL_SCALE = 0.5;
	public static var LARGE_SCALE = 1.0;

	public static function addToLayer(layer:h2d.Layers): Background {
		var background = new Background(layer);
		background.addStars();
		background.addMoon();
		return background;
	}

	public function addStars() {
		for(i in 0...NUMBER_OF_STARS) {
			var star = Assets.tiles.getBitmap("fxCircle0", this);
			star.x = Math.random() * Main.ME.w();
			star.y = Math.random() * Main.ME.h();

			if (Math.random() < SIZE_THRESHOLD) {
				star.scale(LARGE_SCALE);
			} else {
				star.scale(SMALL_SCALE);
			}
		}
	}

	public function addMoon() {
		var moon = Assets.tiles.getBitmap("moon", this);
		moon.x = Main.ME.w() * 0.7;
		moon.y = Main.ME.h() * 0.2;
		moon.scale(0.2);
	}
}
