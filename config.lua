----------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;

core.Config = {}; -- adds Config table to addon namespace

local Config = core.Config;
local UIConfig;
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
  "CC",
  "Silence",
  "SpecialRoot",
  "Root",
  "Immune",
  "Stealth",
  "WarningDisarm",
  "WarningCC",
  "EnemySmoke",
  "MajorOffense",
  "MajorDefense",
  "AuraMastery",
  "SpecialSnare",
  "Disarm",
  "SemiCCCast",
  "SemiCCDmg",
  "MajorDmgBuff",
  "FriendlySmoke",
  "Interrupts",
  "ImmuneSpell",
  "CCReduction",
  "MajorSpeed",
  "Freedoms",
  "MinorOffense",
  "MinorDefense",
  "CastingBuff",
  "SnareWarning",
  "Snare70",
  "Snare70Magic",
  "Snare50",
  "Snare50Magic",
  "Snare30",
  "Snare30Magic",
  "RandomAuras",
  "PvE",
}
core.commands = {
	["config"] = core.Config.Toggle, -- this is a function (no knowledge of Config object)
};
--------------------------------------
-- Config functions
--------------------------------------
function Config:Toggle()
	local menu = UIConfig or Config:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function Config:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function Config:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
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

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = UIConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UIConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local contents = {};
	local frameName = frame:GetName();


	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetText(core["i"..select(i, ...)]);
		tab:SetScript("OnClick", Tab_OnClick);

		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UIConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();

		-- just for tutorial only:
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--	tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

		if (i == 1) then
			tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, 7);
		else
    if (i<11) then
			tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
      else
        if i==12 then
          tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, -19);
          else
          if (i<20) then
          tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
          else
          if i==21 then
            tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, -45);
            else
            if (i<28) then
            tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
            else
            if i==29 then
              tab:SetPoint("TOPLEFT", UIConfig, "BOTTOMLEFT", 5, -70);
              else
              if (i<40) then
              tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
              end
              end
            end
        end
        end
        end
    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

function makeAndShowSpellTT(self)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	GameTooltip:SetSpellByID(self.spellID)
	if (self:GetChecked()) then
		GameTooltip:AddDoubleLine("|cff66FF00Enabled")
	else
		GameTooltip:AddDoubleLine("|cffFF0000Disabled")
	end
	GameTooltip:Show()
end
function Config:CreateMenu()
	UIConfig = CreateFrame("Frame", "LoseControlConfig", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, self:GetThemeColor());
	local jaxTag = string.format("|cff%s%s|r", hex:upper(), "By Jax");
	UIConfig.Title:SetText('Lose Control Spell Config '..jaxTag)
	UIConfig:SetFrameStrata("DIALOG");
	UIConfig:SetFrameLevel(0);
	UIConfig:EnableMouse(true);
	UIConfig:SetMovable(true)
	UIConfig:RegisterForDrag("LeftButton")
	UIConfig:SetScript("OnDragStart", UIConfig.StartMoving)
	UIConfig:SetScript("OnDragStop", UIConfig.StopMovingOrSizing)

	UIConfig:SetSize(800, 400);
	UIConfig:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


	UIConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UIConfig, "UIPanelScrollFrameTemplate");
	UIConfig.ScrollFrame:SetPoint("TOPLEFT", LoseControlConfigDialogBG, "TOPLEFT", 4, -8);
	UIConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", LoseControlConfigDialogBG, "BOTTOMRIGHT", -3, 4);
	UIConfig.ScrollFrame:SetClipsChildren(true);
	UIConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

	UIConfig.ScrollFrame.ScrollBar:ClearAllPoints();
    UIConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UIConfig.ScrollFrame, "TOPRIGHT", -12, -18);
    UIConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UIConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);


	local allContents = SetTabs(UIConfig, #tabs, unpack(tabs));
	local numberOfSpellChecksPerRow = 5
	for i,tab in pairs(tabs) do
		local c = allContents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = 0
		for spellID,type in pairs(core.spellIds) do
		  if (spellID and type and (string.lower(type) == string.lower(tab))) then
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
				spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
				spellCheck.icon:SetScale(0.3)
				spellCheck.icon.check = spellCheck
				spellCheck.text:SetText(GetSpellInfo(spellID) or "SPELL REMOVED: "..spellID);
				spellCheck:SetChecked(_G.LoseControlDB.spellEnabled[spellID] or false);   --Error on 1st ADDON_LOADED
				spellCheck.spellID = spellID
				spellCheck:SetScript("OnClick",
				  function()
					 GameTooltip:Hide()
					 _G.LoseControlDB.spellEnabled[spellCheck.spellID] = spellCheck:GetChecked()
					 makeAndShowSpellTT(spellCheck)
          end
				);
				spellCheck:SetScript("OnEnter", function(self)
						makeAndShowSpellTT(self)
				end)
				spellCheck:SetScript("OnLeave", function(self)
					GameTooltip:Hide()
				end)
				previousSpellID = spellID
			end
		end
	end


	UIConfig:Hide();
	return UIConfig;
end
