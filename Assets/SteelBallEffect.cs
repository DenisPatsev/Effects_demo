using System;
using UnityEngine;

public class SteelBallEffect : MonoBehaviour
{
    [SerializeField] private Renderer _renderer;
    [SerializeField] private ParticleSystem _groundDamage;
    [SerializeField] private ParticleSystem _smoke;
    [SerializeField] private ParticleSystem _dust;

    [ColorUsage(true, true)] [SerializeField]
    private Color _startColor;

    [ColorUsage(true, true)] [SerializeField]
    private Color _targetColor;

    [SerializeField] private float _colorChangeSpeed;

    private MaterialPropertyBlock _materialPropertyBlock;

    private void Start()
    {
        _materialPropertyBlock = new MaterialPropertyBlock();
    }

    private void OnCollisionEnter(Collision other)
    {
        _groundDamage.Play();
        _smoke.Play();
        _dust.Play();
    }

    private void FixedUpdate()
    {
        Color color = Color.Lerp(_targetColor, _startColor, _colorChangeSpeed * Time.fixedTime);
        _materialPropertyBlock.SetColor("_FresnelColor",
            color);
        _renderer.SetPropertyBlock(_materialPropertyBlock);
    }
}