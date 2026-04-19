using UnityEngine;
using Jianghu.Player;

namespace Jianghu.UI
{
    /// <summary>
    /// 占位 HUD：用 IMGUI (<see cref="OnGUI"/>) 画血条/内力条 + 对话框 + 操作提示。
    /// 后续用 uGUI / UIToolkit 替换即可，不影响别的模块。
    /// </summary>
    public class HUD : MonoBehaviour
    {
        private static HUD _instance;

        [SerializeField] private PlayerStats stats;

        private static string _dialogueSpeaker;
        private static string _dialogueLine;
        private static bool _dialogueVisible;

        private GUIStyle _barBg;
        private GUIStyle _barFg;
        private GUIStyle _labelShadow;
        private GUIStyle _labelBox;

        public static HUD Instance => _instance;

        public static void ShowDialogue(string speaker, string line)
        {
            _dialogueSpeaker = speaker;
            _dialogueLine = line;
            _dialogueVisible = true;
        }

        public static void HideDialogue()
        {
            _dialogueVisible = false;
        }

        public void Bind(PlayerStats s) => stats = s;

        private void Awake()
        {
            _instance = this;
        }

        private void EnsureStyles()
        {
            if (_barBg != null) return;
            _barBg = new GUIStyle(GUI.skin.box);
            _barFg = new GUIStyle(GUI.skin.box);
            _labelShadow = new GUIStyle(GUI.skin.label) { fontSize = 14 };
            _labelShadow.normal.textColor = Color.white;
            _labelBox = new GUIStyle(GUI.skin.box) { fontSize = 15, alignment = TextAnchor.MiddleLeft, wordWrap = true };
            _labelBox.normal.textColor = Color.white;
        }

        private void OnGUI()
        {
            EnsureStyles();

            // 操作提示
            GUI.Label(new Rect(12, 8, 620, 22),
                "WASD 移动  |  Shift 跑  |  Space 跳  |  鼠标看向  |  左键普攻  |  1/2/3 武功  |  E 对话  |  F5 保存 / F9 读档",
                _labelShadow);

            if (stats != null)
            {
                DrawBar(new Rect(12, 36, 220, 14), (float)stats.Hp / Mathf.Max(1, stats.maxHp),
                    $"血 {stats.Hp}/{stats.maxHp}", new Color(0.8f, 0.15f, 0.15f));
                DrawBar(new Rect(12, 54, 220, 12), (float)stats.Mp / Mathf.Max(1, stats.maxMp),
                    $"内 {stats.Mp}/{stats.maxMp}", new Color(0.2f, 0.45f, 0.9f));
                DrawBar(new Rect(12, 70, 220, 10), stats.Stamina / Mathf.Max(1, stats.maxStamina),
                    $"体 {(int)stats.Stamina}/{stats.maxStamina}", new Color(0.85f, 0.75f, 0.25f));
            }

            if (_dialogueVisible)
            {
                float w = Mathf.Min(Screen.width - 40, 900);
                float h = 110;
                Rect box = new Rect((Screen.width - w) * 0.5f, Screen.height - h - 24, w, h);
                GUI.Box(box, "");
                GUI.Label(new Rect(box.x + 16, box.y + 10, w - 32, 22),
                    $"【{_dialogueSpeaker}】", _labelShadow);
                GUI.Label(new Rect(box.x + 16, box.y + 34, w - 32, h - 40),
                    _dialogueLine + "\n\n(按 E 继续)", _labelBox);
            }
        }

        private void DrawBar(Rect rect, float fill, string label, Color color)
        {
            GUI.color = new Color(0f, 0f, 0f, 0.5f);
            GUI.Box(rect, "");
            GUI.color = color;
            GUI.Box(new Rect(rect.x, rect.y, rect.width * Mathf.Clamp01(fill), rect.height), "");
            GUI.color = Color.white;
            GUI.Label(new Rect(rect.x + 6, rect.y - 2, rect.width, rect.height + 4), label, _labelShadow);
        }
    }
}
