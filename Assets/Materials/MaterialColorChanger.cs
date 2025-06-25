using UnityEngine;

public class MaterialColorChanger : MonoBehaviour
{
    [ColorUsage(true, true)] 
    [SerializeField]
    private Color32 _color;
    [SerializeField] private float _distortionStrenght;
    [Range(0f, 1f)] public float distortionBlend;

    [SerializeField] private MeshRenderer _meshRenderer;

    private MaterialPropertyBlock _materialPropertyBlock;

    private void Start()
    {
        _materialPropertyBlock = new MaterialPropertyBlock();
        _meshRenderer.GetPropertyBlock(_materialPropertyBlock);
        _materialPropertyBlock.SetColor("_Color", _color);
        _materialPropertyBlock.SetFloat("_DistortionStrenght", _distortionStrenght);
        _materialPropertyBlock.SetFloat("_DistortionBlend", distortionBlend);
        _meshRenderer.SetPropertyBlock(_materialPropertyBlock);
        // _meshRenderer.sharedMaterial.SetColor("_Color", _color);
    }
}