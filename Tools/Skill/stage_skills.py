

from turtle import end_fill


stage_skills = {
    "BladeFlurry": "刀刃乱舞",
    "ChargedDash": "蓄力疾风闪",
    "Cyclone": "旋风斩",
    "Reave": "冲击波",
    "VaalReave": "瓦尔.冲击波",
    "ScourgeArrow": "天灾之箭",
    "Blight": "枯萎",
    "DivineTempest": "圣怨",
    "Flameblast": "烈焰爆破",
    "VaalFlameblast": "瓦尔.烈焰爆破",
    "FrostGlobe": "冰霜护盾",
    "Incinerate": "烧毁",
    "FireBeam": "灼热光线",
    "FrostFury": "寒冬宝珠",
    "MagmaSigil": "忏悔烙印",
    "ImmolationSigil": "冬潮烙印",
    "BloodSacramentUnique": "赤色誓言",
    "DeathWish": "死亡之愿",
    "ChannelledSnipe": "狙击",
    "ExplosiveArrow": "爆炸箭矢",
}

mod_patterns = [
    "\"Multiplier:{}MaxStages\"", "var = \"{}Stage\"", "\"{}StageAfterFirst\"", 
    "\"Multiplier:{}MaxStagesAfterFirst\"", "\"Multiplier:{}Stage\""]

def translate_stage_skill_mods():
    file_list = ["Data/Skills/act_dex.lua", "Data/Skills/act_int.lua", "Data/Skills/act_str.lua"]
    for file in file_list:
        content = ""
        with open(file, "r", encoding="utf-8") as f:
            content = f.read()
        for skill_en, skill_cn in stage_skills.items():
            for p in mod_patterns:
                mod_en = p.format(skill_en)
                mod_cn = p.format(skill_cn)
                content = content.replace(mod_en, mod_cn)
        with open(file, "w", encoding="utf-8") as f:
            f.write(content)

translate_stage_skill_mods()