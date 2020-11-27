package ui;

class Hud extends dn.Process {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;

	var flow : h2d.Flow;
	var invalidated = true;

	public var powerSupply: ProgressBar;

	public function new() {
		super(Game.ME);

		createRootInLayers(game.root, Const.DP_UI);
		root.filter = new h2d.filter.ColorMatrix(); // force pixel perfect rendering

		flow = new h2d.Flow(root);
		flow.paddingLeft = 50;
		flow.paddingTop = 50;

		var panel = new Panel('Ship Systems', flow);
		powerSupply = new ProgressBar('Power', 300, 50);
		panel.addRow(powerSupply);
		panel.addFooter();
	}

	override function onResize() {
		super.onResize();
		root.setScale(Const.UI_SCALE);
	}

	public inline function invalidate() invalidated = true;

	function render() {}

	override function postUpdate() {
		super.postUpdate();

		if( invalidated ) {
			invalidated = false;
			render();
		}
	}
}
