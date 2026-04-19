using System;
using System.IO;
using UnityEngine;
using Jianghu.Player;
using Jianghu.World;

namespace Jianghu.Save
{
    /// <summary>
    /// 极简 JSON 存档：F5 保存，F9 读档。
    /// 存档位置：<c>Application.persistentDataPath/save.json</c>。
    /// </summary>
    public class SaveSystem : MonoBehaviour
    {
        [SerializeField] private PlayerStats player;
        [SerializeField] private Transform playerTransform;

        [Serializable]
        public struct SaveData
        {
            public string version;
            public long savedAtUnix;
            public Vector3 playerPos;
            public Vector3 playerEuler;
            public int hp;
            public int mp;
            public int level;
            public int exp;
            public float hour;
        }

        private string SavePath => Path.Combine(Application.persistentDataPath, "save.json");

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.F5)) Save();
            if (Input.GetKeyDown(KeyCode.F9)) Load();
        }

        public void Save()
        {
            if (player == null || playerTransform == null) return;

            var data = new SaveData
            {
                version = "v0.1",
                savedAtUnix = DateTimeOffset.UtcNow.ToUnixTimeSeconds(),
                playerPos = playerTransform.position,
                playerEuler = playerTransform.eulerAngles,
                hp = player.Hp,
                mp = player.Mp,
                level = player.level,
                exp = player.exp,
                hour = WorldManager.Instance != null && WorldManager.Instance.TimeOfDay != null
                    ? WorldManager.Instance.TimeOfDay.CurrentHour
                    : 8f,
            };
            string json = JsonUtility.ToJson(data, true);
            File.WriteAllText(SavePath, json);
            Debug.Log($"[Save] Written → {SavePath}");
        }

        public void Load()
        {
            if (!File.Exists(SavePath))
            {
                Debug.LogWarning($"[Save] 未找到存档：{SavePath}");
                return;
            }

            string json = File.ReadAllText(SavePath);
            var data = JsonUtility.FromJson<SaveData>(json);

            if (playerTransform != null)
            {
                var cc = playerTransform.GetComponent<CharacterController>();
                if (cc != null) cc.enabled = false;
                playerTransform.position = data.playerPos;
                playerTransform.eulerAngles = data.playerEuler;
                if (cc != null) cc.enabled = true;
            }

            if (player != null)
            {
                player.LoadFromSave(data.hp, data.mp, data.level, data.exp);
            }

            if (WorldManager.Instance != null && WorldManager.Instance.TimeOfDay != null)
            {
                WorldManager.Instance.TimeOfDay.SetHour(data.hour);
            }

            Debug.Log("[Save] Loaded.");
        }

        public void Bind(PlayerStats p, Transform pTransform)
        {
            player = p;
            playerTransform = pTransform;
        }
    }
}
