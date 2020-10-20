// Buffer C by Michael Bowen
//  -> Buf C
//source for information regarding multi-pass/optimizations: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
//
//Desc: Calculates the x-axis gaussian blur with a convolution kernal using weighted sampling based on pascales triangle

//------------------------------------------------------------
// SHADERTOY Buffer C



// mainImage: process the current pixel (exactly one call per pixel)
//    fragColor: output final color for current pixel
//    fragCoord: input location of current pixel in image (in pixels)
void mainImage(out color4 fragColor, in sCoord fragCoord)
{
    //global variables
	//float weight[3] = float[](0.375, 0.25, 0.625); // divides by the sum removing a division calculation from the code(weight at n)/(2^n) = weight at kernal
    //Convolution experimentation: float weight[3] = float[](6.0, 4.0, 1.0); //based on the pascels triangle. half of a given row
    
    //setup
    vec2 pixelSize = 1.0 / iChannelResolution[0].xy; //invRes
    vec2 uv = vec2(fragCoord) * pixelSize; //define uv plane

    //Convolution Experimentation Declaration
    //float weightSum;
    //vec3 tex;

    //sampling
	int i;
    vec4 textureColor = texture(iChannel0, uv) * weight[0]; //runs outside the loop because the weight index at zero only runs once
    for(i= weight.length() - 1; i > 0; --i){
        
        //All the pixel samples to the right
        uv = (vec2(fragCoord) + vec2(float(i), 0.0)) * pixelSize; //since pixel size is the measure of a single UV pixel can we get rid of the call to frag coord?
        textureColor += texture(iChannel0, uv) * weight[i];
        
        //All the pixel samples to the left
        uv = (vec2(fragCoord) - vec2(float(i), 0.0)) * pixelSize;
        textureColor += texture(iChannel0, uv) * weight[i];
        
        //Convolution experimentation
        //float weight = length(textureColor);
        //weightSum += weight[i];
    	//tex += weight * textureColor.rgb;
    }

    fragColor = textureColor;
    
    // TESTING
    // set iChannel0 to 'Misc/Buffer A' and fetch sample
    //fragColor = tex;
    
    //more Convolution experimentation
    //float inverseWeightSum = 1.0/weightSum; //don't need because of the construction of the weight array
    //vec4 finalColor = vec4(vec3(textureColor.rgb*inverseWeightSum), 1.0);
    //vec4 finalColor = vec4(vec3(textureColor.rgb), 1.0);
    //vec4 finalColor = textureColor;
    
}