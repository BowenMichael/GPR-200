// GLSL STARTER CODE BY DANIEL S. BUCKSTEIN
//  -> IMAGE TAB (final)

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
    
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    fragColor = texture(iChannel0, uv);
}