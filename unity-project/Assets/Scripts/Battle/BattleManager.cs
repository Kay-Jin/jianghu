using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 战斗总控制器：初始化所有系统，接收玩家输入，驱动状态机，协调 UI 与 AI。
    /// 场景中唯一的战斗入口 GameObject 挂此组件。
    /// </summary>
    public class BattleManager : MonoBehaviour
    {
        public static BattleManager Instance { get; private set; }

        // ── Inspector 配置 ─────────────────────────────────────────────
        [Header("Grid")]
        [SerializeField] private HexGrid hexGrid;

        [Header("Battle Setup")]
        [Tooltip("玩家上场配置（最多 6 个 CharacterData）")]
        [SerializeField] private CharacterData[] playerParty;
        [Tooltip("敌方上场配置")]
        [SerializeField] private CharacterData[] enemyParty;
        [Tooltip("玩家方出生格坐标（Axial q,r，顺序对应 playerParty）")]
        [SerializeField] private Vector2Int[] playerSpawns;
        [SerializeField] private Vector2Int[] enemySpawns;
        [Tooltip("玩家/敌方初始等级")]
        [SerializeField] private int playerLevel = 1;
        [SerializeField] private int enemyLevel  = 1;

        [Header("Components")]
        [SerializeField] private BattleUI   battleUI;
        [SerializeField] private EnemyAI    enemyAI;

        // ── 运行时 ─────────────────────────────────────────────────────
        public List<BattleUnit> AllUnits     { get; private set; } = new();
        public List<BattleUnit> PlayerUnits  { get; private set; } = new();
        public List<BattleUnit> EnemyUnits   { get; private set; } = new();

        private BattleStateMachine _fsm;
        private HashSet<HexCell>   _movableRange  = new();
        private HashSet<HexCell>   _attackRange   = new();

        // ── 生命周期 ───────────────────────────────────────────────────
        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
        }

        private void Start()
        {
            if (hexGrid == null) hexGrid = FindFirstObjectByType<HexGrid>();
            if (enemyAI == null) enemyAI = gameObject.AddComponent<EnemyAI>();
            enemyAI.Init(this);

            _fsm = new BattleStateMachine();
            _fsm.OnStateChanged  += HandleStateChange;
            _fsm.OnUnitTurnBegin += HandleUnitTurnBegin;
            _fsm.OnRoundStart    += r => battleUI?.SetRound(r);
            _fsm.OnBattleEnd     += HandleBattleEnd;

            StartCoroutine(InitBattle());
        }

        private IEnumerator InitBattle()
        {
            // 等 HexGrid 生成完毕
            yield return null;

            SpawnUnits(playerParty, playerSpawns, playerLevel, PlayerUnits);
            SpawnUnits(enemyParty,  enemySpawns,  enemyLevel,  EnemyUnits);
            AllUnits.AddRange(PlayerUnits);
            AllUnits.AddRange(EnemyUnits);

            battleUI?.Init(this);
            _fsm.StartBattle(AllUnits);
        }

        // ── 生成单位 ───────────────────────────────────────────────────
        private void SpawnUnits(CharacterData[] party, Vector2Int[] spawns,
            int level, List<BattleUnit> list)
        {
            for (int i = 0; i < party.Length && i < spawns.Length; i++)
            {
                var data  = party[i];
                if (data == null) continue;
                var coord = new HexCoord(spawns[i].x, spawns[i].y);
                var cell  = hexGrid?.Get(coord);
                if (cell == null)
                {
                    Debug.LogWarning($"[BattleManager] 格子 {coord} 不存在，跳过生成 {data.characterName}。");
                    continue;
                }

                GameObject go = data.modelPrefab != null
                    ? Instantiate(data.modelPrefab)
                    : CreatePlaceholder(data);

                var unit = go.GetComponent<BattleUnit>() ?? go.AddComponent<BattleUnit>();
                unit.Init(data, cell, level);
                list.Add(unit);
            }
        }

        private static GameObject CreatePlaceholder(CharacterData data)
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            go.name = data.characterName;
            go.transform.localScale = new Vector3(0.5f, 0.6f, 0.5f);
            return go;
        }

        // ── 状态机回调 ─────────────────────────────────────────────────
        private void HandleStateChange(BattleStateMachine.State from, BattleStateMachine.State to)
        {
            hexGrid?.ClearAllHighlights();
            battleUI?.OnStateChanged(to, _fsm.ActiveUnit);

            if (to == BattleStateMachine.State.EnemyTurn && _fsm.ActiveUnit != null)
                HandleEnemyTurn(_fsm.ActiveUnit);

            if (to == BattleStateMachine.State.CheckVictory)
                CheckVictoryCondition();
        }

        private void HandleUnitTurnBegin(BattleUnit unit)
        {
            battleUI?.SetActiveUnit(unit);
        }

        private void HandleBattleEnd(bool playerWin)
        {
            battleUI?.ShowBattleResult(playerWin);
            Debug.Log($"[Battle] 战斗结束 — {(playerWin ? "玩家胜利！" : "玩家失败…")}");
        }

        // ── 玩家输入（鼠标点击格子）────────────────────────────────────
        private void Update()
        {
            if (_fsm == null) return;

            if (Input.GetMouseButtonDown(0))
                HandleClick();

            if (Input.GetKeyDown(KeyCode.Space))
                _fsm.EndUnitTurn();
        }

        private void HandleClick()
        {
            var ray  = Camera.main?.ScreenPointToRay(Input.mousePosition);
            if (ray == null) return;

            if (!Physics.Raycast(ray.Value, out var hit, 100f)) return;
            var cell = hit.collider.GetComponentInParent<HexCell>()
                    ?? hit.collider.GetComponent<HexCell>();
            if (cell == null) return;

            var state = _fsm.Current;

            if (state == BattleStateMachine.State.PlayerSelect)
            {
                if (cell.Occupant != null && cell.Occupant == _fsm.ActiveUnit)
                {
                    _fsm.TrySelectUnit(cell.Occupant);
                    ShowMoveRange(_fsm.SelectedUnit);
                }
            }
            else if (state == BattleStateMachine.State.PlayerMove)
            {
                if (_movableRange.Contains(cell))
                {
                    StartCoroutine(DoPlayerMove(_fsm.SelectedUnit, cell));
                }
            }
            else if (state == BattleStateMachine.State.PlayerAttack)
            {
                if (cell.Occupant != null && cell.Occupant.Faction == CharacterFaction.Enemy
                    && _attackRange.Contains(cell))
                {
                    StartCoroutine(DoPlayerAttack(_fsm.SelectedUnit, cell.Occupant));
                }
            }
        }

        private void ShowMoveRange(BattleUnit unit)
        {
            _movableRange = hexGrid.GetMovableRange(unit.Cell, unit.Stats.MoveRange, unit);
            hexGrid.HighlightSet(_movableRange, HexCell.HighlightMode.Movable);
        }

        private void ShowAttackRange(BattleUnit unit)
        {
            _attackRange = hexGrid.GetAttackRange(unit.Cell, 1, unit.Data.attackRange);
            hexGrid.HighlightSet(_attackRange, HexCell.HighlightMode.Attackable);
        }

        private IEnumerator DoPlayerMove(BattleUnit unit, HexCell target)
        {
            var path = hexGrid.FindPath(unit.Cell, target, unit);
            if (path == null) { _fsm.EndUnitTurn(); yield break; }
            hexGrid.ClearAllHighlights();
            yield return StartCoroutine(unit.MoveAlongPath(path));
            unit.SetMoved();
            _fsm.ConfirmMove(target);
            ShowAttackRange(unit);
        }

        private IEnumerator DoPlayerAttack(BattleUnit attacker, BattleUnit defender)
        {
            attacker.FaceToward(defender.Cell);
            yield return new WaitForSeconds(0.3f);

            if (DamageCalculator.IsEvaded(attacker, defender))
            {
                Debug.Log($"[Player] {defender.Data.characterName} 闪避！");
                battleUI?.ShowFloatText(defender, "闪！", Color.cyan);
            }
            else
            {
                float encircle = DamageCalculator.CalcEncirclementBonus(defender);
                int   dmg      = Mathf.RoundToInt(
                    DamageCalculator.CalcNormalAttack(attacker, defender) * encircle);
                battleUI?.ShowFloatText(defender, $"-{dmg}", Color.red);
                defender.TakeDamage(dmg);
            }

            attacker.SetActed();
            _fsm.ConfirmAttack(defender);
            CheckVictoryCondition();
        }

        // ── 胜负判定 ───────────────────────────────────────────────────
        public void CheckVictoryCondition()
        {
            if (_fsm.Current == BattleStateMachine.State.PlayerWin ||
                _fsm.Current == BattleStateMachine.State.PlayerLose) return;

            bool allEnemyDead  = EnemyUnits.All(u => !u.IsAlive);
            bool allPlayerDead = PlayerUnits.All(u => !u.IsAlive);

            if (allEnemyDead || allPlayerDead)
            {
                _fsm.NotifyVictory(allEnemyDead);
                return;
            }

            if (_fsm.Current == BattleStateMachine.State.CheckVictory)
                _fsm.AdvanceToNextUnit();
        }

        // ── 敌方 AI 完成回调 ──────────────────────────────────────────
        public void OnEnemyActionComplete()
        {
            CheckVictoryCondition();
            if (_fsm.Current != BattleStateMachine.State.PlayerWin &&
                _fsm.Current != BattleStateMachine.State.PlayerLose)
                _fsm.OnEnemyActionDone();
        }

        // ── EnemyTurn 状态由 Manager 触发 AI ──────────────────────────
        // (在 HandleStateChange 中调用)
        private void HandleEnemyTurn(BattleUnit unit)
        {
            StartCoroutine(enemyAI.ExecuteTurn(unit));
        }

        // ── UI 按钮回调 ─────────────────────────────────────────────────
        public void OnActionMenuAttack() => _fsm.ChooseAttack();
        public void OnActionMenuEndTurn() => _fsm.EndUnitTurn();
    }
}
