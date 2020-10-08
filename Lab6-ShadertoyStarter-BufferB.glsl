// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//------------------------------------------------------------
// SHADERTOY MAIN

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    // setup
    // test UV for input image
    sCoord uv = fragCoord / iChannelResolution[0].xy;
    
	vec4 textureColor = texture(iChannel0, uv);
    //vec3 modifier = vec3(-textureColor);
	vec3 brightColor = vec3(2.0 * (squareValue(textureColor.xyz)) -1.0);
    fragColor = vec4(brightColor.rgb, 1.0);

        
        
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = textureColor;
}