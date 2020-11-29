class Const {
	public static var FPS = 60;
	public static var FIXED_FPS = 30;
	public static var AUTO_SCALE_TARGET_WID = 1920; // -1 to disable auto-scaling on width
	public static var AUTO_SCALE_TARGET_HEI = 1080; // -1 to disable auto-scaling on height
	public static var SCALE = 1.0; // ignored if auto-scaling
	public static var UI_SCALE = 1.0;
	public static var GRID = 16;
	public static var VIEWPORT_WIDTH = 1920;
	public static var VIEWPORT_HEIGHT = 1080;

	public static var FIELD_WIDTH = 1920 * 2;
	public static var FIELD_HEIGHT = 1080 * 3;

	static var _uniq = 0;
	public static var NEXT_UNIQ(get,never) : Int; static inline function get_NEXT_UNIQ() return _uniq++;
	public static var INFINITE = 999999;

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_MAIN = _inc++;
	public static var DP_FRONT = _inc++;
	public static var DP_FX_FRONT = _inc++;
	public static var DP_TOP = _inc++;
	public static var DP_UI = _inc++;

	public static var SHIP_WIDTH = 9;
	public static var SHIP_HEIGHT = 9;
	public static var SHIP_PART_SCALE = 0.1;
	public static var SHIP_PART_ROTATE_SPEED = 0.001;
	public static var SHIP_HULL_STRENGTH = 1000.0;

	public static var SHIP_PANEL_WIDTH = 400;

	public static var PROJECTILE_SPEED = 10;

	public static var ASTEROID_SPEED = 0.1;
	public static var ASTEROID_ROTATION_SPEED = 2.0;

	public static var PACKAGE_ROTATION_SPEED = 0.01;

	public static var THRUST_FORCE = .5;
	public static var SHIPBUILDING_FADEOUT_SECONDS = 5;
}
