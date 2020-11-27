package ui;

import h2d.Graphics;

class ProgressBar extends h2d.Graphics {
	var width: Float;
	var height: Float;
	var value: Float;
	var label: String;

	static var FG_COLOR: Int = 0xD04B38;
	static var BG_COLOR: Int = 0x7C7561;

	public function new (label: String, width: Float, height: Float, ?parent: h2d.Object) {
		super(parent);
		this.width = width;
		this.height = height;
		this.value = 1.0;
		this.label = label;

		var text = new h2d.Text(Assets.fontSmall, this);
		text.text = this.label;
		text.textColor = 0xFFFFFF;

		redraw();
	}

	public function setValue (value: Float) {
		this.value = Math.max(0, Math.min(value, 1.0));
		redraw();
	}

	private function redraw () {
		clear();
		beginFill(BG_COLOR);
		drawRect(0.0, 0.0, this.width, this.height);
		endFill();

		beginFill(FG_COLOR);
		drawRect(0.0, 0.0, this.value * this.width, this.height);
		endFill();

	}
}