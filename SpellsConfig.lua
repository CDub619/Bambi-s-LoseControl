local _, L = ...;

L.SpellsConfig = {}; -- adds SpellsConfig table to addon namespace

local SpellsConfig = L.SpellsConfig;
local UISpellsConfig;
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


local tabs = {
	"CC",
	"Silence",
	"RootPhyiscal_Special",
	"RootMagic_Special",
	"Root",
	"ImmunePlayer",
	"Disarm_Warning",
	"CC_Warning",
	--"Enemy_Smoke_Bomb",
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

function SpellsConfig:TabNumber(type)
		for k, v in ipairs(tabs) do
			if type == v then
				return k
			end
		end
	end
--------------------------------------
-- SpellsConfig functions
--------------------------------------
function SpellsConfig:Addon_Load()
if not UISpellsConfig then SpellsConfig:CreateMenu(); SpellsConfig:UpdateAllSpellList() end
end

function SpellsConfig:Reset()
if not UISpellsConfig then return end
	SpellsConfig:WipeAllSpellList()
	SpellsConfig:UpdateAllSpellList()
end

function SpellsConfig:Toggle() --Builds the Table
	if not UISpellsConfig then SpellsConfig:CreateMenu(); SpellsConfig:UpdateAllSpellList() end
	local menu = UISpellsConfig
	menu:SetShown(not menu:IsShown());
end

function SpellsConfig:UpdateTab(i)
	if not UISpellsConfig then return end
	SpellsConfig:WipeSpellList(i)
	SpellsConfig:UpdateSpellList(i);
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

	local scrollChild = UISpellsConfig.ScrollFrame:GetScrollChild();
	if (scrollChild) then
		scrollChild:Hide();
	end

	UISpellsConfig.ScrollFrame:SetScrollChild(self.content);
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

		if L[select(i, ...)] then
			tab:SetText(L[select(i, ...)].."                                                                    "); --String Needs to be 20
		else
			tab:SetText(tabs[i].."                                                                    "); --String Needs to be 20
		end

		tab:SetScript("OnClick", Tab_OnClick);
		tab.content = CreateFrame("Frame", tab:GetName()..'Content', UISpellsConfig.ScrollFrame);
		tab.content:SetSize(760, 360);
		tab.content:Hide();
		tab.content.bg = tab.content:CreateTexture(nil, "BACKGROUND");
		tab.content.bg:SetAllPoints(true);
	--tab.content.bg:SetColorTexture(math.random(), math.random(), math.random(), 0.6);

		table.insert(contents, tab.content);

		if tabs[i] == "Interrupt" then
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
				tblinsert(_G.LoseControlDB.customSpellIds, 1, {spell, tabs[i], nil, nil, nil,"custom", 1, i,"PVP", tabs[i]})  --v[7]: Category Tab to enter spell / v[8]: Tab to update / v[9]: Table / v[10]: tab name
				local r = L.LoseControlCompile:CustomCompileSpells(spell)
				if r then
					if r[1] then --Means your moving a custom spell
						if (r[1] == r[2]) and (r[3] == r[4]) then --Means your moving a custom spell from the same tab
							SpellsConfig:WipeSpellList(r[1])
							L.LoseControlCompile:CompileSpells()
							SpellsConfig:UpdateSpellList(r[1])
						elseif (r[1] ~= r[2]) and (r[3] == r[4]) then --Means your moving a custom spell from PVP but differnt tab
							SpellsConfig:WipeSpellList(r[1])
							SpellsConfig:WipeSpellList(r[2])
							L.LoseControlCompile:CompileSpells()
							SpellsConfig:UpdateSpellList(r[1])
							SpellsConfig:UpdateSpellList(r[2])
						elseif (r[3] ~= r[4]) then --Means your moving a custom spell from PVE to PVP but differnt tab
							SpellsConfig:WipeSpellList(r[1])
							L.SpellsPVEConfig:WipeSpellList(r[2])
							L.LoseControlCompile:CompileSpells()
							SpellsConfig:UpdateSpellList(r[1])
							L.SpellsPVEConfig:UpdateSpellList(r[2])
						end
					elseif r[5] then --Means your moving an orignal spell
						  if r[5] == 1 then  --Moving Spell from PVP tab
							z = SpellsConfig:TabNumber(r[6])
							SpellsConfig:WipeSpellList(z)
							SpellsConfig:WipeSpellList(i)
							L.LoseControlCompile:CompileSpells()
							SpellsConfig:UpdateSpellList(z)
							SpellsConfig:UpdateSpellList(i)
						else --Moving Spell from PVE tab
							L.SpellsPVEConfig:WipeSpellList(r[5] - 1)
							SpellsConfig:WipeSpellList(i)
							L.LoseControlCompile:CompileSpells()
							L.SpellsPVEConfig:UpdateSpellList(r[5] - 1)
							SpellsConfig:UpdateSpellList(i)
						end
					end
				else  --Adding a new custom spell
					SpellsConfig:WipeSpellList(i)
					L.LoseControlCompile:CompileSpells()
					SpellsConfig:UpdateSpellList(i)
				end
				print("|cff00ccffLoseControl|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..tabs[i].." (PVP)")
	    end)
		end

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


function SpellsConfig:ResetSpellList(i)
	local c = contents[i]
	for spellCount = 1, (#L.spells[1] + 1) do
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

function SpellsConfig:WipeSpellList(i)
local c = contents[i]
 	for spellCount = 1, (#L.spells[1] + 1) do
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


function SpellsConfig:UpdateSpellList(i)
local numberOfSpellChecksPerRow = 5
if i == nil then return end
	local c = contents[i]
	local previousSpellID = nil
	local Y = -10
	local X = 230
	local spellCount = 1
	for l = 2, #L.spells[1] do
		local spellID, prio, zone, instanceType, duration, custom
		if L.spells[1][l] then
			if L.spells[1][l][1] then spellID = L.spells[1][l][1]	end
			if L.spells[1][l][2] then prio = L.spells[1][l][2] end
			if L.spells[1][l][3] then instanceType = L.spells[1][l][3] end
			if L.spells[1][l][4] then zone = L.spells[1][l][4] end
			if L.spells[1][l][5] then duration = L.spells[1][l][5] end
			if L.spells[1][l][6] then custom = L.spells[1][l][6] end
		end
			 if (spellID and prio and (string.lower(prio) == string.lower(tabs[i]))) then
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

				local raid_opts = {
				    ['name']='raid',
				    ['parent']=spellCheck,
				    ['title']='',
				    ['items']= tabs,
				    ['defaultVal']='',
				    ['changeFunc']=function(dropdown_frame, dropdown_val)
							if dropdown_val == "Delete" then
								---Call Stuff To Delete
							else
								for k, v in ipairs(tabs) do
									if dropdown_val == L[v] then
										dropdown_val = v
									end
								end
								local i2 = SpellsConfig:TabNumber(dropdown_val)
								 if i ~= i2 then
									 local spell, name
									 name = GetSpellInfo(tonumber(spellID))
									 if name then spell = tonumber(spellID) else spell = spellID end
									 tblinsert(_G.LoseControlDB.customSpellIds, 1, {spell, tabs[i2], nil, nil, nil,"custom", 1, i,"PVP", tabs[i]})  --v[7]: Category Tab to enter spell / v[8]: Tab to update / v[9]: Table / v[10]: tab name
									 local r = L.LoseControlCompile:CustomCompileSpells(spellID)
									 SpellsConfig:WipeSpellList(i)
									 SpellsConfig:WipeSpellList(i2)
									 L.LoseControlCompile:CompileSpells()
									 SpellsConfig:UpdateSpellList(i)
									 SpellsConfig:UpdateSpellList(i2)
									 print("|cff00ccffLoseControl|r : ".."|cff009900Added |r"..spell.." |cff009900to to list: |r"..tabs[i2].." (PVP)")
								 end
							 end
					   end
				}
				raidDD = SpellsConfig:createDropdown(raid_opts)

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
					if duration then
					aString = GetSpellInfo(spellID)..": "..duration or "SPELL REMOVED: "..spellID
					else
					aString = GetSpellInfo(spellID) or "SPELL REMOVED: "..spellID
					end
					spellCheck.icon:SetNormalTexture(GetSpellTexture(spellID) or 1)
				else
				spellCheck.icon:SetNormalTexture(1008124)
				end
				local cutString = string.sub(aString, 0, 23);
				if custom then
					spellCheck.text:SetText(cutString.."\n".."("..custom..")");
				else
					spellCheck.text:SetText(cutString);
				end
				if not duration then
				raidDD:SetPoint("LEFT", spellCheck.text, "RIGHT", -10,0)
				raidDD:SetScale(.55)
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

	function SpellsConfig:WipeAllSpellList()
		for i = 1, #tabs do
		SpellsConfig:WipeSpellList(i)
		end
	end
	function SpellsConfig:UpdateAllSpellList()
		for i = 1, #tabs do
		SpellsConfig:UpdateSpellList(i)
		end
	end
	function SpellsConfig:ResetAllSpellList()
		for i = 1, #tabs do
		SpellsConfig:ResetSpellList(i)
		end
	end


	function SpellsConfig:CreateMenu()
		UISpellsConfig = CreateFrame("Frame", "LoseControlSpellsConfig", UIParent, "UIPanelDialogTemplate");
		local hex = select(4, self:GetThemeColor());
		local BambiTag = string.format("|cff%s%s|r", hex:upper(), "By Bambi");
		UISpellsConfig.Title:SetText('LoseControl PVP Spells Config '..BambiTag)
		UISpellsConfig:SetFrameStrata("DIALOG");
		UISpellsConfig:SetFrameLevel(2);
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

		UISpellsConfig:Hide();
		return UISpellsConfig;
	end



function SpellsConfig:createDropdown(opts)
	    local dropdown_name = '$parent_' .. opts['name'] .. '_dropdown'
	    local menu_items = opts['items'] or {}
	    local title_text = opts['title'] or ''
	    local dropdown_width = 0
	    local default_val = opts['defaultVal'] or ''
	    local change_func = opts['changeFunc'] or function (dropdown_val) end

	    local dropdown = CreateFrame("Frame", dropdown_name, opts['parent'], 'UIDropDownMenuTemplate')
	    local dd_title = dropdown:CreateFontString(dropdown, 'OVERLAY', 'GameFontNormal')
	    dd_title:SetPoint("TOPLEFT", 20, 10)

	    for _, item in pairs(menu_items) do -- Sets the dropdown width to the largest item string width.
	        dd_title:SetText(item)
	        local text_width = dd_title:GetStringWidth() + 20
	        if text_width > dropdown_width then
	            dropdown_width = text_width
	        end
	    end

	    UIDropDownMenu_SetWidth(dropdown, 1)
	    UIDropDownMenu_SetText(dropdown, 1)
	    dd_title:SetText(title_text)

	    UIDropDownMenu_Initialize(dropdown, function(self, level, _)
	        local info = UIDropDownMenu_CreateInfo()
	        for key, val in pairs(menu_items) do
						if L[val] then val = L[val] end
	            info.text = val;
	            info.checked = false
	            info.menuList= key
	            info.hasArrow = false
	            info.func = function(b)
	                UIDropDownMenu_SetSelectedValue(dropdown, b.value, b.value)
	                UIDropDownMenu_SetText(dropdown, b.value)
	                b.checked = true
	                change_func(dropdown, b.value)
	            end
	            UIDropDownMenu_AddButton(info)
	        end
	    end)

	    return dropdown
		end
