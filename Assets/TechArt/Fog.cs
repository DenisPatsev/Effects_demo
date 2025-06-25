using System;
using UnityEngine;

public class Fog : MonoBehaviour
{
    [SerializeField] private Shader _fogShader;
    [SerializeField] private Color _farColor;
    [Range(0, 5f)] public float _fogEnd;

    private Material _material;
    private Camera mainCamera;

    private void Awake()
    {
        mainCamera = GetComponent<Camera>();
        mainCamera.depthTextureMode = DepthTextureMode.Depth;
        _material = new Material(_fogShader);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _material.SetColor("_FarColor", _farColor);
        _material.SetFloat("_DepthFactor", _fogEnd);
        Graphics.Blit(source, destination, _material, 0);
    }

    private void OnDisable()
    {
        mainCamera.depthTextureMode = DepthTextureMode.None;
    }
}