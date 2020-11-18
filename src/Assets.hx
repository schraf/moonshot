import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;
	public static var background : hxd.res.Atlas;
	public static var fx : hxd.res.Atlas;
	public static var ship : hxd.res.Atlas;
	public static var ui : hxd.res.Atlas;

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
		tiles = dn.heaps.assets.Atlas.load("atlas/fx.atlas");
		background = hxd.Res.atlas.background;
		fx = hxd.Res.atlas.fx;
		ship = hxd.Res.atlas.ship;
		ui = hxd.Res.atlas.ui;
	}
}