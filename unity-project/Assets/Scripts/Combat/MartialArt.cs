using UnityEngine;

namespace Jianghu.Combat
{
    /// <summary>
    /// 武功定义（ScriptableObject）。
    /// 可在编辑器右键 Create → Jianghu → MartialArt 创建。
    /// 数值/效果由数据驱动，配合 <see cref="CombatSystem"/> 触发。
    /// </summary>
    [CreateAssetMenu(menuName = "Jianghu/MartialArt", fileName = "MA_")]
    public class MartialArt : ScriptableObject
    {
        [Header("基本信息")]
        public string displayName = "基础刀法";
        [TextArea] public string description = "招式朴素，练到极致亦是宗师。";

        [Header("资源消耗")]
        public int mpCost = 5;
        public float staminaCost = 10f;
        public float cooldown = 0.8f;

        [Header("判定")]
        [Tooltip("从角色身前的起点到攻击面中心的距离")]
        public float reach = 2.2f;

        [Tooltip("攻击盒体的半径 (x=宽，y=高，z=深)")]
        public Vector3 hitBoxHalfExtents = new Vector3(1.2f, 1.0f, 1.2f);

        [Header("伤害与打击感")]
        public int damage = 15;
        public float hitStopDuration = 0.05f;
        public float camImpulseStrength = 0.25f;

        [Header("效果")]
        public float knockback = 2f;
        public float stunDuration = 0.15f;

        [Header("特效（可选）")]
        public GameObject vfxPrefab;
        public AudioClip sfxClip;
    }
}
