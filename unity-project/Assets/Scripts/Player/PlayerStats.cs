using UnityEngine;
using Jianghu.Combat;

namespace Jianghu.Player
{
    /// <summary>
    /// 玩家属性：血、内力、体力、经验、等级等最小集合。
    /// 战斗伤害由 <see cref="Damageable"/> 处理并回调到这里。
    /// </summary>
    [RequireComponent(typeof(Damageable))]
    public class PlayerStats : MonoBehaviour
    {
        [Header("Vitals")]
        public int maxHp = 100;
        public int maxMp = 50;
        public int maxStamina = 100;

        [Header("Progression")]
        public int level = 1;
        public int exp;

        public int Hp { get; private set; }
        public int Mp { get; private set; }
        public float Stamina { get; private set; }

        public event System.Action<PlayerStats> OnChanged;
        public event System.Action OnDied;

        private Damageable _dmg;

        private void Awake()
        {
            Hp = maxHp;
            Mp = maxMp;
            Stamina = maxStamina;
            _dmg = GetComponent<Damageable>();
            _dmg.maxHp = maxHp;
            _dmg.Init();
            _dmg.OnDamaged += HandleDamaged;
            _dmg.OnDied += HandleDied;
        }

        private void Update()
        {
            // 体力回复
            if (Stamina < maxStamina)
            {
                Stamina = Mathf.Min(maxStamina, Stamina + 10f * Time.deltaTime);
                OnChanged?.Invoke(this);
            }
        }

        public bool TrySpendMp(int cost)
        {
            if (Mp < cost) return false;
            Mp -= cost;
            OnChanged?.Invoke(this);
            return true;
        }

        public bool TrySpendStamina(float cost)
        {
            if (Stamina < cost) return false;
            Stamina -= cost;
            OnChanged?.Invoke(this);
            return true;
        }

        public void Heal(int amount)
        {
            Hp = Mathf.Min(maxHp, Hp + amount);
            _dmg.Heal(amount);
            OnChanged?.Invoke(this);
        }

        public void LoadFromSave(int hp, int mp, int lvl, int xp)
        {
            Hp = hp; Mp = mp; level = lvl; exp = xp;
            _dmg.SetHp(hp);
            OnChanged?.Invoke(this);
        }

        private void HandleDamaged(int damage, int hpLeft)
        {
            Hp = hpLeft;
            OnChanged?.Invoke(this);
        }

        private void HandleDied()
        {
            OnDied?.Invoke();
            Debug.Log("[PlayerStats] Player died.");
        }
    }
}
