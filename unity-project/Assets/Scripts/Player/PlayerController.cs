using UnityEngine;

namespace Jianghu.Player
{
    /// <summary>
    /// 第三人称角色控制器：WASD 移动、空格跳跃、鼠标视角由 <see cref="ThirdPersonCamera"/> 驱动。
    /// 使用 Unity 原生 <see cref="CharacterController"/>，无需 Rigidbody，手感可控、零依赖。
    /// </summary>
    [RequireComponent(typeof(CharacterController))]
    public class PlayerController : MonoBehaviour
    {
        [Header("Movement")]
        [SerializeField] private float walkSpeed = 4f;
        [SerializeField] private float runSpeed = 7.5f;
        [SerializeField] private float rotationSpeed = 720f;
        [SerializeField] private float jumpHeight = 1.4f;
        [SerializeField] private float gravity = -20f;

        [Header("References")]
        [Tooltip("用于读取朝向的相机；留空则自动使用 Camera.main。")]
        [SerializeField] private Transform cameraRef;

        private CharacterController _cc;
        private Vector3 _velocity;
        private bool _grounded;

        public bool IsMoving { get; private set; }
        public bool IsRunning { get; private set; }

        private void Awake()
        {
            _cc = GetComponent<CharacterController>();
            if (cameraRef == null && Camera.main != null)
            {
                cameraRef = Camera.main.transform;
            }
        }

        private void Update()
        {
            _grounded = _cc.isGrounded;
            if (_grounded && _velocity.y < 0f)
            {
                _velocity.y = -2f;
            }

            HandleMovement();
            HandleJump();
            ApplyGravity();
        }

        private void HandleMovement()
        {
            float h = Input.GetAxisRaw("Horizontal");
            float v = Input.GetAxisRaw("Vertical");
            Vector3 input = new Vector3(h, 0f, v);
            IsMoving = input.sqrMagnitude > 0.01f;
            IsRunning = IsMoving && Input.GetKey(KeyCode.LeftShift);

            if (!IsMoving)
            {
                return;
            }

            Vector3 forward = cameraRef != null ? cameraRef.forward : Vector3.forward;
            Vector3 right = cameraRef != null ? cameraRef.right : Vector3.right;
            forward.y = 0f;
            right.y = 0f;
            forward.Normalize();
            right.Normalize();

            Vector3 move = (forward * v + right * h).normalized;
            float speed = IsRunning ? runSpeed : walkSpeed;
            _cc.Move(move * speed * Time.deltaTime);

            Quaternion target = Quaternion.LookRotation(move, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(transform.rotation, target, rotationSpeed * Time.deltaTime);
        }

        private void HandleJump()
        {
            if (_grounded && Input.GetKeyDown(KeyCode.Space))
            {
                _velocity.y = Mathf.Sqrt(jumpHeight * -2f * gravity);
            }
        }

        private void ApplyGravity()
        {
            _velocity.y += gravity * Time.deltaTime;
            _cc.Move(_velocity * Time.deltaTime);
        }
    }
}
