package flixel.addons.display;

#if (nme || flash)
	#if (FLX_NO_COVERAGE_TEST && !(doc_gen))
		#error "FlxRuntimeShader isn't available with nme or flash."
	#end
#else
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.util.FlxStringUtil;
#end
#if lime
import lime.utils.Float32Array;
#end
import openfl.display.BitmapData;
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;

using StringTools;

/**
 * An wrapper for Flixel/OpenFL's shaders, which takes fragment and vertex source
 * in the constructor instead of using macros, so it can be provided data
 * at runtime (for example, when using mods).
 *
 * HOW TO USE:
 * 1. Create an instance of this class, passing the text of the `.frag` and `.vert` files.
 *    Note that you can set either of these to null (making them both null would make the shader do nothing???).
 * 2. Use `flxSprite.shader = runtimeShader` to apply the shader to the sprite.
 * 3. Use `runtimeShader.setFloat()`, `setBool()` etc. to modify any uniforms.
 * 4. Use `setBitmapData()` to add additional textures as `sampler2D` uniforms
 *
 * @author MasterEric
 * @see https://github.com/openfl/openfl/blob/develop/src/openfl/utils/_internal/ShaderMacro.hx
 * @see https://dixonary.co.uk/blog/shadertoy
 */
class FlxRuntimeShader extends FlxGraphicsShader
{
	#if FLX_DRAW_QUADS
	// We need to add stuff from FlxGraphicsShader too!
	#else
	// Only stuff from openfl.display.GraphicsShader is needed
	#end
	// These variables got copied from openfl.display.GraphicsShader
	// and from flixel.graphics.tile.FlxGraphicsShader.

	static final PRAGMA_HEADER:String = "#pragma header";
	static final PRAGMA_BODY:String = "#pragma body";

	/**
	 * Constructs a GLSL shader.
	 * @param fragmentSource The fragment shader source.
	 * @param vertexSource The vertex shader source.
	 * Note you also need to `initialize()` the shader MANUALLY! It can't be done automatically.
	 */
	public function new(?fragmentSource:String, ?vertexSource:String, ?glslVersion:String):Void
	{
		if (glslVersion != null) {
			// Don't set the value (use getDefaultGLVersion) if it's null.
			this.glVersion = glslVersion;
		}

		if (fragmentSource == null)
		{
			this.glFragmentSource = __processFragmentSource(glFragmentSourceRaw);
		}
		else
		{
			this.glFragmentSource = __processFragmentSource(fragmentSource);
		}

		if (vertexSource == null)
		{
			this.glVertexSource = __processVertexSource(glVertexSourceRaw);
		}
		else
		{ 
			this.glVertexSource = __processVertexSource(vertexSource);
		}

		@:privateAccess {
			// This tells the shader that the glVertexSource/glFragmentSource have been updated.
			this.__glSourceDirty = true;
		}

		super();
	}

	/**
	 * Replace the `#pragma header` and `#pragma body` with the fragment shader header and body.
	 */
	@:noCompletion private function __processFragmentSource(input:String):String
	{
		return input.replace(PRAGMA_HEADER, glFragmentHeaderRaw).replace(PRAGMA_BODY, glFragmentBodyRaw);
	}

	/**
	 * Replace the `#pragma header` and `#pragma body` with the vertex shader header and body.
	 */
	@:noCompletion private function __processVertexSource(input:String):String
	{
		return input.replace(PRAGMA_HEADER, glVertexHeaderRaw).replace(PRAGMA_BODY, glVertexBodyRaw);
	}

	/**
	 * Modify a float parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setFloat(name:String, value:Float):Void
	{
		final shaderParameter:ShaderParameter<Float> = Reflect.field(this.data, name);
		@:privateAccess
		if (shaderParameter == null)
		{
			trace('[WARN] Shader float parameter ${name} not found.');
			return;
		}
		shaderParameter.value = [value];
	}

	/**
	 * Modify a float array parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setFloatArray(name:String, value:Array<Float>):Void
	{
		final shaderParameter:ShaderParameter<Float> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader float[] parameter ${name} not found.');
			return;
		}
		shaderParameter.value = value;
	}

	/**
	 * Modify an integer parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setInt(name:String, value:Int):Void
	{
		final shaderParameter:ShaderParameter<Int> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader int parameter ${name} not found.');
			return;
		}
		shaderParameter.value = [value];
	}

	/**
	 * Modify an integer array parameter of the shader.
	 *
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setIntArray(name:String, value:Array<Int>):Void
	{
		final shaderParameter:ShaderParameter<Int> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader int[] parameter ${name} not found.');
			return;
		}
		shaderParameter.value = value;
	}

	/**
	 * Modify a boolean parameter of the shader.
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setBool(name:String, value:Bool):Void
	{
		final shaderParameter:ShaderParameter<Bool> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader bool parameter ${name} not found.');
			return;
		}
		shaderParameter.value = [value];
	}

	/**
	 * Modify a boolean array parameter of the shader.
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setBoolArray(name:String, value:Array<Bool>):Void
	{
		final shaderParameter:ShaderParameter<Bool> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader bool[] parameter ${name} not found.');
			return;
		}
		shaderParameter.value = value;
	}

	/**
	 * Modify a bitmap data input of the shader.
	 * @param name The name of the parameter to modify.
	 * @param value The new value to use.
	 */
	public function setBitmapData(name:String, value:openfl.display.BitmapData):Void
	{
		final shaderInput:ShaderInput<openfl.display.BitmapData> = Reflect.field(this.data, name);
		if (shaderInput == null)
		{
			trace('[WARN] Shader sampler2D input ${name} not found.');
			return;
		}
		shaderInput.input = value;
	}

	/**
	 * Retrieve a float parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getFloat(name:String):Null<Float>
	{
		final shaderParameter:ShaderParameter<Float> = Reflect.field(this.data, name);
		if (shaderParameter == null || shaderParameter.value.length == 0)
		{
			trace('[WARN] Shader float parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value[0];
	}

	/**
	 * Retrieve a float array parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getFloatArray(name:String):Null<Array<Float>>
	{
		final shaderParameter:ShaderParameter<Float> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader float[] parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value;
	}

	/**
	 * Retrieve an integer parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getInt(name:String):Null<Int>
	{
		final shaderParameter:ShaderParameter<Int> = Reflect.field(this.data, name);
		if (shaderParameter == null || shaderParameter.value.length == 0)
		{
			trace('[WARN] Shader int parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value[0];
	}

	/**
	 * Retrieve an integer array parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getIntArray(name:String):Null<Array<Int>>
	{
		final shaderParameter:ShaderParameter<Int> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader int[] parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value;
	}

	/**
	 * Retrieve a boolean parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getBool(name:String):Null<Bool>
	{
		final shaderParameter:ShaderParameter<Bool> = Reflect.field(this.data, name);
		if (shaderParameter == null || shaderParameter.value.length == 0)
		{
			trace('[WARN] Shader bool parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value[0];
	}

	/**
	 * Retrieve a boolean array parameter of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getBoolArray(name:String):Null<Array<Bool>>
	{
		final shaderParameter:ShaderParameter<Bool> = Reflect.field(this.data, name);
		if (shaderParameter == null)
		{
			trace('[WARN] Shader bool[] parameter ${name} not found.');
			return null;
		}
		return shaderParameter.value;
	}

	/**
	 * Retrieve a bitmap data input of the shader.
	 * @param name The name of the parameter to retrieve.
	 * @return The value of the parameter.
	 */
	public function getBitmapData(name:String):Null<openfl.display.BitmapData>
	{
		final shaderInput:ShaderInput<openfl.display.BitmapData> = Reflect.field(this.data, name);
		if (shaderInput == null)
		{
			trace('[WARN] Shader sampler2D input ${name} not found.');
			return null;
		}
		return shaderInput.input;
	}

	/**
	 * Convert the shader to a readable string name. Useful for debugging.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			for (field in Reflect.fields(data))
				LabelValuePair.weak(field, Reflect.field(data, field))
		]);
	}
}
