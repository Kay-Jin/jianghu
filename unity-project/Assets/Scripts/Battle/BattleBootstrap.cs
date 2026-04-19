using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Jianghu.Battle
{
    /// <summary>
    /// 战斗场景自举脚本：无需手动配置 Inspector 即可快速启动一场 6v6 测试战斗。
    /// 在空场景中建一个 GameObject 挂此脚本，Play 即可运行。
    /// </summary>
    public class BattleBootstrap : MonoBehaviour
    {
        [Header("Quick Test (无 Prefab 时全部程序化生成)")]
        [Tooltip("网格宽度")]  [SerializeField] private int gridWidth  = 12;
        [Tooltip("网格高度")]  [SerializeField] private int gridHeight = 10;
        [Tooltip("六边形尺寸")][SerializeField] private float hexSize  = 1.1f;

        private void Awake()
        {
            Application.targetFrameRate = 60;
            // 只在专用 Battle 场景里自举；如果 BattleManager 已存在则跳过
            if (FindFirstObjectByType<BattleManager>() != null) return;
            BuildScene();
        }

        private void BuildScene()
        {
            // ── 1. 相机 ────────────────────────────────────────────────
            var camGo = new GameObject("BattleCamera");
            var cam   = camGo.AddComponent<Camera>();
            cam.clearFlags        = CameraClearFlags.SolidColor;
            cam.backgroundColor   = new Color(0.08f, 0.08f, 0.12f);
            cam.fieldOfView       = 60f;
            camGo.transform.position = new Vector3(6f, 14f, -6f);
            camGo.transform.eulerAngles = new Vector3(55f, 0f, 0f);
            cam.tag = "MainCamera";

            // ── 2. 方向光 ──────────────────────────────────────────────
            var lightGo = new GameObject("DirectionalLight");
            var light   = lightGo.AddComponent<Light>();
            light.type      = LightType.Directional;
            light.intensity = 1.2f;
            lightGo.transform.eulerAngles = new Vector3(50f, -30f, 0f);

            // ── 3. HexGrid ─────────────────────────────────────────────
            var gridGo = new GameObject("HexGrid");
            var grid   = gridGo.AddComponent<HexGrid>();
            // 通过反射（或改为 internal setter）注入参数，或直接在 Awake 后手动调用
            SetField(grid, "width",   gridWidth);
            SetField(grid, "height",  gridHeight);
            SetField(grid, "hexSize", hexSize);

            // 设置一些地形变化（让地图看起来有内容）
            var terrains = BuildTerrainMap(gridWidth, gridHeight);
            SetField(grid, "terrainOverride", terrains);

            // ── 4. 生成 CharacterData（测试用）─────────────────────────
            var playerData = CreateTestParty();
            var enemyData  = CreateTestEnemies();

            // ── 5. 出生坐标 ────────────────────────────────────────────
            var playerSpawns = new[]
            {
                new Vector2Int(0, 0), new Vector2Int(1, 0), new Vector2Int(2, 0),
                new Vector2Int(0, 1), new Vector2Int(1, 1), new Vector2Int(2, 1),
            };
            var enemySpawns = new[]
            {
                new Vector2Int(8, 7), new Vector2Int(9, 7), new Vector2Int(10,7),
                new Vector2Int(8, 8), new Vector2Int(9, 8), new Vector2Int(10,8),
            };

            // ── 6. BattleManager ──────────────────────────────────────
            var mgrGo = new GameObject("BattleManager");
            var mgr   = mgrGo.AddComponent<BattleManager>();
            SetField(mgr, "hexGrid",      grid);
            SetField(mgr, "playerParty",  playerData);
            SetField(mgr, "enemyParty",   enemyData);
            SetField(mgr, "playerSpawns", playerSpawns);
            SetField(mgr, "enemySpawns",  enemySpawns);
            SetField(mgr, "playerLevel",  1);
            SetField(mgr, "enemyLevel",   1);

            // ── 7. UI（最简版，无 Prefab）──────────────────────────────
            BuildMinimalUI(mgr);

            Debug.Log("[BattleBootstrap] 场景构建完成。按鼠标左键选择/移动/攻击，Space=结束回合。");
        }

        // ── 测试角色数据 ───────────────────────────────────────────────
        private CharacterData[] CreateTestParty()
        {
            var configs = new (string name, int gg, int nl, int wx, int sf, int tp)[]
            {
                ("沈墨（主角）", 6, 8,12, 6, 8),  // 项目经理
                ("苏晚晴",       8,10, 9, 9, 8),
                ("白玉京",      10, 9, 7, 8,10),
                ("云裳",         7, 8,10,12, 7),
                ("铁无双",      12, 7, 6, 8,14),
                ("明月楼",       8,12, 9, 7, 8),
            };
            return BuildDataArray(configs, CharacterFaction.Player);
        }

        private CharacterData[] CreateTestEnemies()
        {
            var configs = new (string name, int gg, int nl, int wx, int sf, int tp)[]
            {
                ("黑衣刺客甲",   8, 7, 7, 9, 8),
                ("黑衣刺客乙",   8, 7, 7, 9, 8),
                ("黑衣刺客丙",   9, 6, 6, 8,10),
                ("黑衣副队长",  10, 9, 8, 8,11),
                ("黑衣弓手",     6, 8, 8,11, 6),
                ("黑衣队长",    12,10, 9, 9,13),
            };
            return BuildDataArray(configs, CharacterFaction.Enemy);
        }

        private CharacterData[] BuildDataArray(
            (string name, int gg, int nl, int wx, int sf, int tp)[] configs,
            CharacterFaction faction)
        {
            var result = new CharacterData[configs.Length];
            for (int i = 0; i < configs.Length; i++)
            {
                var d = ScriptableObject.CreateInstance<CharacterData>();
                var c = configs[i];
                d.characterName = c.name;
                d.faction       = faction;
                d.genGu   = c.gg;
                d.neiLi   = c.nl;
                d.wuXing  = c.wx;
                d.shenFa  = c.sf;
                d.tiPo    = c.tp;
                d.baseAttack  = 15 + c.gg / 2;
                d.attackRange = 1;
                result[i] = d;
            }
            return result;
        }

        // ── 地形地图 ───────────────────────────────────────────────────
        private TerrainType[] BuildTerrainMap(int w, int h)
        {
            int total = w * h;
            var map   = new TerrainType[total];
            var rng   = new System.Random(42);
            for (int i = 0; i < total; i++)
            {
                int roll = rng.Next(100);
                map[i] = roll switch
                {
                    < 70 => TerrainType.Plain,
                    < 80 => TerrainType.Forest,
                    < 87 => TerrainType.Hill,
                    < 90 => TerrainType.Road,
                    < 93 => TerrainType.Building,
                    < 96 => TerrainType.Water,
                    _    => TerrainType.Plain,
                };
            }
            return map;
        }

        // ── 最简 UI（无 Prefab）────────────────────────────────────────
        private void BuildMinimalUI(BattleManager mgr)
        {
            var canvasGo = new GameObject("Canvas");
            var canvas   = canvasGo.AddComponent<Canvas>();
            canvas.renderMode = RenderMode.ScreenSpaceOverlay;
            canvasGo.AddComponent<UnityEngine.UI.CanvasScaler>();
            canvasGo.AddComponent<UnityEngine.UI.GraphicRaycaster>();

            // 提示文字
            var hint = CreateLabel(canvasGo.transform, "点击己方单位选择 → 蓝格=移动 → PlayerAction=选择攻击/结束 | Space=结束回合",
                new Vector2(0, -20), new Vector2(800, 40));
            hint.GetComponent<TMPro.TextMeshProUGUI>().fontSize = 14;

            var ui = canvasGo.AddComponent<BattleUI>();
            SetField(ui, "roundText", CreateLabel(canvasGo.transform, "第1回合", new Vector2(-350, 270), new Vector2(200, 40))
                .GetComponent<TMPro.TextMeshProUGUI>());
            SetField(ui, "phaseText", CreateLabel(canvasGo.transform, "", new Vector2(-350, 230), new Vector2(200, 40))
                .GetComponent<TMPro.TextMeshProUGUI>());
            SetField(mgr, "battleUI", ui);
        }

        private GameObject CreateLabel(Transform parent, string text, Vector2 anchoredPos, Vector2 size)
        {
            var go  = new GameObject("Label");
            go.transform.SetParent(parent, false);
            var tmp = go.AddComponent<TMPro.TextMeshProUGUI>();
            tmp.text      = text;
            tmp.fontSize  = 18;
            tmp.color     = Color.white;
            tmp.alignment = TMPro.TextAlignmentOptions.Center;
            var rt = go.GetComponent<RectTransform>();
            rt.anchoredPosition = anchoredPos;
            rt.sizeDelta        = size;
            return go;
        }

        // ── SerializedField 注入（绕过访问修饰符，仅限 Editor/测试）───
        private static void SetField(object obj, string fieldName, object value)
        {
            var field = obj.GetType().GetField(fieldName,
                System.Reflection.BindingFlags.NonPublic |
                System.Reflection.BindingFlags.Public    |
                System.Reflection.BindingFlags.Instance);
            if (field != null) field.SetValue(obj, value);
            else Debug.LogWarning($"[Bootstrap] 字段 '{fieldName}' 在 {obj.GetType().Name} 中未找到。");
        }
    }
}
