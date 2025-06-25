using System;
using UnityEngine;

public class MaterialPropertySetter : MonoBehaviour
{
    private Renderer _renderer;
    private Terrain _terrain;
    
    private MaterialPropertyBlock _propertyBlock;

    private void Awake()
    {
        _renderer = GetComponent<Renderer>();
        _propertyBlock = new MaterialPropertyBlock();
    }

    private void Update()
    {
        _propertyBlock.SetColor("_Color", _renderer.material.color);
        _renderer.SetPropertyBlock(_propertyBlock);
    }
}
