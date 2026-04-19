using UnityEngine;
using Jianghu.Player;
using Jianghu.Combat;
using Jianghu.NPC;
using Jianghu.World;
using Jianghu.Save;
using Jianghu.UI;

namespace Jianghu.Bootstrap
{
    /// <summary>
    /// 一键自举：在空场景里挂到一个空 GameObject 上，Play 即可看到：
    ///   - 地面 Plane、天空 / 方向光 / 环境光
    ///   - 主角胶囊（PlayerController + PlayerStats + CombatSystem + Dialogue）
    ///   - 第三人称相机（ThirdPersonCamera）
    ///   - 3 个颜色各异的 NPC 胶囊
    ///   - HUD / WorldManager / SaveSystem / MartialArtDatabase + 示例武功
    /// </summary>
    public class SceneBootstrap : MonoBehaviour
    {
        [Header("世界")]
        [SerializeField] private Vector2 groundSize = new Vector2(80f, 80f);
        [SerializeField] private int npcCount = 3;
        [SerializeField] private float npcSpawnRadius = 8f;

        private void Start()
        {
            BuildWorld();
            GameObject player = BuildPlayer();
            BuildCamera(player.transform);
            BuildNpcs();
            BuildHud(player);
            BuildSaveSystem(player);
            Debug.Log("[Bootstrap] 江湖打工人原型已启动。WASD 移动，鼠标看向，左键普攻，1/2/3 武功，E 对话，F5/F9 存读档。");
        }

        // -----------------------------------------------------------------
        private void BuildWorld()
        {
            // 地面
            GameObject ground = GameObject.CreatePrimitive(PrimitiveType.Plane);
            ground.name = "Ground";
            ground.transform.localScale = new Vector3(groundSize.x / 10f, 1f, groundSize.y / 10f);
            var groundRenderer = ground.GetComponent<Renderer>();
            groundRenderer.material.color = new Color(0.35f, 0.45f, 0.30f);

            // 几块装饰石头
            for (int i = 0; i < 10; i++)
            {
                GameObject rock = GameObject.CreatePrimitive(PrimitiveType.Cube);
                rock.name = $"Rock_{i}";
                rock.transform.position = new Vector3(Random.Range(-groundSize.x * 0.4f, groundSize.x * 0.4f),
                    0.5f, Random.Range(-groundSize.y * 0.4f, groundSize.y * 0.4f));
                rock.transform.localScale = new Vector3(Random.Range(0.8f, 2.2f), 1f, Random.Range(0.8f, 2.2f));
                rock.GetComponent<Renderer>().material.color = new Color(0.5f, 0.5f, 0.52f);
            }

            // 方向光
            GameObject sunGO = new GameObject("Sun");
            Light sun = sunGO.AddComponent<Light>();
            sun.type = LightType.Directional;
            sun.intensity = 1.1f;
            sun.shadows = LightShadows.Soft;
            sun.transform.rotation = Quaternion.Euler(40f, 170f, 0f);

            // TimeOfDay + WorldManager
            GameObject world = new GameObject("WorldManager");
            var tod = world.AddComponent<TimeOfDay>();
            tod.SetSun(sun);
            var wm = world.AddComponent<WorldManager>();
            wm.SetTimeOfDay(tod);
        }

        // -----------------------------------------------------------------
        private GameObject BuildPlayer()
        {
            GameObject player = new GameObject("Player");
            player.transform.position = new Vector3(0f, 1f, 0f);

            // 视觉
            GameObject body = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            body.name = "Body";
            body.transform.SetParent(player.transform, false);
            Destroy(body.GetComponent<Collider>());
            body.GetComponent<Renderer>().material.color = new Color(0.85f, 0.78f, 0.3f);

            // 控制器
            var cc = player.AddComponent<CharacterController>();
            cc.height = 1.9f;
            cc.radius = 0.35f;
            cc.center = new Vector3(0f, 0.95f, 0f);
            cc.stepOffset = 0.35f;

            // 逻辑组件
            var damageable = player.AddComponent<Damageable>();
            damageable.maxHp = 100;
            damageable.faction = Faction.Player;
            player.AddComponent<PlayerStats>();
            player.AddComponent<PlayerController>();
            player.AddComponent<CombatSystem>();
            player.AddComponent<Dialogue>();

            return player;
        }

        private void BuildCamera(Transform target)
        {
            GameObject camGO;
            if (Camera.main != null)
            {
                camGO = Camera.main.gameObject;
            }
            else
            {
                camGO = new GameObject("Main Camera");
                camGO.tag = "MainCamera";
                camGO.AddComponent<Camera>();
                camGO.AddComponent<AudioListener>();
            }
            var tpc = camGO.GetComponent<ThirdPersonCamera>();
            if (tpc == null) tpc = camGO.AddComponent<ThirdPersonCamera>();
            tpc.SetTarget(target);
        }

        // -----------------------------------------------------------------
        private void BuildNpcs()
        {
            Color[] palette = { new Color(0.3f, 0.55f, 0.8f), new Color(0.8f, 0.3f, 0.3f), new Color(0.3f, 0.75f, 0.4f) };
            string[] names = { "镇口老汉", "卖酒阿婆", "游方郎中" };
            string[][] lines =
            {
                new[]
                {
                    "客官面生啊，是外乡来的江湖人？",
                    "这镇子最近不太平，山里的狼出来了。",
                    "向西走便是县城。",
                },
                new[]
                {
                    "来壶梨花白？只要三文钱。",
                    "江湖人过得也苦，我这酒却最解乏。",
                },
                new[]
                {
                    "阿弥陀佛……咦？这位施主的气色尚可。",
                    "行走江湖，总要带着金创药。",
                },
            };

            for (int i = 0; i < npcCount; i++)
            {
                float ang = i / (float)npcCount * Mathf.PI * 2f;
                Vector3 pos = new Vector3(Mathf.Cos(ang) * npcSpawnRadius, 1f, Mathf.Sin(ang) * npcSpawnRadius);

                GameObject npc = GameObject.CreatePrimitive(PrimitiveType.Capsule);
                npc.name = $"NPC_{names[i % names.Length]}";
                npc.transform.position = pos;
                var col = npc.GetComponent<Collider>(); // keep collider for hit detection
                col.isTrigger = false;
                npc.GetComponent<Renderer>().material.color = palette[i % palette.Length];

                var dmg = npc.AddComponent<Damageable>();
                dmg.maxHp = 50;
                dmg.faction = Faction.Friendly;

                var ctrl = npc.AddComponent<NPCController>();
                ctrl.npcName = names[i % names.Length];
                ctrl.dialogueLines = lines[i % lines.Length];
            }
        }

        // -----------------------------------------------------------------
        private void BuildHud(GameObject player)
        {
            GameObject hudGO = new GameObject("HUD");
            var hud = hudGO.AddComponent<HUD>();
            hud.Bind(player.GetComponent<PlayerStats>());

            // 创建一个武功库，并注入两个示例武功（ScriptableObject.CreateInstance）
            GameObject maGO = new GameObject("MartialArtDatabase");
            var db = maGO.AddComponent<MartialArtDatabase>();

            var palm = ScriptableObject.CreateInstance<MartialArt>();
            palm.displayName = "降龙十八掌·亢龙有悔";
            palm.description = "一击正面大范围伤害，消耗内力。";
            palm.mpCost = 12; palm.staminaCost = 15f; palm.cooldown = 1.2f;
            palm.reach = 2.4f; palm.hitBoxHalfExtents = new Vector3(1.4f, 1.1f, 1.4f);
            palm.damage = 28; palm.hitStopDuration = 0.08f; palm.camImpulseStrength = 0.5f;
            db.Register(palm);

            var sword = ScriptableObject.CreateInstance<MartialArt>();
            sword.displayName = "太极剑·揽雀尾";
            sword.description = "轻灵一式，快速出招，伤害较低。";
            sword.mpCost = 4; sword.staminaCost = 8f; sword.cooldown = 0.6f;
            sword.reach = 2.0f; sword.hitBoxHalfExtents = new Vector3(1.0f, 1.0f, 1.0f);
            sword.damage = 14; sword.hitStopDuration = 0.04f; sword.camImpulseStrength = 0.25f;
            db.Register(sword);

            var finger = ScriptableObject.CreateInstance<MartialArt>();
            finger.displayName = "一阳指";
            finger.description = "聚气于指，单点高伤。";
            finger.mpCost = 18; finger.staminaCost = 10f; finger.cooldown = 1.5f;
            finger.reach = 3.2f; finger.hitBoxHalfExtents = new Vector3(0.5f, 0.6f, 0.5f);
            finger.damage = 40; finger.hitStopDuration = 0.1f; finger.camImpulseStrength = 0.6f;
            db.Register(finger);
        }

        private void BuildSaveSystem(GameObject player)
        {
            GameObject saveGO = new GameObject("SaveSystem");
            var save = saveGO.AddComponent<SaveSystem>();
            save.Bind(player.GetComponent<PlayerStats>(), player.transform);
        }
    }
}
