using UnityEngine;

/// <summary>
/// Controller script for the whole animation 
/// Handles ground, beam, light, camera shake and particles
/// </summary>
public class SequenceController : MonoBehaviour
{
    /// <summary>
    /// 0 is the start of the sequence, 1 the end
    /// </summary>
    [Range(0,1)]
    public float SequenceVal;

    /// <summary>
    /// The material of the ground. Used for setting the sequence var there
    /// </summary>
    public Material GroundMat;
    /// <summary>
    /// The material of the beam. Used for setting the sequence variable there
    /// </summary>
    public Material BeamMat;

    /// <summary>
    /// Point light used for simulation additional emission from the beam
    /// </summary>
    public Light LaserLight;

    /// <summary>
    /// The dust particle systems
    /// </summary>
    public GameObject[] ParticleSystems;

    /// <summary>
    /// The particle system transform of the lightning
    /// This one always stays on, however it scales based on the beam width
    /// </summary>
    public Transform LightningParticles;

    /// <summary>
    /// Transform component of the camera
    /// Nested inside an empty parent to allow orbital movement while shaking the screen
    /// </summary>
    public Transform CameraTransform;
    
    //Cacke the shader properties to avoid string comparisons
    private static readonly int Sequence = Shader.PropertyToID("_Sequence");
    private static readonly int HeightMax = Shader.PropertyToID("_Sequence");

    //Handle the sequence loop
    private void Update()
    {
        //Current sequence duration is 5s
        SequenceVal += Time.deltaTime * 0.2f;
        if (SequenceVal > 1.0f)
        {
            SequenceVal = 0.0f;
            CameraTransform.localPosition = Vector3.zero;
        }

        //Orbit camera rotation
        Transform localTransform;
        (localTransform = transform).rotation = Quaternion.Euler(45.0f, SequenceVal * 120.0f + 15.0f, 0);
        localTransform.position = -(localTransform.rotation * (Vector3.forward * 2.5f));

        //The first part of the sequence behaves differently from the second part
        if (SequenceVal < 0.1f)
        {
            //Ground Material
            GroundMat.SetFloat(Sequence, 0.01f - SequenceVal * 0.1f);
            
            //Beam Material
            BeamMat.SetFloat(HeightMax, Mathf.Pow(SequenceVal * 10.0f, 5.0f));
            
            //Light
            LaserLight.intensity = SequenceVal * 8.0f;
            
            //Particle System
            foreach (GameObject go in ParticleSystems)
                go.SetActive(false);

            //Lighting Particles
            LightningParticles.localScale = new Vector3(0.4f, 0.4f, 1.0f);
        }
        else
        {
            //Ground Material
            GroundMat.SetFloat(Sequence, SequenceVal * 1.09f - 0.09f);
            
            //Beam Material
            BeamMat.SetFloat(HeightMax, 1.0f);
            
            //Light
            LaserLight.intensity = Mathf.Sin(Time.time * 30.0f) * 0.03f + 
                                   Mathf.Sin(Time.time * 50.0f) * 0.03f +
                                   Mathf.Sin(Time.time * 7.0f) * 0.01f +
                                   0.8f;
            
            //Particle System
            foreach (GameObject go in ParticleSystems)
            {
                go.SetActive(true);
            }

            //Lighting Particles
            LightningParticles.localScale = Vector3.one;

            //Camera shake
            CameraTransform.localPosition = Random.insideUnitSphere * 0.04f * (1.0f - SequenceVal);
        }
    }
}
