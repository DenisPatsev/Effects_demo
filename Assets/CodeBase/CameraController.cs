using System;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public GameObject cameraPivot;
    public Camera camera;
    public float rotationSpeed;
    public float manualRotationSpeed;
    [Range(0, 1)] public float minZoom;
    public bool isManualControl;
    public Vector3 cameraOffset;

    private float _rotationX;
    private float _rotationY;
    private float _targetPosZ;

    private void Start()
    {
        camera.transform.position = cameraPivot.transform.position + cameraOffset;

        if (isManualControl)
            CalculateDynamicZoomedRotation();
    }

    private void Update()
    {
        camera.transform.LookAt(cameraPivot.transform.position);

        if (!isManualControl)
        {
            AutoRotate();
        }
        else
        {
            RotateManually();
        }
    }

    private void AutoRotate()
    {
        cameraPivot.transform.rotation *= Quaternion.Euler(0, Time.deltaTime * rotationSpeed, 0);
    }

    private void RotateManually()
    {
        if (Input.GetKey(KeyCode.Mouse0))
        {
            _rotationX = Mathf.Lerp(_rotationX, _rotationX + Input.GetAxis("Mouse X"),
                manualRotationSpeed * Time.deltaTime);
            _rotationY += Input.GetAxis("Mouse Y") * manualRotationSpeed * Time.deltaTime;

            _rotationY = Mathf.Clamp(_rotationY, -90, 20);

            CalculateDynamicZoomedRotation();
        }
    }

    private void CalculateDynamicZoomedRotation()
    {
        float zMultiplier = (Mathf.Abs(_rotationY) / 90f);

        zMultiplier = Mathf.Clamp(zMultiplier, minZoom, 1);

        float zPos = (cameraPivot.transform.position.z + cameraOffset.z) * zMultiplier;
        _targetPosZ = Mathf.Lerp(_targetPosZ, (cameraPivot.transform.position.z + cameraOffset.z) * zMultiplier,
            Time.deltaTime * manualRotationSpeed);

        camera.transform.localPosition = new Vector3(camera.transform.localPosition.x, camera.transform.localPosition.y,
            _targetPosZ);

        cameraPivot.transform.rotation = Quaternion.Euler(-_rotationY, _rotationX, 0);
    }
}