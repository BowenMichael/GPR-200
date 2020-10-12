// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> buf c

//------------------------------------------------------------
// SHADERTOY MAIN

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    int kernalSize = 5;
    //int halfKernalSize = kernalSize*.5;
    // setup
    // test UV for input image
    
    int x,y;
    float weightSum;
    vec3 tex;

    for(y = 0; y < kernalSize; y++){
        sCoord uv = vec2(fragCoord.x, fragCoord.y + float(y)) / iChannelResolution[0].xy;
        vec4 textureColor = texture(iChannel0, uv);
        float weight = length(textureColor);
        weightSum += weight;
        tex += weight * textureColor.rgb;
    }
	
    float inverseWeightSum = 1.0/weightSum;
    vec4 normalizedColor = vec4(vec3(inverseWeightSum * tex), 1.0);
    fragColor = normalizedColor;
    
    
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = tex;
    
    //Convolution
    
}