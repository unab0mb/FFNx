$input a_position, a_color0, a_texcoord0
$output v_color0, v_texcoord0

#include <bgfx/bgfx_shader.sh>

uniform mat4 d3dViewport;
uniform mat4 d3dProjection;
uniform mat4 worldView;

uniform vec4 VSFlags;
#define isTLVertex VSFlags.x > 0.0
#define blendMode VSFlags.y
#define isFBTexture VSFlags.z > 0.0

void main()
{
	vec4 pos = a_position;
    vec4 color = a_color0;
    vec2 coords = a_texcoord0;

    color.rgba = color.bgra;

    if (isTLVertex)
    {
        pos.w = 1.0 / pos.w;
        pos.xyz *= pos.w;
        pos = mul(u_proj, pos);
    }
    else
    {
#if BGFX_SHADER_LANGUAGE_HLSL
        pos = mul(mul(d3dViewport,mul(d3dProjection,worldView)), vec4(pos.xyz, 1.0));
#else
    #if BGFX_SHADER_LANGUAGE_SPIRV
        pos = mul(vec4(pos.xyz, 1.0), transpose(d3dViewport) * transpose(d3dProjection) * transpose(worldView));
    #else
        pos = mul(d3dViewport * d3dProjection * worldView, vec4(pos.xyz, 1.0));
    #endif
#endif

        if (color.a > 0.5) color.a = 0.5;
    }

    if (blendMode == 4.0) color.a = 1.0;
    else if (blendMode == 3.0) color.a = 0.25;

#if BGFX_SHADER_LANGUAGE_HLSL
#else
    #if BGFX_SHADER_LANGUAGE_SPIRV
    #else
        if (isFBTexture) coords.y = 1.0 - coords.y;
    #endif
#endif

    gl_Position = pos;
    v_color0 = color;
    v_texcoord0 = coords;
}

