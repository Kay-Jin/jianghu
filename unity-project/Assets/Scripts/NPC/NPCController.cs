using UnityEngine;
using Jianghu.Combat;

namespace Jianghu.NPC
{
    /// <summary>
    /// 最小 NPC：能挨打、可对话、可在范围内小幅漫游。
    /// 挂在 GameObject 上：建议同时挂 <see cref="CharacterController"/> 或 Rigidbody + Collider + Damageable。
    /// </summary>
    [RequireComponent(typeof(Damageable))]
    public class NPCController : MonoBehaviour
    {
        [Header("身份")]
        public string npcName = "路人甲";
        [TextArea] public string[] dialogueLines = new[] { "客官，敢问是路过还是专程来？" };

        [Header("漫游（占位，不依赖 NavMesh）")]
        [SerializeField] private float wanderRadius = 3f;
        [SerializeField] private float wanderInterval = 4f;
        [SerializeField] private float walkSpeed = 1.2f;

        private Vector3 _home;
        private Vector3 _target;
        private float _nextChooseTime;
        private Damageable _dmg;

        public bool IsInteractable => _dmg != null && !_dmg.IsDead;

        private void Awake()
        {
            _home = transform.position;
            _target = _home;
            _dmg = GetComponent<Damageable>();
            _dmg.faction = Faction.Friendly;
            _dmg.OnDied += HandleDied;
        }

        private void Update()
        {
            if (_dmg.IsDead) return;

            if (Time.time >= _nextChooseTime || Vector3.Distance(transform.position, _target) < 0.2f)
            {
                PickNewTarget();
            }

            Vector3 dir = (_target - transform.position);
            dir.y = 0f;
            if (dir.sqrMagnitude > 0.01f)
            {
                Vector3 step = dir.normalized * walkSpeed * Time.deltaTime;
                transform.position += step;
                Quaternion look = Quaternion.LookRotation(dir.normalized, Vector3.up);
                transform.rotation = Quaternion.Slerp(transform.rotation, look, 5f * Time.deltaTime);
            }
        }

        private void PickNewTarget()
        {
            Vector2 r = Random.insideUnitCircle * wanderRadius;
            _target = _home + new Vector3(r.x, 0f, r.y);
            _nextChooseTime = Time.time + wanderInterval;
        }

        private void HandleDied()
        {
            Debug.Log($"[NPC] {npcName} 倒下。");
            // 死亡占位：躺平 + 禁用胶囊 collider
            transform.Rotate(0f, 0f, 90f);
            var col = GetComponent<Collider>();
            if (col != null) col.enabled = false;
        }

        public string[] GetDialogueLines() => dialogueLines;
    }
}
