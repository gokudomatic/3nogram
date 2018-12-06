shader_type spatial;

uniform int mode : hint_range(0,2);
uniform vec4 color : hint_color;
uniform vec4 marked_color : hint_color;
uniform vec4 maybe_color : hint_color;
uniform vec4 revealed_color : hint_color;
uniform int marked = 0;
uniform bool found = false;
uniform bool reveal = false;
uniform bool hint_visible = true;

uniform float border_width = 0.02;

uniform sampler2D tex_square;
uniform sampler2D tex_circle;

uniform sampler2D tex_number;


void fragment() {
	vec3 tex = color.xyz;
	if(reveal){
		tex=revealed_color.xyz;
	} else {
		if(marked==1) {
			tex=marked_color.xyz;
		} else if(marked==2) {
			tex=maybe_color.xyz;
		}
		
		if(hint_visible){
			vec3 number_tex=texture(tex_number, UV).rgb;
			if (found){
				number_tex=min(vec3(1.0,1.0,1.0),number_tex+vec3(0.4,0.4,0.4));
			}
			tex = tex*number_tex;
			
			if (mode==1) {
				tex=tex*texture(tex_circle, UV).rgb;
			} else if (mode==2) {
				tex=tex*texture(tex_square, UV).rgb;
			}
		}
		if(UV.x<border_width || UV.y<border_width || UV.x>1.0-border_width || UV.y>1.0-border_width){
			tex=vec3(1,1,1);
		}
	}
	ALBEDO=tex;
}