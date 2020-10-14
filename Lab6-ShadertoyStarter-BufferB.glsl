// Buffer B by Michael Bowen
//  -> Buf B
//
//Desc: Bright pass with linear fall off

//------------------------------------------------------------
// SHADERTOY MAIN

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    // setup
    vec2 uv = fragCoord / iChannelResolution[0].xy;
    vec4 tex = texture(iChannel0, uv);
    
    //Bright Pass
    float brightness = calcLuminance(tex); //luminance calc
    float fallOffBrightness = (brightness - .5)*.5; //linear fall off
    fragColor = vec4(vec3(fallOffBrightness), 1.0); //Mapping the brightness of the image to a grayscale
    
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = textureColor;
    
    //Alternate Fall off calculations
    //float fallOffBrightness = brightness/(brightness+1.0)-2.0; //Calculates the value based on its prightness
}