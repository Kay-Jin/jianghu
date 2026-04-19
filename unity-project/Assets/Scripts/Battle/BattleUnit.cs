using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 上场的战斗单位（每个角色 = 一个 BattleUnit）。
    /// 持有 <see cref="CharacterStats"/>、所在格子引用、已使用的行动。
    /// </summary>
    public class BattleUnit : MonoBehaviour
    {
        // ── 公开数据 ───────────────────────────────────────────────────
        public CharacterData   Data   { get; private set; }
        public CharacterStats  Stats  { get; private set; }
        public CharacterFaction Faction => Data.faction;

        public HexCell Cell   { get; private set; }
        public bool IsAlive   => Stats != null && !Stats.IsDead;

        // ── 回合行动状态 ───────────────────────────────────────────────
        public bool HasMoved    { get; private set; }
        public bool HasActed    { get; private set; }
        public bool TurnDone    => HasMoved && HasActed;

        // ── 面向（0-5 对应六个方向）────────────────────────────────────
        public int FacingDir    { get; private set; } = 0;

        // ── 事件 ──────────────────────────────────────────────────────
        public event System.Action<BattleUnit, int> OnDamaged;  // (unit, dmg)
        public event System.Action<BattleUnit>      OnDied;
        public event System.Action<BattleUnit>      OnTurnStart;
        public event System.Action<BattleUnit>      OnTurnEnd;

        // ── 视觉 ──────────────────────────────────────────────────────
        private static readonly Color ColorPlayer  = new Color(0.3f, 0.6f, 1.0f);
        private static readonly Color ColorAlly    = new Color(0.3f, 0.9f, 0.4f);
        private static readonly Color ColorEnemy   = new Color(1.0f, 0.3f, 0.3f);

        // ── 初始化 ─────────────────────────────────────────────────────
        public void Init(CharacterData data, HexCell startCell, int level = 1)
        {
            Data  = data;
            Stats = new CharacterStats(data, level);
            PlaceAt(startCell);
            ApplyVisual();
        }

        private void ApplyVisual()
        {
            var r = GetComponentInChildren<Renderer>();
            if (r == null) return;
            var mpb = new MaterialPropertyBlock();
            r.GetPropertyBlock(mpb);
            Color c = Faction switch
            {
                CharacterFaction.Player => ColorPlayer,
                CharacterFaction.Ally   => ColorAlly,
                CharacterFaction.Enemy  => ColorEnemy,
                _                       => Color.white,
            };
            mpb.SetColor("_BaseColor", c);
            r.SetPropertyBlock(mpb);
        }

        // ── 位置 ───────────────────────────────────────────────────────
        public void PlaceAt(HexCell cell)
        {
            if (Cell != null) Cell.Occupant = null;
            Cell = cell;
            if (cell != null)
            {
                cell.Occupant = this;
                transform.position = HexCoord.ToWorld(cell.Coord, HexGrid.Instance != null
                    ? 1.1f : 1.1f) + Vector3.up * 0.6f;
            }
        }

        // ── 面向 ───────────────────────────────────────────────────────
        public void FaceToward(HexCell target)
        {
            if (target == null) return;
            for (int d = 0; d < 6; d++)
            {
                if (Cell.Coord.Neighbor(d) == target.Coord)
                {
                    FacingDir = d;
                    Vector3 dir = HexCoord.ToWorld(target.Coord, 1.1f) - HexCoord.ToWorld(Cell.Coord, 1.1f);
                    if (dir != Vector3.zero)
                        transform.rotation = Quaternion.LookRotation(dir, Vector3.up);
                    break;
                }
            }
        }

        // ── 受伤与死亡 ─────────────────────────────────────────────────
        public void TakeDamage(int amount)
        {
            if (!IsAlive) return;
            amount = Mathf.Max(1, amount);
            Stats.Hp -= amount;
            OnDamaged?.Invoke(this, amount);
            Debug.Log($"[Battle] {Data.characterName} 受到 {amount} 点伤害，剩余 {Stats.Hp}/{Stats.MaxHp}");

            if (Stats.IsDead) Die();
        }

        public void Heal(int amount)
        {
            if (!IsAlive) return;
            Stats.Hp += amount;
        }

        private void Die()
        {
            Debug.Log($"[Battle] {Data.characterName} 战败！");
            OnDied?.Invoke(this);
            if (Cell != null) Cell.Occupant = null;
            Cell = null;
            // 占位：倒地效果（后续接动画）
            StartCoroutine(DeathVisual());
        }

        private IEnumerator DeathVisual()
        {
            transform.Rotate(0f, 0f, 90f);
            yield return new WaitForSeconds(1.2f);
            gameObject.SetActive(false);
        }

        // ── 回合管理 ───────────────────────────────────────────────────
        public void BeginTurn()
        {
            HasMoved = false;
            HasActed = false;
            Stats.RecoverMpPerTurn();
            OnTurnStart?.Invoke(this);
        }

        public void EndTurn()
        {
            HasMoved = true;
            HasActed = true;
            OnTurnEnd?.Invoke(this);
        }

        public void SetMoved()  => HasMoved = true;
        public void SetActed()  => HasActed = true;

        // ── 移动动画 ───────────────────────────────────────────────────
        public IEnumerator MoveAlongPath(List<HexCell> path, float speed = 5f)
        {
            foreach (var cell in path)
            {
                Vector3 target = HexCoord.ToWorld(cell.Coord, 1.1f) + Vector3.up * 0.6f;
                FaceToward(cell);
                while (Vector3.Distance(transform.position, target) > 0.05f)
                {
                    transform.position = Vector3.MoveTowards(transform.position, target, speed * Time.deltaTime);
                    yield return null;
                }
                transform.position = target;
            }
            if (path.Count > 0) PlaceAt(path[^1]);
        }

        public override string ToString() => $"{Data.characterName}@{Cell?.Coord}";
    }
}
