using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 伤害计算器：统一所有伤害公式，方便后续调整数值平衡。
    /// 公式参考设计文档 GAME_MECHANICS.md。
    /// </summary>
    public static class DamageCalculator
    {
        // ── 伤害公式 ───────────────────────────────────────────────────
        /// <summary>
        /// 计算一次普通攻击的最终伤害值。
        /// 公式：(攻击基础 × 根骨加成) × (1 - 防御减伤) × 地形加成 × 面向修正 × 随机浮动
        /// </summary>
        public static int CalcNormalAttack(BattleUnit attacker, BattleUnit defender)
        {
            if (attacker?.Data == null || defender?.Stats == null) return 0;

            float baseDmg   = attacker.Data.baseAttack * attacker.Stats.AtkMult;
            float defReduce = defender.Stats.DefMult;
            float terrain   = 1f + defender.Cell?.DefenseBonus() ?? 0f;
            float facing    = CalcFacingModifier(attacker, defender);
            float random    = Random.Range(0.9f, 1.1f);

            int final = Mathf.Max(1, Mathf.RoundToInt(baseDmg * (1f - defReduce) * terrain * facing * random));
            return final;
        }

        /// <summary>
        /// 计算武功（技能）伤害。
        /// 公式：(武功基础伤害 + 根骨加成) × 武功倍率 × 克制加成 × (1 - 防御减伤) × 地形 × 面向
        /// </summary>
        public static int CalcMartialArt(BattleUnit attacker, BattleUnit defender,
            int martialBaseDmg, float skillMult, MartialArtType atkType, MartialArtType defType)
        {
            float baseDmg    = (martialBaseDmg + attacker.Stats.GenGu * 2f) * attacker.Stats.AtkMult;
            float restraint  = CalcRestraintMult(atkType, defType);
            float defReduce  = defender.Stats.DefMult;
            float terrain    = 1f + defender.Cell?.DefenseBonus() ?? 0f;
            float facing     = CalcFacingModifier(attacker, defender);
            float random     = Random.Range(0.92f, 1.08f);

            int final = Mathf.Max(1,
                Mathf.RoundToInt(baseDmg * skillMult * restraint * (1f - defReduce) * terrain * facing * random));
            return final;
        }

        /// <summary>
        /// 判断是否触发闪避（随机判定）。
        /// </summary>
        public static bool IsEvaded(BattleUnit attacker, BattleUnit defender)
        {
            float hitRate   = 1f - defender.Stats.DodgeRate;
            float roll      = Random.value;
            return roll > hitRate;
        }

        // ── 面向修正 ───────────────────────────────────────────────────
        /// <summary>
        /// 面向修正：
        ///  正面受到攻击 → ×0.90（正面格挡，防御更容易）
        ///  侧面 → ×1.00
        ///  背面 → ×1.30（背刺加成）
        /// </summary>
        private static float CalcFacingModifier(BattleUnit attacker, BattleUnit defender)
        {
            if (attacker?.Cell == null || defender?.Cell == null) return 1f;

            // 攻击者相对防御者的方向 id
            int attackDir = -1;
            for (int d = 0; d < 6; d++)
            {
                if (defender.Cell.Coord.Neighbor(d) == attacker.Cell.Coord)
                {
                    attackDir = d;
                    break;
                }
            }
            if (attackDir < 0) return 1f;

            // 防御者的面向方向（FacingDir 是防御者朝向）
            int facing     = defender.FacingDir;
            int diff       = Mathf.Abs((attackDir - (facing + 3) % 6 + 6) % 6);

            if (diff == 0)       return 1.30f; // 背刺
            if (diff == 1 || diff == 5) return 1.10f; // 侧翼
            return 0.90f;                            // 正面
        }

        // ── 克制关系（策划文档 MARTIAL_ARTS.md）──────────────────────
        /// <summary>
        /// 克制关系：
        ///  剑→刀→棍→剑（石头剪刀布）
        ///  拳掌→暗器→轻功→拳掌
        ///  无克制 → ×1.00
        ///  克制 → ×1.10
        ///  被克制 → ×0.90
        /// </summary>
        private static float CalcRestraintMult(MartialArtType atk, MartialArtType def)
        {
            if (Restrains(atk, def)) return 1.10f;
            if (Restrains(def, atk)) return 0.90f;
            return 1.00f;
        }

        private static bool Restrains(MartialArtType a, MartialArtType b)
        {
            return (a == MartialArtType.Sword  && b == MartialArtType.Blade)  ||
                   (a == MartialArtType.Blade  && b == MartialArtType.Staff)  ||
                   (a == MartialArtType.Staff  && b == MartialArtType.Sword)  ||
                   (a == MartialArtType.Fist   && b == MartialArtType.Hidden) ||
                   (a == MartialArtType.Hidden && b == MartialArtType.Qinggong)||
                   (a == MartialArtType.Qinggong && b == MartialArtType.Fist);
        }

        // ── 围攻加成（多个己方相邻同一敌方）─────────────────────────
        /// <summary>
        /// 围攻加成：相邻的己方单位每多 1 个 +5%，最高 +30%。
        /// </summary>
        public static float CalcEncirclementBonus(BattleUnit target)
        {
            if (target?.Cell == null) return 1f;
            int allies = 0;
            for (int d = 0; d < 6; d++)
            {
                var nb = HexGrid.Instance?.Get(target.Cell.Coord.Neighbor(d));
                if (nb?.Occupant != null && nb.Occupant.Faction != target.Faction && nb.Occupant.IsAlive)
                    allies++;
            }
            return 1f + Mathf.Min(allies * 0.05f, 0.30f);
        }
    }

    /// <summary>武功类型（用于克制计算）。</summary>
    public enum MartialArtType
    {
        Normal,      // 无属性
        Sword,       // 剑法
        Blade,       // 刀法
        Staff,       // 棍法
        Fist,        // 拳掌
        Qinggong,    // 轻功
        Hidden,      // 暗器
        Inner,       // 内功
        Medical,     // 医毒
    }
}
