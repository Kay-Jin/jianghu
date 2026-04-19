using UnityEngine;

namespace Jianghu.Battle
{
    /// <summary>
    /// 六边形 Axial 坐标 (q, r)。
    /// 使用 Flat-top 六边形：六个邻居方向固定。
    /// Cube 坐标满足 x+y+z=0，由 q/r 可推导 s = -q-r。
    /// </summary>
    [System.Serializable]
    public struct HexCoord : System.IEquatable<HexCoord>
    {
        public int q;
        public int r;
        public int s => -q - r;

        public static readonly HexCoord Zero = new HexCoord(0, 0);

        // Flat-top 六个邻居方向（顺时针从右上开始）
        public static readonly HexCoord[] Directions =
        {
            new HexCoord(1, 0),   // 右
            new HexCoord(1, -1),  // 右上
            new HexCoord(0, -1),  // 左上
            new HexCoord(-1, 0),  // 左
            new HexCoord(-1, 1),  // 左下
            new HexCoord(0, 1),   // 右下
        };

        public HexCoord(int q, int r) { this.q = q; this.r = r; }

        // ── 算术 ──────────────────────────────────────────────────────────
        public static HexCoord operator +(HexCoord a, HexCoord b) => new HexCoord(a.q + b.q, a.r + b.r);
        public static HexCoord operator -(HexCoord a, HexCoord b) => new HexCoord(a.q - b.q, a.r - b.r);
        public static HexCoord operator *(HexCoord a, int k)      => new HexCoord(a.q * k, a.r * k);

        // ── 距离 ──────────────────────────────────────────────────────────
        /// <summary>六边形格子步数距离（曼哈顿距离的六边形版本）。</summary>
        public static int Distance(HexCoord a, HexCoord b)
        {
            HexCoord d = a - b;
            return Mathf.Max(Mathf.Abs(d.q), Mathf.Abs(d.r), Mathf.Abs(d.s));
        }

        public int DistanceTo(HexCoord other) => Distance(this, other);

        // ── 邻居 ──────────────────────────────────────────────────────────
        public HexCoord Neighbor(int dir) => this + Directions[dir % 6];

        // ── 世界坐标转换（Flat-top, 格子大小 = hexSize）─────────────────
        /// <summary>将 Axial 坐标转换为世界 XZ 平面坐标（Y=0）。</summary>
        public static Vector3 ToWorld(HexCoord h, float hexSize)
        {
            float x = hexSize * (3f / 2f * h.q);
            float z = hexSize * (Mathf.Sqrt(3f) / 2f * h.q + Mathf.Sqrt(3f) * h.r);
            return new Vector3(x, 0f, z);
        }

        /// <summary>将世界 XZ 坐标转换为最近的 Axial 坐标。</summary>
        public static HexCoord FromWorld(Vector3 worldPos, float hexSize)
        {
            float q = (2f / 3f * worldPos.x) / hexSize;
            float r = (-1f / 3f * worldPos.x + Mathf.Sqrt(3f) / 3f * worldPos.z) / hexSize;
            return Round(q, r);
        }

        private static HexCoord Round(float fq, float fr)
        {
            float fs = -fq - fr;
            int rq = Mathf.RoundToInt(fq);
            int rr = Mathf.RoundToInt(fr);
            int rs = Mathf.RoundToInt(fs);
            float dq = Mathf.Abs(rq - fq);
            float dr = Mathf.Abs(rr - fr);
            float ds = Mathf.Abs(rs - fs);
            if (dq > dr && dq > ds) rq = -rr - rs;
            else if (dr > ds)       rr = -rq - rs;
            return new HexCoord(rq, rr);
        }

        // ── 相等 ──────────────────────────────────────────────────────────
        public bool Equals(HexCoord other) => q == other.q && r == other.r;
        public override bool Equals(object obj) => obj is HexCoord h && Equals(h);
        public override int GetHashCode() => q * 1000003 + r;
        public static bool operator ==(HexCoord a, HexCoord b) => a.Equals(b);
        public static bool operator !=(HexCoord a, HexCoord b) => !a.Equals(b);
        public override string ToString() => $"({q},{r})";
    }
}
