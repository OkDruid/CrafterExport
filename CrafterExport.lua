-- CrafterExport.lua
local addon_name, CE = ...
local ExcludedRecipes = CE.ExcludedRecipes
local toggle = false

-- profession text colors
local professions = {
  Alchemy = "0.64, 0.82, 0.79",
  Blacksmithing = "0.51, 0.50, 0.51",
  Cooking = "0.91, 0.56, 0.36",
  Enchanting = "0.95, 0.36, 0.32",
  Engineering = "1, 0.89, 0.33",
  Inscription = "0.28, 0.53, 0.31",
  Jewelcrafting = "0.56, 0.42, 0.58",
  Leatherworking = "0.65, 0.5, 0.35",
  Mining = "0.49, 0.49, 0.41",
  Smelting = "0.49, 0.49, 0.41",
  Tailoring = "0.82, 0.78, 0.69"
}

function OnEvent(self, event, ...)

  CrafterExport:RegisterEvent("TRADE_SKILL_UPDATE")
  CrafterExport:RegisterEvent("CRAFT_UPDATE")

  -- When the profession window is closed
  if (event == "TRADE_SKILL_CLOSE") then
    CrafterExport:UnregisterEvent("TRADE_SKILL_UPDATE")
  end
  if (event == "CRAFT_CLOSE") then
    CrafterExport:UnregisterEvent("CRAFT_UPDATE")
  end

  openCrafterExport(toggle)

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

function isTradeOrCraft()
  local craftName, craftRank, _ = GetCraftDisplaySkillLine()
  
  if (craftRank > 0) then
    return CraftFrame
  else
    return TradeSkillFrame
  end
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function ProfessionTextColor(index)
  if (index) then
  CrafterExportText:SetTextColor(index:match("^%s*(.-)%s*$"):match("([^,]+),([^,]+),([^,]+)"))
  end
end

function openCrafterExport(closed)
  if not CrafterExportFrame then
    createCrafterExport()
  end
  
  local localizedClass, englishClass, classIndex = UnitClass("player")
  local source = GetRecipes()
  local recipes = Recipes(ExcludedRecipes, source)
  local recipeCount =  tablelength(source)
  local craftName, craftRank, _ = GetCraftDisplaySkillLine()
	local tsName, tsRank, _ = GetTradeSkillLine()
  local professionName = tsName
  if (craftRank > 0) then
    professionName = craftName
  end
  CrafterExportFrame.title:SetText("CrafterExport: " .. professionName .. " (" .. recipeCount .. ")")
  CrafterExportText:SetText(recipes:sub(1, -2))
  
  ProfessionTextColor(professions[professionName])
  
  if (closed) then
    CrafterExportFrame:Show()
    CrafterExportButton:SetText("Close CrafterExport")
  else
    CrafterExportFrame:Hide()
    CrafterExportButton:SetText("Open CrafterExport")
  end

end

function createCrafterExport() 
  local Profession = isTradeOrCraft()
  local frame = CreateFrame("Frame", "CrafterExportFrame", Profession, "TooltipBorderedFrameTemplate")
  frame:SetPoint("TOPRIGHT", Profession, 270, -12)
  frame:SetSize(300, 456)
  frame:SetBackdropBorderColor(255, 255, 255, 1)
  frame:SetBackdropColor(32/255, 34/255, 37/255)
  frame:SetMovable(false)
  frame:SetClampedToScreen(true)
  frame:SetFrameStrata("HIGH")

  frame.title = frame:CreateFontString(nil, "OVERLAY")
	frame.title:SetFontObject("SystemFont_Outline")
	frame.title:SetPoint("TOPLEFT", frame, 12, -10)	

  frame.scrollFrame = CreateFrame("ScrollFrame", "CrafterExportScroll", CrafterExportFrame, "UIPanelScrollFrameTemplate")
  frame.scrollFrame:SetPoint("TOP", 0, -32)
  frame.scrollFrame:SetPoint("BOTTOM", 0, 36)
  frame.scrollFrame:SetPoint("LEFT", 12, 0)
  frame.scrollFrame:SetPoint("RIGHT", -32, 0)
  
  frame.editBox = CreateFrame("EditBox", "CrafterExportText",  CrafterExportScroll)
  frame.editBox:SetPoint("TOPLEFT", frame.scrollFrame, 5, -5)
  frame.editBox:SetSize(frame.scrollFrame:GetSize())
  frame.editBox:SetMultiLine(true)
  frame.editBox:SetAutoFocus(false)
  frame.editBox:SetFontObject("SystemFont_Outline_Small")
  frame.editBox:SetMaxLetters(99999)
  --frame.editBox:EnableKeyboard(false)
  frame.editBox:SetScript("OnEscapePressed", function()
    frame:Hide()
  end)
  frame.scrollFrame:SetScrollChild(frame.editBox)

  frame.select = CreateFrame("Button", nil, CrafterExportFrame, "UIPanelButtonTemplate")
  frame.select:SetPoint("BOTTOM", 0, 7)
  frame.select:SetPoint("LEFT", 6, 0)
  frame.select:SetSize(288, 25)
  frame.select:SetText("Select All")
  frame.select:SetNormalFontObject("GameFontNormal")
  frame.select:SetHighlightFontObject("GameFontHighlight")
  frame.select:SetScript("OnClick", function() 
    frame.editBox:HighlightText()
    frame.editBox:SetFocus(true)
  end)

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
function Recipes(excluded, source)  
  local exportRecipes = ""
  local recipes = source
  
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
