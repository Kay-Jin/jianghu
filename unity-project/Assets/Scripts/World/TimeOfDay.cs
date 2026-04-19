using UnityEngine;

namespace Jianghu.World
{
    /// <summary>
    /// 日夜循环：控制方向光角度与颜色，并对环境光做简单过渡。
    /// 一个「游戏日」= <see cref="dayLengthSeconds"/> 秒（默认 10 分钟）。
    /// </summary>
    [ExecuteAlways]
    public class TimeOfDay : MonoBehaviour
    {
        [SerializeField] private Light sun;
        [SerializeField, Range(0f, 24f)] private float currentHour = 8f;
        [SerializeField] private float dayLengthSeconds = 600f;

        [Header("Color Ramp")]
        [SerializeField] private Gradient sunColor = DefaultSunGradient();
        [SerializeField] private Gradient ambientColor = DefaultAmbientGradient();

        public float CurrentHour => currentHour;

        public void SetSun(Light s) => sun = s;

        private void Update()
        {
            if (Application.isPlaying)
            {
                currentHour += (24f / Mathf.Max(1f, dayLengthSeconds)) * Time.deltaTime;
                if (currentHour >= 24f) currentHour -= 24f;
            }

            Apply();
        }

        public void SetHour(float hour)
        {
            currentHour = Mathf.Repeat(hour, 24f);
            Apply();
        }

        private void Apply()
        {
            if (sun == null) return;
            float t = currentHour / 24f;
            float angle = (currentHour - 6f) / 24f * 360f;
            sun.transform.rotation = Quaternion.Euler(angle, 170f, 0f);
            sun.color = sunColor.Evaluate(t);
            sun.intensity = Mathf.Lerp(0.1f, 1.2f, Mathf.Clamp01(Mathf.Sin(Mathf.PI * t)));
            RenderSettings.ambientLight = ambientColor.Evaluate(t);
        }

        private static Gradient DefaultSunGradient()
        {
            var g = new Gradient();
            g.SetKeys(new[]
            {
                new GradientColorKey(new Color(0.05f, 0.07f, 0.18f), 0.0f), // 0 点，深夜
                new GradientColorKey(new Color(1.00f, 0.65f, 0.35f), 0.25f), // 日出
                new GradientColorKey(new Color(1.00f, 0.96f, 0.86f), 0.50f), // 正午
                new GradientColorKey(new Color(1.00f, 0.55f, 0.30f), 0.75f), // 日落
                new GradientColorKey(new Color(0.05f, 0.07f, 0.18f), 1.0f),
            }, new[]
            {
                new GradientAlphaKey(1f, 0f), new GradientAlphaKey(1f, 1f)
            });
            return g;
        }

        private static Gradient DefaultAmbientGradient()
        {
            var g = new Gradient();
            g.SetKeys(new[]
            {
                new GradientColorKey(new Color(0.05f, 0.06f, 0.10f), 0.0f),
                new GradientColorKey(new Color(0.40f, 0.40f, 0.55f), 0.25f),
                new GradientColorKey(new Color(0.60f, 0.62f, 0.72f), 0.50f),
                new GradientColorKey(new Color(0.55f, 0.40f, 0.35f), 0.75f),
                new GradientColorKey(new Color(0.05f, 0.06f, 0.10f), 1.0f),
            }, new[]
            {
                new GradientAlphaKey(1f, 0f), new GradientAlphaKey(1f, 1f)
            });
            return g;
        }
    }
}
