-- CrafterExport.lua
local addon_name, CE = ...
local Excluded = CE.ExcludedRecipes
local toggle = true

-- Create Frame and Register events
local CrafterExport = CreateFrame("Frame", "CrafterExport")
CrafterExport:Hide()
CrafterExport:RegisterEvent("TRADE_SKILL_SHOW")
CrafterExport:RegisterEvent("CRAFT_SHOW")
CrafterExport:RegisterEvent("TRADE_SKILL_CLOSE")
CrafterExport:RegisterEvent("CRAFT_CLOSE")

-- Handle events
CrafterExport:SetScript("OnEvent", function(self, event)

  -- When the profession window is open
	if (event == "TRADE_SKILL_SHOW" or event == "CRAFT_SHOW") then
		  CrafterExport:RegisterEvent("TRADE_SKILL_UPDATE")
      CrafterExport:RegisterEvent("CRAFT_UPDATE")
  end

  -- When the profession window is closed
	if (event == "TRADE_SKILL_CLOSE" or event == "CRAFT_CLOSE") then
		  CrafterExport:UnregisterEvent("TRADE_SKILL_UPDATE")
      CrafterExport:UnregisterEvent("CRAFT_UPDATE")
  end

  -- When a profession is changed or filtered
  if (event == "TRADE_SKILL_UPDATE" or event == "CRAFT_UPDATE") then
      ExportRecipes(Recipes(Excluded), toggle) 
  end

end)

-- Create Export Button, Frame, ScrollFrame and EditBox then pass recipe text and visibility state
function ExportRecipes(text, closed) 
  local Profession = CraftFrame or TradeSkillFrame

  if (Profession) then
    -- Create CrafterExportButton
    CrafterExport.button = CreateFrame("Button", "CrafterExportButton", Profession, "UIPanelButtonTemplate")
      CrafterExportButton:SetPoint("BOTTOMLEFT", Profession, 10, 45)
      CrafterExportButton:SetSize(340, 25)
      CrafterExportButton:SetFrameLevel(10)
      CrafterExportButton:SetScript("OnClick", function()
        toggleExport(self)
        CrafterExportText:SetFocus()
      end)
      CrafterExportButton:SetText("Open CrafterExport")

    -- Create CrafterExportFrame
    CrafterExport.frame = CreateFrame("Frame", "CrafterExportFrame", Profession, "DialogBoxFrame")
      CrafterExportFrameButton:Hide()
      CrafterExportFrame:SetSize(340, 456)
      CrafterExportFrame:SetPoint("TOPRIGHT", Profession, 310, -12)
      CrafterExportFrame:SetMovable(false)
      CrafterExportFrame:SetClampedToScreen(true)
      CrafterExportFrame:SetBackdrop({ 
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
        edgeSize = 16, 
        insets = { left = 4, right = 4, top = 4, bottom = 4 } 
      })
      CrafterExportFrame:SetBackdropBorderColor(255, 255, 255, 1)
      CrafterExportFrame:SetBackdropColor(0.1, 0.1, 0.1, 1)
      CrafterExportFrame:Hide()

    -- Create CrafterExportScroll
    CrafterExport.scroll = CreateFrame("ScrollFrame", "CrafterExportScroll", CrafterExport.frame, "UIPanelScrollFrameTemplate")
      CrafterExportScroll:SetPoint("TOP", 0, -18)
      CrafterExportScroll:SetPoint("BOTTOM", 0, 18)
      CrafterExportScroll:SetPoint("LEFT", 18, 0)
      CrafterExportScroll:SetPoint("RIGHT", -36, 0)

    -- Create CrafterExportText
    CrafterExport.text = CreateFrame("EditBox", "CrafterExportText",  CrafterExport.scroll)
      CrafterExportText:SetSize(CrafterExportScroll:GetSize())
      CrafterExportText:SetMultiLine(true)
      CrafterExportText:SetAutoFocus(false)
      CrafterExportText:SetFontObject("ChatFontSmall")
      CrafterExportText:SetScript("OnEscapePressed", function()
        CrafterExportFrame:Hide()
        toggleExport(self)
      end)
      CrafterExportScroll:SetScrollChild(CrafterExportText)


    if closed then
      CrafterExportFrame:Hide()
      CrafterExportButton:SetText("Open CrafterExport")
      CrafterExportText:SetText("")
    else
      CrafterExportFrame:Show()
      CrafterExportButton:SetText("Close CrafterExport")
      CrafterExportText:SetText(text:sub(1, -2))
      CrafterExportText:HighlightText()
    end

  end -- profession

end

-- set CrafterExportFrame visibility and trigger on button click
function toggleExport(self)
  if (toggle) then
    toggle = false
  else
    toggle = true
  end
  ExportRecipes(Recipes(Excluded), toggle)
end

-- get table of recipe names from open profession window
function GetRecipes()
  local name, type
  local recipes = {}
  local first = true

  if GetNumTradeSkills() > 1 then
      for i = 1, GetNumTradeSkills() do
          name, type, _, _, _, _ = GetTradeSkillInfo(i)
          if (name and type ~= "header") then
              if (first) then
                  recipes[i] = name
                  first = false
              else
                  recipes[i] = name
              end
          end
      end
  else
      for i = 1, GetNumCrafts() do
          name, _, type, _, _, _, _ = GetCraftInfo(i)
          if (name and type ~= "header") then
              if (first) then
                  recipes[i] = name
                  first = false
              else
                  recipes[i] = name
              end
          end
      end
  end

  return recipes

end

-- Iterate through recipes excluding those from trainers
function Recipes(excluded)  
  local exportRecipes = ""
  local recipes = GetRecipes()
  
  for index, recipe in pairs(recipes) do
    local exportRecipe = ""
    if not has_value(excluded, recipe) then
      exportRecipe = recipes[index] .. ","
    end
    exportRecipes = (exportRecipes .. exportRecipe)
  end

  if next(recipes) == nil then
    return "Expand category subclasses to include in the export.  "
  else 
    return exportRecipes
  end

end

-- check if a table has a specific value
function has_value(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return true
    end
  end
  return false
end