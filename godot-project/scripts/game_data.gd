## GameData — 全游戏静态数据库（Autoload）
## 包含：角色定义 / 武功 / 物品 / 任务 / 地点
## 角色名称版本 v2.0 — 已清理所有与已知作品冲突的名称
extends Node

# ─────────────────────────────────────────────
# 五维属性说明
#   根骨(gengu)  → 攻击基础、武功威力
#   内力(neili)  → MP上限、内功技能效果
#   悟性(wuxing) → 学武速度、战斗洞察加成
#   身法(shenfa) → 移动范围、回避率
#   体魄(tipo)   → HP上限、防御基础
# ─────────────────────────────────────────────

# ══════════════════════════════════════════════
# 角色基础数据
# ══════════════════════════════════════════════
const CHARACTERS: Dictionary = {
	# ── 主角（固定：现代项目经理穿越，身体18岁） ──
	"protagonist": {
		"id": "protagonist",
		"name": "林渊",
		"nickname": "林工",
		"title": "异世界项目经理",
		"age_body": 18, "age_mind": 28,
		"faction": "player",
		"origin": "project_manager",
		"portrait": "res://assets/characters/protagonist.png",
		"portrait_scholar": "res://assets/characters/protagonist_scholar.png",
		"portrait_warrior": "res://assets/characters/protagonist_warrior.png",
		"portrait_final": "res://assets/characters/protagonist_final.png",
		"model": "res://assets/models/protagonist.glb",
		"base_stats": {"gengu":8,"neili":6,"wuxing":10,"shenfa":7,"tipo":9},
		"level": 1,
		"martial_arts": ["basic_punch","jian_qi_shan"],
		"modern_items": ["phone_pouch","wireless_earbuds","notebook","sticky_notes","bamboo_pen_tube"],
		"costumes": ["default","disciple","scholar","night_wanderer","grand_hero"],
		"description": "原28岁的互联网公司项目经理，被AI系统意外导入宋代江湖，身体还原为18岁。武功为零，但有10年职场经验——江湖比职场复杂不了多少，对吗？",
	},
	# ── 十位男队友 ────────────────────────────
	"shen_ren": {
		"id": "shen_ren", "name": "沈刃",
		"title": "断剑山庄大弟子",
		"faction": "ally", "origin": "sword_sect",
		"portrait": "res://assets/characters/shen_ren.png",
		"model": "res://assets/models/shen_ren.glb",
		"base_stats": {"gengu":14,"neili":8,"wuxing":12,"shenfa":13,"tipo":10},
		"level": 3,
		"martial_arts": ["duan_jian_jian_fa","po_jun","jian_qi_shan"],
		"description": "断剑山庄首席弟子，剑如其名，利而简。沉默寡言，对义父沈天剑忠诚至死。",
	},
	"gu_yuming": {
		"id": "gu_yuming", "name": "顾昱明",
		"title": "断剑山庄义子",
		"faction": "ally", "origin": "sword_sect",
		"portrait": "res://assets/characters/gu_yuming.png",
		"model": "res://assets/models/gu_yuming.glb",
		"base_stats": {"gengu":12,"neili":6,"wuxing":11,"shenfa":14,"tipo":9},
		"level": 2,
		"martial_arts": ["duan_jian_jian_fa","sword_dance"],
		"description": "庄主义子，外表开朗，内心藏有关于义父过去的秘密——关于沈家兄弟之间的隐痛。",
	},
	"yan_zheng": {
		"id": "yan_zheng", "name": "燕铮",
		"title": "铁血盟统领",
		"faction": "ally", "origin": "military",
		"portrait": "res://assets/characters/yan_zheng.png",
		"model": "res://assets/models/yan_zheng.glb",
		"base_stats": {"gengu":16,"neili":7,"wuxing":9,"shenfa":10,"tipo":18},
		"level": 5,
		"martial_arts": ["iron_fist","tie_xue_pao","shield_crush"],
		"description": "铁血盟统领，铮铮铁骨，为抗金义军燃尽一生。背负当年劫粮的愧疚，寻求救赎。",
	},
	"ning_ben": {
		"id": "ning_ben", "name": "宁奔",
		"title": "前六扇门捕快",
		"faction": "ally", "origin": "constable",
		"portrait": "res://assets/characters/ning_ben.png",
		"model": "res://assets/models/ning_ben.glb",
		"base_stats": {"gengu":11,"neili":9,"wuxing":13,"shenfa":16,"tipo":10},
		"level": 3,
		"martial_arts": ["chain_strike","capture_art","whirlwind_kick"],
		"description": "前六扇门精英捕快，奔走四方。因目睹上司枉法，愤而辞职独行江湖，寻旧账。",
	},
	"qingxu": {
		"id": "qingxu", "name": "清虚",
		"title": "逍遥渡散人（道号·清虚道人）",
		"faction": "ally", "origin": "taoist_hermit",
		"portrait": "res://assets/characters/qingxu.png",
		"model": "res://assets/models/qingxu.glb",
		"base_stats": {"gengu":9,"neili":18,"wuxing":16,"shenfa":12,"tipo":8},
		"level": 6,
		"martial_arts": ["tai_xu_jian_qi","wu_wei_zhang","nei_li_bao"],
		"description": "逍遥渡出走的修道奇人，道号清虚，看透世事却被一段师门旧情羁绊。",
	},
	"luo_heng": {
		"id": "luo_heng", "name": "罗衡",
		"title": "天机阁首席机关师",
		"faction": "ally", "origin": "inventor",
		"portrait": "res://assets/characters/luo_heng.png",
		"model": "res://assets/models/luo_heng.glb",
		"base_stats": {"gengu":8,"neili":11,"wuxing":19,"shenfa":10,"tipo":9},
		"level": 3,
		"martial_arts": ["organ_crossbow","trap_deploy","flash_bomb"],
		"description": "天机阁机关天才，话痨，发明常出奇兵——偶尔帮倒忙，关键时刻却能神来一笔。",
	},
	"fang_feng": {
		"id": "fang_feng", "name": "方烽",
		"title": "边境溃兵",
		"faction": "ally", "origin": "deserter_soldier",
		"portrait": "res://assets/characters/fang_feng.png",
		"model": "res://assets/models/fang_feng.glb",
		"base_stats": {"gengu":13,"neili":7,"wuxing":8,"shenfa":12,"tipo":15},
		"level": 2,
		"martial_arts": ["spear_thrust","shield_wall","battle_cry"],
		"description": "边境兵败溃逃的士兵，活在自责和逃避中。有一封三年没写的家书，始终没有勇气发出去。",
	},
	"mu_changfeng": {
		"id": "mu_changfeng", "name": "穆长风",
		"title": "刀客浪人",
		"faction": "ally", "origin": "wandering_swordsman",
		"portrait": "res://assets/characters/mu_changfeng.png",
		"model": "res://assets/models/mu_changfeng.glb",
		"base_stats": {"gengu":15,"neili":8,"wuxing":10,"shenfa":14,"tipo":11},
		"level": 3,
		"martial_arts": ["quick_slash","blade_dance","last_stand"],
		"description": "师门蒙冤，以师父遗刀行走江湖。长风浪迹，只为有朝一日亲手翻案。",
	},
	"ba_tuer": {
		"id": "ba_tuer", "name": "巴图尔",
		"title": "西域使者",
		"faction": "ally", "origin": "western_region",
		"portrait": "res://assets/characters/ba_tuer.png",
		"model": "res://assets/models/ba_tuer.glb",
		"base_stats": {"gengu":14,"neili":10,"wuxing":11,"shenfa":11,"tipo":16},
		"level": 4,
		"martial_arts": ["wrestling_lock","bone_crush","sand_storm_strike"],
		"description": "西域回鹘使者，\"巴图尔\"意为英雄。摔跤高手，为联宋抗金的外交使命孤身深入汉地。",
	},
	"nie_wushang": {
		"id": "nie_wushang", "name": "聂无殇",
		"title": "毒医双修者",
		"faction": "ally", "origin": "medical",
		"portrait": "res://assets/characters/nie_wushang.png",
		"model": "res://assets/models/nie_wushang.glb",
		"base_stats": {"gengu":8,"neili":14,"wuxing":15,"shenfa":11,"tipo":10},
		"level": 4,
		"martial_arts": ["healing_palm","poison_needle","detox_field"],
		"description": "医毒双修，\"无殇\"是他给自己的愿景——无人因为他的医术而早逝。一个关于"救了人却后悔救"的故事。",
	},
	# ── 十位可攻略女主 ─────────────────────────
	"shen_qingyuan": {
		"id": "shen_qingyuan", "name": "沈清鸢",
		"title": "听雨楼少主",
		"faction": "neutral", "origin": "intelligence_guild",
		"portrait": "res://assets/characters/shen_qingyuan.png",
		"model": "res://assets/models/shen_qingyuan.glb",
		"base_stats": {"gengu":10,"neili":12,"wuxing":17,"shenfa":15,"tipo":8},
		"level": 4,
		"martial_arts": ["willow_step","hidden_needle","intelligence_net"],
		"description": "听雨楼情报网络核心，表面是江南名媛，实则是棋局里最深的那枚棋子。鸢者，无声而御风。",
	},
	"bai_zhi": {
		"id": "bai_zhi", "name": "白芷",
		"title": "药王谷传人",
		"faction": "neutral", "origin": "medical_valley",
		"portrait": "res://assets/characters/bai_zhi.png",
		"model": "res://assets/models/bai_zhi.glb",
		"base_stats": {"gengu":7,"neili":14,"wuxing":13,"shenfa":11,"tipo":9},
		"level": 3,
		"martial_arts": ["healing_palm","poison_needle","detox_field"],
		"description": "药王谷天才医师。白芷是一味解毒草药，也是她的性格——温柔而有用，但剂量过当亦是毒。",
	},
	"wei_zhuiyun": {
		"id": "wei_zhuiyun", "name": "卫追云",
		"title": "六扇门女捕头",
		"faction": "neutral", "origin": "constable",
		"portrait": "res://assets/characters/wei_zhuiyun.png",
		"model": "res://assets/models/wei_zhuiyun.glb",
		"base_stats": {"gengu":12,"neili":10,"wuxing":14,"shenfa":15,"tipo":11},
		"level": 4,
		"martial_arts": ["iron_chain","arrest_hold","justice_slash"],
		"description": "六扇门最年轻的女捕头，\"追云\"是她的风格——永远比案子快一步。坚持正义到近乎固执，正在推动内部改革。",
	},
	"huo_yutong": {
		"id": "huo_yutong", "name": "霍毓桐",
		"title": "暗器门派继承人",
		"faction": "neutral", "origin": "hidden_weapon_sect",
		"portrait": "res://assets/characters/huo_yutong.png",
		"model": "res://assets/models/huo_yutong.glb",
		"base_stats": {"gengu":9,"neili":13,"wuxing":15,"shenfa":16,"tipo":8},
		"level": 4,
		"martial_arts": ["tang_hidden_weapon","mechanism_trap","poison_fan"],
		"description": "霍家暗器门派继承人。桐木心坚，百鸟朝凤出于桐。正被叔父霍铁夺权，争夺家族控制权。",
	},
	"yun_moyan": {
		"id": "yun_moyan", "name": "云墨烟",
		"title": "青楼花魁（情报卧底）",
		"faction": "neutral", "origin": "intelligence_guild",
		"portrait": "res://assets/characters/yun_moyan.png",
		"model": "res://assets/models/yun_moyan.glb",
		"base_stats": {"gengu":8,"neili":11,"wuxing":18,"shenfa":16,"tipo":7},
		"level": 4,
		"martial_arts": ["silk_dance","smoke_screen","dance_blade"],
		"description": "京城青楼花魁，实为听雨楼在京城最深的卧底。墨烟散尽，身份亦如墨烟，无人能看清她的真面目。",
	},
	"ke_xingyue": {
		"id": "ke_xingyue", "name": "珂星月",
		"title": "东海游侠",
		"faction": "neutral", "origin": "sea_hermit",
		"portrait": "res://assets/characters/ke_xingyue.png",
		"model": "res://assets/models/ke_xingyue.glb",
		"base_stats": {"gengu":11,"neili":13,"wuxing":12,"shenfa":17,"tipo":10},
		"level": 5,
		"martial_arts": ["sea_whip","moonlit_step","storm_strike"],
		"description": "逍遥渡出身的东海游侠，珂如白玉，月映星海。潇洒不羁，背后有一段与师兄清虚的旧怨。",
	},
	"ling_lixue": {
		"id": "ling_lixue", "name": "凌离雪",
		"title": "前朝复国遗孤",
		"faction": "neutral", "origin": "royal_exile",
		"portrait": "res://assets/characters/ling_lixue.png",
		"model": "res://assets/models/ling_lixue.glb",
		"base_stats": {"gengu":10,"neili":12,"wuxing":14,"shenfa":13,"tipo":9},
		"level": 3,
		"martial_arts": ["royal_sword","restoration_secret","noble_stance"],
		"description": "前朝皇室血脉遗孤，凌于众人，离乡万里，雪冻封城。肩负复国使命，在爱与大义之间艰难抉择。",
	},
	"zhong_ling": {
		"id": "zhong_ling", "name": "钟灵",
		"title": "江湖女侠",
		"faction": "neutral", "origin": "wandering_heroine",
		"portrait": "res://assets/characters/zhong_ling.png",
		"model": "res://assets/models/zhong_ling.glb",
		"base_stats": {"gengu":12,"neili":9,"wuxing":13,"shenfa":18,"tipo":9},
		"level": 3,
		"martial_arts": ["shadow_step","pick_pocket_art","lightweight_blade"],
		"description": "家族蒙冤流落江湖，轻功冠绝同辈，以活泼外表掩藏深重心事。钟灵毓秀，但背负太多。",
	},
	"cheng_yanbi": {
		"id": "cheng_yanbi", "name": "程烟笔",
		"title": "宫廷画师",
		"faction": "neutral", "origin": "court_artist",
		"portrait": "res://assets/characters/cheng_yanbi.png",
		"model": "res://assets/models/cheng_yanbi.glb",
		"base_stats": {"gengu":7,"neili":10,"wuxing":19,"shenfa":11,"tipo":8},
		"level": 2,
		"martial_arts": ["brush_strike","ink_cloud","sight_beyond"],
		"description": "宫廷画师，用画笔记录真相。烟笔之名——烟消了，笔留了下来。感知力超乎寻常，擅长发现常人忽视的细节。",
	},
	"jiang_shisan": {
		"id": "jiang_shisan", "name": "姜十三",
		"title": "复仇女侠",
		"faction": "neutral", "origin": "revenge_warrior",
		"portrait": "res://assets/characters/jiang_shisan.png",
		"model": "res://assets/models/jiang_shisan.glb",
		"base_stats": {"gengu":14,"neili":9,"wuxing":11,"shenfa":13,"tipo":12},
		"level": 3,
		"martial_arts": ["vengeance_strike","blood_edge","iron_will"],
		"description": "姜家第十三女，因父仇独行江湖十年。热血与冷静并存，但复仇的终点也许不是她想象中那个答案。",
	},
	# ── 主要反派（精选用于战斗数据） ─────────
	"ming_yuan_zhu": {
		"id": "ming_yuan_zhu", "name": "冥渊主",
		"title": "幽冥教教主",
		"faction": "enemy", "origin": "cult_leader",
		"portrait": "res://assets/characters/ming_yuan_zhu.png",
		"model": "res://assets/models/ming_yuan_zhu.glb",
		"base_stats": {"gengu":22,"neili":25,"wuxing":20,"shenfa":18,"tipo":20},
		"level": 20,
		"martial_arts": ["death_palm","void_seal","yin_yang_reversal","dark_domain"],
		"description": "幽冥教教主，常以黑纱遮面，眼周有暗功的印记。认为武道必须归于一人统治。终极BOSS。",
	},
	"sikong_wuji": {
		"id": "sikong_wuji", "name": "司空无迹",
		"title": "武林盟主候选",
		"faction": "enemy", "origin": "martial_alliance",
		"portrait": "res://assets/characters/sikong_wuji.png",
		"model": "res://assets/models/sikong_wuji.glb",
		"base_stats": {"gengu":18,"neili":14,"wuxing":16,"shenfa":19,"tipo":14},
		"level": 12,
		"martial_arts": ["traceless_step","shadow_blade","void_slash"],
		"description": "武林盟主最有力竞争者，司空无迹——留不下任何痕迹。表面磊落，暗中效忠幽冥教。",
	},
	"lie_cang": {
		"id": "lie_cang", "name": "裂苍",
		"title": "金国武道天才",
		"faction": "enemy", "origin": "jin_warrior",
		"portrait": "res://assets/characters/lie_cang.png",
		"model": "res://assets/models/lie_cang.glb",
		"base_stats": {"gengu":20,"neili":12,"wuxing":18,"shenfa":16,"tipo":17},
		"level": 10,
		"martial_arts": ["heaven_sunder","mountain_break","war_god_stance"],
		"description": "金国最强武者，一拳可裂苍穹。追求绝对武道，只为遇到真正的对手。",
	},
	"shen_tianying": {
		"id": "shen_tianying", "name": "沈天影",
		"title": "幽冥教内鬼",
		"faction": "enemy", "origin": "sword_sect",
		"portrait": "res://assets/characters/shen_tianying.png",
		"model": "res://assets/models/shen_tianying.glb",
		"base_stats": {"gengu":16,"neili":10,"wuxing":14,"shenfa":17,"tipo":12},
		"level": 8,
		"martial_arts": ["duan_jian_jian_fa","betrayal_blade","shadow_step"],
		"description": "断剑山庄庄主沈天剑的亲弟弟，沈天影——天空里的影子，见不得光。主线一核心反派。",
	},
	"cai_jing": {
		"id": "cai_jing", "name": "蔡京",
		"title": "北宋宰相（历史人物）",
		"faction": "enemy", "origin": "corrupt_official",
		"portrait": "res://assets/characters/cai_jing.png",
		"model": "res://assets/models/cai_jing.glb",
		"base_stats": {"gengu":8,"neili":12,"wuxing":20,"shenfa":7,"tipo":10},
		"level": 8,
		"martial_arts": ["silk_tongue","political_trap","bribed_guards"],
		"description": "北宋四大奸臣之首，政治手腕出神入化，操控整个朝廷。史书上真实存在的人物。",
	},
}

# ══════════════════════════════════════════════
# 关键NPC（义父 + 其他剧情NPC）
# ══════════════════════════════════════════════
const KEY_NPCS: Dictionary = {
	"shen_tianjian": {
		"id": "shen_tianjian", "name": "沈天剑",
		"title": "断剑山庄庄主·义父",
		"portrait": "res://assets/characters/shen_tianjian.png",
		"description": "主角的义父，五六十岁，银发如雪，腰间悬着一把断了的剑——非武器，是纪念。对林渊的现代物品有好奇但从不追问。",
	},
	"huo_tie": {
		"id": "huo_tie", "name": "霍铁",
		"title": "霍家暗器派系叔父（反派）",
		"portrait": "res://assets/characters/huo_tie.png",
		"description": "霍毓桐的叔父，觊觎家族继承权，伪造文书陷害兄长，主线支线反派。",
	},
}


# ══════════════════════════════════════════════
# 武功数据库
# ══════════════════════════════════════════════
const MARTIAL_ARTS: Dictionary = {
	# ── 基础武功 ─────────────────────────────
	"basic_punch": {
		"name": "直拳", "type": "fist",
		"mp_cost": 0, "range": 1, "damage_multiplier": 1.0,
		"description": "最基础的拳击，无消耗。"
	},
	"basic_sword": {
		"name": "普通斩击", "type": "sword",
		"mp_cost": 0, "range": 1, "damage_multiplier": 1.0,
		"description": "基础剑法。"
	},
	# ── 剑法系 ─────────────────────────────
	"duan_jian_jian_fa": {
		"name": "断剑剑法", "type": "sword",
		"mp_cost": 5, "range": 2, "damage_multiplier": 1.5,
		"description": "断剑山庄入门剑法，平衡攻守。"
	},
	"po_jun": {
		"name": "破军", "type": "sword",
		"mp_cost": 15, "range": 2, "damage_multiplier": 2.5,
		"effect": "pierce", "pierce_percent": 0.3,
		"description": "断剑山庄秘传重剑技，无视30%防御。"
	},
	"jian_qi_shan": {
		"name": "剑气闪", "type": "sword",
		"mp_cost": 8, "range": 3, "damage_multiplier": 1.3,
		"effect": "line_aoe",
		"description": "剑气延伸攻击，可打击直线上所有单位。"
	},
	"sword_dance": {
		"name": "剑舞乱影", "type": "sword",
		"mp_cost": 12, "range": 2, "damage_multiplier": 1.4,
		"effect": "multi_hit", "hit_count": 3,
		"description": "三连击，每击伤害递减，但可打断敌方行动。"
	},
	"tai_xu_jian_qi": {
		"name": "太虚剑气", "type": "inner",
		"mp_cost": 20, "range": 4, "damage_multiplier": 2.0,
		"effect": "knockback",
		"description": "逍遥渡上乘剑气，可将敌人击退2格。"
	},
	"traceless_step": {
		"name": "无痕步·斩", "type": "qinggong",
		"mp_cost": 14, "range": 3, "damage_multiplier": 1.8,
		"effect": "teleport_strike",
		"description": "瞬间移形到目标背后发动攻击，背刺加成。"
	},
	"shadow_blade": {
		"name": "影刃", "type": "sword",
		"mp_cost": 10, "range": 2, "damage_multiplier": 1.6,
		"effect": "blind", "duration": 2,
		"description": "令目标陷入目盲状态，命中率降低2回合。"
	},
	"void_slash": {
		"name": "虚空斩", "type": "inner",
		"mp_cost": 25, "range": 3, "damage_multiplier": 3.0,
		"effect": "ignore_defense",
		"description": "最高阶剑法，直接无视防御。"
	},
	# ── 拳法系 ─────────────────────────────
	"iron_fist": {
		"name": "铁拳", "type": "fist",
		"mp_cost": 6, "range": 1, "damage_multiplier": 1.6,
		"description": "铁血盟的刚猛拳法，无多余花哨。"
	},
	"bone_crush": {
		"name": "碎骨功", "type": "fist",
		"mp_cost": 10, "range": 1, "damage_multiplier": 2.0,
		"effect": "defense_down", "amount": 5, "duration": 3,
		"description": "重击令目标防御持续降低3回合。"
	},
	"battle_cry": {
		"name": "战吼", "type": "fist",
		"mp_cost": 8, "range": 0, "damage_multiplier": 0,
		"effect": "self_buff", "attack_buff": 6, "duration": 3,
		"description": "鼓舞战意，自身攻击+6持续3回合。"
	},
	"wrestling_lock": {
		"name": "摔跤锁技", "type": "fist",
		"mp_cost": 10, "range": 1, "damage_multiplier": 1.2,
		"effect": "immobilize", "duration": 1,
		"description": "将目标控制1回合，无法移动。"
	},
	"sand_storm_strike": {
		"name": "风沙打击", "type": "fist",
		"mp_cost": 12, "range": 2, "damage_multiplier": 1.5,
		"effect": "aoe_2",
		"description": "西域摔跤技改良，2格范围内所有目标受伤。"
	},
	# ── 刀法系 ─────────────────────────────
	"quick_slash": {
		"name": "快斩", "type": "blade",
		"mp_cost": 5, "range": 1, "damage_multiplier": 1.4,
		"effect": "priority", 
		"description": "出手极快，当回合优先行动。"
	},
	"blade_dance": {
		"name": "刀舞", "type": "blade",
		"mp_cost": 15, "range": 2, "damage_multiplier": 1.2,
		"effect": "aoe_adj",
		"description": "旋转刀法，攻击周围所有相邻格的敌人。"
	},
	"last_stand": {
		"name": "背水一刀", "type": "blade",
		"mp_cost": 20, "range": 1, "damage_multiplier": 1.0,
		"effect": "hp_scaling", 
		"description": "HP越低，伤害越高。HP10%时伤害×4。"
	},
	# ── 暗器系 ─────────────────────────────
	"hidden_needle": {
		"name": "暗针", "type": "hidden",
		"mp_cost": 6, "range": 4, "damage_multiplier": 1.1,
		"effect": "poison", "poison_dmg": 5, "duration": 3,
		"description": "远程投针，附带持续中毒。"
	},
	"tang_hidden_weapon": {
		"name": "唐门百鸟朝凤", "type": "hidden",
		"mp_cost": 18, "range": 3, "damage_multiplier": 1.3,
		"effect": "multi_target", "target_count": 3,
		"description": "同时向3个目标发动暗器攻击。"
	},
	"mechanism_trap": {
		"name": "机关陷阱", "type": "hidden",
		"mp_cost": 12, "range": 3, "damage_multiplier": 0,
		"effect": "place_trap",
		"description": "在目标格设置陷阱，敌人踩入触发高额伤害。"
	},
	# ── 机关技 ─────────────────────────────
	"organ_crossbow": {
		"name": "连弩机关", "type": "mechanism",
		"mp_cost": 10, "range": 5, "damage_multiplier": 1.2,
		"effect": "line_pierce",
		"description": "直线穿透，命中直线上第一个障碍前的所有目标。"
	},
	"trap_deploy": {
		"name": "布设陷阱", "type": "mechanism",
		"mp_cost": 8, "range": 2, "damage_multiplier": 0,
		"effect": "area_trap",
		"description": "在目标区域布设范围陷阱。"
	},
	"flash_bomb": {
		"name": "闪光雷", "type": "mechanism",
		"mp_cost": 14, "range": 3, "damage_multiplier": 0.8,
		"effect": "aoe_stun", "stun_turns": 1,
		"description": "范围眩晕1回合，目标无法行动。"
	},
	# ── 医术系 ─────────────────────────────
	"healing_palm": {
		"name": "愈合掌", "type": "medical",
		"mp_cost": 12, "range": 2, "damage_multiplier": 0,
		"effect": "heal", "heal_amount": 30,
		"description": "治疗目标友方单位30点HP。"
	},
	"detox_field": {
		"name": "解毒辟毒法", "type": "medical",
		"mp_cost": 10, "range": 3, "damage_multiplier": 0,
		"effect": "cleanse",
		"description": "清除范围内所有友方的中毒/诅咒状态。"
	},
	"poison_needle": {
		"name": "毒针", "type": "medical",
		"mp_cost": 8, "range": 3, "damage_multiplier": 0.8,
		"effect": "strong_poison", "poison_dmg": 12, "duration": 5,
		"description": "药王谷的特制剧毒，持续5回合，毒量远超普通。"
	},
	# ── 内功系 ─────────────────────────────
	"nei_li_bao": {
		"name": "内力爆", "type": "inner",
		"mp_cost": 25, "range": 2, "damage_multiplier": 2.8,
		"effect": "mp_scaling",
		"description": "将内力直接爆发，MP越多伤害越高。"
	},
	"wu_wei_zhang": {
		"name": "无为掌", "type": "inner",
		"mp_cost": 18, "range": 2, "damage_multiplier": 1.5,
		"effect": "reflect", "reflect_pct": 0.5,
		"description": "顺势而为，使用后本回合受到的攻击伤害50%反弹。"
	},
	# ── BOSS专属 ───────────────────────────
	"death_palm": {
		"name": "死亡掌", "type": "inner",
		"mp_cost": 30, "range": 2, "damage_multiplier": 3.5,
		"effect": "instant_death_chance", "death_pct": 0.15,
		"description": "幽冥教绝技，有15%概率直接击杀目标。"
	},
	"void_seal": {
		"name": "封印虚空", "type": "inner",
		"mp_cost": 35, "range": 3, "damage_multiplier": 2.0,
		"effect": "seal_skills", "duration": 2,
		"description": "封印目标2回合内无法使用武功。"
	},
	"dark_domain": {
		"name": "幽冥领域", "type": "inner",
		"mp_cost": 50, "range": 0, "damage_multiplier": 0,
		"effect": "domain_buff",
		"description": "开启领域：范围内所有敌人受伤+30%，持续5回合。"
	},
	"heaven_sunder": {
		"name": "破天一击", "type": "inner",
		"mp_cost": 40, "range": 2, "damage_multiplier": 4.0,
		"effect": "terrain_destroy",
		"description": "摧毁目标格及相邻格地形，造成巨额伤害。"
	},
}

# ══════════════════════════════════════════════
# 物品 / 装备数据库
# ══════════════════════════════════════════════
const ITEMS: Dictionary = {
	# ── 消耗品 ─────────────────────────────
	"hp_small": {"name": "小还魂丹", "type": "consumable", "price": 50, "effect": "heal_hp", "value": 30},
	"hp_medium": {"name": "中还魂丹", "type": "consumable", "price": 120, "effect": "heal_hp", "value": 80},
	"hp_large": {"name": "大还魂丹", "type": "consumable", "price": 280, "effect": "heal_hp", "value": 200},
	"mp_small": {"name": "养气丸", "type": "consumable", "price": 60, "effect": "heal_mp", "value": 30},
	"mp_large": {"name": "聚元丹", "type": "consumable", "price": 180, "effect": "heal_mp", "value": 100},
	"antidote": {"name": "解毒散", "type": "consumable", "price": 80, "effect": "cleanse_poison"},
	"revive": {"name": "续命丹", "type": "consumable", "price": 500, "effect": "revive", "value": 50},
	# ── 装备·武器 ──────────────────────────
	"iron_sword": {"name": "铁剑", "type": "weapon", "price": 200, "attack_bonus": 5},
	"fine_sword": {"name": "精铸剑", "type": "weapon", "price": 600, "attack_bonus": 12},
	"broken_sword_relic": {"name": "断剑山庄残剑", "type": "weapon", "price": 0, "attack_bonus": 20, "special": "sect_heirloom"},
	"battle_saber": {"name": "虎骑刀", "type": "weapon", "price": 400, "attack_bonus": 10, "tipo_bonus": 2},
	"mechanism_crossbow": {"name": "天机连弩", "type": "weapon", "price": 800, "attack_bonus": 8, "range_bonus": 1},
	# ── 装备·护甲 ──────────────────────────
	"cloth_robe": {"name": "布袍", "type": "armor", "price": 100, "defense_bonus": 3},
	"leather_armor": {"name": "皮甲", "type": "armor", "price": 300, "defense_bonus": 8},
	"iron_armor": {"name": "铁甲", "type": "armor", "price": 700, "defense_bonus": 18},
	"loyalty_armor": {"name": "忠义之甲", "type": "armor", "price": 0, "defense_bonus": 22, "special": "quest_reward"},
	# ── 特殊道具 ───────────────────────────
	"canal_pass": {"name": "漕运通行令", "type": "key_item", "price": 0, "description": "乘坐漕运船只时免费且速度加快。"},
	"intelligence_book": {"name": "无名情报书", "type": "key_item", "price": 0, "description": "江南客毕生收集的情报汇总，解锁多个隐藏剧情。"},
	"tianjiqipan": {"name": "天机棋盘", "type": "key_item", "price": 0, "description": "罗衡发明，战前可预知一名敌方全部技能。"},
}

# ══════════════════════════════════════════════
# 地点 / 世界地图数据
# ══════════════════════════════════════════════
const LOCATIONS: Dictionary = {
	# ── 九宫格九大区域 ───────────────────────
	"northwest_desert": {
		"name": "西北荒漠",
		"desc": "龙门客栈所在，沙贼横行，古道遗迹多有奇遇。",
		"background": "res://assets/backgrounds/northwest_desert.png",
		"music": "res://assets/audio/bgm_desert.ogg",
		"unlock_condition": "",
		"connections": ["capital_city", "sichuan_qingcheng"],
		"battle_maps": ["desert_plain","desert_ruins"],
		"towns": ["longmen_inn"],
	},
	"hebei_yanshan": {
		"name": "河北燕山",
		"desc": "铁血盟据点，抗金前线，难民遍地。",
		"background": "res://assets/backgrounds/hebei_yanshan.png",
		"music": "res://assets/audio/bgm_war.ogg",
		"unlock_condition": "",
		"connections": ["capital_city", "liaodong"],
		"battle_maps": ["yanshan_plain","yanshan_fortress"],
		"towns": ["yanshan_city"],
	},
	"liaodong": {
		"name": "辽东",
		"desc": "金国边境，危机四伏，亦有壮丽边塞风光。",
		"background": "res://assets/backgrounds/liaodong.png",
		"music": "res://assets/audio/bgm_border.ogg",
		"unlock_condition": "quest:main_5_started",
		"connections": ["hebei_yanshan"],
		"battle_maps": ["snow_plain","border_fortress"],
		"towns": [],
	},
	"sichuan_qingcheng": {
		"name": "蜀中青城",
		"desc": "断剑山庄所在，山峦叠嶂，机关术发源地。",
		"background": "res://assets/backgrounds/sichuan_qingcheng.png",
		"music": "res://assets/audio/bgm_mountain.ogg",
		"unlock_condition": "",
		"connections": ["capital_city", "southern_mountains"],
		"battle_maps": ["mountain_path","sect_courtyard"],
		"towns": ["duanjian_manor"],
	},
	"capital_city": {
		"name": "临渊城（京城）",
		"desc": "北宋政治中心，百万人口，不夜城，朝廷反派云集。",
		"background": "res://assets/backgrounds/capital_city.png",
		"music": "res://assets/audio/bgm_capital.ogg",
		"unlock_condition": "",
		"connections": ["northwest_desert","hebei_yanshan","sichuan_qingcheng","east_sea","jiangnan"],
		"battle_maps": ["city_alley","imperial_gate","underground_arena"],
		"towns": ["linyan_city"],
	},
	"east_sea": {
		"name": "东海蓬莱",
		"desc": "逍遥渡所在，仙山隐世，海上风波。",
		"background": "res://assets/backgrounds/east_sea.png",
		"music": "res://assets/audio/bgm_sea.ogg",
		"unlock_condition": "",
		"connections": ["capital_city", "jiangnan"],
		"battle_maps": ["sea_cliff","harbor_town","sea_battle"],
		"towns": ["penglai_city"],
	},
	"southern_mountains": {
		"name": "岭南十万大山",
		"desc": "药王谷所在，毒瘴之地亦是药材宝库。",
		"background": "res://assets/backgrounds/southern_mountains.png",
		"music": "res://assets/audio/bgm_jungle.ogg",
		"unlock_condition": "quest:main_3_started",
		"connections": ["sichuan_qingcheng", "jiangnan_south"],
		"battle_maps": ["jungle_dense","valley_entrance"],
		"towns": ["yao_wang_valley"],
	},
	"jiangnan": {
		"name": "江南姑苏",
		"desc": "听雨楼所在，水乡最繁华之地，情报网络中心。",
		"background": "res://assets/backgrounds/jiangnan.png",
		"music": "res://assets/audio/bgm_jiangnan.ogg",
		"unlock_condition": "",
		"connections": ["capital_city", "east_sea", "jiangnan_south"],
		"battle_maps": ["watertown_bridge","garden_ambush"],
		"towns": ["gusu_city"],
	},
	"jiangnan_south": {
		"name": "江南南部·临安",
		"desc": "南宋行在，西湖胜景，偏安一隅的繁华。",
		"background": "res://assets/backgrounds/jiangnan_south.png",
		"music": "res://assets/audio/bgm_linan.ogg",
		"unlock_condition": "quest:main_2_started",
		"connections": ["jiangnan", "southern_mountains"],
		"battle_maps": ["linan_street","west_lake_pavilion"],
		"towns": ["linan_city"],
	},
}

# ══════════════════════════════════════════════
# 任务数据库（ID → 基础结构）
# ══════════════════════════════════════════════
const QUESTS: Dictionary = {
	# ── 主线任务 ──────────────────────────
	"main_1": {
		"id": "main_1", "name": "断剑·碎玉",
		"type": "main", "chapter": 1,
		"location": "sichuan_qingcheng",
		"key_npcs": ["shen_tianying","shen_ren","gu_yuming"],
		"prerequisite": [],
		"description": "断剑山庄遭袭，义父失踪，真凶是亲手带出来的人。",
		"reward": {"items": ["broken_sword_relic"], "martial_arts": ["duan_jian_jian_fa","po_jun"], "attribute_points": 3},
	},
	"main_2": {
		"id": "main_2", "name": "听雨·暗流",
		"type": "main", "chapter": 2,
		"location": "jiangnan",
		"key_npcs": ["su_wan","liu_qingyan","su_yun"],
		"prerequisite": [],
		"description": "听雨楼内鬼、漕运走私、西湖密会——情报之战。",
		"reward": {"items": [], "martial_arts": ["willow_step","intelligence_net"], "attribute_points": 3},
	},
	"main_3": {
		"id": "main_3", "name": "百毒·千药",
		"type": "main", "chapter": 3,
		"location": "southern_mountains",
		"key_npcs": ["yao_linger","man_xiang","hua_wujiu"],
		"prerequisite": [],
		"description": "药王谷被控制的珍贵药材与幽冥教的阴谋。",
		"reward": {"items": ["antidote"], "martial_arts": ["healing_palm","detox_field"], "attribute_points": 3},
	},
	"main_4": {
		"id": "main_4", "name": "复国·迷局",
		"type": "main", "chapter": 4,
		"location": "capital_city",
		"key_npcs": ["mu_rong_xue","wan_yan_zongwang","cai_jing"],
		"prerequisite": [],
		"description": "前朝遗孤、金国皇子、腐败宰相，三方博弈。",
		"reward": {"items": ["loyalty_armor"], "martial_arts": ["royal_sword"], "attribute_points": 4},
	},
	"main_5": {
		"id": "main_5", "name": "铁血·燕山",
		"type": "main", "chapter": 5,
		"location": "hebei_yanshan",
		"key_npcs": ["yue_peng","zhong_yanmou","po_tian"],
		"prerequisite": [],
		"description": "燕山保卫战，铁血盟与金国铁骑的最终决战前奏。",
		"reward": {"items": [], "martial_arts": ["tie_xue_pao","iron_fist"], "attribute_points": 4},
	},
	# ── 支线任务（精选触发条件） ────────────
	"sq_07": {
		"id": "sq_07", "name": "司空无迹的选择",
		"type": "side", "chapter": -1,
		"location": "capital_city",
		"key_npcs": ["ye_wu_hen"],
		"prerequisite": ["main_2"],
		"description": "武林盟主候选人向主角坦白，他的真实效忠对象。",
		"reward": {"items": [], "martial_arts": ["traceless_step"], "attribute_points": 2},
	},
	"sq_08": {
		"id": "sq_08", "name": "破天与主角",
		"type": "side", "chapter": -1,
		"location": "hebei_yanshan",
		"key_npcs": ["po_tian"],
		"prerequisite": ["main_5"],
		"description": "超越国境的武道约定——赢的人的道才是对的。",
		"reward": {"items": [], "martial_arts": ["heaven_sunder"], "attribute_points": 3},
	},
	"sq_50": {
		"id": "sq_50", "name": "管理员，再见",
		"type": "side", "chapter": -1,
		"location": "capital_city",
		"key_npcs": [],
		"prerequisite": ["main_1","main_2","main_3","main_4","main_5"],
		"description": "游戏结局前的最后对话，结局由所有选择共同决定。",
		"reward": {"items": [], "martial_arts": [], "attribute_points": 0},
	},
}

# ══════════════════════════════════════════════
# 江湖出身（角色创建可选项）
# ══════════════════════════════════════════════
const ORIGINS: Dictionary = {
	"project_manager": {
		"name": "项目经理穿越者",
		"fixed": true,
		"bonus_stats": {"wuxing": 3},
		"bonus_gold": 50,
		"bonus_items": [],
		"starting_skills": ["basic_punch"],
		"description": "「一个被AI送进来的现代人。你不会武功，但你会想办法。」\n初始悟性+3，起步艰难但成长最快。",
	},
	"sword_disciple": {
		"name": "野路子剑客",
		"fixed": false,
		"bonus_stats": {"gengu": 2, "shenfa": 1},
		"bonus_gold": 100,
		"bonus_items": ["iron_sword"],
		"starting_skills": ["basic_sword", "jian_qi_shan"],
		"description": "野路子习剑，根骨+2，身法+1，开局有铁剑。",
	},
	"physician": {
		"name": "游医弟子",
		"fixed": false,
		"bonus_stats": {"neili": 2, "wuxing": 1},
		"bonus_gold": 80,
		"bonus_items": ["hp_medium", "antidote"],
		"starting_skills": ["healing_palm", "poison_needle"],
		"description": "跟游医学过一段时间，内力+2，悟性+1，医术入门。",
	},
	"merchant_family": {
		"name": "商贾子弟",
		"fixed": false,
		"bonus_stats": {"tipo": 1},
		"bonus_gold": 500,
		"bonus_items": ["hp_small", "hp_small", "hp_small"],
		"starting_skills": ["basic_punch"],
		"description": "出身商贾，家底丰厚，体魄+1，起步资金最多。",
	},
	"constable_family": {
		"name": "捕快世家",
		"fixed": false,
		"bonus_stats": {"shenfa": 2, "gengu": 1},
		"bonus_gold": 120,
		"bonus_items": ["leather_armor"],
		"starting_skills": ["chain_strike", "capture_art"],
		"description": "祖上做过捕快，身法+2，根骨+1，皮甲一件。",
	},
	"buddhist_novice": {
		"name": "还俗僧人",
		"fixed": false,
		"bonus_stats": {"neili": 3},
		"bonus_gold": 30,
		"bonus_items": [],
		"starting_skills": ["iron_fist", "bone_crush"],
		"description": "少林还俗弟子，内力+3，金钱很少，拳法扎实。",
	},
}

# ══════════════════════════════════════════════
# 工具函数
# ══════════════════════════════════════════════
func get_character(char_id: String) -> Dictionary:
	return CHARACTERS.get(char_id, {}).duplicate(true)

func get_martial_art(art_id: String) -> Dictionary:
	return MARTIAL_ARTS.get(art_id, {}).duplicate(true)

func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id, {}).duplicate(true)

func get_location(loc_id: String) -> Dictionary:
	return LOCATIONS.get(loc_id, {}).duplicate(true)

func get_quest(quest_id: String) -> Dictionary:
	return QUESTS.get(quest_id, {}).duplicate(true)

## 根据五维属性计算战斗数值
func calc_battle_stats(base_stats: Dictionary, level: int) -> Dictionary:
	var g: int = base_stats.get("gengu", 5)
	var n: int = base_stats.get("neili", 5)
	var w: int = base_stats.get("wuxing", 5)
	var s: int = base_stats.get("shenfa", 5)
	var t: int = base_stats.get("tipo", 5)
	return {
		"max_hp":    t * 20 + level * 5,
		"max_mp":    n * 15 + level * 3,
		"attack":    int(g * 2.0 + w * 1.5),
		"defense":   int(t * 1.5 + g * 0.5),
		"move_range": mini(6, 2 + s / 4),
		"weapon_range": 2,
		"evade_pct": minf(0.4, s * 0.015),
	}
