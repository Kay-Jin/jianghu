using System.Collections.Generic;
using UnityEngine;

namespace Jianghu.Combat
{
    /// <summary>
    /// 运行时武功库，给 UI / 存档使用。
    /// 场景中放一个挂这个组件的 GameObject 即可；可在 Inspector 拖入 ScriptableObject。
    /// </summary>
    public class MartialArtDatabase : MonoBehaviour
    {
        public static MartialArtDatabase Instance { get; private set; }

        [SerializeField] private List<MartialArt> arts = new List<MartialArt>();

        private void Awake()
        {
            if (Instance != null && Instance != this)
            {
                Destroy(gameObject);
                return;
            }
            Instance = this;
        }

        public void Register(MartialArt ma)
        {
            if (ma != null && !arts.Contains(ma))
            {
                arts.Add(ma);
            }
        }

        public MartialArt Get(int index) =>
            index >= 0 && index < arts.Count ? arts[index] : null;

        public IReadOnlyList<MartialArt> All => arts;
    }
}
