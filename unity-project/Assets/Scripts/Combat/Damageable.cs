using UnityEngine;

namespace Jianghu.Combat
{
    /// <summary>
    /// 任何可被攻击的对象挂这个组件。玩家、NPC、敌人通用。
    /// </summary>
    public class Damageable : MonoBehaviour
    {
        public int maxHp = 100;
        public int Hp { get; private set; }
        public bool IsDead => Hp <= 0;

        /// <summary>攻击阵营，同阵营不互伤。</summary>
        public Faction faction = Faction.Neutral;

        public event System.Action<int, int> OnDamaged;   // (damage, hpLeft)
        public event System.Action OnDied;

        /// <summary>由外部（如 PlayerStats）在初始化后手动触发。</summary>
        public void Init()
        {
            Hp = maxHp;
        }

        private void Awake()
        {
            if (Hp == 0) Hp = maxHp;
        }

        public void ApplyDamage(int amount, Faction attackerFaction)
        {
            if (IsDead) return;
            if (attackerFaction == faction && faction != Faction.Neutral) return;

            Hp = Mathf.Max(0, Hp - amount);
            OnDamaged?.Invoke(amount, Hp);

            if (Hp <= 0)
            {
                OnDied?.Invoke();
            }
        }

        public void Heal(int amount)
        {
            if (IsDead) return;
            Hp = Mathf.Min(maxHp, Hp + amount);
            OnDamaged?.Invoke(-amount, Hp);
        }

        public void SetHp(int hp)
        {
            Hp = Mathf.Clamp(hp, 0, maxHp);
            OnDamaged?.Invoke(0, Hp);
            if (Hp <= 0) OnDied?.Invoke();
        }
    }

    public enum Faction
    {
        Neutral,
        Player,
        Friendly,
        Enemy
    }
}
