using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 角色五维属性基础数据（ScriptableObject，编辑器配置用）。
    /// 可在 Project 右键 → Create → Jianghu → CharacterData 创建。
    /// </summary>
    [CreateAssetMenu(menuName = "Jianghu/CharacterData", fileName = "Char_")]
    public class CharacterData : ScriptableObject
    {
        [Header("基本信息")]
        public string characterName = "未命名";
        public CharacterFaction faction = CharacterFaction.Player;
        [TextArea(2, 4)]
        public string description;

        [Header("五维基础属性（创建时的固定值）")]
        [Tooltip("根骨：决定武功上限 / 内力恢复速率")]
        [Range(1, 30)] public int genGu    = 10; // 根骨
        [Tooltip("内力：决定技能释放次数 / 内力上限")]
        [Range(1, 30)] public int neiLi    = 10; // 内力
        [Tooltip("悟性：决定武功领悟速度 / 成长加速")]
        [Range(1, 30)] public int wuXing   = 10; // 悟性
        [Tooltip("身法：决定先手顺序 / 闪避率 / 每回合移动力")]
        [Range(1, 30)] public int shenFa   = 10; // 身法
        [Tooltip("体魄：决定最大生命值 / 防御力 / 体力耐久")]
        [Range(1, 30)] public int tiPo     = 10; // 体魄

        [Header("战斗配置")]
        [Tooltip("普通攻击伤害（基准值，实际由 DamageCalculator 计算）")]
        public int baseAttack = 15;
        [Tooltip("攻击射程（格子数，1=近战）")]
        [Range(1, 5)] public int attackRange = 1;
        [Tooltip("可装备的武功 ID 列表")]
        public string[] martialArtIds;

        [Header("视觉")]
        public GameObject modelPrefab;
        public Sprite portrait;
    }

    public enum CharacterFaction { Player, Ally, Enemy, Neutral }
}
