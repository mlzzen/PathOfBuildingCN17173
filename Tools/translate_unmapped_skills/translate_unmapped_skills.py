import csv

def loadSkillsCSV():
    skill_map = {}
    with open('Tools\\translate_unmapped_skills\\skills_en_cn.csv','r', encoding="utf-8") as csv_file:  
        all_lines = csv.reader(csv_file)  
        for line in all_lines:  
            skill_map[line[0]] = line[1]
    # print(skill_map)
    return skill_map

def translate():
    skill_map = loadSkillsCSV()
    text = ""
    with open("Tools\\translate_unmapped_skills\\input.txt",'r', encoding="utf-8") as f:
        text = f.read()
    for k, v in skill_map.items():
        text = text.replace('"{}",'.format(k), '"{}",'.format(v))
    with open("Tools\\translate_unmapped_skills\\output.txt",'w', encoding="utf-8") as f:
        f.write(text)

translate()