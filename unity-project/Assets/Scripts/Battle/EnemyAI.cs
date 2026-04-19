using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 敌方 AI：每次回合时自动选择行动（移动 + 攻击 / 武功）。
    /// 策略：优先攻击血量最低的可攻击目标；否则向最近敌人移动。
    /// </summary>
    public class EnemyAI : MonoBehaviour
    {
        [Tooltip("AI 决策延迟（秒），让玩家看清楚 AI 在做什么")]
        [SerializeField] private float thinkDelay = 0.6f;
        [SerializeField] private float moveSpeed  = 4f;

        private BattleManager _manager;

        public void Init(BattleManager manager) => _manager = manager;

        // ── 主入口（BattleManager 调用）──────────────────────────────
        public IEnumerator ExecuteTurn(BattleUnit unit)
        {
            yield return new WaitForSeconds(thinkDelay);

            if (!unit.IsAlive) yield break;

            var grid    = HexGrid.Instance;
            var targets = GetOppositeUnits(unit);

            if (targets.Count == 0)
            {
                unit.EndTurn();
                yield break;
            }

            // 1. 判断能否直接攻击
            var attackable = targets
                .Where(t => HexCoord.Distance(unit.Cell.Coord, t.Cell.Coord) <= unit.Data.attackRange)
                .OrderBy(t => t.Stats.Hp)
                .FirstOrDefault();

            if (attackable != null)
            {
                // 直接攻击最低血量目标
                yield return StartCoroutine(AttackTarget(unit, attackable));
            }
            else
            {
                // 2. 移动到距最近目标的攻击范围内
                var nearest = targets.OrderBy(t => HexCoord.Distance(unit.Cell.Coord, t.Cell.Coord)).First();
                yield return StartCoroutine(MoveTowardTarget(unit, nearest, grid));

                // 移动后再判断能否攻击
                if (unit.Cell != null)
                {
                    attackable = targets
                        .Where(t => HexCoord.Distance(unit.Cell.Coord, t.Cell.Coord) <= unit.Data.attackRange)
                        .OrderBy(t => t.Stats.Hp)
                        .FirstOrDefault();
                    if (attackable != null)
                        yield return StartCoroutine(AttackTarget(unit, attackable));
                }
            }

            unit.EndTurn();
            _manager?.OnEnemyActionComplete();
        }

        // ── 移动 ───────────────────────────────────────────────────────
        private IEnumerator MoveTowardTarget(BattleUnit unit, BattleUnit target, HexGrid grid)
        {
            if (grid == null) yield break;

            var reachable = grid.GetMovableRange(unit.Cell, unit.Stats.MoveRange, unit);

            // 在可达格中找一个距离目标最近且满足攻击距离的格
            HexCell bestCell = null;
            int bestDist     = int.MaxValue;
            foreach (var cell in reachable)
            {
                int dist = HexCoord.Distance(cell.Coord, target.Cell.Coord);
                if (dist < bestDist)
                {
                    bestDist = dist;
                    bestCell = cell;
                }
            }

            if (bestCell == null || bestCell == unit.Cell) yield break;

            var path = grid.FindPath(unit.Cell, bestCell, unit);
            if (path == null || path.Count == 0) yield break;

            grid.ClearAllHighlights();
            yield return unit.StartCoroutine(unit.MoveAlongPath(path, moveSpeed));
            unit.SetMoved();
        }

        // ── 攻击 ───────────────────────────────────────────────────────
        private IEnumerator AttackTarget(BattleUnit attacker, BattleUnit defender)
        {
            attacker.FaceToward(defender.Cell);
            yield return new WaitForSeconds(0.3f);

            if (DamageCalculator.IsEvaded(attacker, defender))
            {
                Debug.Log($"[AI] {defender.Data.characterName} 闪避了攻击！");
                ShowFloatingText(defender, "闪！", Color.cyan);
                yield break;
            }

            float encircle = DamageCalculator.CalcEncirclementBonus(defender);
            int   dmg      = Mathf.RoundToInt(
                DamageCalculator.CalcNormalAttack(attacker, defender) * encircle);

            ShowFloatingText(defender, $"-{dmg}", Color.red);
            defender.TakeDamage(dmg);
            attacker.SetActed();

            yield return new WaitForSeconds(0.2f);

            _manager?.CheckVictoryCondition();
        }

        // ── 辅助 ───────────────────────────────────────────────────────
        private List<BattleUnit> GetOppositeUnits(BattleUnit unit)
        {
            if (_manager == null) return new List<BattleUnit>();
            return _manager.AllUnits
                .Where(u => u.IsAlive && u.Faction != unit.Faction && u.Faction != CharacterFaction.Neutral)
                .ToList();
        }

        // 占位：浮动伤害数字（后续改为 Canvas UI）
        private void ShowFloatingText(BattleUnit target, string text, Color color)
        {
            Debug.Log($"[FloatText] {target.Data.characterName}: {text}");
        }
    }
}
