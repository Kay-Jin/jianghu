using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 地形类型，决定移动力消耗与战斗加成。
    /// </summary>
    public enum TerrainType
    {
        Plain    = 0,   // 平地  移动1，无加成
        Forest   = 1,   // 树林  移动2，防御+10%
        Hill     = 2,   // 山丘  移动2，攻击+10%（居高临下）
        Water    = 3,   // 水域  不可进入（除轻功专精）
        Road     = 4,   // 道路  移动0.5（快速通行）
        Building = 5,   // 建筑  防御+15%
        Cliff    = 6,   // 悬崖  不可进入
    }

    /// <summary>
    /// 单个六边形格子：坐标、地形、占据单位、高亮状态。
    /// 挂在场景 GameObject 上，由 <see cref="HexGrid"/> 统一管理。
    /// </summary>
    public class HexCell : MonoBehaviour
    {
        // ── 数据 ──────────────────────────────────────────────────────────
        public HexCoord Coord { get; private set; }
        public TerrainType Terrain { get; private set; } = TerrainType.Plain;

        /// <summary>当前占据此格的战斗单位（null 表示空格）。</summary>
        public BattleUnit Occupant { get; set; }

        public bool IsOccupied => Occupant != null;
        public bool IsWalkable(BattleUnit unit = null) =>
            Terrain != TerrainType.Water &&
            Terrain != TerrainType.Cliff &&
            (Occupant == null || Occupant == unit);

        // ── 移动力消耗 ────────────────────────────────────────────────────
        public int MoveCost()
        {
            return Terrain switch
            {
                TerrainType.Road     => 1,  // 路比平地快，但统一按1处理（可改0.5用float）
                TerrainType.Plain    => 1,
                TerrainType.Forest   => 2,
                TerrainType.Hill     => 2,
                TerrainType.Building => 1,
                _                    => 99, // 不可通行
            };
        }

        // ── 战斗加成（百分比，乘法叠加到最终伤害/防御）────────────────────
        public float DefenseBonus()
        {
            return Terrain switch
            {
                TerrainType.Forest   => 0.10f,
                TerrainType.Building => 0.15f,
                _                    => 0f,
            };
        }

        public float AttackBonus()
        {
            return Terrain switch
            {
                TerrainType.Hill => 0.10f,
                _                => 0f,
            };
        }

        // ── 高亮状态 ──────────────────────────────────────────────────────
        public enum HighlightMode { None, Movable, Attackable, Selected, Path }

        private HighlightMode _highlight = HighlightMode.None;
        private Renderer _renderer;

        private static readonly Color ColorNone      = new Color(0f, 0f, 0f, 0f);
        private static readonly Color ColorMovable   = new Color(0.2f, 0.6f, 1f, 0.55f);
        private static readonly Color ColorAttack    = new Color(1f, 0.25f, 0.25f, 0.55f);
        private static readonly Color ColorSelected  = new Color(1f, 0.9f, 0.2f, 0.7f);
        private static readonly Color ColorPath      = new Color(0.3f, 1f, 0.4f, 0.5f);

        private void Awake()
        {
            _renderer = GetComponentInChildren<Renderer>();
        }

        public void Init(HexCoord coord, TerrainType terrain)
        {
            Coord   = coord;
            Terrain = terrain;
            name    = $"Hex_{coord}";
        }

        public void SetHighlight(HighlightMode mode)
        {
            if (_highlight == mode) return;
            _highlight = mode;
            ApplyHighlight();
        }

        private void ApplyHighlight()
        {
            if (_renderer == null) return;
            Color c = _highlight switch
            {
                HighlightMode.Movable   => ColorMovable,
                HighlightMode.Attackable => ColorAttack,
                HighlightMode.Selected  => ColorSelected,
                HighlightMode.Path      => ColorPath,
                _                       => ColorNone,
            };
            // 修改 MaterialPropertyBlock 避免实例化材质
            var mpb = new MaterialPropertyBlock();
            _renderer.GetPropertyBlock(mpb);
            mpb.SetColor("_BaseColor", _highlight == HighlightMode.None
                ? GetTerrainBaseColor()
                : Color.Lerp(GetTerrainBaseColor(), c, 0.7f));
            _renderer.SetPropertyBlock(mpb);
        }

        public void ClearHighlight() => SetHighlight(HighlightMode.None);

        private Color GetTerrainBaseColor()
        {
            return Terrain switch
            {
                TerrainType.Forest   => new Color(0.2f, 0.5f, 0.2f),
                TerrainType.Hill     => new Color(0.6f, 0.5f, 0.35f),
                TerrainType.Water    => new Color(0.2f, 0.4f, 0.8f),
                TerrainType.Road     => new Color(0.75f, 0.65f, 0.45f),
                TerrainType.Building => new Color(0.7f, 0.65f, 0.55f),
                TerrainType.Cliff    => new Color(0.4f, 0.35f, 0.3f),
                _                    => new Color(0.5f, 0.65f, 0.35f),  // Plain
            };
        }
    }
}
