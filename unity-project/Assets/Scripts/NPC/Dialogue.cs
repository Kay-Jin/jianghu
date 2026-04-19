using UnityEngine;
using Jianghu.UI;

namespace Jianghu.NPC
{
    /// <summary>
    /// 放在玩家上的对话触发器：按 E 与最近的 NPC 交互。
    /// 初版用 Unity IMGUI 画一个最小对话框，后续切 uGUI / UI Toolkit。
    /// </summary>
    public class Dialogue : MonoBehaviour
    {
        [SerializeField] private KeyCode interactKey = KeyCode.E;
        [SerializeField] private float interactRadius = 2.2f;
        [SerializeField] private LayerMask npcMask = ~0;

        private NPCController _current;
        private int _lineIndex;

        private void Update()
        {
            if (!Input.GetKeyDown(interactKey)) return;

            if (_current == null)
            {
                TryStart();
            }
            else
            {
                AdvanceOrClose();
            }
        }

        private void TryStart()
        {
            Collider[] hits = Physics.OverlapSphere(transform.position + Vector3.up * 1f, interactRadius,
                npcMask, QueryTriggerInteraction.Ignore);
            NPCController closest = null;
            float minD = float.MaxValue;
            foreach (var c in hits)
            {
                var npc = c.GetComponentInParent<NPCController>();
                if (npc == null || !npc.IsInteractable) continue;
                float d = Vector3.SqrMagnitude(npc.transform.position - transform.position);
                if (d < minD) { minD = d; closest = npc; }
            }

            if (closest == null) return;

            _current = closest;
            _lineIndex = 0;
            HUD.ShowDialogue(_current.npcName, _current.GetDialogueLines()[0]);
        }

        private void AdvanceOrClose()
        {
            _lineIndex++;
            var lines = _current.GetDialogueLines();
            if (_lineIndex >= lines.Length)
            {
                HUD.HideDialogue();
                _current = null;
                return;
            }
            HUD.ShowDialogue(_current.npcName, lines[_lineIndex]);
        }
    }
}
