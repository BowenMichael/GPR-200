// Buffer A by Michael Bowen
//  -> Buf A
//
//Desc: Calculation for revolving cube map

//------------------------------------------------------------
// RENDERING FUNCTIONS

const float  ior = 1.33;

// calcColor: calculate the color of current pixel
//	  vp:  input viewport info
//	  ray: input ray info
color4 calcColor(in sViewport vp, in sRay ray)
{

    float eta = 1.0 / ior;
    //cube map init
    vec3 rayVec = ray.direction.xyz;
    
    //rotation based on mouse position
    vec2 mousePointInspace = (iMouse.xy * vp.resolutionInv)  * 2.0 - 1.0; 
    vec2 theta = mousePointInspace*2.0*PI; //Makes the mouse position more proportinal to the output screen 
    rayVec *= rotXAxis3D(-theta.y) * rotYAxis3D(theta.x); //rotates the scene to an angle based on the mouse position
    
    
    //surface init
    vec3 position = vec3(vp.pixelCoord, -1.0); //surface position
    vec3 normal = vec3(0.0, 0.0, 1.0); //surface 
    
    //Cube init
    const int maxSphere = 20;
    sSphere sphere[maxSphere];
    sSphere rSphere[maxSphere];
    //initSphere(sphere[1], vec3(sin(iTime), 0.0, 0.0), .5);
    //float randMult = rand(vp.ndc);
    //float speed = -iTime;
    for(int i = 0; i < maxSphere; i++){
        initSphere(sphere[i], vec3((float(i) * .5  - 3.0),  .75, 0.0), .25);
        initSphere(rSphere[i], vec3((float(i) * .5 - 3.0), .25,0.0), .25);
    }
    
    
    
    //Light init
    pLight lights[MAX_LIGHTS];
    initPointLight(lights[0], vec3(0.0, 0.0, 1.0), vec4(1.0), 5.0);
    
    //light color init
    vec4 specularColor = vec4(1.0) * .5;
    vec4 diffuseColor = vec4(normal * 0.5 + 0.5, 1.0);
    
    sPlane planes[5];
    
    initPlane(planes[0], vec3(0.0, 0.0, 0.0), vec3(1.0, 0.0, 0.0), vec3(.5, -1.0 , 0.0));
    
   	if(vp.ndc.x > 0.15){
         vec2 coord = vp.pixelCoord.xy;
    	vec2 mouse = iMouse.xy;
    	vec2 resInv = vp.resolutionInv.xy;
    
    	vec2 cPos =  (coord - mouse) * resInv;
    	float cLength = length(cPos);

   		vec2 uv = coord * resInv + (cPos/cLength)*cos(cLength*12.0-iTime*4.0)*0.03;
        vec3 planeVec;
        if(rayVec.z <= 0.0)
        	planeVec = refraction(rayVec, planes[0].normal.xyz, eta);
        else
            planeVec = refraction(rayVec, -planes[0].normal.xyz, eta);
    	vec3 col = texture(iChannel0,planeVec).xyz;

    	return vec4(col,1.0);
        
       
        return texture(iChannel0, planeVec);
    }
	
    for(int i = 0; i < maxSphere; i++){
        vec3 dp;
        if(circleExists(ray, sphere[i], position)) {//Reflections
            calcCircleZ(sphere[i], position, normal);

            //reflection
            float percentOfCubeMap = .25;
            vec2 textureVector = reflect(rayVec * .1, normal).xy;
            vec3 colorVec = reflection(rayVec, normal);



            vec4 textureColor;
            float total = 4.0;
            if(mod(float(i), total) == 0.0)
                textureColor = texture(iChannel1, textureVector);
            else if(mod(float(i), total) == 1.0)
                textureColor = texture(iChannel2, textureVector);
            else if(mod(float(i), total) == 2.0)
               	textureColor = texture(iChannel3, textureVector);

            diffuseColor = texture(iChannel0, colorVec);
            return lambertianReflectance(lights[0], ray, normal, position, diffuseColor, specularColor)*percentOfCubeMap
                + lambertianReflectance(lights[0], ray, normal, position, textureColor, specularColor);
        }
        if(circleExists(ray, rSphere[i], position)) { //Refractions
            calcCircleZ(rSphere[i], position, normal);

            //refraction
            float percentOfCubeMap = 1.0;
            //float eta = 1 * ior; //reflection index of water
            vec3 colorVec = refraction(rayVec, normal, eta);
            vec2 textureVector = refract(rayVec, normal, eta).xy;


            vec4 textureColor;
            float total = 4.0;
            if(mod(float(i), total) == 0.0)
                textureColor = texture(iChannel1, textureVector);
            else if(mod(float(i), total) == 1.0)
                textureColor = texture(iChannel2, textureVector);
            else if(mod(float(i), total) == 2.0)
                textureColor = texture(iChannel3, textureVector);

            diffuseColor = texture(iChannel0, colorVec);
            return lambertianReflectance(lights[0], ray, normal, position, diffuseColor, specularColor)*percentOfCubeMap
            	+ lambertianReflectance(lights[0], ray, normal, position, textureColor, specularColor);
        }
    }
    
    //CubeMap (Code could be contensed for a easier viewing experiance)
    	
	vec4 cube = texture(iChannel0, rayVec);  //Render Cube color
    return cube;
    
    // test inputs
    //return color4(ray.direction.xyz == vp.viewportPoint.xyz); // pass
    //return color4(lengthSq(vp.viewportPoint.xy) >= 0.25); // pass
    //return color4(vp.uv, 0.0, 0.0);
    //return color4(vp.ndc, 0.0, 0.0);
    return asPoint(sBasis(vp.viewportPoint.xy, -vp.viewportPoint.z));
}


//------------------------------------------------------------
// SHADERTOY MAIN

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    // viewing plane (viewport) inputs
    const sBasis eyePosition = sBasis(0.0);
    const sScalar viewportHeight = 2.0, focalLength = 1.5;
    
    // viewport info
    sViewport vp;

    // ray
    sRay ray;
    
    // render
    initViewport(vp, viewportHeight, focalLength, fragCoord, iResolution.xy);
    initRayPersp(ray, eyePosition, vp.viewportPoint.xyz);
    fragColor += calcColor(vp, ray);
}
