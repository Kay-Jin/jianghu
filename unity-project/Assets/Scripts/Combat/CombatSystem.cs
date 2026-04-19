using System.Collections;
using UnityEngine;
using Jianghu.Player;

namespace Jianghu.Combat
{
    /// <summary>
    /// 玩家侧战斗入口：鼠标左键普攻、数字键触发武功（从 <see cref="MartialArtDatabase"/> 取）。
    /// 打击感：命中后全局时间缩放一个很短的顿帧 + Camera shake 占位。
    /// </summary>
    [RequireComponent(typeof(PlayerStats))]
    public class CombatSystem : MonoBehaviour
    {
        [Header("Light Attack (普攻)")]
        [SerializeField] private int lightAttackDamage = 8;
        [SerializeField] private float lightAttackCooldown = 0.4f;
        [SerializeField] private Vector3 lightHitBoxHalfExtents = new Vector3(0.8f, 0.9f, 0.9f);
        [SerializeField] private float lightAttackReach = 1.6f;

        [Header("Layers")]
        [SerializeField] private LayerMask hitMask = ~0;

        [Header("Camera Shake (optional)")]
        [SerializeField] private Transform cameraTransform;
        [SerializeField] private float shakeAmplitude = 0.08f;

        private PlayerStats _stats;
        private float _nextLightAttackTime;
        private float _nextMartialArtTime;

        private void Awake()
        {
            _stats = GetComponent<PlayerStats>();
            if (cameraTransform == null && Camera.main != null)
            {
                cameraTransform = Camera.main.transform;
            }
        }

        private void Update()
        {
            if (Input.GetMouseButtonDown(0))
            {
                TryLightAttack();
            }

            for (int i = 0; i < 3; i++)
            {
                if (Input.GetKeyDown(KeyCode.Alpha1 + i))
                {
                    TryUseMartialArt(i);
                }
            }
        }

        private void TryLightAttack()
        {
            if (Time.time < _nextLightAttackTime) return;
            if (!_stats.TrySpendStamina(5f)) return;

            _nextLightAttackTime = Time.time + lightAttackCooldown;
            DoHitBox(lightAttackReach, lightHitBoxHalfExtents, lightAttackDamage, 0f, 0f);
            Debug.Log("[Combat] Light attack.");
        }

        private void TryUseMartialArt(int index)
        {
            var db = MartialArtDatabase.Instance;
            if (db == null) return;
            var ma = db.Get(index);
            if (ma == null) return;

            if (Time.time < _nextMartialArtTime) return;
            if (!_stats.TrySpendMp(ma.mpCost)) return;
            if (!_stats.TrySpendStamina(ma.staminaCost)) return;

            _nextMartialArtTime = Time.time + ma.cooldown;

            if (ma.vfxPrefab != null)
            {
                Instantiate(ma.vfxPrefab, transform.position + transform.forward * ma.reach * 0.5f + Vector3.up,
                    transform.rotation);
            }

            DoHitBox(ma.reach, ma.hitBoxHalfExtents, ma.damage, ma.hitStopDuration, ma.camImpulseStrength);
            Debug.Log($"[Combat] Use 武功：{ma.displayName}");
        }

        private void DoHitBox(float reach, Vector3 halfExtents, int damage,
            float hitStopDuration, float camImpulse)
        {
            Vector3 center = transform.position + Vector3.up * 1f + transform.forward * reach;
            Quaternion orient = transform.rotation;
            Collider[] hits = Physics.OverlapBox(center, halfExtents, orient, hitMask,
                QueryTriggerInteraction.Ignore);

            bool any = false;
            foreach (var c in hits)
            {
                if (c.transform == transform || c.transform.IsChildOf(transform)) continue;
                var dmg = c.GetComponentInParent<Damageable>();
                if (dmg == null || dmg.IsDead) continue;
                dmg.ApplyDamage(damage, Faction.Player);
                any = true;
            }

            if (any)
            {
                if (hitStopDuration > 0f)
                {
                    StartCoroutine(HitStop(hitStopDuration));
                }
                if (camImpulse > 0f)
                {
                    StartCoroutine(CameraShake(camImpulse, 0.15f));
                }
            }
        }

        private IEnumerator HitStop(float duration)
        {
            float old = Time.timeScale;
            Time.timeScale = 0.05f;
            yield return new WaitForSecondsRealtime(duration);
            Time.timeScale = old;
        }

        private IEnumerator CameraShake(float amplitude, float duration)
        {
            if (cameraTransform == null) yield break;
            Vector3 origin = cameraTransform.localPosition;
            float t = 0f;
            while (t < duration)
            {
                t += Time.unscaledDeltaTime;
                cameraTransform.localPosition = origin + (Vector3)Random.insideUnitSphere * amplitude * shakeAmplitude;
                yield return null;
            }
            cameraTransform.localPosition = origin;
        }
    }
}
