using UnityEngine;

public class ShaderParametersSetter : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private PropertyBlockColor[] _colors;
    [SerializeField] private PropertyBlockParameter[] _parameters;

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

        foreach (var parameter in _parameters)
        {
            _materialPropertyBlock.SetFloat(parameter.parameterName, parameter.parameterValue);
        }

        _renderer.SetPropertyBlock(_materialPropertyBlock);
    }
}