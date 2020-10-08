// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> BUFFER A TAB (scene)

//------------------------------------------------------------
// RENDERING FUNCTIONS

// calcColor: calculate the color of current pixel
//	  vp:  input viewport info
//	  ray: input ray info
color4 calcColor(in sViewport vp, in sRay ray)
{
    //CubeMap (Code could be contensed for a easier viewing experiance)
    vec3 rayVec = ray.direction.xyz;
  
    //rotation based on mouse position
    vec2 mousePointInspace = (iMouse.xy * vp.resolutionInv)  * 2.0 - 1.0; 
    vec2 theta = mousePointInspace*2.0*PI; //Makes the mouse position more proportinal to the output screen 
    rayVec *= rotXAxis3D(-theta.y) * rotYAxis3D(theta.x); //rotates the scene to an angle based on the mouse position
    
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
