using System;
using UnityEngine;

public class CameraController : MonoBehaviour
{
   public GameObject cameraPivot;
   public Camera camera;
   public float rotationSpeed;
   public Vector3 cameraOffset;

   private void Start()
   {
      camera.transform.position = cameraPivot.transform.position + cameraOffset;
   }

   private void Update()
   {
      cameraPivot.transform.rotation *= Quaternion.Euler(0, Time.deltaTime * rotationSpeed, 0);
      camera.transform.LookAt(cameraPivot.transform.position);
   }
}
