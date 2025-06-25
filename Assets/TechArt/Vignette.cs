using System;
using UnityEngine;

public class Vignette : MonoBehaviour
{
    [SerializeField] private Shader _vignetteShader;
    [SerializeField] private Color _color;
    [Range(0, 3f)] public float vignetteRadius;
    [Range(0, 1f)] public float vignetteSmoothness;

    private Material _material;
    
    private void Start()
    {
        _material = new Material(_vignetteShader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _material.SetColor("_Color", _color);
        _material.SetFloat("_VigneteSize", vignetteRadius);
        _material.SetFloat("_VigneteSmoothness", vignetteSmoothness);
        Graphics.Blit(source, destination, _material);
    }
}
