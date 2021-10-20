  
import json

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        pass
 
    try:
        import unicodedata
        unicodedata.numeric(s)
        return True
    except (TypeError, ValueError):
        pass
 
    return False

def LoadFromJson(json_file_name):
    with open(json_file_name, 'rb') as f:
        return json.load(f)

def DataToLuaStr(data, retract = 1, iskey=False):
    if isinstance(data, (int, float)):
        return str(data)
    elif isinstance(data, str):
        if iskey and is_number(data):
            return "{}".format(data)
        else:
            return "\"{}\"".format(data)
    elif isinstance(data, list):
        temp_str = "{\n"
        for one_data in data:
            temp_str += "\t" * retract
            temp_str += "{},\n".format(DataToLuaStr(one_data, retract + 1))
        temp_str += "\t" * (retract - 1)
        temp_str += "}"
        return temp_str
    elif isinstance(data, dict):
        temp_str = "{\n"
        for key in data.keys():
            temp_str += "\t" * retract
            temp_str += "[{}] = {},\n".format(DataToLuaStr(key, iskey=True), DataToLuaStr(data[key], retract + 1))
        temp_str += "\t" * (retract - 1)
        temp_str += "}"
        return temp_str
    
    return "nil"

def SaveToLua(data, lua_file_name, note = ''):
    lua_str = "--[[\n{}\n]]\nreturn ".format(note)
    with open(lua_file_name, 'wb') as f:
        lua_str += DataToLuaStr(data)
        f.write(lua_str.encode("utf-8"))

def PasrseJsonToLua(json_file_name, lua_file_name, note = ''):
    SaveToLua(LoadFromJson(json_file_name), lua_file_name, note)

def TestJson2Lua(json_file_name, lua_file_name, note = ''):
    PasrseJsonToLua(json_file_name, lua_file_name, note)

def TestData2Lua(data, lua_file_name, note = ''):
    SaveToLua(data, lua_file_name, note)

if __name__ == "__main__":
    TestJson2Lua("tree.json", "tree.lua", "i am the note1")