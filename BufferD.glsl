// Buffer D by Michael Bowen
//  -> Buf D
//source for information regarding multi-pass/optimizations: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
//Same as Buf C for y-axis

//------------------------------------------------------------
// SHADERTOY Buffer D

// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
	//float weight[3] = float[](6.0, 4.0, 1.0); //based on the pascels triangle. half of a given row
	//float weight[3] = float[](0.375, 0.25, 0.625); //alternate implementation divides by the sum removing a division calculation from the code(weight at n)/(2^n) = weight at kernal
    // setup
    // test UV for input image
    
    int i;
    vec2 pixelSize = 1.0 / iChannelResolution[0].xy; //declared for optimization
    vec2 uv = vec2(fragCoord) * pixelSize;
    vec4 textureColor = texture(iChannel0, uv) * weight[0]; //runs outside the loop because the weight index at zero only runs once
    for(i= weight.length() - 1; i > 0; --i){
        
        //All the pixel samples to the right
        uv = (vec2(fragCoord) + vec2(0.0, float(i))) * pixelSize;
        textureColor += texture(iChannel0, uv) * weight[i];
        
        //All the pixel samples to the left
        uv = (vec2(fragCoord) - vec2(0.0, float(i))) * pixelSize;
        textureColor += texture(iChannel0, uv) * weight[i];
        

    }
  
    fragColor =  textureColor; 
    
    
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = tex;
    
    
}