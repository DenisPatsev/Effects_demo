using UnityEngine;

public class ShaderColorSetter : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private PropertyBlockColor[] _colors;

    private MaterialPropertyBlock _materialPropertyBlock;

    private void Start()
    {
        _materialPropertyBlock = new MaterialPropertyBlock();
    }

    private void Update()
    {
        foreach (var color in _colors)
        {
            _materialPropertyBlock.SetColor(color.colorName, color.color);
        }

        _renderer.SetPropertyBlock(_materialPropertyBlock);
    }
}