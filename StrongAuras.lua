
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
	for i=1,16 do
		local a,b,c=UnitBuff("player", i)
		if c == buffId then
			return GetPlayerBuffTimeLeft(i)
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
									
									local fn = loadstring(StrongAuras_GS["aura"][auraName]["textfn"])
									--local fn = loadstring(textfn)
									if fn ~= nil then
										local resolved = fn()
										auraFrames[auraName].frame.text:SetText(resolved)
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
					auraFrames[auraName].frame:SetScript("OnUpdate", function() end)
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
				if StrongAuras_GS["aura"][a]["event_unitMana"] ~= nil and StrongAuras_GS["aura"][a]["event_unitMana"] ~= "nil" then
					local unitManaFn = loadstring(StrongAuras_GS["aura"][a]["event_unitMana"])
					unitManaFn()
				end
				if arg1=="player" and StrongAuras_GS["aura"][a]["trigger"] ~= nil and StrongAuras_GS["aura"][a]["trigger"] == "mana" then
					OnAuraUpdate("mana");
				end
			end
		end
	end
end

SLASH_STRONGAURAS1 = "/sa"
SLASH_STRONGAURAS2 = "/strongauras"

base_keys={}
base_keys["type"]=1
base_keys["event_unitMana"]=1
base_keys["onload"]=1

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
	elseif cmd == "new" then
		if vars[2] ~= nil then
			local auraName = vars[2]
			if StrongAuras_GS["aura"] == nil then
				StrongAuras_GS["aura"] = {}
			end
			if StrongAuras_GS["aura"][auraName] == nil then
				StrongAuras_GS["aura"][auraName] = {}
				print("Created new aura named: "..auraName)
				print("Define aura type with command: /sa aura "..auraName.." type=text")
				print("Define aura type with command: /sa aura "..auraName.." type=progress")
				print("Define aura type with command: /sa aura "..auraName.." type=icon")
			end
		end
	elseif cmd == "delete" then
		if vars[2] ~= nil then
			local auraName = vars[2]
			if StrongAuras_GS["aura"] == nil then
				StrongAuras_GS["aura"] = {}
			end
			if StrongAuras_GS["aura"][auraName] ~= nil then
				StrongAuras_GS["aura"][auraName] = nil
				print("Deleted aura named: "..auraName)
			end
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
					if key ~= nil and StrongAuras_GS["aura"][auraName][key] ~= nil then
						print(key.."="..StrongAuras_GS["aura"][auraName][key])
					end
				end
			else
				if StrongAuras_GS["aura"][auraName] ~= nil then
					print("All properties for aura: "..auraName)
					local indent = "    "
					for k,v in StrongAuras_GS["aura"][auraName] do
						print(indent..k.."="..v)
					end
				else
					print("No such aura exists named "..auraName)
				end
			end
		else
			printAllAuras()
		end
	else
		print("Usage:")
		print("/sa auras: Show existing auras")
		print("/sa new [name]: Create new named aura")
		print("/sa delete [name]: Delete new named aura")
		print("/sa aura [name] [property]=[value]: Edit named aura property")
	end
end

SlashCmdList["STRONGAURAS"] = ChatHandler
