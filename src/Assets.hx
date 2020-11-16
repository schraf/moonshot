import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;

	static var initDone = false;
	public static function init() {
		if( initDone )
			return;
		initDone = true;

		fontPixel = hxd.Res.fonts.minecraftiaOutline.toFont();
		fontTiny = hxd.Res.fonts.SquadaOne16.toFont();
		fontSmall = hxd.Res.fonts.SquadaOne32.toFont();
		fontMedium = hxd.Res.fonts.SquadaOne64.toFont();
		fontLarge = hxd.Res.fonts.SquadaOne96.toFont();
		tiles = dn.heaps.assets.Atlas.load("atlas/tiles.atlas");
	}
}