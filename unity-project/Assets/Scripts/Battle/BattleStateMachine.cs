using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 六边形战棋回合制状态机。
    /// 状态：准备 → 玩家选择 → 玩家行动 → 敌方行动 → 结算 → 结束。
    /// 由 <see cref="BattleManager"/> 持有并驱动。
    /// </summary>
    public class BattleStateMachine
    {
        // ── 状态枚举 ──────────────────────────────────────────────────
        public enum State
        {
            Idle,            // 未开始
            RoundStart,      // 回合开始（计算行动顺序）
            PlayerSelect,    // 玩家选择单位
            PlayerMove,      // 玩家选择移动目标
            PlayerAction,    // 玩家选择行动（攻击/武功/结束）
            PlayerAttack,    // 玩家选择攻击目标
            EnemyTurn,       // 敌方行动（由 EnemyAI 驱动）
            RoundEnd,        // 所有单位行动完毕
            CheckVictory,    // 胜负判定
            PlayerWin,       // 玩家胜利
            PlayerLose,      // 玩家失败
        }

        // ── 当前状态 ──────────────────────────────────────────────────
        public State Current { get; private set; } = State.Idle;
        public int   Round   { get; private set; } = 0;

        // ── 行动队列（按 Speed 排序的单位列表）────────────────────────
        public List<BattleUnit> TurnOrder { get; private set; } = new();
        private int _turnIndex = 0;
        public BattleUnit ActiveUnit => _turnIndex < TurnOrder.Count ? TurnOrder[_turnIndex] : null;

        // ── 玩家选择缓存 ───────────────────────────────────────────────
        public BattleUnit SelectedUnit { get; private set; }

        // ── 事件 ──────────────────────────────────────────────────────
        public event System.Action<State, State>    OnStateChanged;   // (from, to)
        public event System.Action<BattleUnit>      OnUnitTurnBegin;
        public event System.Action<int>             OnRoundStart;     // round number
        public event System.Action<bool>            OnBattleEnd;      // true=玩家胜

        // ── 状态机入口 ─────────────────────────────────────────────────
        public void StartBattle(List<BattleUnit> allUnits)
        {
            BuildTurnOrder(allUnits);
            Round = 0;
            Transition(State.RoundStart);
        }

        // ── 状态转移 ───────────────────────────────────────────────────
        public void Transition(State next)
        {
            var prev = Current;
            Current = next;
            OnStateChanged?.Invoke(prev, next);
            EnterState(next);
        }

        private void EnterState(State s)
        {
            switch (s)
            {
                case State.RoundStart:
                    Round++;
                    _turnIndex = 0;
                    OnRoundStart?.Invoke(Round);
                    AdvanceToNextUnit();
                    break;

                case State.PlayerSelect:
                    // BattleManager 负责处理输入
                    break;

                case State.EnemyTurn:
                    // BattleManager 触发 EnemyAI
                    break;

                case State.RoundEnd:
                    RefreshTurnOrder();
                    Transition(State.RoundStart);
                    break;

                case State.CheckVictory:
                    // 由 BattleManager 判断
                    break;
            }
        }

        // ── 行动顺序 ───────────────────────────────────────────────────
        private void BuildTurnOrder(List<BattleUnit> units)
        {
            TurnOrder = units
                .Where(u => u.IsAlive)
                .OrderByDescending(u => u.Stats.Speed)
                .ToList();
        }

        private void RefreshTurnOrder()
        {
            TurnOrder = TurnOrder.Where(u => u.IsAlive).ToList();
        }

        public void AdvanceToNextUnit()
        {
            // 找到下一个还没结束回合的单位
            while (_turnIndex < TurnOrder.Count && TurnOrder[_turnIndex].TurnDone)
                _turnIndex++;

            if (_turnIndex >= TurnOrder.Count)
            {
                Transition(State.RoundEnd);
                return;
            }

            var unit = TurnOrder[_turnIndex];
            unit.BeginTurn();
            OnUnitTurnBegin?.Invoke(unit);

            if (unit.Faction == CharacterFaction.Enemy)
                Transition(State.EnemyTurn);
            else
                Transition(State.PlayerSelect);
        }

        // ── 玩家操作接口 ───────────────────────────────────────────────

        /// <summary>玩家点击己方单位 → 选中。</summary>
        public bool TrySelectUnit(BattleUnit unit)
        {
            if (Current != State.PlayerSelect) return false;
            if (unit == null || !unit.IsAlive) return false;
            if (unit.Faction == CharacterFaction.Enemy) return false;
            if (unit != ActiveUnit) return false;

            SelectedUnit = unit;
            Transition(State.PlayerMove);
            return true;
        }

        /// <summary>玩家选择移动目标。</summary>
        public void ConfirmMove(HexCell target)
        {
            if (Current != State.PlayerMove) return;
            Transition(State.PlayerAction);
        }

        /// <summary>玩家选择攻击。</summary>
        public void ChooseAttack()
        {
            if (Current != State.PlayerAction) return;
            Transition(State.PlayerAttack);
        }

        /// <summary>玩家确认攻击目标。</summary>
        public void ConfirmAttack(BattleUnit target)
        {
            if (Current != State.PlayerAttack) return;
            SelectedUnit?.SetActed();
            Transition(State.CheckVictory);
        }

        /// <summary>玩家结束当前单位回合。</summary>
        public void EndUnitTurn()
        {
            if (Current != State.PlayerAction && Current != State.PlayerMove) return;
            ActiveUnit?.EndTurn();
            _turnIndex++;
            Transition(State.CheckVictory);
        }

        // ── 敌方行动完成回调 ──────────────────────────────────────────
        public void OnEnemyActionDone()
        {
            if (Current != State.EnemyTurn) return;
            ActiveUnit?.EndTurn();
            _turnIndex++;
            Transition(State.CheckVictory);
        }

        // ── 胜负判定结果通知 ──────────────────────────────────────────
        public void NotifyVictory(bool playerWin)
        {
            OnBattleEnd?.Invoke(playerWin);
            Transition(playerWin ? State.PlayerWin : State.PlayerLose);
        }
    }
}
