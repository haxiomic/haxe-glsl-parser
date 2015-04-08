/*
This shader uses spheres and cilynders deformations to create more complex shapes, it´s
loosely based on the domain warping commented in http://www.iquilezles.org/www/articles/warp/warp.htm

The idea is to use a local coordinate system vector and give it different scales depending on
the shape´s needs. for example if you define a sphere as:

sphere = length(u) - ratio

Being "u" a local vector, you can scale the "X" and "Y" values of "U" like:
u.x = 0.02 * pow(u.x, 2.0)
u.y = 0.02 * pow(u.y, 2.0)
u.z = 0.02 * pow(u.z, 2.0)
and this gives you a much less rounded sphere.

For the cilynders you can change the circle profile around the extruded axis using the
local or global coordinates to adapt ratios or scales.

Finally you can adapt how the circle profiles change around the axis using pow functions to
make it curved as you desire (I used differents exponents in the main body to make the lower front
part very pronounced, and the lower back part very "linear".

To create the interpolations for the changes in exponentes for the pow functions I use sometimes
the clamp function to limint the values around the axis of deformation. this is one example of that

interpoler = 0.9 * pow(clamp(0.5 * u.y / largo, 0.0, 1.0), 1.2);

Here the clamp function limits the main value from 0.0 to 0.5, after that, I defined how curved
the intepolation would be using the pow function with a 1.2 exponent (if I use a 7.0 exponent the curve would
be very pronounced. After that I scale the interpolation to 90% using the 0.9 value.

Note that the previous interpolation uses the local "Y" coordenate system to define it.
*/



//#define SHADOWS

//const for ray marching
const int max_iterations = 150;
const float stop_threshold = 0.1;
const float grad_step = 0.1;
const float clip_far = 3000.0;



const float PI = 3.14159265359;	
float uAngle;

//rotations around angles...
mat3 rotX(float angle) {
	angle = radians(angle);
	return mat3(1.0, 0.0, 0.0,
				0.0, cos(angle), -sin(angle),
				0.0, sin(angle), cos(angle));
}

mat3 rotY(float angle) {
	angle = radians(angle);
	return mat3(cos(angle), 0.0, sin(angle),
				0.0, 1.0, 0.0,
				-sin(angle), 0.0, cos(angle));
}

mat3 rotZ(float angle) {
	angle = radians(angle);
	return mat3(cos(angle), -sin(angle), 0.0,
				sin(angle), cos(angle), 0.0,
				0.0, 0.0, 1.0);
}

//Distance for the propeller 
float alabe(vec3 u, float desface) {
	float ratio = 20.0;
	float val = 12.0 * ratio;
	u.y += val * cos(radians(desface));
	u.x += val * sin(radians(desface));
	u *=rotZ(desface);
	u.y *= 0.08 + step(u.y, 0.0) * 0.42;
	u.z *= 3.0;
	
	return length(u) - ratio;
}

//Distance for the tires
float sdTorus( vec3 p, vec2 t ) {
		vec2 q = vec2(length(p.yz)-t.x,p.x);
		return length(q)-t.y;
}


//Distance field of the plane
vec3 dist_field(vec3 p) {

	p *= rotY(uAngle * 0.1);
	p *= rotX(7.0);

	//Vector that defines the distance (x), color (y), and (z) is used for the eyes color
	vec3 outData = vec3(0.0, 0.0, 0.0);		
	
	//The original point always remains the same, the U vector is used as a local coordinate system
	vec3 u = p.xyz;
	
	//Main body (fuselaje), it´s modeled using a deformed cilynder.
	float ratio = 100.0;
	float largo = 600.0;
	float scalarY = 0.7;
	float scalarX = 0.015;
	float interpoler = 0.0;
	if(u.z > 0.0) {
		float sep = 80.0;
		float expo = 7.0 - 5.9 * clamp(0.5 * (p.y + sep) / sep, 0.0, 1.0);
		interpoler = step(-u.z, 0.0) * pow(u.z / largo, expo);
		scalarX += 0.005 * interpoler;
		scalarY -= 0.5 * interpoler;
		ratio -= 60.0 * interpoler;
	} else { 
		float limite = step(u.z, 0.0) * abs(u.z) / largo;
		interpoler =  pow(limite, 2.0);
		scalarX += 0.2 * pow(limite, 5.0);
		ratio -= 70.0 * interpoler;
		u.y -= 40.0 * interpoler;
	}
	u.x = scalarX * pow(p.x, 2.0);
	u.y += step(u.y, 0.0) *scalarY * (ratio - abs(u.x));
	float fuselaje = 0.2 * max(length(u.xy) - ratio, abs(u.z) - largo);
	
	
	//antenna, this is also modeled as a deformed cilynder and then added to the main body
	u.xyz = p.xyz;
	largo = 115.0;
	ratio = 12.0;
	u.z += 150.0;
	u.y -= largo;
	float sep = 20.0;
	ratio -= 6.0 * clamp(0.5 * (p.y - sep - 100.0) / sep, 0.0, 1.0);
	ratio -= 0.3 * ratio * clamp(pow(u.y / largo, 3.0), 1.0, 0.0);		
	float antena = max(length(u.xz) - ratio, abs(u.y) - largo);
	
	fuselaje = min(fuselaje, antena);
	
	//tail, another deformed cilynder added to the main body
	u.xyz = p.xyz;
	u.z += 450.0;
	u.z *= 0.15 + 0.25 * step(-u.z, 0.0);
	ratio = 30.0;
	float colaHeight = 300.0;
	
	interpoler = u.y / colaHeight;
	ratio -= 20.0 * interpoler;
	u.z += 11.0 * interpoler;
		
	float cola = max(length(u.xz) - ratio, abs(u.y) - colaHeight);
	cola = max(cola, -p.y);
	
	//This is a deformed sphere for the upper border of the tail
	u.y = p.y - colaHeight;
	u.y *= 0.3;
	cola = min(cola, length(u) - ratio);
	
	fuselaje = min(fuselaje, cola);
	outData.x = fuselaje;
	
	/*
	The propeller is modeled deforming a spheres, there is the main sphere that holds
	the blades defined in the "alabe" function. the blades are added to the main sphere
	this part of the plain is treated as a different piece to have its own paiting.
	*/
	
	u.xyz = p.xyz;
	u.z = p.z - 600.0;
	u.y += 5.0;
	u.z *= 0.55;
	float helix =  length(u.xyz) - 42.0;
	
	float desface = -uAngle * 0.5;
	u.z = p.z - 615.0;
	
	for(int i = 0; i < 3; i ++) helix = min(helix, alabe(u, desface + 120.0*float(i)));
	helix *= 0.3;
	
	outData.x = min( helix, outData.x );
		
	/*
	Wings distance function, the wings are also modeled as a deformed
	cilynder and treated as a different piece to have its own paiting.
	*/
	u.xyz = p.xyz;
	u.z -= 300.0;
	u.z *= u.z > 0.0 ? 0.35 : 0.1;
	u.y += 130.0;
	ratio = 30.0;
	vec2 sections = vec2(180.0, 1000.0);
	interpoler = step(-abs(u.x), -sections.x) * pow((abs(u.x) - sections.x) / sections.y, 1.0);
	u.y -= 120.0 * interpoler;
	ratio -= 20.0 * interpoler;
	
	float wings = max(length(u.yz) - ratio, abs(u.x) - sections.y);
	
	//these are deformed spheres that defines the borders of the wings.
	u.x = abs(p.x) - sections.y;
	u.x *= 0.3;
	wings = min(wings, length(u) - ratio);
	outData.x = min( wings, outData.x );

	/*
	Modeling of the back wings. It´s the same method used for the wings,
	but there is no change of shape in the profile.
	*/
	u.xyz = p.xyz;
	u.z += 450.0;
	u.z *= 0.1 + 0.25 * step(-u.z, 0.0);
	ratio = 20.0;
	float backWidth = 400.0;
	interpoler = abs(u.x) / backWidth;
	ratio -= 12.0 * interpoler;
	u.z += 12.0 * interpoler;
	
	//Deformed spheres for the borders of the back wings	
	float backWings = max(length(u.yz) - ratio, abs(u.x) - backWidth);
	u.x = abs(p.x) - backWidth;
	u.x *= 0.3;
	backWings = min(backWings, length(u) - ratio);		
	outData.x = min( backWings, outData.x );
	
	/*
	Modeling of the head (cockpit), since this part was modeled using 
	a different file it had to be scaled to put in the plane. The model uses
	two deformed spheres 

	Since there is a need to scale and adapt the head, another local coordinate
	system vector "v" is used to preserve the main "P" vector.
	*/
	
	vec3 v = p.xyz;
	v.y -= 120.0;
	v.z -= 110.0;
	v *= 2.7;
	v *= rotX (-4.8);
	u.xyz= v.xyz;
	
	u.x /= (0.65 + 0.15 * (200.0 - v.y) / 200.0);
	u.y = exp(v.y / 55.0);
	u.z /= (1.0 + 0.0025 * (200.0 - v.y));
	
	//this is the plane hood... 
	vec3 w = u.xyz;
	w.y = exp((v.y - 185.0)/ 55.0);
	w.y *= 8200.0;
	w.x = 0.005 * pow(w.x, 2.0);
	w.x *= (1.0 + 0.001 * v.z);
	w.z *= 0.2 * step(-w.z, 0.0);
	float base = max(length(w) - 200.0, -v.y - 130.0);
	base = max(base, v.z - 1300.0);
	base = max(base, -v.z + 50.0);
	
	//Here we start with the cockpit... 
	u.y = exp(v.y / 55.0);
	if(u.z > 0.0) {
		u.z *= 0.8;
		u.z *= (1.2 + pow(clamp((240.0 - v.y) / 200.0, 0.0, 1.0), 0.6));
		u.z /= (1.0 + 0.002 * (200.0 - v.y));
	} 
	
	float head = max(length(u) - 200.0, -v.y - 130.0);
	head = min(head, base);
	head *= 0.5;		
	outData.x = min( head, outData.x );
	
	
	//This is the landing train under the wings.
	u.xyz = p.xyz;
	ratio = 10.0;
	largo = 120.0;
		
	u.y += largo + 140.0;
	u.x = -abs(p.x) + 220.0;
	u.z -= 250.0;
	u *= rotZ(20.0);
		
	u.x = 0.02 * pow(u.x, 2.0);
	u.z = 0.02 * pow(u.z, 2.0);
	interpoler = 0.0;
	interpoler = step(-u.y, 0.0) * 0.9 * pow(clamp(0.5 * u.y / largo, 0.0, 1.0), 1.2);
	ratio -= step(u.y , 0.0) * 5.0;
	scalarY = 0.5;
	u.z *= scalarY - interpoler;
		
	vec2 train = vec2(max(length(u.xz) - ratio, abs(u.y) - largo), 0.0);
		
	u.xyz = p.xyz;
	u.y += 2.0 * largo + 110.0;
	u.x = -abs(p.x) + 270.0;
	u.z -= 250.0;
	base = train.x;
	train = min(train, max(length(u.yz) - 10.0, abs(u.x) - 40.0));
	u.x += 30.0;
	train = min(train, max(length(u.yz) - 15.0, abs(u.x) - 10.0));
	u.x += 20.0;
	train = min(train,  max(length(u.yz) - 40.0, abs(u.x) - 10.0));
	train = min(train, sdTorus(u, vec2(50.0, 15.0)));
		
	train.x = 0.5 * train.x;


	if(train.x < outData.x) outData.xy = train;
	
	//Back wheel, its another deformed cilynder.
	u.xyz = p.xyz;			
	ratio = 6.0;
	largo = 60.0;
		
	u.y += largo + 40.0;
	u.z += 500.0;
	u *= rotX(-15.0);
		
	u.x = 0.02 * pow(u.x, 2.0);
	u.z = 0.02 * pow(u.z, 2.0);
	interpoler = step(u.y, 0.0) * 0.9 * pow(clamp(0.5 * abs(u.y) / largo, 0.0, 1.0), 1.2);
	u.z += 10.0 * interpoler;
	
	scalarY = 0.5;
	u.z *= scalarY + interpoler;
		
	float backWheel = 0.5 * max(length(u.xz) - ratio, abs(u.y) - largo);
		
	u.xyz = p.xyz;			
	ratio = 5.0;
	largo = 60.0;
		
	u.y += largo * 2.0 + 30.0;
	u.z += 515.0;
		
	backWheel = min(backWheel, 0.5 * max(length(u.yz) - 32.0, abs(u.x) - 6.0));		
	outData.x = min( backWheel, outData.x );
	
	return outData;	
}

//same function of the distance field to obtain colors...
vec3 coloring(vec3 p) {

	p *= rotY(uAngle * 0.1);
	p *= rotX(7.0);

	vec3 outData = vec3(0.0, 0.0, 0.0);				
	vec3 u = p.xyz;
	
	float ratio = 100.0;
	float largo = 600.0;
	float scalarY = 0.7;
	float scalarX = 0.015;
	float interpoler = 0.0;
	if(u.z > 0.0) {
		float sep = 80.0;
		float expo = 7.0 - 5.9 * clamp(0.5 * (p.y + sep) / sep, 0.0, 1.0);
		interpoler = step(-u.z, 0.0) * pow(u.z / largo, expo);
		scalarX += 0.005 * interpoler;
		scalarY -= 0.5 * interpoler;
		ratio -= 60.0 * interpoler;
	} else { 
		float limite = step(u.z, 0.0) * abs(u.z) / largo;
		interpoler =  pow(limite, 2.0);
		scalarX += 0.2 * pow(limite, 5.0);
		ratio -= 70.0 * interpoler;
		u.y -= 40.0 * interpoler;
	}
	u.x = scalarX * pow(p.x, 2.0);
	u.y += step(u.y, 0.0) *scalarY * (ratio - abs(u.x));
	float fuselaje = 0.2 * max(length(u.xy) - ratio, abs(u.z) - largo);
			
	u.xyz = p.xyz;
	largo = 115.0;
	ratio = 12.0;
	u.z += 150.0;
	u.y -= largo;
	float sep = 20.0;
	ratio -= 6.0 * clamp(0.5 * (p.y - sep - 100.0) / sep, 0.0, 1.0);
	ratio -= 0.3 * ratio * clamp(pow(u.y / largo, 3.0), 1.0, 0.0);		
	float antena = max(length(u.xz) - ratio, abs(u.y) - largo);
	
	fuselaje = min(fuselaje, antena);
	
	u.xyz = p.xyz;
	u.z += 450.0;
	u.z *= 0.15 + 0.25 * step(-u.z, 0.0);
	ratio = 30.0;
	float colaHeight = 300.0;
	
	interpoler = u.y / colaHeight;
	ratio -= 20.0 * interpoler;
	u.z += 11.0 * interpoler;
		
	float cola = max(length(u.xz) - ratio, abs(u.y) - colaHeight);
	cola = max(cola, -p.y);
	
	u.y = p.y - colaHeight;
	u.y *= 0.3;
	cola = min(cola, length(u) - ratio);
	
	fuselaje = min(fuselaje, cola);

	/*
	Painting the main body, differents colors are used (defined in the main function),
	the colors are defined in the "y" variable of the outData vector.
	*/
	outData.x = fuselaje;
	outData.y = step(-p.y, 11.0);
	u.z = p.z - 500.0;
	u.y = p.y + 11.0;
	outData.y += step(-u.y / 0.045, u.z) * step(u.y / 0.09, -u.z);
	outData.y += step(-u.y / 0.09, u.z) * step((u.y - 20.0)/ 0.09, -u.z) * step(u.z, -550.0);
	
	u.xyz = p.xyz;
	u.z += 300.0;
	float circle = length(u.yz);
	outData.y -= (outData.y - 3.0) * step(-circle, -60.0) * step(circle, 65.0);
	outData -= outData * step(circle, 60.0);
			

	/*
	The propeller is modeled deforming a spheres, there is the main sphere that holds
	the blades defined in the "alabe" function. the blades are added to the main sphere
	this part of the plain is treated as a different piece to have its own paiting.
	*/
	
	u.xyz = p.xyz;
	u.z = p.z - 600.0;
	u.y += 5.0;
	u.z *= 0.55;
	float helix =  length(u.xyz) - 42.0;
	
	float desface = -uAngle * 0.5;
	u.z = p.z - 615.0;
	
	for(int i = 0; i < 3; i++) helix = min(helix, alabe(u, desface + 120.0*float(i)));
	helix *= 0.3;
	
	//painting of the propeller
	if(helix < fuselaje) {
		outData.x = helix;
		u.xyz = p.xyz;
		u.y += 5.0;
		circle = length(u.yx);
		outData.y = 4.0 * step(circle, 42.0) + 3.0 * step(-circle, -42.0) * step(circle, 200.0) + 5.0 * step(-circle, -200.0);
	}
	
	
	/*
	Wings distance function, the wings are also modeled as a deformed
	cilynder and treated as a different piece to have its own paiting.
	*/
	u.xyz = p.xyz;
	u.z -= 300.0;
	u.z *= u.z > 0.0 ? 0.35 : 0.1;
	u.y += 130.0;
	ratio = 30.0;
	vec2 sections = vec2(180.0, 1000.0);
	interpoler = step(-abs(u.x), -sections.x) * pow((abs(u.x) - sections.x) / sections.y, 1.0);
	u.y -= 120.0 * interpoler;
	ratio -= 20.0 * interpoler;
	
	float wings = max(length(u.yz) - ratio, abs(u.x) - sections.y);
	
	//these are deformed spheres that defines the borders of the wings.
	u.x = abs(p.x) - sections.y;
	u.x *= 0.3;
	wings = min(wings, length(u) - ratio);
	
	
	//paiting of the wings.
	if(wings < outData.x) {
		outData.xy = vec2(wings, 0.0);
		outData.y += 2.0 * step(abs(p.x), sections.x);
		outData.y -= (outData.y - 1.0) * step(-abs(p.x) - 20.0, -sections.y);
		outData.y -= (outData.y - 1.0) * step(-p.z, -300.0);
		
		u.x = p.x - 900.0;
		u.z = p.z - 230.0;
		circle = length(u.xz);
		outData.y -= (outData.y - 3.0) * step(-circle, -50.0) * step(circle, 55.0);
	}
	
	/*
	Modeling of the back wings. It´s the same method used for the wings,
	but there is no change of chape in the profile.
	*/
	u.xyz = p.xyz;
	u.z += 450.0;
	u.z *= 0.1 + 0.25 * step(-u.z, 0.0);
	ratio = 20.0;
	float backWidth = 400.0;
	interpoler = abs(u.x) / backWidth;
	ratio -= 12.0 * interpoler;
	u.z += 12.0 * interpoler;
	
	//Deformed spheres for the borders of the back wings	
	float backWings = max(length(u.yz) - ratio, abs(u.x) - backWidth);
	u.x = abs(p.x) - backWidth;
	u.x *= 0.3;
	backWings = min(backWings, length(u) - ratio);
	
	
	//Painting of the back wings		
	if(backWings < wings && backWings < fuselaje && backWings < helix) {
		outData.xy = vec2(backWings, 2.0);
		outData.y -= (outData.y - 1.0) * step(-abs(p.x), -380.0);
		outData.y -= (outData.y - 1.0) * step(-0.3 * u.z, -1.0);
	}
	
	/*
	Modeling of the head (cockpit), since this part was modeled using 
	a different file it had to be scaled to put in the plane. The model uses
	to deformed spheres 

	Since there is a need to scale and adapt the head, another local coordinate
	system vector "v" is used to preserve the main "P" vector.
	*/
	
	vec3 v = p.xyz;
	v.y -= 120.0;
	v.z -= 110.0;
	v *= 2.7;
	v *= rotX (-4.8);
	u.xyz= v.xyz;
	
	u.x /= (0.65 + 0.15 * (200.0 - v.y) / 200.0);
	u.y = exp(v.y / 55.0);
	u.z /= (1.0 + 0.0025 * (200.0 - v.y));
	
	//this is the plane hood... the float base
	vec3 w = u.xyz;
	w.y = exp((v.y - 185.0)/ 55.0);
	w.y *= 8200.0;
	w.x = 0.005 * pow(w.x, 2.0);
	w.x *= (1.0 + 0.001 * v.z);
	w.z *= 0.2 * step(-w.z, 0.0);
	float base = max(length(w) - 200.0, -v.y - 130.0);
	base = max(base, v.z - 1300.0);
	base = max(base, -v.z + 50.0);
	
	//Here we start with the cockpit... the head float
	u.y = exp(v.y / 55.0);
	if(u.z > 0.0) {
		u.z *= 0.8;
		u.z *= (1.2 + pow(clamp((240.0 - v.y) / 200.0, 0.0, 1.0), 0.6));
		u.z /= (1.0 + 0.002 * (200.0 - v.y));
	} 
	
	float head = max(length(u) - 200.0, -v.y - 130.0);
	head = min(head, base);
	head *= 0.5;
	
	
	/*
	This is the painting of the head, it is divided in the white background, the eyes, the
	"eyelashes" and the black borders, the "Z" value of the outData vector is used to define a
	gradient to paint the eyes since these gradients have to be the same for differents
	local coordinates systems.

	The gradient is defined using the local atan angle of each eye and the color is in the
	main function of the shader.
	*/
	
	if(head < outData.x) {

		outData.xy = vec2(head, 1.0);
		float angle = atan(v.z, v.x);
		float eyesAngle = 35.0;
		float alturaOjos = 238.0;

		outData.y -= step(-angle, -radians(eyesAngle)) * step(angle, radians(180.0 - eyesAngle));
		
		//Painting the eyes...
		float eyesDistance = 50.0;
		
		//This vector defines the ratios or the different parts of the eye
		vec4 ratios = vec4(40.0, 35.0, 25.0, 4.0);
		u.xyz = v.xyz;	
		u.x = -abs(v.x) + eyesDistance;
		u.y -=90.0;
		float eval = length(u.xy);
		outData.z = atan(u.y, u.x);
		outData.y -= (outData.y - 3.0) * step(-eval, -ratios.y) * step(eval, ratios.x) * step(-u.z, 0.0);
		outData.y -= (outData.y - 6.0) * step(-eval, -ratios.z) * step(eval, ratios.y) * step(-u.z, 0.0);
		outData.y -= (outData.y - 3.0) * step(eval, ratios.z) * step(-u.z, 0.0);
		
		u.x = v.x - eyesDistance;
		u.xy += vec2(10.0, -10.0);
		outData.y -= outData.y * step(length(u.xy), ratios.w) * step(-u.z, 0.0);
		u.x += eyesDistance * 2.0;;
		outData.y -= outData.y * step(length(u.xy), ratios.w) * step(-u.z, 0.0);
		
		
		//These are the "eyelashes"
		float sinAngle = 20.0 * sin(3.5 * angle);
		float cosAngle = 15.0 * cos(4.0 * angle);
		outData.y -= (outData.y - 1.0) * step(-v.y, - 135.0 - sinAngle);
		outData.y -= (outData.y - 1.0) * step(v.y, 40.0 - cosAngle);

		//these are the black borders lines.
		float thinkness = 2.0;
		float linearT = 5.0;
		float amm = radians(eyesAngle - thinkness);
		float amM = radians(eyesAngle + thinkness);
		float aMn = radians(180.0 - eyesAngle - thinkness);
		float aMM = radians(180.0 - eyesAngle + thinkness);
		
		outData.y -= (outData.y - 3.0) * step(-angle, -amm) * step(angle, aMM) * (step(-v.y, - alturaOjos + linearT) * step(v.y, alturaOjos + linearT) + step(angle, aMM)* step(-v.y, 0.0) * step(v.y, 2.0 * linearT));
		outData.y -= (outData.y - 3.0) * step(-v.y, 0.0) * step(v.y, alturaOjos + linearT) * (step(-angle, -amm) * step(angle, amM) + step(-angle, -aMn) * step(angle, aMM));
		outData.y -= (outData.y - 3.0) * step(-angle, -amm) * step(angle, aMM) * (step(-v.y, -sinAngle - 132.0) * step(v.y, sinAngle + 136.0) + step(-v.y, - 39.0 + cosAngle) * step(v.y, 43.0 - cosAngle));
	
	}
	
	/*
	This is the landing train under the wings, it uses the landing train function
	defined above and applies symmetry to draw the both needed. Since there are 
	concentrical cilynders in this case, the landingTrain function also specifies
	the painting.

	hence the landingTrain function returns a vec2, the "x" value gives the distance and the "y"
	value returns the color.
	*/
	
	u.xyz = p.xyz;
	ratio = 10.0;
	largo = 120.0;
		
	u.y += largo + 140.0;
	u.x = -abs(p.x) + 220.0;
	u.z -= 250.0;
	u *= rotZ(20.0);
		
	u.x = 0.02 * pow(u.x, 2.0);
	u.z = 0.02 * pow(u.z, 2.0);
	interpoler = 0.0;
	interpoler = step(-u.y, 0.0) * 0.9 * pow(clamp(0.5 * u.y / largo, 0.0, 1.0), 1.2);
	ratio -= step(u.y , 0.0) * 5.0;
	scalarY = 0.5;
	u.z *= scalarY - interpoler;
		
	float train = max(length(u.xz) - ratio, abs(u.y) - largo);
		
	u.xyz = p.xyz;
	u.y += 2.0 * largo + 110.0;
	u.x = -abs(p.x) + 270.0;
	u.z -= 250.0;
	float eval = length(u.yz);
	train = min(train, max(eval - 10.0, abs(u.x) - 40.0));
	u.x += 30.0;
	train = min(train, max(eval - 15.0, abs(u.x) - 10.0));
	u.x += 20.0;
	train = min(train, max(eval - 40.0, abs(u.x) - 10.0));
	train = min(train, sdTorus(u, vec2(50.0, 15.0)));
		
	train = 0.5 * train;
			
	if(train < outData.x) {
		outData.x = train;
		outData.y = 0.0;
		outData.y += 4.0 * step(eval, 11.0);
		outData.y += 3.0 * step(-eval, -11.0) * step(eval, 16.0) * step(u.x, 50.0);
		outData.y += 7.0 * step(-eval, -16.0) * step(eval, 40.0) * step(u.x, 40.0);
		outData.y += 3.0 * step(-eval, -40.0) * step(u.x, 40.0);
	}
	
	//Back wheel, its another deformed cilynder.
	u.xyz = p.xyz;			
	ratio = 6.0;
	largo = 60.0;
		
	u.y += largo + 40.0;
	u.z += 500.0;
	u *= rotX(-15.0);
		
	u.x = 0.02 * pow(u.x, 2.0);
	u.z = 0.02 * pow(u.z, 2.0);
	interpoler = step(u.y, 0.0) * 0.9 * pow(clamp(0.5 * abs(u.y) / largo, 0.0, 1.0), 1.2);
	u.z += 10.0 * interpoler;
	
	scalarY = 0.5;
	u.z *= scalarY + interpoler;
		
	float backWheel = 0.5 * max(length(u.xz) - ratio, abs(u.y) - largo);
		
	u.xyz = p.xyz;			
	ratio = 5.0;
	largo = 60.0;
		
	u.y += largo * 2.0 + 30.0;
	u.z += 515.0;
		
	float c1 = max(length(u.yz) - 32.0, abs(u.x) - 6.0);
	backWheel = min(backWheel, c1);
		
	if(backWheel < outData.x)  outData.xy = vec2(backWheel, 3.0);
	if(outData.x == backWheel && c1 > backWheel) outData.y = 0.0;
	
	return outData;	
}

//Finite differences
vec3 gradient( vec3 v ) {
	const vec3 delta = vec3( grad_step, 0.0, 0.0 );
	float va = dist_field( v ).x;
	return normalize (
		vec3(
			dist_field( v + delta.xyy).x - va,
			dist_field( v + delta.yxy).x - va,
			dist_field( v + delta.yyx).x - va			
		)
	);
}

/*
Since I have deformed many shapes (almost everything) I had to reduce the steps
distances used to aproximate the plane, hence there´s a depth_reduction value used to
adapt the steps to obtain the correct shape.

the depth_reduction value is defined at the beginning of the shader, it can has values between
0.2 and 0.5, above and under those values the shapes start to be badly rendered.

Since this depth_reduction float requires more steps, it makes also the shader go very
slow, try to lower the total iterations to gain some speed if its needed.

*/
vec3 ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	float depth = start;
	vec3 salida = vec3(end);
	vec3 dist = vec3(100.0);
	for ( int i = 0; i < max_iterations; i++ ) 		{
		if ( dist.x < stop_threshold || depth > end ) break;
		
            dist = dist_field( origin + dir * depth );
            depth += dist.x;
	}
	
	if( dist.x<stop_threshold ) {
        dist = coloring( origin + dir * depth );
        salida = vec3(depth, dist.y, dist.z);
	}

	return salida;
}

/*
These are simple shadows, since there no need for quality here I could change the 
depth_reduction value to 0.7 to speed up things.
*/
float shadow( vec3 v, vec3 light ) {
	vec3 lv = v - light;
	float end = length( lv );
	lv /= end;
	
	float depth = ray_marching( light, lv, 0.0, end ).x;

	return step( end - depth, 0.5);
}

//the shading uses a simple phong method, no AO used, just a ambient light
vec3 shading( vec3 v, vec3 n, vec3 eye ) {

	vec3 final = vec3( 0.0 );

	vec3 ev = normalize( v - eye );
	vec3 ref_ev = reflect( ev, n );

	{
		vec3 light_pos   = vec3(0.0, 2000.0, -2000.0);
		vec3 vl = normalize( light_pos - v );
		float diffuse  = max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, 128.0 );
		final += vec3( 0.9 ) * ( diffuse * 0.4 + specular * 0.9 );
		
		#ifdef SHADOWS
		final *= shadow( v, light_pos );
		#endif

		final += vec3(0.15);
	}
	

	return final;
}

//Ray direction 
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan(radians( 90.0 - fov * 0.5 ));	
	float z = size.y * 0.5 * cot_half_fov;

	return normalize( vec3( xy, z ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	uAngle =  iGlobalTime * 200.0;;
		
	vec3 rd = ray_dir(50.0, iResolution.xy, fragCoord.xy );
	
	vec3 eye = vec3( 0.0, 00.0, -1800.0 );

	vec3 color = vec3(0.1);

	vec3 data = ray_marching( eye, rd, 0.0, clip_far );
	if ( data.x < clip_far ) {
		
		vec3 pos = eye + rd * data.x;
		vec3 n = gradient( pos );
		vec3 lightColor =  shading( pos, n, eye ) * 2.0;

		
		if(data.y == 0.0) color = vec3(1.0);
		if(data.y == 1.0) color =  vec3(0.8, 0.4, 0.0) ; //Naranja
		if(data.y == 2.0) color =  vec3(128.0, 181.0, 206.0)  / 255.0; //azul
		if(data.y == 3.0) color = vec3(0.1) ; // negro
		if(data.y == 4.0) color = vec3(0.5) ; // gris
		if(data.y == 5.0) color = vec3(1.0, 1.0, 0.0); // amarillo
		if(data.y == 6.0) color = vec3(0.5, 0.7, 0.9) * (0.01 + 0.99 * abs(cos(data.z + 1.3))); //gradiente o
		if(data.y == 7.0) color = vec3(0.4, 0.0, 0.0) ; //rojo
		color *= lightColor;
	}
		
	fragColor = vec4(color, 1.0 );
} 