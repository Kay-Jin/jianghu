using UnityEngine;

namespace Jianghu.Player
{
    /// <summary>
    /// 极简第三人称越肩相机：按住鼠标右键或始终跟随（<see cref="alwaysRotate"/>）拖动视角。
    /// 不依赖 Cinemachine，首跑原型用；后续可切为 CinemachineCamera + 3rd Person Follow。
    /// </summary>
    public class ThirdPersonCamera : MonoBehaviour
    {
        [Header("Target")]
        [SerializeField] private Transform target;
        [SerializeField] private Vector3 targetOffset = new Vector3(0f, 1.6f, 0f);

        [Header("Distance & Angles")]
        [SerializeField] private float distance = 4.5f;
        [SerializeField] private float minPitch = -20f;
        [SerializeField] private float maxPitch = 70f;

        [Header("Input")]
        [SerializeField] private float mouseSensitivity = 3f;
        [SerializeField] private bool alwaysRotate = true;
        [SerializeField] private KeyCode rotateButton = KeyCode.Mouse1;

        [Header("Collision")]
        [SerializeField] private LayerMask obstructionMask = ~0;
        [SerializeField] private float collisionPadding = 0.2f;

        private float _yaw;
        private float _pitch = 15f;

        public void SetTarget(Transform t) => target = t;

        private void Start()
        {
            if (target != null)
            {
                _yaw = target.eulerAngles.y;
            }
            Cursor.lockState = CursorLockMode.Confined;
        }

        private void LateUpdate()
        {
            if (target == null)
            {
                return;
            }

            bool canRotate = alwaysRotate || Input.GetKey(rotateButton);
            if (canRotate)
            {
                _yaw += Input.GetAxis("Mouse X") * mouseSensitivity;
                _pitch -= Input.GetAxis("Mouse Y") * mouseSensitivity;
                _pitch = Mathf.Clamp(_pitch, minPitch, maxPitch);
            }

            Quaternion rot = Quaternion.Euler(_pitch, _yaw, 0f);
            Vector3 pivot = target.position + targetOffset;
            Vector3 desired = pivot + rot * new Vector3(0f, 0f, -distance);

            if (Physics.SphereCast(pivot, collisionPadding, (desired - pivot).normalized,
                    out RaycastHit hit, distance, obstructionMask, QueryTriggerInteraction.Ignore))
            {
                desired = pivot + (desired - pivot).normalized * (hit.distance - collisionPadding);
            }

            transform.position = desired;
            transform.rotation = rot;
        }
    }
}
