using System;
using UnityEngine;

public class PixelBuildEffect : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private float _buildSpeed;
    
    private MaterialPropertyBlock _materialPropertyBlock;
    private float _progress;

    private void Start()
    {
        _materialPropertyBlock = new MaterialPropertyBlock();
        _progress = 1f;
    }

    private void Update()
    {
        _progress -= Time.deltaTime * _buildSpeed;
        
        _materialPropertyBlock.SetFloat("_BuildProgress", _progress);
        _renderer.SetPropertyBlock(_materialPropertyBlock);
    }
}
