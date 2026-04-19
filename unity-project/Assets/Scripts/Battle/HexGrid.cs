using System.Collections.Generic;
using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 六边形战棋网格管理器。
    /// 负责：生成格子 GameObject、坐标查询、BFS 移动/攻击范围计算、寻路。
    /// 场景中放一个 GameObject 挂此组件即可，格子由代码程序化生成。
    /// </summary>
    public class HexGrid : MonoBehaviour
    {
        public static HexGrid Instance { get; private set; }

        // ── Inspector 配置 ─────────────────────────────────────────────
        [Header("Grid Size")]
        [Tooltip("地图宽度（q 轴格子数）")]
        [SerializeField] private int width  = 12;
        [Tooltip("地图高度（r 轴格子数）")]
        [SerializeField] private int height = 10;
        [Tooltip("六边形外接圆半径（世界单位）")]
        [SerializeField] private float hexSize = 1.1f;

        [Header("Prefab")]
        [Tooltip("单个六边形格子 Prefab（需含 Renderer + Collider）")]
        [SerializeField] private GameObject hexCellPrefab;

        [Header("Terrain Override (optional)")]
        [Tooltip("按索引为格子指定地形，超出范围的全为 Plain")]
        [SerializeField] private TerrainType[] terrainOverride;

        // ── 运行时数据 ─────────────────────────────────────────────────
        private readonly Dictionary<HexCoord, HexCell> _cells = new();
        public IReadOnlyDictionary<HexCoord, HexCell> Cells => _cells;

        private void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
        }

        private void Start()
        {
            if (hexCellPrefab == null)
            {
                Debug.LogWarning("[HexGrid] hexCellPrefab 未赋值，将使用程序化胶囊体。");
            }
            GenerateGrid();
        }

        // ── 生成网格 ───────────────────────────────────────────────────
        public void GenerateGrid()
        {
            ClearGrid();
            int idx = 0;
            for (int r = 0; r < height; r++)
            {
                int qOffset = Mathf.FloorToInt(r / 2f);
                for (int q = -qOffset; q < width - qOffset; q++)
                {
                    var coord = new HexCoord(q, r);
                    TerrainType terrain = idx < terrainOverride?.Length
                        ? terrainOverride[idx]
                        : TerrainType.Plain;
                    CreateCell(coord, terrain);
                    idx++;
                }
            }
        }

        private void CreateCell(HexCoord coord, TerrainType terrain)
        {
            Vector3 pos = HexCoord.ToWorld(coord, hexSize);
            GameObject go;
            if (hexCellPrefab != null)
            {
                go = Instantiate(hexCellPrefab, pos, Quaternion.identity, transform);
            }
            else
            {
                // 程序化备用：扁平圆柱模拟六边形
                go = GameObject.CreatePrimitive(PrimitiveType.Cylinder);
                go.transform.SetParent(transform, false);
                go.transform.position = pos;
                go.transform.localScale = new Vector3(hexSize * 1.8f, 0.05f, hexSize * 1.8f);
            }

            var cell = go.GetComponent<HexCell>() ?? go.AddComponent<HexCell>();
            cell.Init(coord, terrain);
            _cells[coord] = cell;
        }

        private void ClearGrid()
        {
            foreach (var c in _cells.Values)
                if (c) Destroy(c.gameObject);
            _cells.Clear();
        }

        // ── 查询 ───────────────────────────────────────────────────────
        public bool TryGet(HexCoord coord, out HexCell cell) => _cells.TryGetValue(coord, out cell);
        public HexCell Get(HexCoord coord) => _cells.TryGetValue(coord, out var c) ? c : null;

        public HexCell GetAt(Vector3 worldPos)
        {
            var coord = HexCoord.FromWorld(worldPos, hexSize);
            return Get(coord);
        }

        // ── BFS 移动范围 ───────────────────────────────────────────────
        /// <summary>
        /// 返回从 <paramref name="origin"/> 出发、消耗移动力不超过 <paramref name="moveRange"/> 的所有可达格子集合。
        /// </summary>
        public HashSet<HexCell> GetMovableRange(HexCell origin, int moveRange, BattleUnit mover)
        {
            var result  = new HashSet<HexCell>();
            var visited = new Dictionary<HexCoord, int>(); // coord → 剩余移动力
            var queue   = new Queue<(HexCell cell, int remaining)>();
            visited[origin.Coord] = moveRange;
            queue.Enqueue((origin, moveRange));

            while (queue.Count > 0)
            {
                var (current, remaining) = queue.Dequeue();
                for (int d = 0; d < 6; d++)
                {
                    var neighbor = Get(current.Coord.Neighbor(d));
                    if (neighbor == null) continue;
                    if (!neighbor.IsWalkable(mover)) continue;

                    int cost = neighbor.MoveCost();
                    int leftover = remaining - cost;
                    if (leftover < 0) continue;

                    if (!visited.TryGetValue(neighbor.Coord, out int prev) || leftover > prev)
                    {
                        visited[neighbor.Coord] = leftover;
                        result.Add(neighbor);
                        queue.Enqueue((neighbor, leftover));
                    }
                }
            }
            return result;
        }

        // ── BFS 攻击范围（以当前位置为圆心，固定距离圈）────────────────
        /// <summary>
        /// 返回以 <paramref name="center"/> 为原点、距离在 [minRange, maxRange] 内的所有格子。
        /// </summary>
        public HashSet<HexCell> GetAttackRange(HexCell center, int minRange, int maxRange)
        {
            var result = new HashSet<HexCell>();
            foreach (var kv in _cells)
            {
                int dist = HexCoord.Distance(center.Coord, kv.Key);
                if (dist >= minRange && dist <= maxRange)
                    result.Add(kv.Value);
            }
            return result;
        }

        // ── A* 寻路（返回最短路径的格子列表，不含起点）──────────────────
        public List<HexCell> FindPath(HexCell start, HexCell goal, BattleUnit mover)
        {
            var open   = new SortedList<float, HexCoord>(new DuplicateKeyComparer());
            var cameFrom = new Dictionary<HexCoord, HexCoord>();
            var gScore   = new Dictionary<HexCoord, float> { [start.Coord] = 0f };

            open.Add(Heuristic(start.Coord, goal.Coord), start.Coord);

            while (open.Count > 0)
            {
                var current = open.Values[0];
                open.RemoveAt(0);

                if (current == goal.Coord)
                    return ReconstructPath(cameFrom, current);

                for (int d = 0; d < 6; d++)
                {
                    var nb = current.Neighbor(d);
                    if (!_cells.TryGetValue(nb, out var nbCell)) continue;
                    if (!nbCell.IsWalkable(mover)) continue;

                    float tentative = gScore[current] + nbCell.MoveCost();
                    if (!gScore.TryGetValue(nb, out float prev) || tentative < prev)
                    {
                        cameFrom[nb] = current;
                        gScore[nb]   = tentative;
                        float f = tentative + Heuristic(nb, goal.Coord);
                        open.Add(f, nb);
                    }
                }
            }
            return null; // 无法到达
        }

        private static float Heuristic(HexCoord a, HexCoord b) => HexCoord.Distance(a, b);

        private List<HexCell> ReconstructPath(Dictionary<HexCoord, HexCoord> came, HexCoord current)
        {
            var path = new List<HexCell>();
            while (came.ContainsKey(current))
            {
                if (_cells.TryGetValue(current, out var c)) path.Add(c);
                current = came[current];
            }
            path.Reverse();
            return path;
        }

        // ── 高亮辅助 ──────────────────────────────────────────────────
        public void ClearAllHighlights()
        {
            foreach (var c in _cells.Values) c.ClearHighlight();
        }

        public void HighlightSet(IEnumerable<HexCell> cells, HexCell.HighlightMode mode)
        {
            foreach (var c in cells) c.SetHighlight(mode);
        }
    }

    // SortedList 允许重复 key 的比较器
    internal class DuplicateKeyComparer : IComparer<float>
    {
        public int Compare(float x, float y) => x <= y ? -1 : 1;
    }
}
