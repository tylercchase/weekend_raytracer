shader_type canvas_item;

uniform vec3 origin = vec3(0);


struct ray {
	vec3 origin;
	vec3 direction;
};

struct sphere {
	vec3 center;
	float radius;
};

struct hit_record {
	vec3 p;
	vec3 normal;
	float t;
	bool front_face;
};

void set_face_normal(hit_record hit, ray r, vec3 outward_normal) {
	hit.front_face = dot(r.direction, outward_normal) < 0.0;
	hit.normal = hit.front_face ? outward_normal : -outward_normal;
}
vec3 at(ray raycast, float delta) {
	return raycast.origin + raycast.direction * delta;
}

bool hit_sphere(vec3 center, float radius, ray r, inout hit_record rec, float t_min, float t_max) {
	vec3 oc = r.origin - center;

	float a = length(r.direction) * length(r.direction);
	float half_b = dot(oc, r.direction);
	float c = (length(oc) * length(oc)) - (radius * radius);
	float discriminant = half_b*half_b - a*c;
	
	if (discriminant < 0.0) {
		return false;
	} 
//	float sqrtd = sqrt(discriminant);
	
	return true; //(-b - sqrt(discriminant)) / (2.0 * a);
}

bool check_hits(ray r, float t_min, float t_max, inout hit_record rec, sphere world[2]) {
	bool hit_anything = false;
	hit_record temp_rec;
	float closest_so_far = t_max;
	for(int i = 0; i< world.length(); i++) {
		sphere temp = world[i];
		if(hit_sphere(temp.center,temp.radius,r, temp_rec, t_min, t_max)) {
			hit_anything = true;
			
		}
	}
	return false;
}

vec3 ray_color(ray r, sphere world[2]) {
	hit_record temp;
	bool hit = hit_sphere(vec3(0.0,0.0,-1.0), 0.5, r, temp,0.0,1.0);
	if(hit) {
		return vec3(0.0,1.0,0);
	}
//	if (t > 0.0) {
//		vec3 N = vec3(at(r,t) - vec3(0,0,-1));
//		return 0.5*vec3(N.x + 1.0, N.y + 1.0, N.z + 1.0);
//	}
	
	vec3 direction = r.direction;
	float t = 0.5*(direction.y + 1.0);
	return (1.0 - t) * vec3(1.0) + t*vec3(0.5,0.7,1.0);
}

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
	
    const float aspect_ratio = 16.0 / 9.0;
    const int image_width = 400;
    const int image_height = (image_width / int(aspect_ratio));
    float viewport_height = 2.0;
    float viewport_width = aspect_ratio * viewport_height;
    float focal_length = 1.0;

    vec3 horizontal = vec3(viewport_width, 0, 0);
    vec3 vertical = vec3(0, viewport_height, 0);
    vec3 lower_left_corner = origin - horizontal/2.0 - vertical/2.0 - vec3(0, 0, focal_length);
	
	sphere world[] = {
		sphere(vec3(0,0,-1.0),0.5),
		sphere(vec3(0,0,0),100.0)
	};
	
	int samples_per_pixel = 100;
	vec3 r_color = vec3(0);
	for(int s = 0; s < samples_per_pixel; s++) {
		float rand = random(UV);
		ray r = ray(origin,
		 lower_left_corner + (UV.x + rand * 0.00001)*horizontal + (UV.y + rand * 0.00001)*vertical - origin // TODO: don't like this figure out a more shadery way of doing this since we have texture posistions
		);
		
		r_color += ray_color(r, world);
	}
	vec3 color = r_color * vec3(1.0/float(samples_per_pixel));
	color = vec3(clamp(color.r,0.0,1.0), clamp(color.g,0.0,1.0), clamp(color.b,0.0,1.0));
	
	COLOR = vec4(color.r,color.g,color.b, 1.0);
}
