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
    //initSphere(sphere[1], vec3(sin(iTime), 0.0, 0.0), .5);
    float randMult = rand(vp.ndc);
    float speed = -iTime;
    for(int i = 0; i < maxSphere; i++)
    	initSphere(sphere[i], vec3((float(i) * .5  - 3.0) + cos(speed),   sin(speed), 0.0), .25);
    
    
    //Light init
    pLight lights[MAX_LIGHTS];
    initPointLight(lights[0], vec3(0.0, 0.0, 1.0), vec4(1.0), 5.0);
    
    //light color init
    vec4 specularColor = vec4(1.0) * .5;
    vec4 diffuseColor = vec4(normal * 0.5 + 0.5, 1.0);
    
    for(int i = 0; i < maxSphere; i++){
        vec3 dp;
        if(circleExists(ray, sphere[i], position)) {
            calcCircleZ(sphere[i], position, normal);
            //return lambertianReflectance(lights[i], ray, normal, position);
            //return texture(iChannel0, normal);
            //vec3 colorVec = reflection(rayVec, normal);
            vec3 colorVec = refraction(rayVec, normal, 1.33);
            vec4 textureColor = texture(iChannel1, reflect(rayVec * .1, normal).xy);
            diffuseColor = texture(iChannel0, colorVec);
            return lambertianReflectance(lights[0], ray, normal, position, diffuseColor, specularColor)*.25
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
