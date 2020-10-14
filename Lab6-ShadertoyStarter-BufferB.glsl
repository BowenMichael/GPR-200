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
    
    vec4 tex = texture(iChannel0, uv);
    vec4 BrightColor;
    float brightness = dot(tex.rgb, vec3(0.2126, 0.7152, 0.0722));
    brightness -= 2.5; //shifts the input value to move the function output along the x axis
    float fallOffBrightness = brightness/(brightness+1.0)-2.0; //Calculates the value based on its prightness
    BrightColor = vec4(vec3(fallOffBrightness), 1.0);//
    fragColor = BrightColor;
        
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = textureColor;
}