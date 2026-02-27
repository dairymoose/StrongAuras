
--------------------------------------------------------------------------------
function MakeMovable(frame)
    frame:SetMovable(true);
    frame:RegisterForDrag("LeftButton");
    frame:SetScript("OnDragStart", function() this:StartMoving() end);
    frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end);
end
--------------------------------------------------------------------------------
local function print(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 0.5)
end
local function SplitString(s,t)
	local l = {n=0}
	local f = function (s)
		l.n = l.n + 1
		l[l.n] = s
	end
	local p = "%s*(.-)%s*"..t.."%s*"
	s = string.gsub(s,"^%s+","")
	s = string.gsub(s,"%s+$","")
	s = string.gsub(s,p,f)
	l.n = l.n + 1
	l[l.n] = string.gsub(s,"(%s%s*)$","")
	return l
end

--------------------------------------------------------------------------------

local auraFrames={}

local function hideAllFrames(auraName)
	if auraFrames[auraName].frame.progress ~= nil then
		auraFrames[auraName].frame.progress:Hide()
	end
	if auraFrames[auraName].frame.text ~= nil then
		auraFrames[auraName].frame.text:Hide()
	end
	if auraFrames[auraName].frame.icon ~= nil then
		auraFrames[auraName].frame.icon:Hide()
	end
end

local function conditionLogic(auraName, frame)
	if StrongAuras_GS["aura"][auraName] == nil or StrongAuras_GS["aura"][auraName]["condition"] == nil then
		frame:Hide()
		return false
	end
	local conditionFn = loadstring(StrongAuras_GS["aura"][auraName]["condition"])
	local resolvedCondition = conditionFn()
	if not resolvedCondition then
		frame:Hide()
		return false
	end
	frame:Show()
	
	return true
end

function BuffDuration(name)
	local buffId=GetSpellIdForName(name)
	local wantedTexture = 0
	for i=1,16 do
		local a,b,c=UnitBuff("player", i)
		if c == buffId then
			wantedTexture = a
		end
	end
	for i=1,16 do
		local a,b=GetPlayerBuff(i)
		texture = GetPlayerBuffTexture(a)
		if (wantedTexture == texture) then
			return GetPlayerBuffTimeLeft(a)
		end
	end
	return 0
end

function HasBuff(unit, name)
	local buffId=GetSpellIdForName(name)
	for i=1,16 do
		local a,b,c=UnitBuff(unit, i)
		if c == buffId then
			return true
		end
	end
	return false
end

function HasDebuff(unit, name)
	local buffId=GetSpellIdForName(name)
	for i=1,16 do
		local a,b,c=UnitDebuff(unit, i)
		if c == buffId then
			return true
		end
	end
	return false
end

function MissingBuff(unit, name)
	return not HasBuff(unit, name)
end

function MissingDebuff(unit, name)
	return not HasDebuff(unit, name)
end

local glow = "Interface\\AddOns\\StrongAuras\\img\\glow"
local function OnAuraUpdate(updateTrigger)
	for a in StrongAuras_GS["aura"] do
		if StrongAuras_GS["aura"][a]["type"] ~= nil then
			local auraName = a
			local frameType = StrongAuras_GS["aura"][auraName]["type"]
			local triggerType = StrongAuras_GS["aura"][auraName]["trigger"]
			if auraFrames[auraName] == nil then
				auraFrames[auraName] = {}
				auraFrames[auraName].frame = CreateFrame("Frame", a.."AuraFrame", UIParent)
				auraFrames[auraName].frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
				auraFrames[auraName].frame:SetWidth(30)
				auraFrames[auraName].frame:SetHeight(30)
				auraFrames[auraName].frame:SetFrameStrata("DIALOG")
			end
			
			if auraFrames[auraName].frame ~= nil then
				
				hideAllFrames(auraName)
				
				if StrongAuras_GS["aura"][auraName]["onload"] ~= nil then
					local onloadFn = loadstring(StrongAuras_GS["aura"][auraName]["onload"])
					onloadFn()
				end
				
				if frameType == "progress" then
					if auraFrames[auraName].frame.progress == nil then
						auraFrames[auraName].frame.progress = CreateFrame("StatusBar", a.."Progress", auraFrames[auraName].frame)
						--auraFrames[auraName].frame.progress = CreateFrame("StatusBar", a.."Progress", UIParent)
						auraFrames[auraName].frame.progress:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", 0, 0)
						--auraFrames[auraName].frame.progress:SetPoint("CENTER")
						auraFrames[auraName].frame.progress:SetMinMaxValues(0, 100)
						auraFrames[auraName].frame.progress:SetValue(50)
						--"Interface\\AddOns\\pfUI\\img\\bar"
						auraFrames[auraName].frame.progress:SetStatusBarTexture("Interface/TargetingFrame/UI-StatusBar")
						auraFrames[auraName].frame.progress.backdrop = CreateFrame("Frame", a.."ProgressBackdrop", auraFrames[auraName].frame.progress)
						auraFrames[auraName].frame.progress.backdrop:SetWidth(100)
						auraFrames[auraName].frame.progress.backdrop:SetHeight(20)
						local borderWidth = 5
						auraFrames[auraName].frame.progress.backdrop:SetPoint("TOPLEFT", auraFrames[auraName].frame.progress, "TOPLEFT", -borderWidth, borderWidth)
						auraFrames[auraName].frame.progress.backdrop:SetPoint("BOTTOMRIGHT", auraFrames[auraName].frame.progress, "BOTTOMRIGHT", borderWidth, -borderWidth)
						auraFrames[auraName].frame.progress.backdrop:SetFrameLevel(auraFrames[auraName].frame.progress:GetFrameLevel())
						
						auraFrames[auraName].frame.progress.spark = CreateFrame("Frame", a.."ProgressSpark", auraFrames[auraName].frame.progress)
						auraFrames[auraName].frame.progress.spark:SetWidth(3)
						auraFrames[auraName].frame.progress.spark:SetHeight(20)
						auraFrames[auraName].frame.progress.spark:SetPoint("LEFT", auraFrames[auraName].frame.progress, "LEFT", 0, 0)
						auraFrames[auraName].frame.progress.spark.texture = auraFrames[auraName].frame.progress.spark:CreateTexture(nil, "BACKGROUND")
						auraFrames[auraName].frame.progress.spark.texture:SetTexture("Interface/TargetingFrame/UI-StatusBar")
						auraFrames[auraName].frame.progress.spark.texture:SetVertexColor(1, 1, 1, 1)
						auraFrames[auraName].frame.progress.spark.texture:SetAllPoints()
						
						
						auraFrames[auraName].frame.progress.updater = function()
									local c = conditionLogic(auraName, auraFrames[auraName].frame.progress)
									if not c then
										return
									end
								
									auraFrames[auraName].frame.progress:SetWidth(tonumber(StrongAuras_GS["aura"][auraName]["w"]))
									auraFrames[auraName].frame.progress:SetHeight(tonumber(StrongAuras_GS["aura"][auraName]["h"]))
								
									local progressColorFn = loadstring(StrongAuras_GS["aura"][auraName]["progressColorFn"])
									local c1,c2,c3,c4 = progressColorFn()
									auraFrames[auraName].frame.progress:SetStatusBarColor(c1,c2,c3,c4)
									auraFrames[auraName].frame.progress.backdrop:SetBackdrop({bgFile = StrongAuras_GS["aura"][auraName]["backdrop"], 
												edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
												tile = true, tileSize = 16, edgeSize = 16, 
												insets = { left = 2, right = 2, top = 2, bottom = 2 }});
									auraFrames[auraName].frame.progress.backdrop:SetBackdropColor(1, 1, 1, StrongAuras_GS["aura"][auraName]["backdropOpacity"]);
									auraFrames[auraName].frame.progress.backdrop:SetBackdropBorderColor(1, 1, 1, StrongAuras_GS["aura"][auraName]["backdropOpacity"]);
								
									local minFn = loadstring(StrongAuras_GS["aura"][auraName]["minfn"])
									local maxFn = loadstring(StrongAuras_GS["aura"][auraName]["maxfn"])
									local valueFn = loadstring(StrongAuras_GS["aura"][auraName]["valuefn"])
									if minFn ~= nil and maxFn ~= nil and valueFn ~= nil then
										local resolvedMin = minFn()
										local resolvedMax = maxFn()
										auraFrames[auraName].frame.progress:SetMinMaxValues(resolvedMin, resolvedMax)
										
										local resolved = valueFn()
										auraFrames[auraName].frame.progress:SetValue(resolved)
										
										--spark logic
										local zeroBasedMin = resolvedMin - resolvedMin
										local zeroBasedMax = resolvedMax - resolvedMin
										local pct = (resolved - resolvedMin)/zeroBasedMax
										local margin = 2
										local sparkColorFn = loadstring(StrongAuras_GS["aura"][auraName]["sparkColorFn"])
										local sc1,sc2,sc3,sc4 = sparkColorFn()
										auraFrames[auraName].frame.progress.spark:SetHeight(tonumber(StrongAuras_GS["aura"][auraName]["h"]))
										auraFrames[auraName].frame.progress.spark.texture:SetVertexColor(sc1,sc2,sc3,sc4)
										auraFrames[auraName].frame.progress.spark:SetPoint("LEFT", auraFrames[auraName].frame.progress, "LEFT", tonumber(StrongAuras_GS["aura"][auraName]["w"])*pct - margin, 0)
										if StrongAuras_GS["aura"][auraName]["showSpark"] then
											auraFrames[auraName].frame.progress.spark:Show()
										else
											auraFrames[auraName].frame.progress.spark:Hide()
										end
									end
								end
						--auraFrames[auraName].frame.progress:SetStatusBarTexture("Interface\\AddOns\\pfUI\\img\\bar")
						
											
						
						--auraFrames[auraName].frame.progress.bg = auraFrames[auraName].frame.progress:CreateTexture(nil, "BORDER")
						--auraFrames[auraName].frame.progress.bg:SetAllPoints(auraFrames[auraName].frame.progress)
						--local opacity = 1.0
						--auraFrames[auraName].frame.progress.bg:SetTexture(1, 1, 1, opacity)
					end
					
					auraFrames[auraName].frame.progress:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", StrongAuras_GS["aura"][a]["x"], StrongAuras_GS["aura"][a]["y"])
					if triggerType=="frame" and updateTrigger=="frame" then
						auraFrames[auraName].frame:SetScript("OnUpdate", auraFrames[auraName].frame.progress.updater)
					end
					--auraFrames[auraName].frame.progress:Show()
				elseif frameType == "text" then
					if auraFrames[auraName].frame.text == nil then
						auraFrames[auraName].frame.text = auraFrames[auraName].frame:CreateFontString("Status", "DIALOG", "GameFontNormal")
						auraFrames[auraName].frame.text:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", 0, 0)
						auraFrames[auraName].frame.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
						auraFrames[auraName].frame.text:SetTextColor(1, 1, 1, 1)
						auraFrames[auraName].frame.text.updater = function()
									local c = conditionLogic(auraName, auraFrames[auraName].frame.text)
									if not c then
										return 
									end
									
									local textFn = loadstring(StrongAuras_GS["aura"][auraName]["textfn"])
									if textFn ~= nil then
										local resolvedTextFn = textFn()
										auraFrames[auraName].frame.text:SetText(resolvedTextFn)
									end
								end
					
					end
					
					auraFrames[auraName].frame.text:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", StrongAuras_GS["aura"][a]["x"], StrongAuras_GS["aura"][a]["y"])
					if triggerType=="frame" and updateTrigger=="frame" then
						auraFrames[auraName].frame:SetScript("OnUpdate", auraFrames[auraName].frame.text.updater)
					end
					--auraFrames[auraName].frame.text:Show()
				elseif frameType == "icon" then
					if auraFrames[auraName].frame.icon == nil then
						auraFrames[auraName].frame.icon = CreateFrame("Frame", a.."Icon", auraFrames[auraName].frame)
						auraFrames[auraName].frame.icon:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", 0, 0)
						auraFrames[auraName].frame.icon.texture = auraFrames[auraName].frame.icon:CreateTexture(nil, "BACKGROUND")
						auraFrames[auraName].frame.icon.updater = function()
									local c = conditionLogic(auraName, auraFrames[auraName].frame.icon)
									if not c then
										return 
									end
									
									local glowFn = loadstring(StrongAuras_GS["aura"][auraName]["glowfn"])
									local colorFn = loadstring(StrongAuras_GS["aura"][auraName]["colorfn"])
									local textureFn = loadstring(StrongAuras_GS["aura"][auraName]["texturefn"])
									if textureFn ~= nil and colorFn ~= nil then
										local resolved = textureFn()
										local c1,c2,c3,c4 = colorFn()
										local resolvedGlow = glowFn()
										auraFrames[auraName].frame.icon.texture:SetTexture(resolved)
										auraFrames[auraName].frame.icon.texture:SetVertexColor(c1, c2, c3, c4)
										auraFrames[auraName].frame.icon.texture:SetAllPoints()
										
										if resolvedGlow then
											auraFrames[auraName].frame.icon:SetBackdrop({
												edgeFile = glow,
												edgeSize = 16,
												insets = { left = 0, right = 0, top = 0, bottom = 0 }});
											auraFrames[auraName].frame.icon:SetBackdropColor(1, 1, 1, 1);
											auraFrames[auraName].frame.icon:SetBackdropBorderColor(1, 1, 1, 1);
											auraFrames[auraName].frame.icon:SetWidth(StrongAuras_GS["aura"][auraName]["w"]+2.5*math.sin(10*GetTime()))
											auraFrames[auraName].frame.icon:SetHeight(StrongAuras_GS["aura"][auraName]["h"]+2.5*math.sin(10*GetTime()))
										else
											auraFrames[auraName].frame.icon:SetBackdrop({});
											auraFrames[auraName].frame.icon:SetBackdropColor(1, 1, 1, 1);
											auraFrames[auraName].frame.icon:SetBackdropBorderColor(1, 1, 1, 1);
											auraFrames[auraName].frame.icon:SetWidth(tonumber(StrongAuras_GS["aura"][auraName]["w"]))
											auraFrames[auraName].frame.icon:SetHeight(tonumber(StrongAuras_GS["aura"][auraName]["h"]))
										end
										
										
									end
								end
						
						
					end
					
					auraFrames[auraName].frame.icon:SetPoint("CENTER", auraFrames[auraName].frame, "CENTER", StrongAuras_GS["aura"][a]["x"], StrongAuras_GS["aura"][a]["y"])
					local cTime = GetTime()
					if triggerType=="frame" and updateTrigger=="frame" then
						auraFrames[auraName].frame:SetScript("OnUpdate", auraFrames[auraName].frame.icon.updater)
					end
					--auraFrames[auraName].frame.icon:Show()
				end
				--end frame types
				
				if triggerType ~= "frame" and updateTrigger=="frame" then
					auraFrames[auraName].frame:SetScript("OnUpdate", nil)
				else
					if updateTrigger~="frame" and triggerType == updateTrigger then
						if frameType == "progress" then
							auraFrames[auraName].frame.progress.updater()
						elseif frameType == "text" then
							auraFrames[auraName].frame.text.updater()
						elseif frameType == "icon" then
							auraFrames[auraName].frame.icon.updater()
						end
					end
				end
			
			end
			
		end
	end
end

function StrongAuras_OnLoad()
	this:RegisterEvent("ADDON_LOADED")
	this:RegisterEvent("PLAYER_REGEN_ENABLED")
	this:RegisterEvent("UNIT_MANA")
	this:RegisterEvent("UNIT_MANA_UPDATE")
	this:RegisterEvent("UNIT_POWER_UPDATE")
	--this:RegisterEvent("PLAYER_REGEN_DISABLED")
	--this:RegisterEvent("UNIT_INVENTORY_CHANGED")
	--this:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	--this:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
	--this:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	--this:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
	--this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	--this:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	--this:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
end

function StrongAuras_OnEvent()
	if event == "ADDON_LOADED" then
		if (string.lower(arg1) == "strongauras") then
			print("StrongAuras strongly loaded")
			if StrongAuras_GS ~= nil and StrongAuras_GS["aura"] ~= nil then
			for a in StrongAuras_GS["aura"] do
				if StrongAuras_GS["aura"][a]["onload"] ~= nil then
					local onloadFn = loadstring(StrongAuras_GS["aura"][a]["onload"])
					onloadFn()
				end
			end
		end
			OnAuraUpdate("frame")
		end
	elseif event == "UNIT_MANA" then
		if StrongAuras_GS ~= nil and StrongAuras_GS["aura"] ~= nil then
			for a in StrongAuras_GS["aura"] do
				if arg1=="player" and StrongAuras_GS["aura"][a]["event_unitMana"] ~= nil and StrongAuras_GS["aura"][a]["event_unitMana"] ~= "nil" then
					local unitManaFn = loadstring(StrongAuras_GS["aura"][a]["event_unitMana"])
					unitManaFn()
				end
				if arg1=="player" and StrongAuras_GS["aura"][a]["trigger"] ~= nil and StrongAuras_GS["aura"][a]["trigger"] == "mana" then
					OnAuraUpdate("mana");
				end
			end
		end
	elseif event == "UNIT_MANA_UPDATE" then
		print('UNIT_MANA_UPDATE')
	elseif event == "UNIT_POWER_UPDATE" then
		print('UNIT_POWER_UPDATE')
	end
end

SLASH_STRONGAURAS1 = "/sa"
SLASH_STRONGAURAS2 = "/strongauras"

base_keys={}
base_keys["type"]=1
base_keys["event_unitMana"]=1
base_keys["onload"]=1

local function createNewAura(auraName)
	if StrongAuras_GS["aura"] == nil then
		StrongAuras_GS["aura"] = {}
	end
	if StrongAuras_GS["aura"][auraName] == nil then
		StrongAuras_GS["aura"][auraName] = {}
		print("Created new aura named: "..auraName)
	end
end

local function printAllAuras()
	print("All auras:")
	if StrongAuras_GS["aura"] ~= nil then
		for a in StrongAuras_GS["aura"] do
			print(a)
		end
	end
end

local function auraAssign(auraName, key, value)
	print(auraName..": set "..key.."="..value)
	if value=="nil" then
		StrongAuras_GS["aura"][auraName][key] = nil
	else
		StrongAuras_GS["aura"][auraName][key] = value
	end
end

local function auraAssignIfNil(auraName, key, value)
	if StrongAuras_GS["aura"][auraName][key] == nil then
		auraAssign(auraName, key, value)
	end
end

local function auraAssignIfDifferent(auraName, key, value)
	if StrongAuras_GS["aura"][auraName] == nil then
		return false
	end
	if StrongAuras_GS["aura"][auraName][key] ~= nil then
		local existing = StrongAuras_GS["aura"][auraName][key]
		if value ~= existing then
			print('Changing old value from: '..key.."="..existing)
			auraAssign(auraName, key, value)
			return true
		end
	end
	
	return false
end

local function auraAssignIfDifferentOrBlank(auraName, key, value)
	if StrongAuras_GS["aura"][auraName] == nil then
		StrongAuras_GS["aura"][auraName] = {}
	else
		if StrongAuras_GS["aura"][auraName][key] == nil then
			StrongAuras_GS["aura"][auraName][key] = value
		else
			auraAssignIfDifferent(auraName, key, value)
		end
		return true
	end
	return false
end

local function assignDefaultValues(auraName, auraType)
	auraAssignIfNil(auraName, "condition", "return true")
	auraAssignIfNil(auraName, "x", 0)
	auraAssignIfNil(auraName, "y", 0)
	auraAssignIfNil(auraName, "trigger", "frame")
	if auraType == "progress" then
		auraAssignIfNil(auraName, "w", "100")
		auraAssignIfNil(auraName, "h", "20")
		auraAssignIfNil(auraName, "backdrop", 'Interface/Tooltips/UI-Tooltip-Background')
		auraAssignIfNil(auraName, "backdropOpacity", 1.0)
		auraAssignIfNil(auraName, "progressColorFn", "return 0,1,0,1")
		auraAssignIfNil(auraName, "sparkColorFn", "return 1,1,1,1")
		auraAssignIfNil(auraName, "showSpark", 'true')
		auraAssignIfNil(auraName, "minfn", 'return 0')
		auraAssignIfNil(auraName, "maxfn", 'return 1')
		auraAssignIfNil(auraName, "valuefn", 'return UnitHealth("target")/UnitHealthMax("target")')
	end
	if auraType == "text" then
		auraAssignIfNil(auraName, "x", 0)
		auraAssignIfNil(auraName, "y", 0)
		auraAssignIfNil(auraName, "textfn", 'return UnitName("target")')
	end
	if auraType == "icon" then
		auraAssignIfNil(auraName, "w", 50)
		auraAssignIfNil(auraName, "h", 50)
		auraAssignIfNil(auraName, "colorfn", 'return 1,1,1,1')
		auraAssignIfNil(auraName, "glowfn", 'return false')
		auraAssignIfNil(auraName, "texturefn", 'return "Interface/Icons/Ability_Warrior_BattleShout"')
	end
end

local editFrame
local function SpawnEditFrame(auraName)
	if editFrame == nil then
		editFrame = CreateFrame("Frame", auraName.."EditFrame", UIParent)
		editFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		editFrame:SetWidth(1300)
		editFrame:SetHeight(700)
		local textWidth = editFrame:GetWidth()*0.9
		local textHeight = editFrame:GetHeight()*0.9
		editFrame:SetFrameStrata("DIALOG")
		
		editFrame:SetBackdrop({bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', 
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 2, right = 2, top = 2, bottom = 2 }});
		editFrame:SetBackdropColor(1, 1, 1, 1);
		editFrame:SetBackdropBorderColor(1, 1, 1, 1);
		
		editFrame.scroll = CreateFrame("ScrollFrame", auraName.."EditFrameScrollframe", editFrame, "UIPanelScrollFrameTemplate")
		editFrame.scroll:SetPoint("CENTER", editFrame, "CENTER", 0, 0)
		--editFrame.scroll:SetPoint("TOPLEFT", editFrame, "TOPLEFT", 100, -100)
		--editFrame.scroll:SetPoint("BOTTOMRIGHT", editFrame, -100, 100)
		editFrame.scroll:SetWidth(textWidth)
		editFrame.scroll:SetHeight(textHeight)
		
		editFrame.scrollchild = CreateFrame("Frame", auraName.."EditFrameScrollchild", editFrame.scroll)
		--editFrame.scrollchild:SetPoint("CENTER", editFrame, "CENTER", 0, 0)
		editFrame.scrollchild:SetPoint("TOPLEFT", editFrame, "TOPLEFT", 0, 0)
		editFrame.scrollchild:SetWidth(textWidth)
		editFrame.scrollchild:SetHeight(textHeight)
		editFrame.scroll:SetScrollChild(editFrame.scrollchild)
		
		local scrollableAreaScale = 4
		editFrame.text = CreateFrame("EditBox", auraName.."EditFrameEditbox", editFrame.scrollchild)
		editFrame.text:SetPoint("TOPLEFT", editFrame.scrollchild, "TOPLEFT", 0, 0)
		editFrame.text:SetWidth(textWidth)
		editFrame.text:SetHeight(textHeight*scrollableAreaScale)
		editFrame.text:SetMultiLine(true)
		editFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 12)
		--editFrame.text:SetFont("Interface\\AddOns\\StrongAuras\\fonts\\PTSansNarrow-Regular.ttf", 12)
		editFrame.text:SetJustifyH("LEFT")
		--editFrame.text:SetJustifyV("CENTER")
		editFrame.text:SetMaxLetters(99999)
		editFrame.text:SetScript("OnEscapePressed", function(self) editFrame:Hide() end)
		
		--create font
		--local editTextFont = editFrame.text:CreateFontString("Status", "DIALOG", "GameFontNormal")
		--editTextFont:SetPoint("CENTER", editFrame.text, "CENTER", 0, 0)
		--editTextFont:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		--editTextFont:SetTextColor(1, 1, 1, 1)
		
		--create editor backdrop
		editFrame.text.backdrop = CreateFrame("Frame", auraName.."EditBackdrop", editFrame.text)
		editFrame.text.backdrop:SetWidth(editFrame.text:GetWidth())
		editFrame.text.backdrop:SetHeight(editFrame.text:GetHeight())
		local borderWidth = 5
		editFrame.text.backdrop:SetPoint("TOPLEFT", editFrame.text, "TOPLEFT", -borderWidth, borderWidth)
		editFrame.text.backdrop:SetPoint("BOTTOMRIGHT", editFrame.text, "BOTTOMRIGHT", borderWidth, -borderWidth)
		editFrame.text.backdrop:SetFrameLevel(editFrame.text:GetFrameLevel())
		
		editFrame.text.backdrop:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8x8', 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			edgeSize = 14, 
			insets = { left = 0, right = 0, top = 0, bottom = 0 }});
		editFrame.text.backdrop:SetBackdropColor(0, 0, 0, 0.0);
		editFrame.text.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		
		
		editFrame.confirm = CreateFrame("Button", auraName.."EditFrameConfirm", editFrame, "UIPanelButtonTemplate")
		editFrame.confirm:SetPoint("BOTTOM", editFrame, "BOTTOM", -25, 10)
		editFrame.confirm:SetWidth(50)
		editFrame.confirm:SetHeight(20)
		editFrame.confirm:SetText("Confirm")
		editFrame.confirm:SetScript("OnClick", function()
			local edited = editFrame.text:GetText()
			local lineSplit = SplitString(edited, "\n")
			local diffCount = 0
			
			if StrongAuras_GS["aura"][auraName] ~= nil then
				StrongAuras_GS["aura"][auraName] = {}
			end
			
			for no,line in lineSplit do
				local ch = string.sub(line, 1, 2)
				if ch ~= '--' then
					local equalIdx = string.find(line, "=")
					if equalIdx ~= nil then
						local key = string.sub(line, 1, equalIdx-1)
						local value = string.sub(line, equalIdx+1, string.len(line))
						if key ~= nil and value ~= nil then
							local isDifferent = auraAssignIfDifferentOrBlank(auraName, key, value)
							
							if isDifferent then
								diffCount = diffCount + 1
							end
						end
					end
				end
			end
			OnAuraUpdate("frame");
			editFrame:Hide()
		end)
		--editFrame.confirm:RegisterForClicks("AnyDown", "AnyUp")
		
		editFrame.cancel = CreateFrame("Button", auraName.."EditFrameCancel", editFrame, "UIPanelButtonTemplate")
		editFrame.cancel:SetPoint("BOTTOM", editFrame, "BOTTOM", 25, 10)
		editFrame.cancel:SetWidth(50)
		editFrame.cancel:SetHeight(20)
		editFrame.cancel:SetText("Cancel")
		editFrame.cancel:SetScript("OnClick", function()
			editFrame:Hide()
		end)
	end
	
	local editText = ""
	editText = editText.."-- Aura "..auraName.."\n"
	for k,v in StrongAuras_GS["aura"][auraName] do
		editText = editText..k.."="..v.."\n"
	end
	editText = editText.."\n"
	editFrame.text:SetText(editText)
	editFrame:Show()
	--editFrame.cancel:RegisterForClicks("AnyDown", "AnyUp")
end

local function printPropertiesForAura(auraName)
	print("All properties for aura: "..auraName)
	local indent = "    "
	for k,v in StrongAuras_GS["aura"][auraName] do
		print(indent..k.."="..v)
	end
end

local function editExistingAura(auraName)
	if StrongAuras_GS["aura"][auraName] == nil then
		print("No aura exists by the name of "..auraName)
	else
		SpawnEditFrame(auraName)
	end
end

local editorFrameX = 30
local editorFrameY = 0
local editorStartY = -30
local editorFieldExtraY = 0
local fieldGap = 22
local extraLineGap = 12
local borderWidthTextField = 5
local editorFrames = {}
local auraEditor

local textSizeMonospace = 10
local charsPerLine = 129
local function lineCountForEditBox(editBox)
	local lineCount = 0
	local txt = editBox:GetText()
	for i=1,string.len(txt) do
		local ch = string.sub(txt, i, i)
		if ch == '\n' then
			lineCount = lineCount + 1
		end
	end
	lineCount = lineCount + math.floor(string.len(txt)/charsPerLine)
	return lineCount
end

local function auraEditorSetPoints(auraName, parent)
	if editorFrames[auraName] == nil then
		editorFrames[auraName] = {}
	end
	local pointEditorFieldCount = 0
	local pointEditorFieldExtraY = 0
	for k,v in StrongAuras_GS["aura"][auraName] do
		if editorFrames[auraName].text == nil then
			editorFrames[auraName].text = {}
		end
		pointEditorFieldCount = pointEditorFieldCount + 1
		editorFrameY = pointEditorFieldCount*-fieldGap + editorStartY + pointEditorFieldExtraY

		editorFrames[auraName].text[pointEditorFieldCount]:SetPoint("TOPLEFT", parent, "TOPLEFT", editorFrameX, editorFrameY)
		editorFrames[auraName].text[pointEditorFieldCount].label:SetPoint("TOPLEFT", editorFrames[auraName].text[pointEditorFieldCount], "TOPLEFT", 0, 0)
		editorFrames[auraName].text[pointEditorFieldCount].input:SetPoint("TOPLEFT", editorFrames[auraName].text[pointEditorFieldCount], "TOPLEFT", 150, 0)
		editorFrames[auraName].text[pointEditorFieldCount].input.backdrop:SetPoint("TOPLEFT", editorFrames[auraName].text[pointEditorFieldCount].input, "TOPLEFT", -borderWidthTextField, borderWidthTextField)
		editorFrames[auraName].text[pointEditorFieldCount].input.backdrop:SetPoint("BOTTOMRIGHT", editorFrames[auraName].text[pointEditorFieldCount].input, "BOTTOMRIGHT", borderWidthTextField, -borderWidthTextField)
		pointEditorFieldExtraY = pointEditorFieldExtraY + -lineCountForEditBox(editorFrames[auraName].text[pointEditorFieldCount].input)*extraLineGap
	end
end

local newAuraMakerFrame
local function createNewAuraOfTypeWithDefaults(auraName, auraType)
	if auraName ~= nil and string.len(auraName) > 0 then
		if StrongAuras_GS["aura"][auraName] == nil then
			createNewAura(auraName)
			auraAssignIfDifferent(auraName, "type", auraType)
			assignDefaultValues(auraName, auraType)
			return true
		end
	end
	
	return false
end

local function hideAllChildren(parent)
	if parent:GetChildren() ~= nil then
		for i=1, select("#", parent:GetChildren()) do
			local childFrame = select(i, parent:GetChildren())
			childFrame:Hide()
		end
	end
end

local uiFrame
local function deleteAuraByName(auraName)
	if StrongAuras_GS["aura"] == nil then
		StrongAuras_GS["aura"] = {}
	end
	if StrongAuras_GS["aura"][auraName] ~= nil then
		StrongAuras_GS["aura"][auraName] = nil
		if uiFrame.existingAuraButtons[auraName] ~= nil then
			uiFrame.existingAuraButtons[auraName]:Hide()
			uiFrame.existingAuraButtons[auraName] = nil
		end
		print("Deleted aura named: "..auraName)
	end
end

local deleteCounter = {}
local function createAuraEditor(auraName, parent)
	if StrongAuras_GS["aura"][auraName] == nil then
		print('No such aura named '..auraName)
		return false
	end

	if editorFrames[auraName] == nil then
		editorFrames[auraName] = {}
		editorFrames[auraName].fieldCount = 0
	end
	
	hideAllChildren(parent)
	
	--for a in StrongAuras_GS["aura"] do
	--	for k,v in StrongAuras_GS["aura"][a] do
	--		if editorFrames[a] ~= nil and editorFrames[a].text ~= nil then
	--			local pointEditorFieldCount = 0
	--			for i=1,editorFrames[auraName].fieldCount do
	--				editorFrames[a].text[i]:Hide()
	--			end
	--		end
	--	end
	--end
	editorFieldExtraY = 0
	local editBoxWidth = 800
	if editorFrames[auraName].text == nil then
		for k,v in StrongAuras_GS["aura"][auraName] do
			if editorFrames[auraName].text == nil then
				editorFrames[auraName].text = {}
			end
			editorFrames[auraName].fieldCount = editorFrames[auraName].fieldCount + 1
			editorFrameY = editorFrames[auraName].fieldCount*-fieldGap + editorStartY + editorFieldExtraY
			
			editorFrames[auraName].text[editorFrames[auraName].fieldCount] = CreateFrame("Frame", auraName.."AuraFrame", parent)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount]:SetPoint("TOPLEFT", parent, "TOPLEFT", editorFrameX, editorFrameY)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount]:SetWidth(300)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount]:SetHeight(30)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount]:EnableMouse(false)
			
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].label = editorFrames[auraName].text[editorFrames[auraName].fieldCount]:CreateFontString("Status", "DIALOG", "GameFontNormal")
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].label:SetPoint("TOPLEFT", editorFrames[auraName].text[editorFrames[auraName].fieldCount], "TOPLEFT", 0, 0)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].label:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].label:SetTextColor(1, 1, 1, 1)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].label:SetText(k)
			
			--editorFrames[auraName].text[editorFrames[auraName].fieldCount].input = CreateFrame("EditBox", auraName.."EditorFrameEditbox"..editorFrames[auraName].fieldCount, editorFrames[auraName].text[editorFrames[auraName].fieldCount])
			
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input = CreateFrame("EditBox", auraName.."EditorFrameEditbox"..editorFrames[auraName].fieldCount, parent)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetPoint("TOPLEFT", editorFrames[auraName].text[editorFrames[auraName].fieldCount], "TOPLEFT", 150, 0)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetAutoFocus(false)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetWidth(editBoxWidth)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetHeight(30)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetMultiLine(true)
			--editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetFont("Fonts\\FRIZQT__.TTF", 12)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetFont("Interface\\AddOns\\StrongAuras\\fonts\\FiraMono-Medium.ttf", textSizeMonospace)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetJustifyH("LEFT")
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetMaxLetters(99999)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:EnableMouse(true)
			--editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetScript("OnEnter", function(self) print('focus up') end)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetText(v)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetScript("OnEscapePressed", function(self) uiFrame:Hide() end)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:SetScript("OnTextChanged", function(self) auraEditorSetPoints(auraName, parent) end)
			editorFieldExtraY = editorFieldExtraY + -math.floor(string.len(v)/85)*extraLineGap
			--editorFieldExtraY = 0
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop = CreateFrame("Frame", auraName.."EditorBackdrop"..editorFrames[auraName].fieldCount, editorFrames[auraName].text[editorFrames[auraName].fieldCount].input)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetWidth(100)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetHeight(20)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetPoint("TOPLEFT", editorFrames[auraName].text[editorFrames[auraName].fieldCount].input, "TOPLEFT", -borderWidthTextField, borderWidthTextField)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetPoint("BOTTOMRIGHT", editorFrames[auraName].text[editorFrames[auraName].fieldCount].input, "BOTTOMRIGHT", borderWidthTextField, -borderWidthTextField)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetFrameLevel(editorFrames[auraName].text[editorFrames[auraName].fieldCount].input:GetFrameLevel()-1)
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8x8', 
				edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
				edgeSize = 14, 
				insets = { left = 0, right = 0, top = 0, bottom = 0 }});
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetBackdropColor(0, 0, 0, 0.0);
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
			editorFrames[auraName].text[editorFrames[auraName].fieldCount].input.backdrop:EnableMouse(false)
		end
	end
	
	local keyCounter = 0
	for k,v in StrongAuras_GS["aura"][auraName] do
		keyCounter = keyCounter + 1
		editorFrames[auraName].text[keyCounter].label:SetText(k)
		editorFrames[auraName].text[keyCounter].input:SetText(v)
	end
	
	if editorFrames[auraName].text ~= nil then
		for i=1,editorFrames[auraName].fieldCount do
			editorFrames[auraName].text[i]:Show()
			editorFrames[auraName].text[i].label:Show()
			editorFrames[auraName].text[i].input:Show()
		end
	end
	
	uiFrame.save:SetScript("OnClick", function()
			local pointEditorFieldCount = 0
			local pointEditorFieldExtraY = 0
			for k,v in StrongAuras_GS["aura"][auraName] do
				if editorFrames[auraName].text == nil then
					editorFrames[auraName].text = {}
				end
				pointEditorFieldCount = pointEditorFieldCount + 1
				local newText = editorFrames[auraName].text[pointEditorFieldCount].input:GetText()
				auraAssignIfDifferent(auraName, k, newText)
				--StrongAuras_GS["aura"][auraName][k] = newText
			end
			OnAuraUpdate("frame");
		end)
		
	uiFrame.delete:SetScript("OnClick", function()
			if deleteCounter[auraName] == nil then
				deleteCounter[auraName] = 0
			end
			deleteCounter[auraName] = deleteCounter[auraName] + 1
			if deleteCounter[auraName] >= 2 then
				deleteCounter[auraName] = nil
				deleteAuraByName(auraName)
				hideAllChildren(parent)
			end
		end)
	
	return true
end

local xValue = 0
local yValue = -20
local yGap = 21
local minWidth = 15
local function refreshExistingButtons()
	if StrongAuras_GS["aura"] ~= nil then
		if uiFrame.existingAuraButtons == nil then
			uiFrame.existingAuraButtons = {}
		end
		local counter = 0
		for a in StrongAuras_GS["aura"] do
			local auraName = a
			if uiFrame.existingAuraButtons[auraName] == nil then
				uiFrame.existingAuraButtons[auraName] = CreateFrame("Button", "Aura"..auraName.."EditButton", uiFrame.scrollchild, "UIPanelButtonTemplate")
				yValue = yValue - yGap
				uiFrame.existingAuraButtons[auraName]:SetPoint("CENTER", uiFrame.scrollchild, "TOP", xValue, yValue)
				local dynamicWidth = string.len(auraName)*7.5
				if dynamicWidth < minWidth then
					dynamicWidth = minWidth
				end
				uiFrame.existingAuraButtons[auraName]:SetWidth(dynamicWidth)
				uiFrame.existingAuraButtons[auraName]:SetHeight(20)
				uiFrame.existingAuraButtons[auraName]:SetText(auraName)
				uiFrame.existingAuraButtons[auraName]:SetScript("OnClick", function()
					if not createAuraEditor(auraName, uiFrame.scrollchild2) then
						uiFrame.existingAuraButtons[auraName]:Hide()
					end
				end)
			end
		end
	end
end

local function createNewAuraMakerFrame(parent)
	hideAllChildren(parent)

	if newAuraMakerFrame == nil then
		local buttonY = 60

		newAuraMakerFrame = CreateFrame("Frame", "NewAuraMakerFrame", parent)
		newAuraMakerFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)
		newAuraMakerFrame:SetWidth(300)
		newAuraMakerFrame:SetHeight(300)
		
		newAuraMakerFrame.namelabel = newAuraMakerFrame:CreateFontString("Status", "DIALOG", "GameFontNormal")
		newAuraMakerFrame.namelabel:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.namelabel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		newAuraMakerFrame.namelabel:SetTextColor(1, 1, 1, 1)
		newAuraMakerFrame.namelabel:SetText("Aura Name")
		
		buttonY = buttonY - 30
		newAuraMakerFrame.auraname = CreateFrame("EditBox", "NewAuraMakerEditbox", newAuraMakerFrame)
		newAuraMakerFrame.auraname:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.auraname:SetAutoFocus(false)
		newAuraMakerFrame.auraname:SetWidth(500)
		newAuraMakerFrame.auraname:SetHeight(30)
		newAuraMakerFrame.auraname:SetMultiLine(true)
		newAuraMakerFrame.auraname:SetFont("Interface\\AddOns\\StrongAuras\\fonts\\FiraMono-Medium.ttf", 12)
		newAuraMakerFrame.auraname:SetJustifyH("LEFT")
		newAuraMakerFrame.auraname:SetMaxLetters(99999)
		newAuraMakerFrame.auraname:EnableMouse(true)
		newAuraMakerFrame.auraname:SetScript("OnEscapePressed", function(self) uiFrame:Hide() end)
		newAuraMakerFrame.auraname.backdrop = CreateFrame("Frame", "AuraMakerNameBackdrop", newAuraMakerFrame.auraname)
		newAuraMakerFrame.auraname.backdrop:SetWidth(100)
		newAuraMakerFrame.auraname.backdrop:SetHeight(20)
		newAuraMakerFrame.auraname.backdrop:SetPoint("TOPLEFT", newAuraMakerFrame.auraname, "TOPLEFT", -borderWidthTextField, borderWidthTextField)
		newAuraMakerFrame.auraname.backdrop:SetPoint("BOTTOMRIGHT", newAuraMakerFrame.auraname, "BOTTOMRIGHT", borderWidthTextField, -borderWidthTextField)
		newAuraMakerFrame.auraname.backdrop:SetFrameLevel(newAuraMakerFrame.auraname:GetFrameLevel()-1)
		newAuraMakerFrame.auraname.backdrop:SetBackdrop({bgFile = 'Interface/Buttons/WHITE8x8', 
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
			edgeSize = 14, 
			insets = { left = 0, right = 0, top = 0, bottom = 0 }});
		newAuraMakerFrame.auraname.backdrop:SetBackdropColor(0, 0, 0, 0.0);
		newAuraMakerFrame.auraname.backdrop:SetBackdropBorderColor(0.3, 0.3, 0.3, 1.0);
		newAuraMakerFrame.auraname.backdrop:EnableMouse(false)
		
		buttonY = buttonY - 30
		newAuraMakerFrame.typelabel = newAuraMakerFrame:CreateFontString("Status", "DIALOG", "GameFontNormal")
		newAuraMakerFrame.typelabel:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.typelabel:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		newAuraMakerFrame.typelabel:SetTextColor(1, 1, 1, 1)
		newAuraMakerFrame.typelabel:SetText("Aura Type")
		
		buttonY = buttonY - 30
		newAuraMakerFrame.icon = CreateFrame("Button", "IconButton", newAuraMakerFrame, "UIPanelButtonTemplate")
		newAuraMakerFrame.icon:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.icon:SetWidth(80)
		newAuraMakerFrame.icon:SetHeight(20)
		newAuraMakerFrame.icon:SetText("Icon")
		newAuraMakerFrame.icon:SetScript("OnClick", function()
			if createNewAuraOfTypeWithDefaults(newAuraMakerFrame.auraname:GetText(), "icon") then
				hideAllChildren(parent)
				refreshExistingButtons()
			end
		end)
		
		buttonY = buttonY - 30
		newAuraMakerFrame.progress = CreateFrame("Button", "ProgressButton", newAuraMakerFrame, "UIPanelButtonTemplate")
		newAuraMakerFrame.progress:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.progress:SetWidth(80)
		newAuraMakerFrame.progress:SetHeight(20)
		newAuraMakerFrame.progress:SetText("Progress")
		newAuraMakerFrame.progress:SetScript("OnClick", function()
			if createNewAuraOfTypeWithDefaults(newAuraMakerFrame.auraname:GetText(), "progress") then
				hideAllChildren(parent)
				refreshExistingButtons()
			end
		end)
		
		buttonY = buttonY - 30
		newAuraMakerFrame.text = CreateFrame("Button", "TextButton", newAuraMakerFrame, "UIPanelButtonTemplate")
		newAuraMakerFrame.text:SetPoint("CENTER", newAuraMakerFrame, "CENTER", 0, buttonY)
		newAuraMakerFrame.text:SetWidth(80)
		newAuraMakerFrame.text:SetHeight(20)
		newAuraMakerFrame.text:SetText("Text")
		newAuraMakerFrame.text:SetScript("OnClick", function()
			if createNewAuraOfTypeWithDefaults(newAuraMakerFrame.auraname:GetText(), "text") then
				hideAllChildren(parent)
				refreshExistingButtons()
			end
		end)
	end
	
	newAuraMakerFrame:Show()
	uiFrame.save:SetScript("OnClick", nil)
end

local function showUi()
	if uiFrame == nil then
		uiFrame = CreateFrame("Frame", "StrongAurasFrame", UIParent)
		uiFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		uiFrame:SetWidth(1300)
		uiFrame:SetHeight(700)
		uiFrame:SetFrameStrata("DIALOG")
		uiFrame:EnableMouse(false)
		--uiFrame:SetScript("OnEscapePressed", function(self) uiFrame:Hide() end)
		
		uiFrame:SetBackdrop({bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', 
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 2, right = 2, top = 2, bottom = 2 }});
		uiFrame:SetBackdropColor(1, 1, 1, 1);
		uiFrame:SetBackdropBorderColor(1, 1, 1, 1);
		uiFrame:EnableMouse(true)
		uiFrame:SetMovable(true)
		uiFrame:RegisterForDrag(true)
		uiFrame:SetScript("OnDragStart", function() uiFrame:StartMoving() end)
		uiFrame:SetScript("OnDragStop", function() uiFrame:StopMovingOrSizing() end)
		
		local rightSideWidth = 0.8
		local textWidth = uiFrame:GetWidth()*(1-rightSideWidth)
		local textHeight = uiFrame:GetHeight()*0.99
		uiFrame.scroll = CreateFrame("ScrollFrame", "StrongAurasFrameScrollframe1", uiFrame, "UIPanelScrollFrameTemplate")
		uiFrame.scroll:SetPoint("TOPLEFT", uiFrame, "TOPLEFT", 0, 0)
		--uiFrame.scroll:SetPoint("TOPLEFT", uiFrame, "TOPLEFT", 100, -100)
		--uiFrame.scroll:SetPoint("BOTTOMRIGHT", uiFrame, -100, 100)
		uiFrame.scroll:SetWidth(textWidth)
		uiFrame.scroll:SetHeight(textHeight)
		uiFrame.scroll:SetBackdrop({bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', 
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 2, right = 2, top = 2, bottom = 2 }});
		uiFrame.scroll:SetBackdropColor(1, 1, 1, 1);
		uiFrame.scroll:SetBackdropBorderColor(1, 1, 1, 1);
		
		uiFrame.scrollchild = CreateFrame("Frame", "StrongAurasFrameScrollchild1", uiFrame.scroll)
		--uiFrame.scrollchild:SetPoint("CENTER", uiFrame, "CENTER", 0, 0)
		uiFrame.scrollchild:SetPoint("CENTER", uiFrame, "CENTER", 0, 0)
		uiFrame.scrollchild:SetWidth(textWidth)
		uiFrame.scrollchild:SetHeight(textHeight)
		uiFrame.scroll:SetScrollChild(uiFrame.scrollchild)
		
		local textWidth2 = uiFrame:GetWidth()*rightSideWidth - 30
		local textHeight2 = uiFrame:GetHeight()*0.97
		uiFrame.scroll2 = CreateFrame("ScrollFrame", "StrongAurasFrameScrollframe2", uiFrame, "UIPanelScrollFrameTemplate")
		uiFrame.scroll2:SetPoint("TOPLEFT", uiFrame, "TOPLEFT", textWidth + 20, 0)
		--uiFrame.scroll:SetPoint("TOPLEFT", uiFrame, "TOPLEFT", 100, -100)
		--uiFrame.scroll:SetPoint("BOTTOMRIGHT", uiFrame, -100, 100)
		uiFrame.scroll2:SetWidth(textWidth2)
		uiFrame.scroll2:SetHeight(textHeight2)
		uiFrame.scroll2:SetBackdrop({bgFile = 'Interface/DialogFrame/UI-DialogBox-Background', 
			edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", 
			tile = true, tileSize = 16, edgeSize = 16, 
			insets = { left = 2, right = 2, top = 2, bottom = 2 }});
		uiFrame.scroll2:SetBackdropColor(1, 1, 1, 1);
		uiFrame.scroll2:SetBackdropBorderColor(1, 1, 1, 1);
		uiFrame.scroll2:EnableMouse(false)
		
		uiFrame.scrollchild2 = CreateFrame("Frame", "StrongAurasFrameScrollchild2", uiFrame.scroll2)
		--uiFrame.scrollchild:SetPoint("CENTER", uiFrame, "CENTER", 0, 0)
		uiFrame.scrollchild2:SetPoint("TOPLEFT", uiFrame, "TOPLEFT", 0, 0)
		uiFrame.scrollchild2:SetWidth(textWidth2)
		uiFrame.scrollchild2:SetHeight(textHeight2)
		uiFrame.scrollchild2:EnableMouse(true)
		uiFrame.scroll2:SetScrollChild(uiFrame.scrollchild2)
		
		uiFrame.newAura = CreateFrame("Button", "NewAuraButton", uiFrame.scrollchild, "UIPanelButtonTemplate")
		uiFrame.newAura:SetPoint("CENTER", uiFrame.scrollchild, "TOP", xValue, yValue)
		uiFrame.newAura:SetWidth(80)
		uiFrame.newAura:SetHeight(20)
		uiFrame.newAura:SetText("[New Aura]")
		uiFrame.newAura:SetScript("OnClick", function()
			createNewAuraMakerFrame(uiFrame.scrollchild2)
		end)
		
		uiFrame.save = CreateFrame("Button", "StrongAurasFrameCancel", uiFrame, "UIPanelButtonTemplate")
		uiFrame.save:SetPoint("BOTTOM", uiFrame, "BOTTOM", 0, 5)
		uiFrame.save:SetWidth(50)
		uiFrame.save:SetHeight(20)
		uiFrame.save:SetText("Save")
		
		uiFrame.delete = CreateFrame("Button", "StrongAurasFrameCancel", uiFrame, "UIPanelButtonTemplate")
		uiFrame.delete:SetPoint("BOTTOM", uiFrame, "BOTTOM", -320, 5)
		uiFrame.delete:SetWidth(50)
		uiFrame.delete:SetHeight(20)
		uiFrame.delete:SetText("Delete")

		uiFrame.cancel = CreateFrame("Button", "StrongAurasFrameCancel", uiFrame, "UIPanelButtonTemplate")
		uiFrame.cancel:SetPoint("TOPRIGHT", uiFrame, "TOPRIGHT", -5, -3)
		uiFrame.cancel:SetWidth(20)
		uiFrame.cancel:SetHeight(20)
		uiFrame.cancel:SetText("X")
		uiFrame.cancel:SetFrameStrata("TOOLTIP")
		uiFrame.cancel:SetScript("OnClick", function()
			uiFrame:Hide()
		end)
		
	end

	refreshExistingButtons()

	uiFrame:Show()
	--uiFrame.cancel:RegisterForClicks("AnyDown", "AnyUp")
end

local function ChatHandler(msg)
	local vars = SplitString(msg, " ")
	for k,v in vars do
		if v == "" then
			v = nil
		end
	end
	
	if StrongAuras_GS == nil then
		StrongAuras_GS = {}
	end
	
	local cmd, arg = vars[1], vars[2]
	if cmd == "reset" then
		StrongAuras_GS = nil
		print("Reset to defaults.")
	elseif cmd == "auras" then
		printAllAuras()
	elseif cmd == "ui" then
		showUi()
	elseif cmd == "new" then
		if vars[2] ~= nil then
			local auraName = vars[2]
			createNewAura(auraName)
			print("Define aura type with command: /sa aura "..auraName.." type=text")
			print("Define aura type with command: /sa aura "..auraName.." type=progress")
			print("Define aura type with command: /sa aura "..auraName.." type=icon")
		end
	elseif cmd == "delete" then
		if vars[2] ~= nil then
			local auraName = vars[2]
			deleteAuraByName(auraName)
		end
	elseif cmd == "aura" then
		if vars[2] ~= nil then
			local auraName = vars[2]
			if vars[3] ~= nil then
				local split = SplitString(vars[3], "=")
				for k,v in split do
					if v == "" then
						v = nil
					end
				end
				local key = split[1]
				local fullText = "aura "..auraName.." "..key.."="
				local value = string.sub(msg, string.len(fullText)+1)
				if key ~= nil and value ~= nil and string.len(value) > 0 then
					if base_keys[key] ~= nil or StrongAuras_GS["aura"][auraName][key] ~= nil then
						local applyDefaults = false
						if key == "type" and (StrongAuras_GS["aura"][auraName][key] == nil or StrongAuras_GS["aura"][auraName][key] ~= value) then
							applyDefaults = true
						end
						auraAssign(auraName, key, value)
						if applyDefaults then
							assignDefaultValues(auraName, value)
						end
						
						OnAuraUpdate("frame");
					else
						print("Invalid key: "..key)
					end
				else
					if key == "edit" then
						editExistingAura(auraName)
					elseif key ~= nil and StrongAuras_GS["aura"][auraName][key] ~= nil then
						print(key.."="..StrongAuras_GS["aura"][auraName][key])
					end
				end
			else
				if StrongAuras_GS["aura"][auraName] ~= nil then
					--printPropertiesForAura(auraName)
					editExistingAura(auraName)
				else
					print("No such aura exists named "..auraName)
				end
			end
		else
			printAllAuras()
		end
	else
		print("Usage:")
		print("/sa ui: Summon UI")
		print("/sa auras: Show existing auras")
		print("/sa new [name]: Create new named aura")
		print("/sa delete [name]: Delete new named aura")
		print("/sa aura [name] [property]=[value]: Edit named aura property")
	end
end

SlashCmdList["STRONGAURAS"] = ChatHandler
