// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> buf c

//------------------------------------------------------------
// SHADERTOY MAIN

uniform float weight[5] = float[]() //based on the gausian function. F((value we want)/(sum at that index)) = weight at kernal

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{

    // setup
    // test UV for input image
    
    int x,y;
    float weightSum;
    vec3 tex;
    vec2 pixelSize = 1.0 / iChannelResolution[0].xy;
    
    for(x= kernalSize-1; x >= 0; ++x){
        sCoord uv = vec2(fragCoord.x + float(x), fragCoord.y) * pixelSize;
        vec4 textureColor = texture(iChannel0, uv);
        //float weight = length(textureColor);
        weightSum += kernal[x];
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