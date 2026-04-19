using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 运行时角色属性：由五维基础属性 + 等级成长 + 装备加成 换算成战斗数值。
    /// 公式参考策划文档 GAME_MECHANICS.md。
    /// </summary>
    public class CharacterStats
    {
        // ── 原始五维（来自 CharacterData + 存档加成）──────────────────
        public int GenGu   { get; private set; } // 根骨
        public int NeiLi   { get; private set; } // 内力
        public int WuXing  { get; private set; } // 悟性
        public int ShenFa  { get; private set; } // 身法
        public int TiPo    { get; private set; } // 体魄

        public int Level   { get; private set; } = 1;

        // ── 派生战斗数值 ───────────────────────────────────────────────

        /// <summary>最大生命值：体魄 × 20 + 等级 × 5</summary>
        public int MaxHp   => TiPo * 20 + Level * 5;

        /// <summary>最大内力槽：内力 × 10 + 根骨 × 3</summary>
        public int MaxMp   => NeiLi * 10 + GenGu * 3;

        /// <summary>移动力（格子数/回合）：2 + 身法/5（向下取整）</summary>
        public int MoveRange => 2 + Mathf.FloorToInt(ShenFa / 5f);

        /// <summary>行动速度（决定回合顺序）：身法 × 2 + 悟性</summary>
        public int Speed   => ShenFa * 2 + WuXing;

        /// <summary>基础攻击加成（乘法因子，叠加到武器基础攻击上）：1 + 根骨/50</summary>
        public float AtkMult => 1f + GenGu / 50f;

        /// <summary>基础防御减伤（乘法因子）：体魄/(体魄+80)</summary>
        public float DefMult => TiPo / (float)(TiPo + 80);

        /// <summary>闪避率（百分比，上限 60%）：身法 × 0.5%</summary>
        public float DodgeRate => Mathf.Min(0.60f, ShenFa * 0.005f);

        /// <summary>武功领悟速率加成：悟性 × 1%</summary>
        public float LearningBonus => WuXing * 0.01f;

        // ── 运行时状态 ─────────────────────────────────────────────────
        private int _hp;
        private int _mp;

        public int Hp
        {
            get => _hp;
            set => _hp = Mathf.Clamp(value, 0, MaxHp);
        }

        public int Mp
        {
            get => _mp;
            set => _mp = Mathf.Clamp(value, 0, MaxMp);
        }

        public bool IsDead => Hp <= 0;

        // ── 初始化 ─────────────────────────────────────────────────────

        /// <summary>从 CharacterData 初始化（角色创建 / 战斗开始时）。</summary>
        public CharacterStats(CharacterData data, int level = 1)
        {
            Level   = level;
            GenGu   = data.genGu;
            NeiLi   = data.neiLi;
            WuXing  = data.wuXing;
            ShenFa  = data.shenFa;
            TiPo    = data.tiPo;
            // 等级成长：每升一级各维 +1
            int growth = level - 1;
            GenGu   += growth;
            NeiLi   += growth;
            ShenFa  += growth;
            TiPo    += growth;
            // 悟性成长稍快
            WuXing  += growth + Mathf.FloorToInt(growth * 0.3f);

            Hp = MaxHp;
            Mp = MaxMp;
        }

        /// <summary>从存档数据重建（hp/mp 从存档恢复）。</summary>
        public CharacterStats(CharacterData data, int level, int savedHp, int savedMp)
            : this(data, level)
        {
            Hp = savedHp;
            Mp = savedMp;
        }

        /// <summary>为主角在创建时追加自由分配的属性点。</summary>
        public void ApplyBonusPoints(int genGu, int neiLi, int wuXing, int shenFa, int tiPo)
        {
            GenGu  += genGu;
            NeiLi  += neiLi;
            WuXing += wuXing;
            ShenFa += shenFa;
            TiPo   += tiPo;
            Hp = MaxHp;
            Mp = MaxMp;
        }

        /// <summary>回合开始时内力自然恢复（每回合 +5）。</summary>
        public void RecoverMpPerTurn()
        {
            Mp += 5;
        }
    }
}
