-- Path of Building
--
-- Class: Edit Control
-- Basic edit control.
--
--local launch, main = ...

local m_max = math.max
local m_min = math.min
local m_floor = math.floor

local function lastLine(str)
	local lastLineIndex = 1
	while true do
		local nextLine = utf8.find(str, "\n", lastLineIndex, true)
		if nextLine then
			lastLineIndex = nextLine + 1
		else
			break
		end
	end
	return utf8.sub(str, lastLineIndex, -1)
end

local function newlineCount(str)
	local count = 0
	local lastLineIndex = 1
	while true do
		local nextLine = utf8.find(str, "\n", lastLineIndex, true)
		if nextLine then
			count = count + 1
			lastLineIndex = nextLine + 1
		else
			return count
		end
	end
end

local EditClass = newClass("EditControl", "ControlHost", "Control", "UndoHandler", "TooltipHost", function(self, anchor, x, y, width, height, init, prompt, filter, limit, changeFunc, lineHeight)
	self.ControlHost()
	self.Control(anchor, x, y, width, height)
	self.UndoHandler()
	self.TooltipHost()
	self:SetText(init or "")
	self.prompt = prompt
	self.filter = filter or "^%w%p "
	self.filterPattern = "["..self.filter.."]"
	self.limit = limit
	self.changeFunc = changeFunc
	self.lineHeight = lineHeight
	self.font = "VAR"
	self.textCol = "^7"
	self.inactiveCol = "^8"
	self.disableCol = "^9"
	self.selCol = "^0"
	self.selBGCol = "^xBBBBBB"
	self.blinkStart = GetTime()
	if self.filter == "%D" or self.filter == "^%-%d" then
		-- Add +/- buttons for integer number edits
		self.isNumeric = true
		local function buttonSize()
			local width, height = self:GetSize()
			return height - 4
		end
		self.controls.buttonDown = new("ButtonControl", {"RIGHT",self,"RIGHT"}, -2, 0, buttonSize, buttonSize, "-", function()
			self:OnKeyUp("DOWN")
		end)
		self.controls.buttonUp = new("ButtonControl", {"RIGHT",self.controls.buttonDown,"LEFT"}, -1, 0, buttonSize, buttonSize, "+", function()
			self:OnKeyUp("UP")
		end)
	end
	self.controls.scrollBarH = new("ScrollBarControl", {"BOTTOMLEFT",self,"BOTTOMLEFT"}, 1, -1, 0, 14, 60, "HORIZONTAL", true)
	self.controls.scrollBarH.width = function()
		local width, height = self:GetSize()
		return width - (self.controls.scrollBarV.enabled and 16 or 2)
	end
	self.controls.scrollBarV = new("ScrollBarControl", {"TOPRIGHT",self,"TOPRIGHT"}, -1, 1, 14, 0, (lineHeight or 0) * 3, "VERTICAL", true)
	self.controls.scrollBarV.height = function()
		local width, height = self:GetSize()
		return height - (self.controls.scrollBarH.enabled and 16 or 2)
	end
	if not lineHeight then
		self.controls.scrollBarH.shown = false
		self.controls.scrollBarV.shown = false
	end
end)

function EditClass:SetText(text, notify)
	self.buf = tostring(text)
	self.caret = utf8.len(self.buf) + 1
	self.sel = nil
	if notify and self.changeFunc then
		self.changeFunc(self.buf)
	end
	self:ResetUndo()
end

function EditClass:IsMouseOver()
	if not self:IsShown() then
		return false
	end
	return self:IsMouseInBounds() or self:GetMouseOverControl()
end

function EditClass:SelectAll()
	self.caret = utf8.len(self.buf) + 1
	self.sel = 1
	self:ScrollCaretIntoView()
end

function EditClass:ReplaceSel(text)
	text = utf8.gsub(text, "\r", "")
	if utf8.match(text, self.filterPattern) then
		return
	end
	local left = m_min(self.caret, self.sel)
	local right = m_max(self.caret, self.sel)
	local newBuf = utf8.sub(self.buf, 1, left - 1) .. text .. utf8.sub(self.buf, right)
	if self.limit and utf8.len(newBuf) > self.limit then
		return
	end
	self.buf = newBuf
	self.caret = left + utf8.len(text)
	self.sel = nil
	self:ScrollCaretIntoView()
	self.blinkStart = GetTime()
	if self.changeFunc then
		self.changeFunc(self.buf)
	end
	self:AddUndoState()
end

function EditClass:Insert(text)
	text = utf8.gsub(text, "\r", "")
	if utf8.match(text, self.filterPattern) then
		return
	end
	local newBuf = utf8.sub(self.buf, 1, self.caret - 1) .. text .. utf8.sub(self.buf, self.caret)
	if self.limit and utf8.len(newBuf) > self.limit then
		return
	end
	self.buf = newBuf
	self.caret = self.caret + utf8.len(text)
	self.sel = nil
	self:ScrollCaretIntoView()
	self.blinkStart = GetTime()
	if self.changeFunc then
		self.changeFunc(self.buf)
	end
	self:AddUndoState()
end

function EditClass:UpdateScrollBars()
	local width, height = self:GetSize()
	local textHeight = self.lineHeight or (height - 4)
	if self.lineHeight then
		self.controls.scrollBarH:SetContentDimension(DrawStringWidth(textHeight, self.font, self.buf) + 2, width - 18)
		self.controls.scrollBarV:SetContentDimension(newlineCount(self.buf.."\n") * textHeight, height - (self.controls.scrollBarH.enabled and 18 or 4))
	else
		self.controls.scrollBarH:SetContentDimension(DrawStringWidth(textHeight, self.font, self.buf) + 2, width - 4 - (self.prompt and DrawStringWidth(textHeight, self.font, self.prompt) + textHeight/2 or 0))
	end
end

function EditClass:ScrollCaretIntoView()
	local width, height = self:GetSize()
	local textHeight = self.lineHeight or (height - 4)
	local pre = utf8.sub(self.buf, 1, self.caret - 1)
	local caretX = DrawStringWidth(textHeight, self.font, lastLine(pre))
	self:UpdateScrollBars()
	self.controls.scrollBarH:ScrollIntoView(caretX - textHeight, textHeight * 2)
	if self.lineHeight then
		local caretY = newlineCount(pre) * textHeight
		self.controls.scrollBarV:ScrollIntoView(caretY, textHeight)
	end
end

function EditClass:MoveCaretVertically(offset)
	local pre = utf8.sub(self.buf, 1, self.caret - 1)
	local caretX = DrawStringWidth(self.lineHeight, self.font, lastLine(pre))
	local caretY = newlineCount(pre) * self.lineHeight
	self.caret = DrawStringCursorIndex(self.lineHeight, self.font, self.buf, caretX + 1, caretY + self.lineHeight/2 + offset)
	self.lastUndoState.caret = self.caret
	self:ScrollCaretIntoView()
	self.blinkStart = GetTime()
end

function EditClass:Draw(viewPort)
	local x, y = self:GetPos()
	local width, height = self:GetSize()
	local enabled = self:IsEnabled()
	local mOver = self:IsMouseOver()
	if not enabled then
		SetDrawColor(0.33, 0.33, 0.33)
	elseif mOver then
		SetDrawColor(1, 1, 1)
	else
		SetDrawColor(0.5, 0.5, 0.5)
	end
	DrawImage(nil, x, y, width, height)
	if not enabled then
		SetDrawColor(0, 0, 0)
	elseif self.hasFocus or mOver then
		if self.lineHeight then
			SetDrawColor(0.1, 0.1, 0.1)
		else
			SetDrawColor(0.15, 0.15, 0.15)
		end
	else
		SetDrawColor(0, 0, 0)
	end
	DrawImage(nil, x + 1, y + 1, width - 2, height - 2)
	local textX = x + 2
	local textY = y + 2
	local textHeight = self.lineHeight or (height - 4)
	if self.prompt then
		if not enabled then
			DrawString(textX, textY, "LEFT", textHeight, self.font, self.disableCol..self.prompt)
		else
			DrawString(textX, textY, "LEFT", textHeight, self.font, self.textCol..self.prompt..":")
		end
		textX = textX + DrawStringWidth(textHeight, self.font, self.prompt) + textHeight/2
	end
	
	if mOver then
		SetDrawLayer(nil, 100)
		self:DrawTooltip(x, y, width, height, viewPort)
		SetDrawLayer(nil, 0)
	end
	
	self:UpdateScrollBars()
	local marginL = textX - x - 2
	local marginR = self.controls.scrollBarV:IsShown() and 14 or 0
	local marginB = self.controls.scrollBarH:IsShown() and 14 or 0
	SetViewport(textX, textY, width - 4 - marginL - marginR, height - 4 - marginB)
	if not self.hasFocus then
		SetDrawColor(self.inactiveCol)
		DrawString(-self.controls.scrollBarH.offset, -self.controls.scrollBarV.offset, "LEFT", textHeight, self.font, self.buf)
		SetViewport()
		self:DrawControls(viewPort)
		return
	end
	if not enabled then
		
		return
	end
	if not IsKeyDown("LEFTBUTTON") then
		self.drag = false
	end
	if self.drag then
		local cursorX, cursorY = GetCursorPos()
		self.caret = DrawStringCursorIndex(textHeight, self.font, self.buf, cursorX - textX + self.controls.scrollBarH.offset, cursorY - textY + self.controls.scrollBarV.offset)
		self.lastUndoState.caret = self.caret
		self:ScrollCaretIntoView()
	end
	textX = -self.controls.scrollBarH.offset
	textY = -self.controls.scrollBarV.offset
	if self.lineHeight then
		local left = m_min(self.caret, self.sel or self.caret)
		local right = m_max(self.caret, self.sel or self.caret)
		local caretX
		SetDrawColor(self.textCol)
		for s, line, e in utf8.gmatch(self.buf.."\n", "()([^\n]*)\n()") do
			textX = -self.controls.scrollBarH.offset
			if left >= e or right <= s then
				DrawString(textX, textY, "LEFT", textHeight, self.font, line)
			end
			if left < e then
				if left > s then
					local pre = utf8.sub(line, 1, left - s)
					DrawString(textX, textY, "LEFT", textHeight, self.font, pre)
					textX = textX + DrawStringWidth(textHeight, self.font, pre)
				end
				if left >= s and left == self.caret then
					caretX, caretY = textX, textY
				end
			end
			if left ~= right and left < e and right > s then
				local sel = self.selCol .. StripEscapes(utf8.sub(line, m_max(1, left - s + 1), m_min(utf8.len(line), right - s)))
				if right >= e then
					sel = sel .. "  "
				end
				local selWidth = DrawStringWidth(textHeight, self.font, sel)
				SetDrawColor(self.selBGCol)
				DrawImage(nil, textX, textY, selWidth, textHeight)
				DrawString(textX, textY, "LEFT", textHeight, self.font, sel)
				SetDrawColor(self.textCol)
				textX = textX + selWidth
			end
			if right >= s and right < e and right == self.caret then
				caretX, caretY = textX, textY
			end
			if right > s then
				if right < e then
					local post = utf8.sub(line, right - s + 1)
					DrawString(textX, textY, "LEFT", textHeight, self.font, post)
					textX = textX + DrawStringWidth(textHeight, self.font, post)
				end
			end
			textY = textY + textHeight
		end
		if caretX then
			if (GetTime() - self.blinkStart) % 1000 < 500 then
				SetDrawColor(self.textCol)
				DrawImage(nil, caretX, caretY, 1, textHeight)
			end
		end
	elseif self.sel and self.sel ~= self.caret then
		local left = m_min(self.caret, self.sel)
		local right = m_max(self.caret, self.sel)
		local pre = self.textCol .. utf8.sub(self.buf, 1, left - 1)
		local sel = self.selCol .. StripEscapes(utf8.sub(self.buf, left, right - 1))
		local post = self.textCol .. utf8.sub(self.buf, right)
		DrawString(textX, textY, "LEFT", textHeight, self.font, pre)
		textX = textX + DrawStringWidth(textHeight, self.font, pre)
		local selWidth = DrawStringWidth(textHeight, self.font, sel)
		SetDrawColor(self.selBGCol)
		DrawImage(nil, textX, textY, selWidth, textHeight)
		DrawString(textX, textY, "LEFT", textHeight, self.font, sel)
		DrawString(textX + selWidth, textY, "LEFT", textHeight, self.font, post)
		if (GetTime() - self.blinkStart) % 1000 < 500 then
			local caretX = (self.caret > self.sel) and textX + selWidth or textX
			SetDrawColor(self.textCol)
			DrawImage(nil, caretX, textY, 1, textHeight)
		end
	else
		local pre = self.textCol .. utf8.sub(self.buf, 1, self.caret - 1)
		local post = utf8.sub(self.buf, self.caret)
		DrawString(textX, textY, "LEFT", textHeight, self.font, pre)
		textX = textX + DrawStringWidth(textHeight, self.font, pre)
		DrawString(textX, textY, "LEFT", textHeight, self.font, post)
		if (GetTime() - self.blinkStart) % 1000 < 500 then
			SetDrawColor(self.textCol)
			DrawImage(nil, textX, textY, 1, textHeight)
		end
	end
	SetViewport()
	self:DrawControls(viewPort)
end

function EditClass:OnFocusGained()
	self.blinkStart = GetTime()
	if not self.drag and not self.selControl and not self.lineHeight then
		self:SelectAll()
	end
end
  
function EditClass:OnKeyDown(key, doubleClick)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	local mOverControl = self:GetMouseOverControl()
	if mOverControl and mOverControl.OnKeyDown then
		self.selControl = mOverControl
		return mOverControl:OnKeyDown(key) and self
	else
		self.selControl = nil
	end
	local shift = IsKeyDown("SHIFT")
	local ctrl =  IsKeyDown("CTRL")
	if key == "LEFTBUTTON" then
		if not self.Object:IsMouseOver() then
			return
		end
		if doubleClick then
			if self.lineHeight then
				if utf8.match(utf8.sub(self.buf, self.caret - 1, self.caret), "^%C\n$") then
					self.caret = self.caret - 1
				end
				while utf8.match(utf8.sub(self.buf, self.caret - 1, self.caret), "[^\n][ \t]") do
					self.caret = self.caret - 1
				end
				local caretChar = utf8.sub(self.buf, self.caret, self.caret)
				if utf8.match(caretChar, "%w") then
					self.sel = self.caret
					while utf8.match(utf8.sub(self.buf, self.sel - 1, self.sel - 1), "%w") do
						self.sel = self.sel - 1
					end
					while utf8.match(utf8.sub(self.buf, self.caret, self.caret), "%w") do
						self.caret = self.caret + 1
					end
				elseif caretChar:match("%S") then
					self.sel = self.caret
					while utf8.sub(self.buf, self.sel - 1, self.sel - 1) == caretChar do
						self.sel = self.sel - 1
					end
					while utf8.sub(self.buf, self.caret, self.caret) == caretChar do
						self.caret = self.caret + 1
					end
				end
			else
				self.sel = 1
				self.caret = utf8.len(self.buf) + 1
			end
			self.lastUndoState.caret = self.caret
			self:ScrollCaretIntoView()
		else
			self.drag = true
			local x, y = self:GetPos()			
			local width, height = self:GetSize()
			local textX = x + 2
			local textY = y + 2
			local textHeight = self.lineHeight or (height - 4)
			if self.prompt then
				textX = textX + DrawStringWidth(textHeight, self.font, self.prompt) + textHeight/2
			end

 
			local cursorX, cursorY = GetCursorPos()		
			
			
			self.caret = DrawStringCursorIndex(textHeight, self.font, self.buf, cursorX - textX + self.controls.scrollBarH.offset, cursorY - textY + self.controls.scrollBarV.offset)

--local fileW = io.open("test.txt", "a+b")

--			fileW:write("x="..x.."&y="..y.."&textX="..textX.."&textY="..textY.."&textHeight="..textHeight.."&cursorX="..cursorX.."&cursorY="..cursorY.."\r\n")

--fileW:write(textHeight..",".. self.font..",".. cursorX - textX + self.controls.scrollBarH.offset..",".. cursorY - textY + self.controls.scrollBarV.offset.."\r\n")
--fileW:write(self.caret.."\r\n")
--			fileW:flush()
--fileW:close()

			self.sel = self.caret
			self.lastUndoState.caret = self.caret
			self:ScrollCaretIntoView()
			self.blinkStart = GetTime()
		end
	elseif key == "ESCAPE" then
		return
	elseif key == "RETURN" then
		if self.lineHeight then
			self:Insert("\n")
		else
			if self.enterFunc then
				self.enterFunc(self.buf)
			end
			return
		end
	elseif key == "a" and ctrl then
		self:SelectAll()
	elseif (key == "c" or key == "x") and ctrl then
		if self.sel and self.sel ~= self.caret then
			local left = m_min(self.caret, self.sel)
			local right = m_max(self.caret, self.sel)
			Copy(utf8.sub(self.buf, left, right - 1))
			if key == "x" then
				self:ReplaceSel("")
			end
		end
	elseif key == "v" and ctrl or key == "RIGHTBUTTON" and self.Object:IsMouseOver() then
		local text = Paste()
		if text then
			if self.pasteFilter then
				text = self.pasteFilter(text)
			end
			if self.sel and self.sel ~= self.caret then
				self:ReplaceSel(text)
			else
				self:Insert(text)
			end
		end
	elseif key == "z" and ctrl then
		self:Undo()
	elseif key == "y" and ctrl then
		self:Redo()
	elseif key == "LEFT" then
		self.sel = shift and (self.sel or self.caret) or nil
		if self.caret > 1 then
			self.caret = self.caret - 1
			self.lastUndoState.caret = self.caret
			self:ScrollCaretIntoView()
			self.blinkStart = GetTime()
		end
	elseif key == "RIGHT" then
		self.sel = shift and (self.sel or self.caret) or nil
		if self.caret <= utf8.len(self.buf) then
			self.caret = self.caret + 1
			self.lastUndoState.caret = self.caret
			self:ScrollCaretIntoView()
			self.blinkStart = GetTime()
		end
	elseif key == "UP" and self.lineHeight then
		self.sel = shift and (self.sel or self.caret) or nil
		self:MoveCaretVertically(-self.lineHeight)
	elseif key == "DOWN" and self.lineHeight then
		self.sel = shift and (self.sel or self.caret) or nil
		self:MoveCaretVertically(self.lineHeight)
	elseif key == "HOME" then
		self.sel = shift and (self.sel or self.caret) or nil
		if self.lineHeight and not ctrl then
			self.caret = self.caret - utf8.len(lastLine(utf8.sub(self.buf, 1, self.caret - 1)))
		else
			self.caret = 1
		end
		self.lastUndoState.caret = self.caret
		self:ScrollCaretIntoView()
		self.blinkStart = GetTime()
	elseif key == "END" then
		self.sel = shift and (self.sel or self.caret) or nil
		if self.lineHeight and not ctrl then
			self.caret = self.caret + utf8.len(utf8.match(utf8.sub(self.buf, self.caret, -1), "[^\n]*"))
		else
			self.caret = utf8.len(self.buf) + 1
		end
		self.lastUndoState.caret = self.caret
		self:ScrollCaretIntoView()
		self.blinkStart = GetTime()
	elseif key == "PAGEUP" and self.lineHeight then
		self.sel = shift and (self.sel or self.caret) or nil
		local width, height = self:GetSize()
		self:MoveCaretVertically(-height + 18)
	elseif key == "PAGEDOWN" and self.lineHeight then
		self.sel = shift and (self.sel or self.caret) or nil
		local width, height = self:GetSize()
		self:MoveCaretVertically(height - 18)
	elseif key == "BACK" then
		if self.sel and self.sel ~= self.caret then
			self:ReplaceSel("")
		elseif self.caret > 1 then
			local len = 1
			if IsKeyDown("CTRL") then
				while self.caret - len > 1 and utf8.match(utf8.len(self.buf, self.caret - len, self.caret - len), "%s") and not utf8.match(utf8.sub(self.buf, self.caret - len - 1, self.caret - len - 1), "\n") do
					len = len + 1
				end
				if utf8.match(utf8.sub(self.buf, self.caret - len, self.caret - len), "%w") then
					while self.caret - len > 1 and utf8.match(utf8.sub(self.buf, self.caret - len - 1, self.caret - len - 1), "%w") do
						len = len + 1
					end
				end
			end
			self.buf = utf8.sub(self.buf, 1, self.caret - 1 - len) .. utf8.sub(self.buf, self.caret)
			self.caret = self.caret - len
			self.sel = nil
			self:ScrollCaretIntoView()
			self.blinkStart = GetTime()
			if self.changeFunc then
				self.changeFunc(self.buf)
			end
			self:AddUndoState()
		end
	elseif key == "DELETE" then
		if self.sel and self.sel ~= self.caret then
			self:ReplaceSel("")
		elseif self.caret <= utf8.len(self.buf) then
			local len = 1
			if IsKeyDown("CTRL") then
				while self.caret + len <= utf8.len(self.buf) and utf8.match(utf8.sub(self.buf, self.caret + len - 1, self.caret + len - 1), "%s") and not utf8.match(utf8.sub(self.buf, self.caret + len, self.caret + len), "\n") do
					len = len + 1
				end
				if utf8.match(utf8.sub(self.buf, self.caret + len - 1, self.caret + len - 1), "%w") then
					while self.caret + len <= utf8.len(self.buf) and utf8.match(utf8.sub(self.buf, self.caret + len, self.caret + len), "%w") do
						len = len + 1
					end
				end
			end
			self.buf = utf8.sub(self.buf, 1, self.caret - 1) .. utf8.sub(self.buf, self.caret + len)
			self.sel = nil
			self.blinkStart = GetTime()
			if self.changeFunc then
				self.changeFunc(self.buf)
			end
			self:AddUndoState()
		end
	elseif key == "TAB" then
		return self.Object:TabAdvance(shift and -1 or 1)
	end
	return self
end

function EditClass:OnKeyUp(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if self.selControl then
		local newSel = self.selControl:OnKeyUp(key)
		if newSel then
			return self
		else
			self.selControl = nil
		end
	end
	if key == "LEFTBUTTON" then
		if self.drag then
			self.drag = false
		end
	elseif self.isNumeric then
		local cur = tonumber(self.buf)
		if key == "WHEELUP" or key == "UP" then
			if cur then
				self:SetText(tostring(cur + (self.numberInc or 1)), true)
			else
				self:SetText("1", true)
			end
		elseif key == "WHEELDOWN" or key == "DOWN" then
			if cur and (self.filter ~= "%D" or cur > 0 )then
				self:SetText(tostring(cur - (self.numberInc or 1)), true)
			else
				self:SetText("0", true)
			end
		end
	elseif key == "WHEELUP" then
		if self.controls.scrollBarV.enabled then
			self.controls.scrollBarV:Scroll(-1)
		else
			self.controls.scrollBarH:Scroll(-1)
		end
	elseif key == "WHEELDOWN" then
		if self.controls.scrollBarV.enabled then
			self.controls.scrollBarV:Scroll(1)
		else
			self.controls.scrollBarH:Scroll(1)
		end
	end
	return self.hasFocus and self
end

function EditClass:OnChar(key)
	if not self:IsShown() or not self:IsEnabled() then
		return
	end
	if key ~= '\b' then
		if self.sel and self.sel ~= self.caret then
			self:ReplaceSel(key)
		else
			self:Insert(key)
		end
	end
	return self
end

function EditClass:CreateUndoState()
	local state = {
		buf = self.buf,
		caret = self.caret,
	}
	self.lastUndoState = state
	return state
end

function EditClass:RestoreUndoState(state)
	self.buf = state.buf
	self.caret = state.caret
	self.sel = nil
	self:ScrollCaretIntoView()
	if self.changeFunc then
		self.changeFunc(self.buf)
	end
	self.lastUndoState = state
end
