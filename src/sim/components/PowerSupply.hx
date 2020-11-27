package sim.components;

class PowerSupply {
	var maxPower: Float;
	var currentPower: Float;
	var rechargeRate: Float;

	public function new (maxPower: Float, rechargeRate: Float) {
		this.maxPower = maxPower;
		this.currentPower = this.maxPower;
		this.rechargeRate = rechargeRate;
	}

	public function getCurrentPowerPercentage (): Float {
		return this.currentPower / this.maxPower;
	}

	public function consumePower (power: Float): Bool {
		if (this.currentPower >= power) {
			this.currentPower -= power;
			return true;
		}

		return false;
	}

	public function update () {
		this.currentPower = Math.min(this.currentPower + this.rechargeRate, this.maxPower);
	}
}