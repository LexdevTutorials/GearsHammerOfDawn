Shader "Lexdev/GearsHammer/Beam"
{
    Properties
    {
        //Color properties
        _Color ("Color", Color) = (1,1,1,1)
        _Emission ("Emission", Color) = (1,1,1,1)
        
        //0 = start of the sequence (small beam at the bottom), 1 = end of sequence (large beam)
        _Sequence("Sequence Value", Range(0,1)) = 0.1

        //Changes the width of the whole beam
        _Width("Width Multiplier", Range(1,3)) = 2

        //Noise
        _NoiseFrequency("Noise Frequency", Range(1,100)) = 50.0
        _NoiseLength("Noise Length", Range(0.01,1.0)) = 0.25
        _NoiseIntensity("Noise Intensity", Range(0,0.1)) = 0.02
    }
    SubShader
    {
        CGPROGRAM

        //Add a vertex function
        #pragma surface surf Standard vertex:vert

        //Unity's surface shaders require an input struct which cannot be empty
        struct Input
        {
            float4 color;
        };

        //Property variables
        fixed4 _Color;
        fixed4 _Emission;
        
        float _Sequence;
        float _Width;
        float _NoiseFrequency;
        float _NoiseLength;
        float _NoiseIntensity;
        
        //Vertex function. Controls the width of the beam
        void vert(inout appdata_full v)
        {
            float beamHeight = 20.0f; //The Height of the beam object
            float pi = 3.141f; //Roughly the value of pi. Good enough for us

            float scaledSeq = (1.0f - _Sequence) * 2.0f - 1.0f; //Invert the sequence value and scale it to [-1;1]
            float scaledHeightMax = scaledSeq * beamHeight; //The sequence value scaled with the height of the beam object
            
            //Create a maximum that moves from the top to the bottom of the beam based on the sequence value
            float cosVal = cos(pi * (v.vertex.z / beamHeight - scaledSeq));
            //Calculate the width of the beam below the maximum
            float width = lerp(0.05f * (beamHeight - scaledHeightMax + 0.5f), cosVal, pow(smoothstep(scaledHeightMax - 8.0f, scaledHeightMax, v.vertex.z), 0.1f));
            //Calculate the width of the beam above the maximum
            width = lerp(width, 0.4f, smoothstep(scaledHeightMax, scaledHeightMax + 10.0f, v.vertex.z));
            
            //Apply the calculated width to the beam
            v.vertex.xy *= width * _Width;
            
            //Add some noise to the beam
            v.vertex.xy += sin(_Time.y * _NoiseFrequency + v.vertex.z * _NoiseLength) * _NoiseIntensity * _Sequence;
        }

        //Basic surface function
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Color.rgb;
            o.Emission = _Emission;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
