using System;
using UnityEngine;

public class CreationEffect : MonoBehaviour
{
    public GameObject effectParent;
    public GameObject plane;
    public ParticleSystem sparclesEffect;
    public Renderer renderer;
    public float moveSpeed;
    public float creationSpeed;

    private float _yPos;
    private float _creationProgress;

    private void Start()
    {
        sparclesEffect.Play();
        _creationProgress = 0.013f;
        _yPos = 0.0098f;
    }

    public void Update()
    {
        _yPos = Mathf.MoveTowards(_yPos, -0.00915f, moveSpeed * Time.deltaTime);
        _creationProgress = Mathf.MoveTowards(_creationProgress, -0.015f, creationSpeed * Time.deltaTime);
        renderer.material.SetFloat("_VertexPosCutoff", _creationProgress);
        effectParent.transform.localPosition = new Vector3(0, _yPos, 0);

        if (_yPos < -0.009148f)
        {
            sparclesEffect.Stop();
            plane.gameObject.SetActive(false);
        }
    }
}