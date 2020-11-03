----------------------------------------
-- Namespaces
--------------------------------------
local _, L = ...;

L.SpellsArenaConfig = {}; -- adds SpellsArenaConfig table to addon namespace

local SpellsArenaConfig = L.SpellsArenaConfig;
local UISpellsArenaConfig;
local tooltip = CreateFrame("GameTooltip", "fPBMouseoverTooltip", UIParent, "GameTooltipTemplate")
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

local tabs = {
	"Drink_Purge",
	"Immune",
	"CC",
	"Silence",
	"Interrupt", -- Needs to be same
	"Special_High",
	"Ranged_Major_OffenisiveCDs",
	"Roots_90_Snares",
	"Disarms",
	"Melee_Major_OffenisiveCDs",
	"Big_Defensive_CDs",
	"Player_Party_OffensiveCDs",
	"Small_Offenisive_CDs",
	"Small_Defensive_CDs",
	"Freedoms_Speed",
	"Snares_WithCDs",
	"Special_Low",
	"Snares_Ranged_Spamable",
	"Snares_Casted_Melee",
}
--------------------------------------
-- SpellsArenaConfig functions
--------------------------------------
function SpellsArenaConfig:Toggle()
	local menu = UISpellsArenaConfig or SpellsArenaConfig:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function SpellsArenaConfig:Update()
	local menu = UISpellsArenaConfig or SpellsArenaConfig:CreateMenu();
	SpellsArenaConfig:UpdateSpellList();
end

function SpellsArenaConfig:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function SpellsArenaConfig:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
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

	local scrollChild = UISpellsArenaConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsArenaConfig.ScrollFrame:SetScrollChild(self.content);
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
		tab:SetFrameLevel(3)

		if L[select(i, ...)] then
			tab:SetText(L[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);

		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsArenaConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();

		-- just for tutorial only:
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--	tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);



		if (i == 1) then
		tab:SetPoint("TOPLEFT", UISpellsArenaConfig, "BOTTOMLEFT", 5, 7);
		rowCount = 1
		else
				if rowCount <= 9 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					rowCount = rowCount + 1
	    	else
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpellsArenaConfig, "BOTTOMLEFT", 5, y);
					rows = rows + 1
					rowCount = 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function makeAndShowSpellTTArena(self)
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
function SpellsArenaConfig:CreateMenu()
	UISpellsArenaConfig = CreateFrame("Frame", "LoseControlSpellsArenaConfig", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, self:GetThemeColor());
	local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
	UISpellsArenaConfig.Title:SetText('LoseControl Arena Spells Config '..BambiTag)
	UISpellsArenaConfig:SetFrameStrata("DIALOG");
	UISpellsArenaConfig:SetFrameLevel(3);
	UISpellsArenaConfig:EnableMouse(true);
	UISpellsArenaConfig:SetMovable(true)
	UISpellsArenaConfig:RegisterForDrag("LeftButton")
	UISpellsArenaConfig:SetScript("OnDragStart", UISpellsArenaConfig.StartMoving)
	UISpellsArenaConfig:SetScript("OnDragStop", UISpellsArenaConfig.StopMovingOrSizing)

	UISpellsArenaConfig:SetSize(1050, 400);
	UISpellsArenaConfig:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


	UISpellsArenaConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UISpellsArenaConfig, "UIPanelScrollFrameTemplate");
	UISpellsArenaConfig.ScrollFrame:SetPoint("TOPLEFT", LoseControlSpellsArenaConfigDialogBG, "TOPLEFT", 4, -8);
	UISpellsArenaConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", LoseControlSpellsArenaConfigDialogBG, "BOTTOMRIGHT", -3, 4);
	UISpellsArenaConfig.ScrollFrame:SetClipsChildren(true);
	UISpellsArenaConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

	UISpellsArenaConfig.ScrollFrame.ScrollBar:ClearAllPoints();
    UISpellsArenaConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UISpellsArenaConfig.ScrollFrame, "TOPRIGHT", -12, -18);
    UISpellsArenaConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UISpellsArenaConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);


	local allContents = SetTabs(UISpellsArenaConfig, #tabs, unpack(tabs));
	local numberOfSpellChecksPerRow = 5
	for i,tab in pairs(tabs) do
		local c = allContents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = -1

		for k in ipairs(L.spellsArena) do
			local spellID = L.spellsArena[k][1]
			local prio =  L.spellsArena[k][2]
			local duration
			if L.spellsArena[k][3] then
				duration = L.spellsArena[k][3]
			end
		  if (spellID and prio and (string.lower(prio) == string.lower(tab))) then
				spellCount = spellCount + 1
				local spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
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
				spellCheck.icon = CreateFrame("Button", spellCheck:GetName().."Icon", spellCheck, "ActionButtonTemplate")
				spellCheck.icon:Disable()
				spellCheck.icon:SetPoint("CENTER", spellCheck, "CENTER", -90, 0)
				spellCheck.icon:SetScale(0.3)
				spellCheck.icon.check = spellCheck
				if type(spellID) == "number" then
					if duration then
					spellCheck.text:SetText(GetSpellInfo(spellID)..": "..duration or "SPELL REMOVED: "..spellID);
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					else
					spellCheck.text:SetText(GetSpellInfo(spellID) or "SPELL REMOVED: "..spellID);
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					end
				else
				spellCheck.text:SetText(spellID);
				spellCheck.icon:SetNormalTexture(1008124)
				end
				spellCheck:SetChecked(_G.LoseControlDB.spellEnabledArena[spellID] or false);   --Error on 1st ADDON_LOADED
				spellCheck.spellID = spellID
				spellCheck:SetScript("OnClick",
				  function()
					 GameTooltip:Hide()
					 _G.LoseControlDB.spellEnabledArena[spellCheck.spellID] = spellCheck:GetChecked()
					 makeAndShowSpellTTArena(spellCheck)
          end
				);
				spellCheck:SetScript("OnEnter", function(self)
						makeAndShowSpellTTArena(self)
				end)
				spellCheck:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
				previousSpellID = spellID
			end
		end
	end


	UISpellsArenaConfig:Hide();
	return UISpellsArenaConfig;
end

function SpellsArenaConfig:UpdateSpellList()
	local numberOfSpellChecksPerRow = 5
	for i,tab in pairs(tabs) do
		local c = contents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = -1

		for k in ipairs(L.spellsArena) do
			local spellID = L.spellsArena[k][1]
			local prio =  L.spellsArena[k][2]
			local duration
			if L.spellsArena[k][3] then
				duration = L.spellsArena[k][3]
			end
		  if (spellID and prio and (string.lower(prio) == string.lower(tab))) then
				spellCount = spellCount + 1
				local spellCheck
				if  _G[c:GetName().."spellCheck"..spellID] then
				spellCheck = _G[c:GetName().."spellCheck"..spellID];
				else
				spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
		  	end
				if (previousSpellID) then
					if (spellCount % numberOfSpellChecksPerRow == 0) then
						Y = Y - 40
						X = 30
					end
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", X, Y);
					X = X + 200
				else
					spellCheck:SetPoint("TOPLEFT", c, "TOPLEFT", 30, -10);
				end
				spellCheck.icon = CreateFrame("Button", spellCheck:GetName().."Icon", spellCheck, "ActionButtonTemplate")
				spellCheck.icon:Disable()
				spellCheck.icon:SetPoint("CENTER", spellCheck, "CENTER", -90, 0)
				spellCheck.icon:SetScale(0.3)
				spellCheck.icon.check = spellCheck
				if type(spellID) == "number" then
					if duration then
					spellCheck.text:SetText(GetSpellInfo(spellID)..": "..duration or "SPELL REMOVED: "..spellID);
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					else
					spellCheck.text:SetText(GetSpellInfo(spellID) or "SPELL REMOVED: "..spellID);
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					end
				else
				spellCheck.text:SetText(spellID);
				spellCheck.icon:SetNormalTexture(1008124)
				end
				spellCheck:SetChecked(_G.LoseControlDB.spellEnabledArena[spellID] or false);   --Error on 1st ADDON_LOADED
				spellCheck.spellID = spellID
				spellCheck:SetScript("OnClick",
				  function()
					 GameTooltip:Hide()
					 _G.LoseControlDB.spellEnabledArena[spellCheck.spellID] = spellCheck:GetChecked()
					 makeAndShowSpellTTArena(spellCheck)
          end
				);
				spellCheck:SetScript("OnEnter", function(self)
						makeAndShowSpellTTArena(self)
				end)
				spellCheck:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
				previousSpellID = spellID
			end
		end
	end
end
