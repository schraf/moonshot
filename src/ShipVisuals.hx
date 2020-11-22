import ShipDefinition.ShipPartAttachment;

class ShipVisuals {

	static function createPartVisuals(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Bitmap {
		var part = new h2d.Bitmap(Assets.ship.getTile(tileName), parent);
		part.width = width;
		part.height = height;
		part.name = tileName;
		return part;
	}

	static function createSimpleShipPart(tileName: String, width: Float, height: Float, ?parent: h2d.Object): h2d.Bitmap {
		var base = createPartVisuals("base", width, height, parent);
		createPartVisuals(tileName, width, height, base);
		return base;
	}

	public static function create(part: Data.ShipPart, width: Float, height: Float, attachments: Int, ?parent: h2d.Object): h2d.Bitmap {
		var base = createPartVisuals("base", width, height, parent);
		var top = createPartVisuals(part.tile_name, width, height, base);
		top.rotation = part.rotation * Math.PI / 180;

		if (part.rotation == 90) {
			top.x += width;
		} else if (part.rotation == 180) {
			top.x += width;
			top.y += height;
		} else if (part.rotation == 270) {
			top.y += height;
		}

		setAttachments(base, attachments);
		return base;
	}

	public static function createFromDefinition(definition: ShipDefinition, width: Float, height: Float, ?parent: h2d.Object): h2d.Object {
		var object = new h2d.Object(parent);
		var offsetX = Const.SHIP_WIDTH * width * 0.5;
		var offsetY = Const.SHIP_HEIGHT * height * 0.5;

		for (shipPartDefinition in definition.parts) {
			var part = create(shipPartDefinition.part, width, height, shipPartDefinition.attachments, object);
			part.x = shipPartDefinition.x * width - offsetX;
			part.y = shipPartDefinition.y * height - offsetY;
		}

		return object;
	}

	public static function addAttachment(partVisual: h2d.Bitmap, attachmentDir: ShipPartAttachment) {
		var attachment = createPartVisuals("attachment", partVisual.width, partVisual.height, partVisual);

		switch (attachmentDir) {
			case ShipPartAttachment.Top:
				attachment.rotate(Math.PI);
				attachment.x += attachment.width;
				attachment.y += attachment.height;
			case ShipPartAttachment.Bottom:
			case ShipPartAttachment.Left:
				attachment.rotate(Math.PI * 0.5);
				attachment.x += attachment.width;
			case ShipPartAttachment.Right:
				attachment.rotate(Math.PI * 1.5);
				attachment.y += attachment.height;
		}
	}

	public static function setAttachments(partVisual: h2d.Bitmap, attachments: Int) {
		var i = partVisual.numChildren - 1;

		while (i >= 0) {
			var child = partVisual.getChildAt(i);

			if (child.name == "attachment") {
				child.remove();
			}
			--i;
		}

		if (attachments & ShipPartAttachment.Bottom != 0) {
			addAttachment(partVisual, ShipPartAttachment.Bottom);
		}

		if (attachments & ShipPartAttachment.Top != 0) {
			addAttachment(partVisual, ShipPartAttachment.Top);
		}

		if (attachments & ShipPartAttachment.Left != 0) {
			addAttachment(partVisual, ShipPartAttachment.Left);
		}

		if (attachments & ShipPartAttachment.Right != 0) {
			addAttachment(partVisual, ShipPartAttachment.Right);
		}
	}
}
