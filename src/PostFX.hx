
class FilmGrainShader extends h3d.shader.ScreenShader {
	static var SRC = {
		@param var texture: Sampler2D;
		@param var time: Float;
		@param var strength: Float;
		@param var speed: Float;
		@param var distortion: Float;
		@param var iterations: Int;
		@param var blend: Float;
		@param var vignetteSize: Float;
		@param var vignetteSpeed: Float;
		@param var vignetteStrength: Float;

		function sample(uv: Vec2): Vec4 {
			var bgColor = vec4(0.098, 0.196, 0.282, 1.0);
			var texColor = texture.get(uv);
			return vec4((texColor.rgb * texColor.a) + (bgColor.rgb * (1.0 - texColor.a)), 1.0);
		}

		function brownConradyDistortion(uv: Vec2, scalar: Float): Vec2 {
			uv = (uv - 0.5) * 2.0;
			var barrelDistortion = -0.02 * scalar;
			var r2 = dot(uv, uv);
			uv *= 1.0 + barrelDistortion * r2;
			return (uv / 2.0) + 0.5;
		}

		function grayscale(color: Vec4): Vec4 {
			return vec4(dot(color.xyz, vec3(.299, .587, .114)));
		}

		function vignette(uv: Vec2, time: Float): Vec4
		{
			uv *=  1.0 - uv.yx;
			var vig: Float = uv.x * uv.y * vignetteSize;
			var t: Float = sin(time * 23.0) * cos(time * 8.0 + 0.5);
			vig = pow(vig, 0.4 + t * vignetteSpeed);
			return vec4(vec3(vig), 1.0);
		}

		function fragment() {
			var texColor = sample(calculatedUV);

			var colourScalar: Vec4 = vec4(700.0, 560.0, 490.0, 1.0);
			colourScalar /= max(max(colourScalar.x, colourScalar.y), colourScalar.z);
			colourScalar *= 2.0;
			colourScalar *= distortion;

			var chromaticAberration  = vec4(0.0);

			for (i in 0...iterations) {
				chromaticAberration.r += sample(brownConradyDistortion(calculatedUV, colourScalar.r)).r;
				chromaticAberration.g += sample(brownConradyDistortion(calculatedUV, colourScalar.g)).g;
				chromaticAberration.b += sample(brownConradyDistortion(calculatedUV, colourScalar.b)).b;
				colourScalar *= 0.99;
			}

			chromaticAberration = chromaticAberration / float(iterations);
			chromaticAberration.a = 1.0;

			var sepia: Vec4 = vec4(1.2, 1.0, 0.0, 1.0) * grayscale(texColor);
			var x: Float = (calculatedUV.x + 4.0) * (calculatedUV.y + 4.0) * (time * speed);
			var grain: Vec4 = vec4(mod((mod(x, 13.0) + 1.0) * (mod(x, 123.0) + 1.0), 0.01)-0.005) * strength;
			pixelColor = mix(sepia, chromaticAberration, blend);
			pixelColor += grain;
			pixelColor *= min(vignette(calculatedUV, time) + (1.0 - vignetteStrength), 1.0);
			pixelColor.a = 1.0;
		}
	}
}

class PostFX {
	static var shader: FilmGrainShader;

	public static function init(scene: h2d.Scene) {
		#if debug
		ui.Console.ME.addCommand(
			"filmgrain",
			"Sets the post fx film grain settings",
			[
				{ name: "strength", t: AFloat, opt: false },
				{ name: "speed", t: AFloat, opt: false },
				{ name: "distortion", t: AFloat, opt: false },
				{ name: "iterations", t: AInt, opt: false },
				{ name: "blend", t: AFloat, opt: false },
				{ name: "vignette_size", t: AFloat, opt: false },
				{ name: "vignette_speed", t: AFloat, opt: false },
				{ name: "vignette_strength", t: AFloat, opt: false },
			],
			function (strength: Float, speed: Float, distortion: Float, iterations: Int, blend: Float, vignetteSize: Float, vignetteSpeed: Float, vignetteStrength: Float) {
				shader.strength = strength;
				shader.speed = speed;
				shader.distortion = distortion;
				shader.iterations = iterations;
				shader.vignetteSize = vignetteSize;
				shader.vignetteSpeed = vignetteSpeed;
				shader.vignetteStrength =vignetteStrength;
			});
		#end

		shader = new FilmGrainShader();
		shader.strength = 10.0;
		shader.speed = 5.0;
		shader.distortion = 0.25;
		shader.iterations = 8;
		shader.blend = 0.95;
		shader.vignetteSize = 20.0;
		shader.vignetteSpeed = 0.02;
		shader.vignetteStrength = 0.50;
		scene.filter = new h2d.filter.Shader(shader);
	}

	public static function update(tmod: Float) {
		shader.time += tmod;
	}
}
