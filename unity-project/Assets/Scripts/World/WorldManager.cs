using UnityEngine;

namespace Jianghu.World
{
    /// <summary>
    /// 世界总管：现在只做很小的事（持有 TimeOfDay 引用 + 场景全局状态）。
    /// 后续接管场景加载、天气、区域派生事件等。
    /// </summary>
    public class WorldManager : MonoBehaviour
    {
        public static WorldManager Instance { get; private set; }

        [SerializeField] private TimeOfDay timeOfDay;

        public TimeOfDay TimeOfDay => timeOfDay;

        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
        }

        public void SetTimeOfDay(TimeOfDay tod) => timeOfDay = tod;
    }
}
