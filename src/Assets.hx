import dn.heaps.slib.*;

class Assets {
	public static var fontPixel : h2d.Font;
	public static var fontTiny : h2d.Font;
	public static var fontSmall : h2d.Font;
	public static var fontMedium : h2d.Font;
	public static var fontLarge : h2d.Font;
	public static var tiles : SpriteLib;
	public static var background : SpriteLib;
	public static var fx : SpriteLib;
	public static var ship : SpriteLib;
	public static var ui : SpriteLib;
	
	public static var rocketLaunch: dn.heaps.Sfx;
	public static var thruster: dn.heaps.Sfx;

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
		background = dn.heaps.assets.Atlas.load("atlas/background.atlas");
		fx = dn.heaps.assets.Atlas.load("atlas/fx.atlas");
		ship = dn.heaps.assets.Atlas.load("atlas/ship.atlas");
		ui = dn.heaps.assets.Atlas.load("atlas/ui.atlas");

		rocketLaunch = new dn.heaps.Sfx(hxd.Res.sfx.rocket_launch);
		thruster = new dn.heaps.Sfx(hxd.Res.sfx.thruster);
	}
}