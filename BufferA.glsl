// Buffer A by Michael Bowen
//  -> Buf A
//
//Desc: Calculation for revolving cube map

//------------------------------------------------------------
// RENDERING FUNCTIONS



// calcColor: calculate the color of current pixel
//	  vp:  input viewport info
//	  ray: input ray info
color4 calcColor(in sViewport vp, in sRay ray)
{
    //cube map init
    vec3 rayVec = ray.direction.xyz;
    
    //surface init
    vec3 position = vec3(vp.pixelCoord, -1.0); //surface position
    vec3 normal = vec3(0.0, 0.0, 1.0); //surface 
    
    //Cube init
    sSphere sphere[5];
    initSphere(sphere[1], vec3(sin(iTime), 0.0, 0.0), .5);
    initSphere(sphere[0], vec3(0.0, 0.0, 0.0), .25);
    
    
    //Light init
    pLight lights[MAX_LIGHTS];
    initPointLight(lights[0], vec3(0.0, 0.0, 2.0), vec4(1.0), 20.0);
    
    //light color init
    vec4 specularColor = vec4(1.0);
    vec4 diffuseColor = vec4(normal * 0.5 + 0.5, 1.0);
    
    for(int i = 0; i < 5; i++){
        vec3 dp;
        if(circleExists(ray, sphere[i], position)) {
            calcCircleZ(sphere[i], position, normal);
            //return lambertianReflectance(lights[i], ray, normal, position);
            //return texture(iChannel0, normal);
            vec4 color = reflection(ray, normal, iChannel0);
            diffuseColor = color;
            return lambertianReflectance(lights[0], ray, normal, position, diffuseColor, specularColor);
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
