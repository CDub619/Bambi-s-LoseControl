----------------------------------------
-- Namespaces
--------------------------------------
local _, core = ...;

core.SpellsConfig = {}; -- adds SpellsConfig table to addon namespace

local SpellsConfig = core.SpellsConfig;
local UISpellsConfig;
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
	"SnareMagic70",
	"SnarePhysical50",
	"SnarePosion50",
	"SnareMagic50",
	"SnarePhysical30",
	"SnareMagic30",
	"Snare",
}
--------------------------------------
-- SpellsConfig functions
--------------------------------------
function SpellsConfig:Toggle()
	local menu = UISpellsConfig or SpellsConfig:CreateMenu();
	menu:SetShown(not menu:IsShown());
end

function SpellsConfig:Reset()
	local menu = UISpellsConfig or SpellsConfig:CreateMenu();
	menu:Hide()
end

function SpellsConfig:GetThemeColor()
	local c = defaults.theme;
	return c.r, c.g, c.b, c.hex;
end

function SpellsConfig:CreateButton(point, relativeFrame, relativePoint, yOffset, text)
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

	local scrollChild = UISpellsConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsConfig.ScrollFrame:SetScrollChild(self.content);
	self.content:Show();
end

local function SetTabs(frame, numTabs, ...)
	frame.numTabs = numTabs;

	local contents = {};
	local frameName = frame:GetName();
	local width = {}
	local rows = 1
	local rowCount = 1


	for i = 1, numTabs do
		local tab = CreateFrame("Button", frameName.."Tab"..i, frame, "CharacterFrameTabButtonTemplate");
		tab:SetID(i);
		tab:SetFrameLevel(1)

		if core[select(i, ...)] then
			tab:SetText(core[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);

		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();

		-- just for tutorial only:
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--	tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

		if (i == 1) then
		tab:SetPoint("TOPLEFT", UISpellsConfig, "BOTTOMLEFT", 5, 7);
		rowCount = 1
		else
				if rowCount <= 9 then
			 		tab:SetPoint("TOPLEFT", _G[frameName.."Tab"..(i - 1)], "TOPRIGHT", -27, 0);
					rowCount = rowCount + 1
	    	else
					y = 7 - (25 * rows)
					tab:SetPoint("TOPLEFT", UISpellsConfig, "BOTTOMLEFT", 5, y);
					rows = rows + 1
					rowCount = 1
	    end
		end
	end

	Tab_OnClick(_G[frameName.."Tab1"]);

	return contents;
end

local function makeAndShowSpellTT(self)
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

function SpellsConfig:CreateMenu()
	UISpellsConfig = CreateFrame("Frame", "LoseControlSpellsConfig", UIParent, "UIPanelDialogTemplate");
	local hex = select(4, self:GetThemeColor());
	local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
	UISpellsConfig.Title:SetText('LoseControl Player & Party Spells Config '..BambiTag)
	UISpellsConfig:SetFrameStrata("DIALOG");
	UISpellsConfig:SetFrameLevel(1);
	UISpellsConfig:EnableMouse(true);
	UISpellsConfig:SetMovable(true)
	UISpellsConfig:RegisterForDrag("LeftButton")
	UISpellsConfig:SetScript("OnDragStart", UISpellsConfig.StartMoving)
	UISpellsConfig:SetScript("OnDragStop", UISpellsConfig.StopMovingOrSizing)

	UISpellsConfig:SetSize(1050, 400);
	UISpellsConfig:SetPoint("CENTER"); -- Doesn't need to be ("CENTER", UIParent, "CENTER")


	UISpellsConfig.ScrollFrame = CreateFrame("ScrollFrame", nil, UISpellsConfig, "UIPanelScrollFrameTemplate");
	UISpellsConfig.ScrollFrame:SetPoint("TOPLEFT", LoseControlSpellsConfigDialogBG, "TOPLEFT", 4, -8);
	UISpellsConfig.ScrollFrame:SetPoint("BOTTOMRIGHT", LoseControlSpellsConfigDialogBG, "BOTTOMRIGHT", -3, 4);
	UISpellsConfig.ScrollFrame:SetClipsChildren(true);
	UISpellsConfig.ScrollFrame:SetScript("OnMouseWheel", ScrollFrame_OnMouseWheel);

	UISpellsConfig.ScrollFrame.ScrollBar:ClearAllPoints();
    UISpellsConfig.ScrollFrame.ScrollBar:SetPoint("TOPLEFT", UISpellsConfig.ScrollFrame, "TOPRIGHT", -12, -18);
    UISpellsConfig.ScrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", UISpellsConfig.ScrollFrame, "BOTTOMRIGHT", -7, 18);


	local allContents = SetTabs(UISpellsConfig, #tabs, unpack(tabs));
	local numberOfSpellChecksPerRow = 5
	for i,tab in pairs(tabs) do
		local c = allContents[i]
		local previousSpellID = nil
		local Y = -10
		local X = 230
		local spellCount = -1

		for k in ipairs(core.spells) do
			local spellID = core.spells[k][1]
			local prio =  core.spells[k][2]
			local duration
			if core.spells[k][3] then
				duration = core.spells[k][3]
			end
		  if (spellID and prio and (string.lower(prio) == string.lower(tab))) then
				spellCount = spellCount + 1
				local spellCheck = CreateFrame("CheckButton", c:GetName().."spellCheck"..spellID, c, "UICheckButtonTemplate");
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


	UISpellsConfig:Hide();
	return UISpellsConfig;
end
