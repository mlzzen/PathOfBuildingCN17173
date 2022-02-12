import json

NODE_GROUPS = {
	"Juggernaut": {"x": -10400, "y": 5200},
	"Berserker": {"x": -10400, "y": 3700},
	"Chieftain": {"x": -10400, "y": 2200},
	"Raider": {"x": 10200, "y": 5200},
	"Deadeye": {"x": 10200, "y": 2200},
	"Pathfinder": {"x": 10200, "y": 3700},
	"Occultist": {"x": -1500, "y": -9850},
	"Elementalist": {"x": 0, "y": -9850},
	"Necromancer": {"x": 1500, "y": -9850},
	"Slayer": {"x": 1500, "y": 9800},
	"Gladiator": {"x": -1500, "y": 9800},
	"Champion": {"x": 0, "y": 9800},
	"Inquisitor": {"x": -10400, "y": -2200},
	"Hierophant": {"x": -10400, "y": -3700},
	"Guardian": {"x": -10400, "y": -5200},
	"Assassin": {"x": 10200, "y": -5200},
	"Trickster": {"x": 10200, "y": -3700},
	"Saboteur": {"x": 10200, "y": -2200},
	"Ascendant": {"x": -7800, "y": 7200},
	"勇士": {"x": -10400, "y": 5200},
	"暴徒": {"x": -10400, "y": 3700},
	"酋长": {"x": -10400, "y": 2200},
	"侠客": {"x": 10200, "y": 5200},
	"锐眼": {"x": 10200, "y": 2200},
	"追猎者": {"x": 10200, "y": 3700},
	"秘术家": {"x": -1500, "y": -9850},
	"元素使": {"x": 0, "y": -9850},
	"召唤师": {"x": 1500, "y": -9850},
	"处刑者": {"x": 1500, "y": 9800},
	"卫士": {"x": -1500, "y": 9800},
	"冠军": {"x": 0, "y": 9800},
	"判官": {"x": -10400, "y": -2200},
	"圣宗": {"x": -10400, "y": -3700},
	"守护者": {"x": -10400, "y": -5200},
	"暗影大师": {"x": 10200, "y": -5200},
	"欺诈师": {"x": 10200, "y": -3700},
	"破坏者": {"x": 10200, "y": -2200},
	"升华使徒": {"x": -7800, "y": 7200},
}
ascLocations = {}
GroupOffset = {}


def main():
	with open("./Tools/Tree/tree.json", encoding="utf_8_sig") as f:
		data = json.load(f)
	for group in data["groups"]:
		if (
			data["groups"][group]["nodes"]
			and "ascendancyName" in data["nodes"][data["groups"][group]["nodes"][0]]
		):
			for node in data["groups"][group]["nodes"]:
				if "isAscendancyStart" in data["nodes"][node]:
					ascLocations[data["nodes"][data["groups"][group]["nodes"][0]]["ascendancyName"]] = {"x": data["groups"][group]["x"], "y" : data["groups"][group]["y"]}
					break
	for group in data["groups"]:
		if (
			data["groups"][group]["nodes"]
			and "ascendancyName" in data["nodes"][data["groups"][group]["nodes"][0]]
		):
			asc = data["nodes"][data["groups"][group]["nodes"][0]]["ascendancyName"]
			GroupOffset[group] = {"x": (ascLocations[asc]["x"] - data["groups"][group]["x"]), "y": (ascLocations[asc]["y"] - data["groups"][group]["y"])}
	for group in data["groups"]:
		if (
			data["groups"][group]["nodes"]
			and "ascendancyName" in data["nodes"][data["groups"][group]["nodes"][0]]
		):
			asc = data["nodes"][data["groups"][group]["nodes"][0]]["ascendancyName"]
			data["groups"][group]["x"] = NODE_GROUPS[asc]["x"] - GroupOffset[group]["x"]
			data["groups"][group]["y"] = NODE_GROUPS[asc]["y"] - GroupOffset[group]["y"]

	with open("./Tools/Tree/data_fixed.json", "w", encoding="utf_8_sig") as o:
		o.write(json.dumps(data, indent=4, ensure_ascii=False))
if __name__ == "__main__":
	main()