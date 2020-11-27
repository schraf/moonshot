import h2d.Bitmap;
import dn.Rand;

class Background extends h2d.Layers
{
	public static var STAR_DENSITY = 0.0001;
	public static var STAR_SIZE_THRESHOLD = 0.3; // smaller = more small stars
	public static var STAR_SMALL_SCALE = 0.25;
	public static var STAR_LARGE_SCALE = 0.5;

	public function addStars(bounds: h2d.col.Bounds) {
		var numberOfStars = Math.ceil(bounds.width * bounds.height * STAR_DENSITY);

		for (i in 0...numberOfStars) {
			var star = new h2d.Bitmap(Assets.fx.getTile("fxCircle0"), this);
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
		var moon = new h2d.Bitmap(Assets.background.getTile("moon"), this);
		moon.x = x;
		moon.y = y;
		moon.scale(scale);
	}

	public function addGround() {
		var ground = new h2d.Bitmap(Assets.background.getTile("ground"), this);
		ground.x = 0;
		ground.y = Const.VIEWPORT_HEIGHT - ground.tile.height;

		var tower = new h2d.Bitmap(Assets.background.getTile("tower"), this);
		tower.x = (Const.VIEWPORT_WIDTH * 0.5) - (tower.tile.width * 0.5);
		tower.y = ground.y - tower.tile.height + 150;
	}
}
