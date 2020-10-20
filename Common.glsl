// Common by Michael Bowen
//  -> Common
//
//Desc: Common functions shared across tabs

float globalIntensity = .1;
vec4 globalColor = vec4(1.0);
const int MAX_LIGHTS = 5;
const bool RUN_WORMHOLE = true; //set to true to run wormhole
#define PI 3.1415926538
vec4 LUMINANCE = vec4(.2125,.07154,.0721, 1.0);
float weight[3] = float[](0.375, 0.25, 0.625); //alternate implementation divides by the sum removing a division calculation from the code(weight at n)/(2^n) = weight at kernal

//------------------------------------------------------------
// TYPE ALIASES & UTILITY FUNCTIONS

// sScalar: alias for a 1D scalar (non-vector)
#define sScalar float

// sCoord: alias for a 2D coordinate
#define sCoord vec2

// sDCoord: alias for a 2D displacement or measurement
#define sDCoord vec2

// sBasis: alias for a 3D basis vector
#define sBasis vec3

// sPoint: alias for a point/coordinate/location in space
#define sPoint vec4

// sVector: alias for a vector/displacement/change in space
#define sVector vec4


// color3: alias for a 3D vector representing RGB color
// 	(this is non-spatial so neither a point nor vector)
#define color3 vec3

// color4: alias for RGBA color, which is non-spatial
// 	(this is non-spatial so neither a point nor vector)
#define color4 vec4


// asPoint: promote a 3D vector into a 4D vector 
//	representing a point in space (w=1)
//    v: input 3D vector to be converted
sPoint asPoint(in sBasis v)
{
    return sPoint(v, 1.0);
}

// asVector: promote a 3D vector into a 4D vector 
//	representing a vector through space (w=0)
//    v: input 3D vector to be converted
sVector asVector(in sBasis v)
{
    return sVector(v, 0.0);
}


// lengthSq: calculate the squared length of a vector type
//    x: input whose squared length to calculate
sScalar lengthSq(sScalar x)
{
    return (x * x);
    //return dot(x, x); // for consistency with others
}

sScalar lengthSq(sDCoord x)
{
    return dot(x, x);
}
sScalar lengthSq(sBasis x)
{
    return dot(x, x);
}
sScalar lengthSq(sVector x)
{
    return dot(x, x);
}

float squareValue(float v){
	return v*v;
}

vec3 squareValue(vec3 v){
	return vec3(squareValue(v.x), squareValue(v.y), squareValue(v.z));
}
vec4 squareValue(vec4 v){
	return vec4(squareValue(v.x), squareValue(v.y), squareValue(v.z), squareValue(v.a));
}

float powerOfTwo (in float base, in int power){
    for(int i = power - 1; i >= 0; --i){
    	base *= base;
    }
	return base;
}


//Rotation Functions
//mat3(1.0,0.0,0.0,0.0,c,s,0.0,-s,c); //Rotates around the X axis
//mat3(c,0.0,-s,0.0		  ,1.0,0.0,s,0.0,c); //rotates around the y axis
//mat3(c  ,s  ,0.0,-s ,c  ,0.0,0.0,0.0,1.0); //rotates around the z axis
mat3 rotXAxis3D(in float theta){
    float c = cos(theta);
    float s = sin(theta);
    return mat3(1.0,0.0,0.0,
                0.0,c,s,
                0.0,-s,c); //Rotates around the X axis
}

mat3 rotYAxis3D(in float theta){
    float c = cos(theta);
    float s = sin(theta);
    return mat3(c,0.0,-s,
                0.0,1.0,0.0,
                s,0.0,c); //rotates around the y axis
}

float calcLuminance(in vec4 color){
	return dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
}

vec4 screen(vec4 color1, vec4 color2){
    return 1.0 - (1.0 - color1) * (1.0 - color2); //screen
}

vec4 softLight(vec4 color1, vec4 color2){
	return (1.0 - 2.0*color2)*squareValue(color1) +2.0*color2*color1;
}



//------------------------------------------------------------
// VIEWPORT INFO

// sViewport: info about viewport
//    viewportPoint: location on the viewing plane 
//							x = horizontal position
//							y = vertical position
//							z = plane depth (negative focal length)
//	  pixelCoord:    position of pixel in image
//							x = [0, width)	-> [left, right)
//							y = [0, height)	-> [bottom, top)
//	  resolution:    resolution of viewport
//							x = image width in pixels
//							y = image height in pixels
//    resolutionInv: resolution reciprocal
//							x = reciprocal of image width
//							y = reciprocal of image height
//	  size:       	 in-scene dimensions of viewport
//							x = viewport width in scene units
//							y = viewport height in scene units
//	  ndc: 			 normalized device coordinate
//							x = [-1, +1) -> [left, right)
//							y = [-1, +1) -> [bottom, top)
// 	  uv: 			 screen-space (UV) coordinate
//							x = [0, 1) -> [left, right)
//							y = [0, 1) -> [bottom, top)
//	  aspectRatio:   aspect ratio of viewport
//	  focalLength:   distance to viewing plane
struct sViewport
{
    sPoint viewportPoint;
	sCoord pixelCoord;
	sDCoord resolution;
	sDCoord resolutionInv;
	sDCoord size;
	sCoord ndc;
	sCoord uv;
	sScalar aspectRatio;
	sScalar focalLength;
};

// initViewport: calculate the viewing plane (viewport) coordinate
//    vp: 		      output viewport info structure
//    viewportHeight: input height of viewing plane
//    focalLength:    input distance between viewer and viewing plane
//    fragCoord:      input coordinate of current fragment (in pixels)
//    resolution:     input resolution of screen (in pixels)
void initViewport(out sViewport vp,
                  in sScalar viewportHeight, in sScalar focalLength,
                  in sCoord fragCoord, in sDCoord resolution)
{
    vp.pixelCoord = fragCoord;
    vp.resolution = resolution;
    vp.resolutionInv = 1.0 / vp.resolution;
    vp.aspectRatio = vp.resolution.x * vp.resolutionInv.y;
    vp.focalLength = focalLength;
    vp.uv = vp.pixelCoord * vp.resolutionInv;
    vp.ndc = vp.uv * 2.0 - 1.0;
    vp.size = sDCoord(vp.aspectRatio, 1.0) * viewportHeight;
    vp.viewportPoint = asPoint(sBasis(vp.ndc * vp.size * 0.5, -vp.focalLength));
}

struct pLight
{
	vec4 center;
    vec4 color;
    float intensity;
};

void initPointLight(out pLight light, in vec3 center, in vec4 color, in float intensity)
{
  	light.center = asPoint(center);
    light.color = color;
    light.intensity = intensity;
    
}

struct sSphere
{
	float radius;
    vec4 center;
};

void initSphere (out sSphere sphere, in vec3 center, in float radius) 
{
	sphere.center = asPoint(center);
    sphere.radius = radius;

}


//------------------------------------------------------------
// RAY INFO

// sRay: ray data structure
//	  origin: origin point in scene
//    direction: direction vector in scene
struct sRay
{
    sPoint origin;
    sVector direction;
};

// initRayPersp: initialize perspective ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayPersp(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // ray origin relative to viewer is the origin
    // w = 1 because it represents a point; can ignore when using
    ray.origin = asPoint(eyePosition);

    // ray direction relative to origin is based on viewing plane coordinate
    // w = 0 because it represents a direction; can ignore when using
    ray.direction = asVector(viewport - eyePosition);
}

// initRayOrtho: initialize orthographic ray
//    ray: 		   output ray
//    eyePosition: position of viewer in scene
//    viewport:    input viewing plane offset
void initRayOrtho(out sRay ray,
             	  in sBasis eyePosition, in sBasis viewport)
{
    // offset eye position to point on plane at the same depth
    initRayPersp(ray, eyePosition + sBasis(viewport.xy, 0.0), viewport);
}

//calc rotation angle of a vec3 from pixel space


vec2 pixelToNdc(in vec2 pixel, in sViewport vp){
	return (pixel.xy * vp.resolutionInv)  * 2.0 - 1.0; 
}

bool circleExists(sRay ray, sSphere sphere, inout vec3 dp) {
    dp.xy = ray.direction.xy - sphere.center.xy; //ray from pixel toward the center of the circle
    float lSq = lengthSq(dp.xy), //the length function calulates the square length so it is more efficent just square it
          rSq = squareValue(sphere.radius);
    if(lSq <= rSq){
        return true;
    }
    return false;
}

float calcDiffuseIntensity(in vec3 surfacePos, in vec3 surfaceNorm, in pLight light, inout vec3 normalizedLightVector){
        //Diffuse Intensity
        vec3 lightVector = light.center.xyz - surfacePos;
        float lightVectorLengthSq = lengthSq(lightVector); //saves a square root function
        normalizedLightVector = lightVector * inversesqrt(lightVectorLengthSq); //declaration of var
        float diffusionCoefficent = max(0.0, (dot(surfaceNorm, normalizedLightVector)));
        float attenuation = (1.0 - lightVectorLengthSq/squareValue(light.intensity));
        return diffusionCoefficent * attenuation; 
}

float calcSpecularIntensity(in vec3 surfacePos, in vec3 surfaceNorm, in sRay ray, in vec3 normalizedLightVector ){
		//Blinn-Phong Reflectance
        vec3 viewVector = ray.origin.xyz - surfacePos; //Created because viewVector is used twice
        vec3 normalViewVector = viewVector * inversesqrt(lengthSq(viewVector)); //Multiplied by the inverse and uses the dquared length function
        vec3 halfWayVector = normalizedLightVector + normalViewVector; //Used twice 
        vec3 normalHalfWayVector = halfWayVector * inversesqrt(lengthSq(halfWayVector));
        float specCoefficent = max(0.0, dot(surfaceNorm, normalHalfWayVector)); //Multiplied by the inverse and uses the dquared length function
        return powerOfTwo(specCoefficent, 3); //improved eff by removing pow function and adding a power of two function
}



vec4 lambertianReflectance(in pLight lights, in sRay ray, in vec3 normal, in vec3 position, vec4 diffuseColor, vec4 specularColor ){


    vec3 normalizedLightVector;
    float diffuse = calcDiffuseIntensity(position, normal, lights, normalizedLightVector);
    float specular = calcSpecularIntensity(position, normal, ray, normalizedLightVector );

    vec4 sumOfColors = globalIntensity * globalColor + ((diffuse * diffuseColor + specular * specularColor) * lights.color);    
    return sumOfColors;
}

vec4 reflection(in sRay ray, in vec3 normal, samplerCube iChannel){
    return  texture(iChannel, reflect(ray.direction.xyz, normal));// + (calcDiffuseIntensity(position, normal, lights, normalizedLightVector)* luminance);
}

void calcCircleZ(in sSphere sphere, inout vec3 position, inout vec3 normal){
		position.z = squareValue(sphere.radius) - ((position.x*position.x)+(position.y*position.y));
        position.xy = sphere.center.xy + vec2(position.x, position.y);
        normal.xy = (position.xy - sphere.center.xy) / sphere.radius;
}

/*vec3 mouseVectorTanslation(in vec2 mouse, in sViewport vp, inout vec3 rayDir){
	//rotation based on mouse position

  
    rayDir *= rotXAxis3D(-theta.y) * rotYAxis3D(theta.x); //rotates the scene to an angle based on the mouse position
    return rayDir;
}*/

//------------------------------------------------------------
/*
// GLSL FRAGMENT SHADER STRUCTURE WITH COMMON TAB
//  -> This is (likely) how Shadertoy compiles buffer tabs:

// latest version or whichever is used
#version 300 es

// **CONTENTS OF COMMON TAB PASTED HERE**

// PROGRAM UNIFORMS (see 'Shader Inputs' dropdown)

// **CONTENTS OF BUFFER TAB PASTED HERE**

// FRAGMENT SHADER INPUTS (more on this later)

// FRAGMENT SHADER OUTPUTS (framebuffer render target(s))
//out vec4 rtFragColor; // no specific target
layout (location = 0) out vec4 rtFragColor; // default

void main()
{
    // Call 'mainImage' in actual shader main, which is 
	// 	our prototyping interface for ease of use.
	//		rtFragColor:  shader output passed by reference,
	//			full vec4 read in 'mainImage' as 'fragColor'
	//		gl_FragCoord: GLSL's built-in pixel coordinate,
	//			vec2 part read in 'mainImage' as 'fragCoord'
    mainImage(rtFragColor, gl_FragCoord.xy);
}
*/
