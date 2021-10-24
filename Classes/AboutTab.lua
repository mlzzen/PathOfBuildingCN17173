-- Path of Building
--
-- Module: Notes Tab
-- Notes tab for the current build.
--
--local launch, main = ...

local t_insert = table.insert

local AboutTabClass = newClass("AboutTab", "ControlHost", "Control", function(self, build)
	self.ControlHost()
	self.Control()

	self.build = build

	self.lastContent = ""

	self.controls.edit = new("EditControl", {"TOPLEFT",self,"TOPLEFT"}, 8, 48, 0, 60, "", nil, "^%C\t\n", nil, nil, 16)
	self.controls.edit.width = function()
		return self.width - 16
	end
	self.controls.edit.height = function()
		return self.height - 16
	end
	
	self.controls.about = new("ButtonControl", {"TOPLEFT",self,"TOPLEFT"}, 8, 8, 250, 24, "去踩蘑菇论坛反馈", function()
		 OpenURL("https://www.caimogu.net/post/67779.html")
	end)
	self.controls.about2 = new("ButtonControl", {"TOPLEFT",self,"TOPLEFT"}, 268, 8, 250, 24, "去17173论坛反馈", function()
		 OpenURL("http://bbs.17173.com/thread-11316406-1-1.html")
	end)
	
	if self.controls.edit.buf==nil or #self.controls.edit.buf==0 then 
	local scriptPath = GetScriptPath()
	local fileR = io.open(scriptPath.."/Launch.dl", "rb")
	if fileR ~=nil then
			local content = fileR:read("*a")
			fileR:close()
			self.controls.edit.buf=content;
	end
	end
	
	self:SelectControl(self.controls.edit)
	self:SelectControl(self.controls.about)
	self:SelectControl(self.controls.about2)
	
end)

function AboutTabClass:Load()--xml, fileName
	--for _, node in ipairs(xml) do
	--	if type(node) == "string" then
	--		self.controls.edit:SetText(node)
	--	end
	--end
	--self.lastContent = self.controls.edit.buf
	
		 
			
	
end

function AboutTabClass:Save(xml)
	--t_insert(xml, self.controls.edit.buf)
	--self.lastContent = self.controls.edit.buf
end

function AboutTabClass:Draw(viewPort, inputEvents)
	self.x = viewPort.x
	self.y = viewPort.y
	self.width = viewPort.width
	self.height = viewPort.height

	
	self:ProcessControlsInput(inputEvents, viewPort)

	main:DrawBackground(viewPort)

	self:DrawControls(viewPort)

	
	 
end
