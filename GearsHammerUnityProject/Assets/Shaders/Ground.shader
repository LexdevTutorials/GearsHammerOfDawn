Shader "Lexdev/GearsHammer/Ground"
{
    Properties
    {
        //0 = start of the sequence (slightly cracked floor), 1 = end of sequence (everything gone crazy)
        _Sequence("Sequence", Range(0,1)) = 0.0
        //Some perlin noise to randomize some values
        _Noise("Noise Texture", 2D) = "white" {}

        _Exp("Shape Exponent", Range(1.0,10.0)) = 5.0
        _Rot("Rotation Multiplier", Range(1.0,100.0)) = 50.0
        _Height("Height Multiplier", Range(0.1,1.0)) = 0.5
    }
    SubShader
    {
        CGPROGRAM

        #pragma surface surf Standard vertex:vert

        struct Input
        {
            float3 color;
        };

        //Property variables
        float _Sequence;
        sampler2D _Noise;

        float _Exp;
        float _Rot;
        float _Height;

        //Helper function used to rotate a vertex and it's normal around a point and axis
        void Rotate(inout float4 vertex, inout float3 normal, float3 center, float3 around, float angle)
        {
            //Translation matrix for the center position and reverse matrix
            float4x4 translation = float4x4(
                1, 0, 0, center.x,
                0, 1, 0, -center.y,
                0, 0, 1, -center.z,
                0, 0, 0, 1);
            float4x4 translationT = float4x4(
                1, 0, 0, -center.x,
                0, 1, 0, center.y,
                0, 0, 1, center.z,
                0, 0, 0, 1);

            //Calculate some values that are used often
            around.x = -around.x;
            around = normalize(around);
            float s = sin(angle);
            float c = cos(angle);
            float ic = 1.0 - c;

            //Rotation matrix around an arbitrary, given axis
            float4x4 rotation = float4x4(
                ic * around.x * around.x + c           , ic * around.x * around.y - s * around.z, ic * around.z * around.x + s * around.y, 0.0,
                ic * around.x * around.y + s * around.z, ic * around.y * around.y + c           , ic * around.y * around.z - s * around.x, 0.0,
                ic * around.z * around.x - s * around.y, ic * around.y * around.z + s * around.x, ic * around.z * around.z + c           , 0.0,
                0.0                                    , 0.0                                    , 0.0                                    , 1.0);

            //Rotate the vertex and its normal
            vertex = mul(translationT, mul(rotation, mul(translation, vertex)));
            normal = mul(translationT, mul(rotation, mul(translation, float4(normal, 0.0f)))).xyz;
        }

        //Vertex function
        void vert(inout appdata_full v)
        {
            float noise = tex2Dlod(_Noise, v.texcoord * 2.0f).r; //Noise value for the center
            float2 uvDir = v.texcoord.xy - 0.5f; //UV is [0;1], however our center is at 0.5, 0.5 so we have to shift coords
            float scaledSequence = _Sequence * 1.52f - 0.02f; //This is actually just done by testing
            float seqVal = pow(1.0f - (noise + 1.0f) * length(uvDir), _Exp) * scaledSequence; //Basic explosion shape

            //Rotate the vertices
            Rotate(v.vertex, v.normal, float3(2.0f * uvDir, 0), cross(float3(uvDir, 0), float3(noise * 0.1f,0,1)), seqVal * _Rot);

            //Vertex position offsets
            v.vertex.z += sin(seqVal * 2.0f) * (noise + 1.0f) * _Height;
            v.vertex.xy -= normalize(float2(v.texcoord.x, 1.0f - v.texcoord.y) - 0.5f) * seqVal * noise;
        }

        //Basic surface function
        void surf (Input i, inout SurfaceOutputStandard o)
        {
            o.Albedo = float3(1, 1, 1);
        }

        ENDCG
    }
}
