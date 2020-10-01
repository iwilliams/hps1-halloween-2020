shader_type spatial; 
render_mode skip_vertex_transform, diffuse_lambert_wrap, specular_disabled, vertex_lighting;

uniform vec4 color : hint_color;
uniform sampler2D albedoTex : hint_albedo;
uniform sampler2D albedoTexR : hint_albedo;
uniform sampler2D albedoTexG : hint_albedo;
uniform sampler2D albedoTexB : hint_albedo;
uniform float specular_intensity : hint_range(0, 1);
uniform float resolution = 256;
const float cull_distance = 15.;
uniform vec2 uv_scale = vec2(1.0, 1.0);
uniform vec2 uv_offset = vec2(.0, .0);
uniform bool mix_textures = false;

varying vec4 vertex_coordinates;

uniform bool dither_enabled = true;
uniform float dither_resolution = 1;
uniform float dither_intensity = .1;
uniform int color_depth = 31;
uniform vec3 dither_luminosity = vec3(.299, 0.587, 0.114);

// https://gist.github.com/jw-0/9486042b5343c1f4f90451de7f4ef86e
float dither4x4(vec2 position, float brightness)
{
	float x = floor(mod(position.x, 4));
	float y = floor(mod(position.y, 4));
	float index = floor(x + y * 4.0);
	float limit = 0.0;

	if(x < 8.0)
	{
		if (index == float(0))  { limit = 0.0625; }
		else if (index == float(1))  { limit = 0.5625; }
		else if (index == float(2))  { limit = 0.1875; }
		else if (index == float(3))  { limit = 0.6875; }
		else if (index == float(4))  { limit = 0.8125; }
		else if (index == float(5))  { limit = 0.3125; }
		else if (index == float(6))  { limit = 0.9375; }
		else if (index == float(7))  { limit = 0.4375; }
		else if (index == float(8))  { limit = 0.25;   }
		else if (index == float(9))  { limit = 0.75;   }
		else if (index == float(10)) { limit = 0.125;  }
		else if (index == float(11)) { limit = 0.625;  }
		else if (index == float(12)) { limit = 1.0;    }
		else if (index == float(13)) { limit = 0.5;    }
		else if (index == float(14)) { limit = 0.875;  }
		else if (index == float(15)) { limit = 0.375;  } 
	}
	return brightness < limit ? 1.0 : 0.0;
}

// https://stackoverflow.com/a/42470600
vec4 band_color(vec4 _color, int num_of_colors)
{
	vec4 num_of_colors_vec = vec4(float(num_of_colors));
	return floor(_color * num_of_colors_vec) / num_of_colors_vec;
}

void vertex() {
    UV = UV * uv_scale + uv_offset;
    
    float vertex_distance = length((MODELVIEW_MATRIX * vec4(VERTEX, 1.0)));
    
    VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float vPos_w = (PROJECTION_MATRIX * vec4(VERTEX, 1.0)).w;
    VERTEX.xy = vPos_w * floor(resolution * VERTEX.xy / vPos_w) / resolution;
    vertex_coordinates = vec4(UV * VERTEX.z, VERTEX.z, .0);
    
    if (vertex_distance > cull_distance)
        VERTEX = vec3(.0);
}

void fragment() {
    vec2 affine_coord = vertex_coordinates.xy / vertex_coordinates.z;
    vec2 tex_coord = mix(affine_coord, UV.xy, 0);
    vec4 tex = vec4(0.);
    
    if (mix_textures) {
        tex = mix(tex, texture(albedoTexR, tex_coord), COLOR.r);
        tex = mix(tex, texture(albedoTexG, tex_coord), COLOR.g);
//        tex.rgb = COLOR.rgb;
//        tex = mix(texture(albedoTexR, tex_coord), vec4(0.), 0.);
    } else {
        tex = texture(albedoTex, tex_coord);
    }
    
    tex.rgb *= COLOR.rgb;
    vec4 banded_tex = band_color(tex, color_depth);
    
    if (dither_enabled) {
        float luma = dot(tex.rgb, dither_luminosity);
        vec4 checker = vec4(vec3(dither4x4(vec2(dither_resolution) * FRAGCOORD.xy, luma)), 1);
        banded_tex = mix(banded_tex, banded_tex * checker, dither_intensity);
    }

//    ALBEDO = banded_tex.rgb;
    
    ALBEDO = tex.rgb;
    SPECULAR = specular_intensity;
}