package ui;

class Button extends h2d.Interactive {

	public function new (name: String, width: Float, height: Float, ?parent: h2d.Object, ?shape: h2d.col.Collider) {
		super(width, height, parent, shape);

		var flow = new h2d.Flow(this);

		new h2d.Bitmap(Assets.ui.get("LargeEndCap"), flow);
		flow.addSpacing(5);

		var button = new h2d.Bitmap(Assets.ui.get("ButtonPrimary"), flow);
		flow.addSpacing(5);

		var flippedEndCap = Assets.ui.get("LargeEndCap");
		flippedEndCap.flipX();
		flippedEndCap.dx = 0.0;
		new h2d.Bitmap(flippedEndCap, flow);

		var label = new h2d.Text(Assets.fontSmall, button);
		label.text = name;
		label.x = button.tile.width - label.textWidth;
		label.y = button.tile.height - label.textHeight;
	}
}
