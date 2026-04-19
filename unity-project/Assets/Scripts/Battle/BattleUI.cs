using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

namespace Jianghu.Battle
{
    /// <summary>
    /// 战斗 UI：回合数、行动顺序条、选中单位信息、操作菜单（移动/攻击/结束）、战斗结果面板。
    /// 需要在场景 Canvas 下挂此组件，并将各 UI 引用拖入 Inspector。
    /// </summary>
    public class BattleUI : MonoBehaviour
    {
        // ── Inspector 引用 ─────────────────────────────────────────────
        [Header("Round Info")]
        [SerializeField] private TextMeshProUGUI roundText;
        [SerializeField] private TextMeshProUGUI phaseText;

        [Header("Active Unit Panel")]
        [SerializeField] private GameObject     unitPanel;
        [SerializeField] private TextMeshProUGUI unitNameText;
        [SerializeField] private Slider         hpSlider;
        [SerializeField] private TextMeshProUGUI hpText;
        [SerializeField] private Slider         mpSlider;
        [SerializeField] private TextMeshProUGUI mpText;

        [Header("Action Menu")]
        [SerializeField] private GameObject actionMenu;
        [SerializeField] private Button     btnMove;
        [SerializeField] private Button     btnAttack;
        [SerializeField] private Button     btnEndTurn;

        [Header("Turn Order Bar")]
        [SerializeField] private Transform         turnOrderBar;
        [SerializeField] private GameObject        turnIconPrefab; // 小头像/色块

        [Header("Result Panel")]
        [SerializeField] private GameObject     resultPanel;
        [SerializeField] private TextMeshProUGUI resultText;
        [SerializeField] private Button         btnRetry;
        [SerializeField] private Button         btnReturn;

        [Header("Floating Text")]
        [SerializeField] private Canvas floatCanvas;

        // ── 运行时 ─────────────────────────────────────────────────────
        private BattleManager _manager;
        private BattleUnit    _activeUnit;

        // ── 初始化 ─────────────────────────────────────────────────────
        public void Init(BattleManager manager)
        {
            _manager = manager;
            if (resultPanel) resultPanel.SetActive(false);
            if (actionMenu)  actionMenu.SetActive(false);

            btnMove?.onClick.AddListener(() =>
            {
                // 直接进入 PlayerMove 状态，显示移动范围已在 BattleManager 处理
                BattleStateMachine_Select();
            });
        btnAttack?.onClick.AddListener(() =>
        {
            // BattleManager 持有 FSM，通过事件驱动
            BattleManager.Instance?.OnActionMenuAttack();
        });
        btnEndTurn?.onClick.AddListener(() =>
        {
            BattleManager.Instance?.OnActionMenuEndTurn();
        });
        }

        // 兼容调用（BattleStateMachine 无静态 Instance 时改用事件驱动）
        private void BattleStateMachine_Select() { /* BattleManager.Update 处理输入 */ }

        // ── 外部调用 ───────────────────────────────────────────────────
        public void SetRound(int round)
        {
            if (roundText) roundText.text = $"第 {round} 回合";
        }

        public void SetActiveUnit(BattleUnit unit)
        {
            _activeUnit = unit;
            if (unit == null) { if (unitPanel) unitPanel.SetActive(false); return; }
            if (unitPanel) unitPanel.SetActive(true);
            RefreshUnitPanel(unit);
        }

        private void RefreshUnitPanel(BattleUnit unit)
        {
            if (unitNameText) unitNameText.text = unit.Data.characterName;
            if (hpSlider)
            {
                hpSlider.maxValue = unit.Stats.MaxHp;
                hpSlider.value    = unit.Stats.Hp;
            }
            if (hpText) hpText.text = $"{unit.Stats.Hp}/{unit.Stats.MaxHp}";
            if (mpSlider)
            {
                mpSlider.maxValue = unit.Stats.MaxMp;
                mpSlider.value    = unit.Stats.Mp;
            }
            if (mpText) mpText.text = $"{unit.Stats.Mp}/{unit.Stats.MaxMp}";
        }

        public void OnStateChanged(BattleStateMachine.State state, BattleUnit active)
        {
            bool showMenu = state == BattleStateMachine.State.PlayerAction &&
                            active?.Faction != CharacterFaction.Enemy;
            if (actionMenu) actionMenu.SetActive(showMenu);

            if (phaseText)
            {
                phaseText.text = state switch
                {
                    BattleStateMachine.State.PlayerSelect => "选择单位",
                    BattleStateMachine.State.PlayerMove   => "选择移动目标",
                    BattleStateMachine.State.PlayerAction => "选择行动",
                    BattleStateMachine.State.PlayerAttack => "选择攻击目标",
                    BattleStateMachine.State.EnemyTurn    => "敌方行动中…",
                    BattleStateMachine.State.RoundStart   => "回合开始",
                    _                                     => ""
                };
            }

            if (btnMove && active != null)
                btnMove.interactable = !active.HasMoved;
            if (btnAttack && active != null)
                btnAttack.interactable = !active.HasActed;

            if (active != null) RefreshUnitPanel(active);
        }

        public void ShowBattleResult(bool playerWin)
        {
            if (resultPanel) resultPanel.SetActive(true);
            if (actionMenu)  actionMenu.SetActive(false);
            if (resultText)
            {
                resultText.text  = playerWin ? "胜利！" : "败北…";
                resultText.color = playerWin ? Color.yellow : Color.red;
            }
            btnRetry?.onClick.AddListener(() => UnityEngine.SceneManagement.SceneManager.LoadScene(
                UnityEngine.SceneManagement.SceneManager.GetActiveScene().name));
            btnReturn?.onClick.AddListener(() => UnityEngine.SceneManagement.SceneManager.LoadScene("MainMenu"));
        }

        // ── 行动顺序条 ─────────────────────────────────────────────────
        public void RefreshTurnOrder(List<BattleUnit> order)
        {
            if (turnOrderBar == null) return;
            foreach (Transform child in turnOrderBar) Destroy(child.gameObject);
            foreach (var unit in order)
            {
                if (!unit.IsAlive) continue;
                GameObject icon;
                if (turnIconPrefab != null)
                {
                    icon = Instantiate(turnIconPrefab, turnOrderBar);
                }
                else
                {
                    icon = new GameObject($"icon_{unit.Data.characterName}");
                    icon.transform.SetParent(turnOrderBar, false);
                    var img = icon.AddComponent<Image>();
                    img.color = unit.Faction == CharacterFaction.Enemy ? Color.red : Color.cyan;
                    var rect = icon.GetComponent<RectTransform>();
                    rect.sizeDelta = new Vector2(40, 40);
                }
                var label = icon.GetComponentInChildren<TextMeshProUGUI>();
                if (label) label.text = unit.Data.characterName.Substring(0, 1);
            }
        }

        // ── 浮动伤害文字 ───────────────────────────────────────────────
        public void ShowFloatText(BattleUnit target, string msg, Color color)
        {
            if (floatCanvas == null) { Debug.Log($"[Float] {target.Data.characterName} {msg}"); return; }
            StartCoroutine(FloatTextCoroutine(target, msg, color));
        }

        private IEnumerator FloatTextCoroutine(BattleUnit target, string msg, Color color)
        {
            var go  = new GameObject("FloatTxt");
            go.transform.SetParent(floatCanvas.transform, false);
            var tmp = go.AddComponent<TextMeshProUGUI>();
            tmp.text      = msg;
            tmp.color     = color;
            tmp.fontSize  = 28;
            tmp.alignment = TextAlignmentOptions.Center;

            var rt = go.GetComponent<RectTransform>();
            Vector3 screenPos = Camera.main.WorldToScreenPoint(
                target.transform.position + Vector3.up * 1.5f);
            rt.position  = screenPos;
            rt.sizeDelta = new Vector2(120, 60);

            float elapsed = 0f;
            float duration = 1.2f;
            Vector3 startPos = rt.position;
            while (elapsed < duration)
            {
                elapsed += Time.deltaTime;
                float t = elapsed / duration;
                rt.position = startPos + Vector3.up * (50f * t);
                tmp.color   = new Color(color.r, color.g, color.b, 1f - t);
                yield return null;
            }
            Destroy(go);
        }

        // ── Update：每帧刷新当前单位面板（HP可能变化）─────────────────
        private void Update()
        {
            if (_activeUnit != null && unitPanel != null && unitPanel.activeSelf)
                RefreshUnitPanel(_activeUnit);
        }
    }
}
