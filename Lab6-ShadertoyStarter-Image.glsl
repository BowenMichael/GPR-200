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
    vec4 t1 = texture(iChannel0, uv);
    vec4 t2 = texture(iChannel1, uv);
    vec4 t3 = texture(iChannel2, uv);
    vec4 mixedColor = t1 + t2; //add
    mixedColor = mix(t1, t2, .5); //mix
    mixedColor = screen(t1, t2); //screen
    mixedColor = softLight(t1, t2); //Pegtop's formula soft light compositing

    fragColor = mixedColor; //Mixed Colors
    //fragColor = t3; //bright pass
    //fragColor = t2; //cubemap
    //fragColor = t1; //blur
}