----------------------------------------
-- Namespaces
--------------------------------------
local _, L = ...;

L.SpellsPVEConfig = {}; -- adds SpellsPVEConfig table to addon namespace

local SpellsPVEConfig = L.SpellsPVEConfig;
local UISpellsPVEConfig;
local tooltip = CreateFrame("GameTooltip", "fPBMouseoverTooltip", UIParent, "GameTooltipTemplate")
local iconcheck = {}
local tblinsert = table.insert
--------------------------------------
-- Defaults (usually a database!)
--------------------------------------
local defaults = {
	theme = {
		r = 0,
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}


local tabs = {}


--------------------------------------
-- SpellsPVEConfig functions
--------------------------------------
function SpellsPVEConfig:Addon_Load()
if UISpellsPVEConfig then SpellsPVEConfig:WipeAllSpellList() end
local menu = UISpellsPVEConfig or SpellsPVEConfig:CreateMenu();
SpellsPVEConfig:UpdateAllSpellList()
end

function SpellsPVEConfig:Toggle() --Builds the Table
	local menu = UISpellsPVEConfig
	menu:SetShown(not menu:IsShown());
end

function SpellsPVEConfig:UpdateTab(i)
	SpellsPVEConfig:WipeSpellList(i)
	SpellsPVEConfig:UpdateSpellList(i);
end

function SpellsPVEConfig:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function SpellsPVEConfig:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
	local btn = CreateFrame("Button", nil, relativeFrame, "GameMenuButtonTemplate");
	btn:SetPoint(point, relativeFrame, relativePoint, 0, yOffset);
	btn:SetSize(140, 40);
	btn:SetText(text);
	btn:SetNormalFontObject("GameFontNormalLarge");
	btn:SetHighlightFontObject("GameFontHighlightLarge");
	return btn;
end

local function ScrollFrame_OnMouseWheel(self, delta)
	local newValue = self:GetVerticalScroll() - (delta * 20);

	if (newValue < 0) then
		newValue = 0;
	elseif (newValue > self:GetVerticalScrollRange()) then
		newValue = self:GetVerticalScrollRange();
	end

	self:SetVerticalScroll(newValue);
end

local function PanelTemplates_DeselectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Enable();
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_SelectTab(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Hide();
	getglobal(name.."Middle"):Hide();
	getglobal(name.."Right"):Hide();
	--tab:LockHighlight();
	tab:Disable();
	getglobal(name.."LeftDisabled"):Show();
	getglobal(name.."MiddleDisabled"):Show();
	getglobal(name.."RightDisabled"):Show();

	if ( GameTooltip:IsOwned(tab) ) then
		GameTooltip:Hide();
	end
end

local function PanelTemplates_SetDisabledTabState(tab)
	local name = tab:GetName();
	getglobal(name.."Left"):Show();
	getglobal(name.."Middle"):Show();
	getglobal(name.."Right"):Show();
	--tab:UnlockHighlight();
	tab:Disable();
	tab.text = tab:GetText();
	-- Gray out text
	tab:SetDisabledTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	getglobal(name.."LeftDisabled"):Hide();
	getglobal(name.."MiddleDisabled"):Hide();
	getglobal(name.."RightDisabled"):Hide();
end

local function PanelTemplates_UpdateTabs(frame)
	if ( frame.selectedTab ) then
		local tab;
		for i=1, frame.numTabs, 1 do
			tab = getglobal(frame:GetName().."Tab"..i);
			if ( tab.isDisabled ) then
				PanelTemplates_SetDisabledTabState(tab);
			elseif ( i == frame.selectedTab ) then
				PanelTemplates_SelectTab(tab);
			else
				PanelTemplates_DeselectTab(tab);
			end
		end
	end
end

local function PanelTemplates_SetTab(frame, id)
	frame.selectedTab = id;
	PanelTemplates_UpdateTabs(frame);
end

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = UISpellsPVEConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsPVEConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local contents = {};

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local frameName = frame:GetName();
	local width = {}
	local rows = 1
	local rowCount = 1

	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetFrameLevel(10)

		if L[select(i, ...)] then
			tab:SetText(L[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);
		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsPVEConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

	if tabs[i] == "Discovered LC Spells" then
		else
		tab.content.input = CreateFrame("EditBox", tab:GetName()..'CustomSpells', 	tab.content, 'InputBoxTemplate')
  	tab.content.input:SetSize(150,22)
  	tab.content.input:SetAutoFocus(false)
  	tab.content.input:SetMaxLetters(30)
  	tab.content.input:SetPoint("TOPLEFT", tab.content, "TOPRIGHT", 45, -14)
  	tab.content.input:SetScript('OnChar', function(self, customspelltext)
    			 	tab.content.input.customspelltext = self:GetText()
    end)
    --
  	tab.content.add = CreateFrame("Button",  tab:GetName()..'CustomSpellsButton', 	tab.content.input, "UIPanelButtonTemplate")
    tab.content.add:SetSize(50,22)
  	tab.content.add:SetPoint("TOPLEFT",	tab.content.input, "TOPRIGHT", 2, 0)
  	tab.content.add:SetText("Add")
  	tab.content.add:SetScript("OnClick", function(self, addenemy)
			local spell, name
			name = GetSpellInfo(tonumber(tab.content.input.customspelltext))
			if name then spell = tonumber(tab.content.input.customspelltext) else spell = tab.content.input.customspelltext end
	  	tblinsert(_G.LoseControlDB.customSpellIds, 1, {spell, "typeplaceholder", nil, nil, nil,"custom", i + 1, i, "PvE", tabs[i]}) --v[7]: Category Tab to enter spell / v[8]: Tab to update / v[9]: Table / v[10]: tab name
			local r = L.LoseControlCompile:CustomCompileSpells(spell)
			if r then
				if r[1] then --Means your moving a custom spell
					if (r[1] == r[2]) and (r[3] == r[4]) then  --Means your moving a custom spell from the same tab
						SpellsPVEConfig:WipeSpellList(r[1])
						L.LoseControlCompile:CompileSpells()
						SpellsPVEConfig:UpdateSpellList(r[1])
					elseif (r[1] ~= r[2]) and (r[3] == r[4]) then --Means your moving a custom spell from PVE but differnt tab
						SpellsPVEConfig:WipeSpellList(r[1])
						SpellsPVEConfig:WipeSpellList(r[2])
						L.LoseControlCompile:CompileSpells()
						SpellsPVEConfig:UpdateSpellList(r[1])
						SpellsPVEConfig:UpdateSpellList(r[2])
					elseif (r[3] ~= r[4]) then --Means your moving a custom spell from PVP to PVE but differnt tab
						SpellsPVEConfig:WipeSpellList(r[1])
					  L.SpellsConfig:WipeSpellList(r[2])
						L.LoseControlCompile:CompileSpells()
						SpellsPVEConfig:UpdateSpellList(r[1])
					  L.SpellsConfig:UpdateSpellList(r[2])
					end
				elseif r[5] then --Means your moving an orignal spell
					if r[5] == 1 then --Moving Spell from PVP tab
						z = L.SpellsConfig:TabNumber(r[6])
						L.SpellsConfig:WipeSpellList(z)
						SpellsPVEConfig:WipeSpellList(i)
						L.LoseControlCompile:CompileSpells()
						L.SpellsConfig:UpdateSpellList(z)
						SpellsPVEConfig:UpdateSpellList(i)
					else -- --Moving Spell from PVE tab
						SpellsPVEConfig:WipeSpellList(r[5] - 1)
						SpellsPVEConfig:WipeSpellList(i)
						L.LoseControlCompile:CompileSpells()
						SpellsPVEConfig:UpdateSpellList(r[5] - 1)
						SpellsPVEConfig:UpdateSpellList(i)
					end
				end
			else --Adding a new custom spell
				SpellsPVEConfig:WipeSpellList(i)
				L.LoseControlCompile:CompileSpells()
				SpellsPVEConfig:UpdateSpellList(i)
			end
			print("|cff00ccffLoseControl|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..tabs[i].." (PVE)")
    end)
	end

		if (i == 1) then
		tab:SetPoint("TOPLEFT", UISpellsPVEConfig, "BOTTOMLEFT", 5, 7);
		rowCount = 1
		else
				if rowCount <= 9 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					rowCount = rowCount + 1
	    	else
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpellsPVEConfig, "BOTTOMLEFT", 5, y);
					rows = rows + 1
					rowCount = 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function makeAndShowSpellTTPVE(self)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	if type(self.spellID) == "number" then
	GameTooltip:SetSpellByID(self.spellID)
	else
		GameTooltip:SetText(self.spellID, 1, 1, 1, true)
		GameTooltip:AddLine("This Spell Uses the Name not SpellID.", 1.0, 0.82, 0.0, true);
	end
	if (self:GetChecked()) then
		GameTooltip:AddDoubleLine("|cff66FF00Enabled")
	else
		GameTooltip:AddDoubleLine("|cffFF0000Disabled")
	end
	GameTooltip:Show()
end


function SpellsPVEConfig:ResetSpellList(i)
	local c = contents[i]
	for spellCount = 1, #L.spells[i+1] do
		if  _G[c:GetName().."spellCheck"..i..spellCount] then
			local spellCheck = _G[c:GetName().."spellCheck"..i..spellCount];
			spellCheck.icon = _G[spellCheck:GetName().."Icon"]
			spellCheck.icon.check = spellCheck
			spellID = spellCheck.spellID
			_G.LoseControlDB.spellEnabled[spellID] = true
			spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);   --Error on 1st ADDON_LOADED
		end
	end
end

function SpellsPVEConfig:WipeSpellList(i)
local c = contents[i]
 	for spellCount = 1, #L.spells[i+1] do
		if  _G[c:GetName().."spellCheck"..i..spellCount] then
			local spellCheck = _G[c:GetName().."spellCheck"..i..spellCount];
			spellCheck:Hide()
			spellCheck:SetParent(nil)
			spellCheck:ClearAllPoints()
			spellCheck.icon =	_G[spellCheck:GetName().."Icon"]
			spellCheck.icon:Hide()
			spellCheck.icon:SetParent(nil)
			spellCheck.icon:ClearAllPoints()
			spellCheck.icon.check = spellCheck
			spellCheck.icon:SetParent(nil)
			spellCheck.icon:ClearAllPoints()
			spellCheck.text:ClearAllPoints()
			_G[spellCheck:GetName().."Icon"] = nil
			_G[c:GetName().."spellCheck"..i..spellCount] = nil
		end
	end
end


function SpellsPVEConfig:UpdateSpellList(i)
local numberOfSpellChecksPerRow = 5
if i == nil then return end
	local c = contents[i]
	local previousSpellID = nil
	local Y = -10
	local X = 230
	local spellCount = 1
	for l = 2, #L.spells[i+1] do
		local spellID, prio, zone, instanceType
		if L.spells[i+1][l] then
			if L.spells[i+1][l][1] then spellID = L.spells[i+1][l][1]	end
			if L.spells[i+1][l][2] then prio = L.spells[i+1][l][2] end
			if L.spells[i+1][l][3] then instanceType = L.spells[i+1][l][3] end
			if L.spells[i+1][l][4] then zone = L.spells[i+1][l][4] end
			if L.spells[i+1][l][5] then duration = L.spells[i+1][l][5] end
			if L.spells[i+1][l][6] then custom = L.spells[i+1][l][6] end
		end
			if (spellID) then
				local spellCheck
				spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..i..spellCount, c, "UICheckButtonTemplate");
				if (previousSpellID) then
					if (spellCount % numberOfSpellChecksPerRow == 0) then
						Y = Y-40
						X = 30
					end
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
					X = X+200
				else
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
				end
				spellCheck:Show()
				if _G[spellCheck:GetName().."Icon"] then
				spellCheck.icon = _G[spellCheck:GetName().."Icon"]
				else
				spellCheck.icon = CreateFrame("Button", spellCheck:GetName().."Icon", spellCheck, "ActionButtonTemplate")
		  	end
				spellCheck.icon:Disable()
				spellCheck.icon:SetPoint("CENTER", spellCheck, "CENTER", -90, 0)
				spellCheck.icon:SetScale(0.3)
				spellCheck.icon:Show()
				spellCheck.icon.check = spellCheck
				local aString = spellID
				if type(spellID) == "number" then
					if (instanceType ==  "arena" or instanceType == "pvp") then
						local aString1 = GetSpellInfo(spellID)..": "..prio or "SPELL REMOVED: "..spellID
						local aString2 = " ("..instanceType..")"
						local cutString1 = string.sub(aString1, 0, 25);
						local cutString2 = string.sub(aString2, 0, 27);
						local aString3 = cutString1.."\n"..cutString2
						spellCheck.text:SetText(aString3);
					elseif zone then
						local aString1 = GetSpellInfo(spellID)..": "..prio or "SPELL REMOVED: "..spellID
						local aString2 = " ("..zone..")"
						local cutString1 = string.sub(aString1, 0, 25);
						local cutString2 = string.sub(aString2, 0, 27);
					  local	aString3 = cutString1.."\n"..cutString2
						spellCheck.text:SetText(aString3);
					else
						aString = GetSpellInfo(spellID)..": "..prio or "SPELL REMOVED: "..spellID
						local cutString = string.sub(aString, 0, 25);
						spellCheck.text:SetText(cutString);
					end
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
				else
				aString = spellID..": "..prio
				local cutString = string.sub(aString, 0, 25);
				spellCheck.text:SetText(cutString);
				spellCheck.icon:SetNormalTexture(1008124)
				end
				spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);   --Error on 1st ADDON_LOADED
				spellCheck.spellID = spellID
				spellCheck:SetScript("OnClick",
					function()
					 GameTooltip:Hide()
					 _G.LoseControlDB.spellEnabled[spellCheck.spellID] = spellCheck:GetChecked()
					 makeAndShowSpellTTPVE(spellCheck)
					end
				);
				spellCheck:SetScript("OnEnter", function(self)
						makeAndShowSpellTTPVE(self)
				end)
				spellCheck:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
				previousSpellID = spellID
				spellCount = spellCount + 1
			end
		end
	end

	function SpellsPVEConfig:WipeAllSpellList()
		for i = 1, #tabs do
		SpellsPVEConfig:WipeSpellList(i)
		end
	end
	function SpellsPVEConfig:UpdateAllSpellList()
		for i = 1, #tabs do
		SpellsPVEConfig:UpdateSpellList(i)
		end
	end
	function SpellsPVEConfig:ResetAllSpellList()
		for i = 1, #tabs do
		SpellsPVEConfig:ResetSpellList(i)
		end
	end


	function SpellsPVEConfig:CreateMenu()

		for i = 1, #L.spells - 1 do
			tabs[i] = L.spells[i + 1][1]
		end

		UISpellsPVEConfig = CreateFrame("Frame", "LoseControlSpellsPVEConfig", UIParent, "UIPanelDialogTemplate");
		local hex = select(4, self:GetThemeColor());
		local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
		UISpellsPVEConfig.Title:SetText('LoseControl PVE Spells Config '..BambiTag)
		UISpellsPVEConfig:SetFrameStrata("DIALOG");
		UISpellsPVEConfig:SetFrameLevel(10);
		UISpellsPVEConfig:EnableMouse(true);
		UISpellsPVEConfig:SetMovable(true)
		UISpellsPVEConfig:RegisterForDrag("LeftButton")
		UISpellsPVEConfig:SetScript("OnDragStart", UISpellsPVEConfig.StartMoving)
		UISpellsPVEConfig:SetScript("OnDragStop", UISpellsPVEConfig.StopMovingOrSizing)

		UISpellsPVEConfig:SetSize(1050, 400);
		UISpellsPVEConfig:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


		UISpellsPVEConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UISpellsPVEConfig, "UIPanelScrollFrameTemplate");
		UISpellsPVEConfig.ScrollFrame:SetPoint("TOPLEFT", LoseControlSpellsPVEConfigDialogBG, "TOPLEFT", 4, -8);
		UISpellsPVEConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", LoseControlSpellsPVEConfigDialogBG, "BOTTOMRIGHT", -3, 4);
		UISpellsPVEConfig.ScrollFrame:SetClipsChildren(true);
		UISpellsPVEConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

		UISpellsPVEConfig.ScrollFrame.ScrollBar:ClearAllPoints();
	  UISpellsPVEConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UISpellsPVEConfig.ScrollFrame, "TOPRIGHT", -12, -18);
	  UISpellsPVEConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UISpellsPVEConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);

		local allContents = SetTabs(UISpellsPVEConfig, #tabs, unpack(tabs));

		UISpellsPVEConfig:Hide();
		return UISpellsPVEConfig;
	end
