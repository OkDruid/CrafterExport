-- CrafterExport.lua
local addon_name, CE = ...
local ExcludedRecipes = CE.ExcludedRecipes
local toggle = false


local function OnEvent(self, event, ...)

    -- When the profession window is open
	if (event == "TRADE_SKILL_SHOW") then 
    CrafterExport:RegisterEvent("TRADE_SKILL_UPDATE")
  end
  if (event == "CRAFT_SHOW") then 
    CrafterExport:RegisterEvent("CRAFT_UPDATE")
  end

  -- When the profession window is closed
  if (event == "TRADE_SKILL_CLOSE" or event == "CRAFT_CLOSE") then
      CrafterExport:UnregisterEvent("TRADE_SKILL_UPDATE")
      CrafterExport:UnregisterEvent("CRAFT_UPDATE")
  end
  if (event == "CRAFT_CLOSE") then
    CrafterExport:UnregisterEvent("CRAFT_UPDATE")
  end

  -- When a profession is changed or filtered
  if (event == "TRADE_SKILL_UPDATE" or event == "CRAFT_UPDATE") then
      openCrafterExport(toggle) 
  end

end

-- Create Frame and Register events
local CrafterExport = CreateFrame("Frame", "CrafterExport")
CrafterExport:RegisterEvent("TRADE_SKILL_SHOW")
CrafterExport:RegisterEvent("CRAFT_SHOW")
CrafterExport:RegisterEvent("TRADE_SKILL_CLOSE")
CrafterExport:RegisterEvent("CRAFT_CLOSE")
CrafterExport:SetScript("OnEvent", OnEvent)


function toggleCrafterExport(self)
  if (toggle) then
    toggle = false
  else
    toggle = true
  end
  openCrafterExport(toggle)
end

function openCrafterExport(closed)
  if not CrafterExportFrame then
    createCrafterExport()
  end

  local recipes = Recipes(ExcludedRecipes);

  CrafterExportText:SetText(recipes:sub(1, -2))
  CrafterExportText:HighlightText()

  if (closed) then
    CrafterExportFrame:Show()
    CrafterExportButton:SetText("Close CrafterExport")
  else
    CrafterExportFrame:Hide()
    CrafterExportButton:SetText("Open CrafterExport")
  end

end

function createCrafterExport() 
  local Profession = CraftFrame or TradeSkillFrame
  local frame = CreateFrame("Frame", "CrafterExportFrame", Profession, "DialogBoxFrame")
  frame:SetSize(340, 456)
  frame:SetPoint("TOPRIGHT", Profession, 310, -12)
  frame:SetMovable(false)
  frame:SetClampedToScreen(true)
  frame:SetBackdrop({ bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = { left = 4, right = 4, top = 4, bottom = 4 } })
  frame:SetBackdropBorderColor(255, 255, 255, 1)
  frame:SetBackdropColor(0.1, 0.1, 0.1, 1)
  frame:SetFrameStrata("HIGH")
  CrafterExportFrameButton:Hide()
  
  frame.scrollFrame = CreateFrame("ScrollFrame", "CrafterExportScroll", CrafterExportFrame, "UIPanelScrollFrameTemplate")
  frame.scrollFrame:SetPoint("TOP", 0, -18)
  frame.scrollFrame:SetPoint("BOTTOM", 0, 18)
  frame.scrollFrame:SetPoint("LEFT", 18, 0)
  frame.scrollFrame:SetPoint("RIGHT", -36, 0)
  
  frame.editBox = CreateFrame("EditBox", "CrafterExportText",  CrafterExportScroll)
  frame.editBox:SetPoint("TOPLEFT", frame.scrollFrame, 5, -5)
  frame.editBox:SetSize(CrafterExportScroll:GetSize())
  frame.editBox:SetMultiLine(true)
  frame.editBox:SetAutoFocus(false)
  frame.editBox:SetFontObject("ChatFontSmall")
  frame.editBox:SetMaxLetters(99999)
  frame.editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
  frame.scrollFrame:SetScrollChild(frame.editBox)
  
  frame.button = CreateFrame("Button", "CrafterExportButton", Profession, "UIPanelButtonTemplate")
  frame.button:SetPoint("BOTTOMLEFT", Profession, 10, 45)
  frame.button:SetSize(340, 25)
  frame.button:SetFrameLevel(10)
  frame.button:SetScript("OnClick", function() toggleCrafterExport(self) end)
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
