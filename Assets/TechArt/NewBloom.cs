using UnityEngine;

[ImageEffectAllowedInSceneView]
public class NewBloom : MonoBehaviour
{
    private const int BoxDownPreFilterPass = 0;
    private const int BoxDownPass = 1;
    private const int BoxUpPass = 2;
    private const int ApplyBloomPass = 3;

    [Range(0, 10f)] public float bloomIntensity;
    [Range(0, 2f)] public float bloomThreshold;
    [Range(1, 16f)] public int iterations;
    public Shader newBloomShader;

    private Material _bloomMat;

    private void Start()
    {
        _bloomMat = new Material(newBloomShader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _bloomMat.SetFloat("_Intensity", bloomIntensity);
        _bloomMat.SetFloat("_Threshold", bloomThreshold);
        RenderTexture[] textures = new RenderTexture[16];
        int width = source.width;
        int height = source.height;

        RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, source.format);

        Graphics.Blit(source, currentDestination, _bloomMat, BoxDownPreFilterPass);
        RenderTexture currentSource = currentDestination;

        int i = 1;
        
        for (; i < iterations; i++)
        {
            width /= 2;
            height /= 2;

            if (height < 2)
                break;

            currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, source.format);
            Graphics.Blit(currentSource, currentDestination, _bloomMat, BoxDownPass);
            currentSource = currentDestination;
        }

        for (i -= 2; i >= 0; i--)
        {
            currentDestination = textures[i];
            textures[i] = null;
            Graphics.Blit(currentSource, currentDestination, _bloomMat, BoxUpPass);
            RenderTexture.ReleaseTemporary(currentSource);
            currentSource = currentDestination;
        }

        _bloomMat.SetTexture("_SourceTex", source);
        Graphics.Blit(currentSource, destination, _bloomMat, ApplyBloomPass);
        RenderTexture.ReleaseTemporary(currentSource);
    }
}