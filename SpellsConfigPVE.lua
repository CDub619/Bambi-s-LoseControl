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

local tabs = {
	"CC",
	"Silence",
	"RootPhyiscal_Special",
	"RootMagic_Special",
	"Root",
	"ImmunePlayer",
	"Disarm_Warning",
	"CC_Warning",
	"Enemy_Smoke_Bomb",
	"Stealth",
	"Immune",
	"ImmuneSpell",
	"ImmunePhysical",
	"AuraMastery_Cast_Auras",
	"ROP_Vortex",
	"Disarm",
	"Haste_Reduction",
	"Dmg_Hit_Reduction",
	"Interrupt",
	"AOE_DMG_Modifiers",
	"Friendly_Smoke_Bomb",
	"AOE_Spell_Refections",
	"Trees",
	"Speed_Freedoms",
	"Freedoms",
	"Friendly_Defensives",
	"Mana_Regen",
	"CC_Reduction",
	"Personal_Offensives",
	"Peronsal_Defensives",
	"Movable_Cast_Auras",

	"Other", --PVE only
	"PvE", --PVE only

	"SnareSpecial",
	"SnarePhysical70",
	"SnareMagical70",
	"SnarePhysical50",
	"SnarePosion50",
	"SnareMagic50",
	"SnarePhysical30",
	"SnareMagic30",
	"Snare",
}
--------------------------------------
-- SpellsPVEConfig functions
--------------------------------------
function SpellsPVEConfig:Toggle()
	local menu = UISpellsPVEConfig or SpellsPVEConfig:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function SpellsPVEConfig:Reset()
	local menu = UISpellsPVEConfig or SpellsPVEConfig:CreateMenu();
	menu:Hide()
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

local function Tab_OnClick(self)
	PanelTemplates_SetTab(self:GetParent(), self:GetID());

	local scrollChild = UISpellsPVEConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsPVEConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local contents = {};
	local frameName = frame:GetName();
	local width = {}
	local rows = 1
	local widthTabrow = {121,}


	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		if core[select(i, ...)] then
		tab:SetText(core[select(i, ...)]);
		width[i] = string.len(core[select(i, ...)])
		else
		tab:SetText(tabs[i]);
		width[i] = string.len(tabs[i])
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
		widthTab = width[i]
		else
					widthTab = widthTab + width[i]
		   if widthTab < widthTabrow[rows] -2 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					widthTabrow[rows + 1] = widthTab
	    	else
					widthTab = 0
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpellsPVEConfig, "BOTTOMLEFT", 5, y);
					rows = rows + 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function makeAndShowSpellTTPVE(self)
	GameTooltip:SetOwner (self, "ANCHOR_RIGHT")
	GameTooltip:SetSpellByID(self.spellID)
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
	UISpellsPVEConfig:SetFrameLevel(0);
	UISpellsPVEConfig:EnableMouse(true);
	UISpellsPVEConfig:SetMovable(true)
	UISpellsPVEConfig:RegisterForDrag("LeftButton")
	UISpellsPVEConfig:SetScript("OnDragStart", UISpellsPVEConfig.StartMoving)
	UISpellsPVEConfig:SetScript("OnDragStop", UISpellsPVEConfig.StopMovingOrSizing)

	UISpellsPVEConfig:SetSize(800, 400);
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
		local spellCount = 0

		for k in ipairs(core.spellsPVE) do
			local spellID = core.spellsPVE[k][1]
			local type =  core.spellsPVE[k][2]
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


	UISpellsPVEConfig:Hide();
	return UISpellsPVEConfig;
end
