----------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;

core.SpellsPVEConfig = {}; -- adds SpellsPVEConfig table to addon namespace

local SpellsPVEConfig = core.SpellsPVEConfig;
local UISpellsPVEConfig;
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


local tabs = {}


for i = 1, #core.spellsPVE do
	tabs[i] = core.spellsPVE[i][1]
end
--------------------------------------
-- SpellsPVEConfig functions
--------------------------------------
function SpellsPVEConfig:Toggle() --Builds the Table
	local menu = UISpellsPVEConfig or SpellsPVEConfig:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function SpellsPVEConfig:Update()
	local menu = UISpellsPVEConfig or SpellsPVEConfig:CreateMenu();
	SpellsPVEConfig:UpdateSpellList();
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
		tab:SetFrameLevel(2)

		if core[select(i, ...)] then
			tab:SetText(core[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);

		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsPVEConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();

		-- just for tutorial only:
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--	tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

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

function SpellsPVEConfig:CreateMenu()
	UISpellsPVEConfig = CreateFrame("Frame", "LoseControlSpellsPVEConfig", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, self:GetThemeColor());
	local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
	UISpellsPVEConfig.Title:SetText('LoseControl PVE Spells Config '..BambiTag)
	UISpellsPVEConfig:SetFrameStrata("DIALOG");
	UISpellsPVEConfig:SetFrameLevel(2);
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
	local numberOfSpellChecksPerRow = 5
	for i,tab in pairs(tabs) do
		local c = allContents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = -1

		for l = 1, #core.spellsPVE[i] do
			if l ~=1 then
				local spellID = core.spellsPVE[i][l][1]
				local prio =  core.spellsPVE[i][l][2]
			  if (spellID) then
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
					spellCheck.text:SetText(GetSpellInfo(spellID)..": "..prio or "SPELL REMOVED: "..spellID);
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
					else
					spellCheck.text:SetText(spellID..": "..prio);
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
				end
			end
		end
	end


	UISpellsPVEConfig:Hide();
	return UISpellsPVEConfig;
end

function SpellsPVEConfig:UpdateSpellList()
local numberOfSpellChecksPerRow = 5
for i,tab in pairs(tabs) do
	local c = contents[i]
	local previousSpellID = nil
	local Y = -10
	local X = 230
	local spellCount = -1

	for l = 1, #core.spellsPVE[i] do
		if l ~=1 then
			local spellID = core.spellsPVE[i][l][1]
			local prio =  core.spellsPVE[i][l][2]
			if (spellID) then
				spellCount = spellCount + 1
				local spellCheck
				if  _G[c:GetName().."spellCheck"..spellID] then
				spellCheck = _G[c:GetName().."spellCheck"..spellID];
				else
				spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
				end
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
				spellCheck.text:SetText(GetSpellInfo(spellID)..": "..prio or "SPELL REMOVED: "..spellID);
				spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
				else
				spellCheck.text:SetText(spellID..": "..prio);
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
			end
		end
	end
end
end
