--------------------------------------------------------------------
--  NetherBot – Ace3 (3.3.5a)  •  locale-safe + scale-fix
--------------------------------------------------------------------
local AceAddon   = LibStub("AceAddon-3.0")
local AceConsole = LibStub("AceConsole-3.0")
local AceEvent   = LibStub("AceEvent-3.0")
local AceGUI     = LibStub("AceGUI-3.0")
local AceLocale = LibStub("AceLocale-3.0")
local GUI = LibStub("AceGUI-3.0")


-- 1) CRÉATION DE L’ADDON (doit venir en tout début)
local NetherBot = AceAddon:NewAddon("NetherBot", "AceConsole-3.0", "AceEvent-3.0")

-- 2) Chargement des locales & utilitaires
local L = AceLocale:GetLocale("NetherBot")
local function i18n(key)
  return (L and L[key]) or key
end

-- 2) Plus bas, une fois l’addon créé, récupérez les libs :
local LDB     = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0",       true)

-----------------------------------------------------------------
-- Variables d'erreur
-----------------------------------------------------------------
local ERR_SELECT_BOT = i18n("Error_SelectBot")

--------------------------------------------------------------------
--  Patch Module création de Bots
--------------------------------------------------------------------

--------------------------------------------------------------------
-- 1. Table NB_DATA
--------------------------------------------------------------------
local NB_DATA = _G.NB_DATA or error("[NetherBot] NB_DATA manquant (data/data.lua non chargé ?)")

local function buildList(src)
  local t = {}
  for k, v in pairs(src) do t[k] = v end
  return t
end

--------------------------------------------------------------------
-- 2. getLabel
--------------------------------------------------------------------
local function getLabel(cat, race, idx)
  local tbl = NB_DATA.Labels[cat] and NB_DATA.Labels[cat][race]
  if tbl and tbl[idx] then return tbl[idx] end
  return "#" .. tostring(idx)
end

-- Création / MAJ dynamique des listes visuelles ------------------
local function updateVisualDropdowns(race, gender, ddSkin, ddFace, ddHair, ddHairCol, ddFeat)
  if not (race and gender) then return end
  ddSkin:SetList(NB_DATA:BuildRangeList(race, gender, "skin"))
  ddFace:SetList(NB_DATA:BuildRangeList(race, gender, "face"))
  ddHair:SetList(NB_DATA:BuildRangeList(race, gender, "hair"))
  ddHairCol:SetList(NB_DATA:BuildRangeList(race, gender, "haircolor"))
  ddFeat:SetList(NB_DATA:BuildRangeList(race, gender, "features"))
end


--------------------------------------------------------------------
-- 3. Fenêtre
--------------------------------------------------------------------
function NetherBot:ShowCreateBotFrame()
  if self.createBotFrame and self.createBotFrame:IsShown() then return end
  local AceGUI = LibStub("AceGUI-3.0")
  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("BOT_CREATE_TITLE"))
  f:SetLayout("Flow")
  f:SetWidth(380)
  f:SetHeight(480)
  self.createBotFrame = f

----------------------------------------------------------------
-- Tooltips
----------------------------------------------------------------
local function addTooltip(widget, text)
  -- cible réelle : editbox si présent, sinon frame du widget
  local target = widget.editbox or widget.frame
  target:EnableMouse(true)                     -- indispensable pour EditBox
  target:SetScript("OnEnter", function(self)
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(text, 1, 1, 1, true)
      GameTooltip:Show()
  end)
  target:SetScript("OnLeave", GameTooltip_Hide)
end

  ----------------------------------------------------------------
  -- Widgets principaux
  ----------------------------------------------------------------
  local nameBox = AceGUI:Create("EditBox"); nameBox:SetLabel(i18n("BOT_NAME")); nameBox:SetFullWidth(true); addTooltip(nameBox, i18n("BOT_NAME_TOOLTIP")); nameBox.button:Hide(); f:AddChild(nameBox)

  local ddClass = AceGUI:Create("Dropdown"); ddClass:SetLabel(i18n("BOT_CLASS")); ddClass:SetList(buildList(NB_DATA.Classes)); ddClass:SetWidth(200); f:AddChild(ddClass)
  local ddRace  = AceGUI:Create("Dropdown"); ddRace:SetLabel(i18n("BOT_RACE")); ddRace:SetList(buildList(NB_DATA.Races));  ddRace:SetWidth(200); f:AddChild(ddRace)
  local ddGender= AceGUI:Create("Dropdown"); ddGender:SetLabel(i18n("BOT_GENDER"));       ddGender:SetList(buildList(NB_DATA.Genders)); ddGender:SetWidth(100); f:AddChild(ddGender)

  local ddSkin  = AceGUI:Create("Dropdown"); ddSkin:SetLabel(i18n("BOT_SKIN"));          ddSkin:SetWidth(90); f:AddChild(ddSkin)
  local ddFace  = AceGUI:Create("Dropdown"); ddFace:SetLabel(i18n("BOT_FACE"));        ddFace:SetWidth(90); f:AddChild(ddFace)
  local ddHair  = AceGUI:Create("Dropdown"); ddHair:SetLabel(i18n("BOT_HAIRSTYLE"));       ddHair:SetWidth(110); f:AddChild(ddHair)
  local ddHairC = AceGUI:Create("Dropdown"); ddHairC:SetLabel(i18n("BOT_HAIRCOLOR"));      ddHairC:SetWidth(110); f:AddChild(ddHairC)
  local ddFeat = AceGUI:Create("Dropdown"); ddFeat:SetLabel(i18n("BOT_FEATURES"));       ddFeat:SetWidth(90); addTooltip(ddFeat, i18n("BOT_FEATURES_TOOLTIP")); f:AddChild(ddFeat)
  local ddSS    = AceGUI:Create("Dropdown"); ddSS:SetLabel(i18n("BOT_SOUNDSET"));       ddSS:SetList(buildList(NB_DATA.Soundset)); ddSS:SetWidth(90); f:AddChild(ddSS)

----------------------------------------------------------------
-- Résumé dynamique
----------------------------------------------------------------
local summary = AceGUI:Create("Label")
summary:SetFullWidth(true)
summary:SetFontObject(GameFontHighlight)   -- objet, plus d’erreur
summary:SetText(" ")                      -- une ligne vide pour réserver la place
f:AddChild(summary)

----------------------------------------------------------------
-- Ranges
----------------------------------------------------------------
local function fillRanges()
  local r,g = ddRace:GetValue(), ddGender:GetValue()
  if not (r and g) then return end
  ddSkin:SetList(NB_DATA:BuildRangeList(r,g,"skin"))
  ddFace:SetList(NB_DATA:BuildRangeList(r,g,"face"))
  ddHair:SetList(NB_DATA:BuildRangeList(r,g,"hair"))
  ddHairC:SetList(NB_DATA:BuildRangeList(r,g,"haircolor"))
  ddFeat:SetList(NB_DATA:BuildRangeList(r,g,"features"))
end

----------------------------------------------------------------
-- Résumé
----------------------------------------------------------------
local function refreshSummary()
  local race   = ddRace  :GetValue() or -1
  local gender = ddGender:GetValue() or -1
  local nom    = nameBox:GetText():gsub("^%s+",""):gsub("%s+$","")
  if nom == "" then nom = "-" end

  -- récupère chaque étiquette traduite
  local H  = i18n("SUMMARY_HEADER")
  local Nl = i18n("SUMMARY_NAME_LABEL")
  local Cl = i18n("SUMMARY_CLASS_LABEL")
  local Rl = i18n("SUMMARY_RACE_LABEL")
  local Gl = i18n("SUMMARY_GENDER_LABEL")
  local Sl = i18n("SUMMARY_SKIN_LABEL")
  local Fl = i18n("SUMMARY_FACE_LABEL")
  local Hl = i18n("SUMMARY_HAIR_LABEL")
  local Col= i18n("SUMMARY_COLOR_LABEL")
  local Fe = i18n("SUMMARY_FEAT_LABEL")
  local Ss = i18n("SUMMARY_SS_LABEL")

  -- construit le texte avec %s
  local fmt = table.concat({
    H,
    string.format("|cffffd200%s :|r %s", Nl, nom),
    string.format("|cffffd200%s :|r %s", Cl, NB_DATA.Classes[ddClass:GetValue()] or "-"),
    string.format("|cffffd200%s :|r %s", Rl, NB_DATA.Races[race] or "-"),
    string.format("|cffffd200%s :|r %s", Gl, NB_DATA.Genders[gender] or "-"),
    string.format("|cffffd200%s :|r %s", Sl, getLabel("Skin", race, tonumber(ddSkin:GetValue()))),
    string.format("|cffffd200%s :|r %s", Fl, getLabel("Face", race, tonumber(ddFace:GetValue()))),
    string.format("|cffffd200%s :|r %s", Hl, getLabel("HairStyle", race, tonumber(ddHair:GetValue()))),
    string.format("|cffffd200%s :|r %s", Col, getLabel("HairColor", race, tonumber(ddHairC:GetValue()))),
    string.format("|cffffd200%s :|r %s", Fe, getLabel("Features", race, tonumber(ddFeat:GetValue()))),
    string.format("|cffffd200%s :|r %s", Ss, NB_DATA.Soundset[ddSS:GetValue()] or "-"),
  }, "\n")

  summary:SetText(fmt)
end

----------------------------------------------------------------
-- Callbacks centralisés
----------------------------------------------------------------
local function changed()
  fillRanges()
  refreshSummary()
end
for _,dd in ipairs{ddRace, ddGender, ddSkin, ddFace, ddHair, ddHairC, ddFeat, ddClass, ddSS} do
  dd:SetCallback("OnValueChanged", changed)
end

nameBox:SetCallback("OnTextChanged", changed)  -- pour mettre à jour le Nom
changed()  -- affichage initial

  ----------------------------------------------------------------
  -- Bouton Créer
  ----------------------------------------------------------------
  local btnCreate = AceGUI:Create("Button"); btnCreate:SetText(i18n("BOT_CREATE8BUTTON"))
  btnCreate:SetWidth(120)
btnCreate:SetCallback("OnClick", function()
  ----------------------------------------------------------------
  -- 1. Lecture brute du nom
  ----------------------------------------------------------------
  local rawName = nameBox:GetText() or ""

  -- 1.a Majuscule
  local first = rawName:sub(1,1)
  if not first:match("%u") then
    print(i18n("NAME_CAPS"))
    return
  end

  -- 1.b Pas d’espaces autorisés
  if rawName:find("%s") then
    print(i18n("NAME_UNDERSCORE"))
    return
  end

  ----------------------------------------------------------------
  -- 2. Normalisation : trim & underscores (pour safety)
  ----------------------------------------------------------------
  local name = rawName:gsub("^_+", ""):gsub("_+$", "")  -- enlève underscores adventices
  name = name:gsub("%s+", "_")                         -- encore, au cas où
  -- (mais normalement le rawName n’a plus d’espace)

  ----------------------------------------------------------------
  -- 3. Récupération des dropdowns
  ----------------------------------------------------------------
  local class  = ddClass :GetValue()
  local race   = ddRace  :GetValue()
  local gender = ddGender:GetValue()
  local skin   = ddSkin  :GetValue()
  local face   = ddFace  :GetValue()
  local hair   = ddHair  :GetValue()
  local color  = ddHairC :GetValue()
  local feat   = ddFeat  :GetValue()
  local ss     = ddSS    :GetValue()

  -- print("DEBUG values:", "name="..tostring(name), "class",class,"race",race,"gender",gender,"skin",skin,"face",face,"hair",hair,"color",color,"feat",feat,"ss",ss)

  ----------------------------------------------------------------
  -- 4. Vérification finale
  ----------------------------------------------------------------
  local missing = {}
  if name == ""                 then table.insert(missing,"Nom")     end
  if not class                  then table.insert(missing,"Classe")  end
  if not race                   then table.insert(missing,"Race")    end
  if not gender                 then table.insert(missing,"Genre")   end
  if not skin                   then table.insert(missing,"Peau")    end
  if not face                   then table.insert(missing,"Visage")  end
  if not hair                   then table.insert(missing,"Cheveux") end
  if not color                  then table.insert(missing,"Couleur") end
  if not feat                   then table.insert(missing,"Ornements") end
  if not ss                     then table.insert(missing,"Voix")    end

  if #missing > 0 then
    local msg = i18n("ERROR_MISSING_FIELDS"):format(table.concat(missing, ", "))
	print("|cffff0000[NetherBot]|r " .. msg)
    return
  end

  ----------------------------------------------------------------
  -- 5. Envoi de la commande
  ----------------------------------------------------------------
  local cmd = string.format(".npcbot createnew %s %d %d %d %d %d %d %d %d %d",
      name, class, race, gender, skin, face, hair, color, feat, ss)

  print("|cff55ff55Commande envoyée :|r", cmd)
  -- SendChatMessage(cmd, "SAY")
  f:Hide()
end)

  f:AddChild(btnCreate)

end

--------------------------------------------------------------------
--  FIN Patch Module création de Bots
--------------------------------------------------------------------

-- Foncfions pour delete un bot
StaticPopupDialogs["NB_DEL_CONFIRM"] = {
  text = "Delete current target or ID",
  button1 = "Target",
  button2 = "ID",
  OnAccept = function()
    local tgt = UnitName("target")
    if tgt then 
	-- SendChatMessage(".npcbot delete", "SAY") end
	ChatFrame1EditBox:SetText(".npcbot delete")
	ChatEdit_SendText(ChatFrame1EditBox, 0)	
	end
  end,
  OnCancel = function()
    StaticPopup_Show("NB_DEL_ID")
  end,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}

StaticPopupDialogs["NB_DEL_ID"] = {
  text = i18n("Enter NPCBOT ID:"),
  button1 = "Ok",
  button2 = "Cancel",
  hasEditBox = true,
  editBoxWidth = 100,
  timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
  OnAccept = function(self)
    local id = self.editBox:GetText()
    if id and id ~= "" then
      SendChatMessage(".npcbot delete id "..id, "SAY")
    end
  end,
}

StaticPopupDialogs["NB_DEL_FREE_CONFIRM"] = {
  text = i18n("ConfirmDeleteFree"),      -- clé de locale
  button1 = YES,                        -- “Oui”
  button2 = NO,                         -- “Non”
  OnAccept = function()
    -- SendChatMessage(".npcbot delete free", "SAY")
	ChatFrame1EditBox:SetText(".npcbot delete free")
	ChatEdit_SendText(ChatFrame1EditBox, 0)		
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}
-- Fin fonctions

--------------------------------------------------------------------
--  BUFFER & FENÊTRE D’INFO
--------------------------------------------------------------------
local infoBuffer = {}          -- stocke toutes les lignes capturées
local lookupBuffer = {}          -- Lookup-List

-- Variables pour lists
local otherBuffer      = {}    -- stocke chaque ligne “list spawned…”
local otherFrame       = nil   -- la fenêtre Ace
local otherContainer   = nil   -- le ScrollFrame interne

-- utilitaires
local function trim(s)  return (s:gsub("^%s*(.-)%s*$","%1")) end

-- 1) "Label : Valeur"
local function splitColon(line)
  local a,b = line:match("^%s*([^:]+):%s*(.+)$")
  if a and b ~= "" then return trim(a), trim(b) end
end

-- 2) "Label␠␠Valeur" ( ≥ 2 espaces / tab )
local function splitSpaces(line)
  local a,b = line:match("^%s*([^%s].-)%s%s+(.+)$")
  if a and b then return trim(a), trim(b) end
end

-- petit helper pour ne pas répéter la création d’un EditBox
function NetherBot:MakeEdit(label, text)
  local eb = AceGUI:Create("EditBox")
  eb:SetLabel(label)
  eb.label:SetTextColor(1,1,0)    -- jaune
  eb:SetText(text)
  eb.editbox:SetTextColor(1,1,1)  -- blanc
  eb:SetFullWidth(true)
  eb:DisableButton(true)
  eb:SetDisabled(true)
    -- ➜ recolore APRÈS SetDisabled
  eb.label  :SetTextColor(1, 1, 0)   -- jaune
  eb.editbox:SetTextColor(1, 1, 1)   -- blanc
  self.infoContainer:AddChild(eb)
end

--------------------------------------------------------------------
--  Ajoute un widget pour une ligne brute
--------------------------------------------------------------------
function NetherBot:AddInfoWidget(line)
  ----------------------------------------------------------
  -- 0) cas spécial : "Nom (classe : X), maître : Y"
  ----------------------------------------------------------
  if line:find("%(") and line:find(",") then
    for seg in line:gmatch("[^,]+") do
      seg = trim(seg)
      local name = seg:match("^(.-)%s*%(")
      local class = seg:match("classe%s*:%s*(%d+)")
      if name and class then                       -- "Nom (classe : X)"
        self:MakeEdit(name, "Classe "..class)
      else                                         -- "maître : Y" (ou autre)
        self:AddInfoWidget(seg)                    -- ré-analyse récursive
      end
    end
    return
  end

  ----------------------------------------------------------
  -- 1) "Label : Valeur"
  ----------------------------------------------------------
  local lbl,val = splitColon(line)
  if not lbl then                                  -- 2) sinon double-espace
    lbl,val = splitSpaces(line)
  end

  if lbl and val then
    self:MakeEdit(lbl, val)
  elseif line ~= "" then                           -- 3) simple titre/texte
    local l = AceGUI:Create("Label")
    l:SetText(line) ; l:SetColor(1,1,0) ; l:SetFullWidth(true)
    self.infoContainer:AddChild(l)
  end
end

--------------------------------------------------------------------
-- Widget capture liste Bots de la fonction LOOKUP
--------------------------------------------------------------------
function NetherBot:AddLookupWidget(line)

  -- 1. On retire les codes de lien « |Hcreature_entry:…|h »
  line = line:gsub("|Hcreature_entry:%d+|h", "")   -- enlève l’ouvre-lien
               :gsub("|h", "")                     -- enlève le |h fermant

  -- 2. Ligne type « 70515 - [Jorik] Human »   ou   « 70563[Caelnor] No Race »
local id, name, race = line:match("^(%d+)[^%[]*%[(.-)%]%s*(.*)$")
if id and name then

  -- 3) Editbox horizontal
  local row = AceGUI:Create("SimpleGroup")
  row:SetLayout("Flow")
  row:SetFullWidth(true)

  -- 4) Zone texte (EditBox figé)
  local eb = AceGUI:Create("EditBox")
  eb:SetLabel( i18n("LOOKUP_ID_LABEL").." : "..id )
  local nomLabel  = i18n("LOOKUP_NAME_LABEL")  ..": ".. name
  local raceLabel = i18n("LOOKUP_RACE_LABEL") ..": ".. (race ~= "" and race or "—")
  eb:SetText( ("%s    %s"):format(nomLabel, raceLabel) )
  eb:SetRelativeWidth(0.78)             -- ~80 % de la ligne

  eb:DisableButton(true)                -- supprime le bouton « X »
  eb:SetDisabled(true)                  -- grise l’EditBox
  eb.label  :SetTextColor(1,1,0)        -- jaune
  eb.editbox:SetTextColor(1,1,1)        -- blanc

  -- 5) Bouton « Invoquer »
  local btn = AceGUI:Create("Button")
  btn:SetText(i18n("B_INVOQUER"))
  btn:SetWidth(80)
  btn:SetHeight(19)
  -- btn.frame:GetNormalTexture():SetVertexColor(0.10, 1.00, 0.10) -- couleur verte pour le bouton
  btn:SetCallback("OnClick", function()
    SendChatMessage(".npcbot spawn "..id, "SAY")
  end)

  -- 6) tooltip sur le bouton
  btn:SetCallback("OnEnter", function(widget)
  GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
  GameTooltip:SetText(i18n("INVOQUER_TOOLTIP"))
  GameTooltip:Show()
  end)
  btn:SetCallback("OnLeave", function() GameTooltip:Hide() end)

  -- 7) Assemblage de la ligne
  row:AddChild(eb)
  row:AddChild(btn)
  self.lookupContainer:AddChild(row)
  return
end

  --------------------------------------------------------------------
  -- 3. Ligne d’en-tête « Looking for bots of class … »
  --------------------------------------------------------------------
  if line:find("^Looking for bots") then
    local lbl = AceGUI:Create("Label")
    lbl:SetText(line); lbl:SetFullWidth(true)
    self.lookupContainer:AddChild(lbl)
  end
end


--------------------------------------------------------------------
--  Crée / actualise la fenêtre d’info
--------------------------------------------------------------------
function NetherBot:ShowInfoWindow()
  if not self.infoFrame then
    local f = AceGUI:Create("Frame")
    f:SetTitle(i18n("Bot-Info"))
    f:SetLayout("Fill")
    f:SetWidth(480); f:SetHeight(420)
    f:SetCallback("OnClose", function(w)
      AceGUI:Release(w)
      self.infoFrame, self.infoContainer = nil, nil
    end)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List"); scroll:SetFullWidth(true); scroll:SetFullHeight(true)
    f:AddChild(scroll)
    self.infoFrame, self.infoContainer = f, scroll
  end

  self.infoContainer:ReleaseChildren()         -- on repart d’un conteneur vide
  for _,ln in ipairs(infoBuffer) do
    self:AddInfoWidget(ln)
  end
  self.infoFrame:Show()
end

------------------------------------------------------------------
-- Parseur list spawned / free
------------------------------------------------------------------
local function parseSpawnedLine(line)
  local id, name, class, lvl, loc, state =
        line:match('^%s*%d+%)%s*(%d+):%s*([^%-]+)%s*%-%s*([^%-]+)%s*%-%s*level%s*(%d+)%s*%-%s*"([^"]+)"%s*%-%s*(.+)$')
  if not id then
        -- variante sans le bloc - état
        id, name, class, lvl, loc =
          line:match('^%s*%d+%)%s*(%d+):%s*([^%-]+)%s*%-%s*([^%-]+)%s*%-%s*level%s*(%d+)%s*%-%s*"([^"]+)"')
  end
  return id, (name or ""):gsub("%s*$",""),
             (class or ""):gsub("%s*$",""), lvl, loc, state
end

--------------------------------------------------------------------
-- Widget capture liste Bots spawned
--------------------------------------------------------------------
--[[function NetherBot:AddSpawnedWidget(line)
  local id, name, class, lvl, loc, state = parseSpawnedLine(line)
  if not id then return end                          -- pas une ligne cible

  -- Couleur de classe Blizzard
  local clsKey = class:upper():gsub("%s","")
  local col    = RAID_CLASS_COLORS[clsKey] or {r=1,g=1,b=1}
  local hex    = ("%02x%02x%02x"):format(col.r*255,col.g*255,col.b*255)

  --------------------- conteneur horizontal ----------------------
  local row = AceGUI:Create("SimpleGroup")
  row:SetLayout("Flow"); row:SetFullWidth(true)

  --------------------- EditBox figé ------------------------------
  local eb  = AceGUI:Create("EditBox")
  local font, size, flag = eb.editbox:GetFont()
  eb.editbox:SetFont(font, size - 5, flag)  -- -2 = police un peu plus petite
  eb:SetLabel( ("%s : %s"):format(i18n("BOT_ID"), id) )

  local txt = ("%s: %s    %s: |cff%s%s|r    %s: %s    %s: %s%s")
              :format( i18n("NAME_LABEL"),  name,
                        i18n("CLASS_LABEL"), hex, class,
                        i18n("LEVEL_LABEL"), lvl,
                        i18n("LOCATION_LABEL"), loc or "—",
                        state and ("    "..i18n("STATE_LABEL")..": "..state) or "")

  eb:SetText(txt)
  eb:SetRelativeWidth(0.78)
  eb:DisableButton(true); eb:SetDisabled(true)
  eb.label  :SetTextColor(1, 1, 0)   -- jaune
  eb.editbox:SetTextColor(1,1,1)

  --------------------- Bouton Spawn ------------------------------
  local btn = AceGUI:Create("Button")
  btn:SetText(i18n("Move"))
  btn:SetWidth(80)
  btn:SetHeight(19)
  btn:SetCallback("OnClick", function()
        SendChatMessage(".npcbot move "..id, "SAY")
      end)  	
  --------------------- Assemblage -------------------------------
  row:AddChild(eb)
  row:AddChild(btn)
  otherContainer:AddChild(row)
end]]
function NetherBot:AddSpawnedWidget(line)
  local id, name, class, lvl, loc, state = parseSpawnedLine(line)
  if not id then return end                               -- ligne hors-format

  -- ---------- couleur de classe Blizzard ----------
  local clsKey = class:upper():gsub("%s","")
  local col    = RAID_CLASS_COLORS[clsKey] or {r=1,g=1,b=1}
  local hex    = ("%02x%02x%02x"):format(col.r*255,col.g*255,col.b*255)

  -- ---------- conteneur horizontal ----------
  local row = AceGUI:Create("SimpleGroup")
  row:SetLayout("Flow")
  row:SetFullWidth(true)

  -- ---------- EditBox figé ----------
  local eb = AceGUI:Create("EditBox")
  local font, _, flag = eb.editbox:GetFont()
  eb.editbox:SetFont(font, 10, flag)
  eb:SetLabel( ("%s : %s"):format(i18n("BOT_ID"), id) )

  local txt = ("%s: %s    %s: |cff%s%s|r    %s: %s    %s: %s%s")
              :format( i18n("NAME_LABEL"),   name,
                        i18n("CLASS_LABEL"), hex,  class,
                        i18n("LEVEL_LABEL"), lvl,
                        i18n("LOCATION_LABEL"), loc or "—",
                        state and ("    "..i18n("STATE_LABEL")..": "..state) or "" )

  eb:SetText(txt)
  -- eb:SetRelativeWidth(0.82)           -- laisse ~40 % pour les 3 boutons
  eb:SetFullWidth(true)
  eb:DisableButton(true); eb:SetDisabled(true)
  eb.label  :SetTextColor(1,1,0)
  eb.editbox:SetTextColor(1,1,1)

  -- ------------------------------------------------------------------
  --  Petit helper local pour créer un bouton homogène (+ tooltip)
  ---------------------------------------------------------------------
  local function makeSmallBtn(labelKey, tooltipKey, clickFn)
    local b = AceGUI:Create("Button")
    b:SetText(i18n(labelKey))
    b:SetRelativeWidth(0.13)          -- 3 boutons × 13 % ≈ 39 %
    b:SetHeight(19)

    b:SetCallback("OnClick", clickFn)

    b:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame,"ANCHOR_RIGHT")
        GameTooltip:SetText(i18n(labelKey),1,1,0)
        GameTooltip:AddLine(i18n(tooltipKey),1,1,1,true)
        GameTooltip:Show()
      end)
    b:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    return b
  end

  -- ---------- Bouton « Move » ----------
  local btnMove = makeSmallBtn("Move", "MOVE_TOOLTIP", function()
                     SendChatMessage(".npcbot move "..id, "SAY")
                   end)

  -- ---------- Bouton « Go » ----------
  local btnGo   = makeSmallBtn("Bot_Go", "Bot_Go_tooltip", function()
                     SendChatMessage(".npcbot go "..id, "SAY")
                   end)

  -- ---------- Assemblage ----------
  row:AddChild(eb)
  row:AddChild(btnMove)
  row:AddChild(btnGo)
  otherContainer:AddChild(row)
end

--------------------------------------------------------------------
--  FRAME D'AFFICHAGE DE LA CAPTURE DE LA LISTE DES BOTS
--------------------------------------------------------------------
function NetherBot:ShowLookupWindow(title)
  if not self.lookupFrame then
    local f = AceGUI:Create("Frame")
    f:SetTitle(title or "Lookup-List")
    f:SetLayout("Fill")
	f:SetStatusText(i18n("LOOKUP_STATUS"))
    f:SetWidth(520); f:SetHeight(420)
    f:SetCallback("OnClose", function(w)
      AceGUI:Release(w)
      self.lookupFrame, self.lookupContainer = nil, nil
    end)
    local scroll = AceGUI:Create("ScrollFrame")
    scroll:SetLayout("List"); scroll:SetFullWidth(true); scroll:SetFullHeight(true)
    f:AddChild(scroll)
    self.lookupFrame, self.lookupContainer = f, scroll
  else
    self.lookupFrame:SetTitle(title or "Lookup-List")
  end

  self.lookupContainer:ReleaseChildren()
  for _,ln in ipairs(lookupBuffer) do
    self:AddLookupWidget(ln)
  end
  self.lookupFrame:Show()
end

--------------------------------------------------------------------
--  Capture des messages affichés dans la fenêtre de chat
--------------------------------------------------------------------
function NetherBot:OnChatMsg(_, msg)
  table.insert(infoBuffer, msg)
  if self.infoContainer then          -- si la fenêtre est ouverte, live-update
    self:AddInfoWidget(msg)
  end
  
  -- Lookup-window
  if self.lookupContainer then
    table.insert(lookupBuffer, msg)
    self:AddLookupWidget(msg)
  end
  -- Liste spawned
  if otherContainer then
  -- on garde tout (pour réafficher plus tard)…
  table.insert(otherBuffer, msg)
  -- …et on crée un widget à la volée
  self:AddSpawnedWidget(msg)
  end

end
-- FIN CAPTURE

-- ---------- DB & slash ----------
function NetherBot:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("NetherbotDB", {
    profile = {
      scale       = 1,
      minimapIcon = { hide = false },
    },
  })
end

-- Créez l’objet LDB
local dataObj = LDB:NewDataObject("NetherBot", {
  type = "launcher",
  icon = "Interface\\Icons\\INV_Misc_EngGizmos_20",
  OnClick = function(_, button)
    if button == "LeftButton" then
      -- si la fenêtre existe déjà, on la ferme, sinon on l’ouvre
      if NetherBot.gui then
        NetherBot:HideGUI()
      else
        NetherBot:ShowGUI()
      end
    else
      NetherBot:ToggleRaid()
    end
  end,
  OnTooltipShow = function(tt)
    tt:AddLine("NetherBot")
    tt:AddLine("Left-clic : Ouvrir/Fermer le GUI", 1,1,1)
    tt:AddLine("Clic-droit : Toggle Raid-Frame",1,1,1)
  end,
})

function NetherBot:OnEnable()
   self:RegisterChatCommand("netherbot", "HandleSlash")
   self:RegisterEvent("CHAT_MSG_SAY"   , "OnChatMsg")
   self:RegisterEvent("CHAT_MSG_SYSTEM", "OnChatMsg")
  self.db = LibStub("AceDB-3.0"):New("NetherbotDB", {
    profile = { minimapIcon = { hide = false } }
  })
  LDBIcon:Register("NetherBot", dataObj, self.db.profile.minimapIcon)
end

-- commande pour toggle l’icône
function NetherBot:ToggleMinimap()
  local iconDB = self.db.profile.minimapIcon
  iconDB.hide = not iconDB.hide
  LDBIcon:Refresh("NetherBot")
end
NetherBot:RegisterChatCommand("nbminimap", "ToggleMinimap")


function NetherBot:HandleSlash(msg)
  msg = (msg or ""):lower()
  if msg == "show"      then self:ShowGUI()
  elseif msg == "hide"  then self:HideGUI()
  else self:Print("/netherbot show  –  /netherbot hide") end
end

-- pré-déclaration pour que Lua sache qu’il existe localement
-- local initializeFramesAndBars
initializeFramesAndBars = nil

-- Maintenant avec un paramètre tooltipText en option
--[[local function addButton(parent, label, w, cb, tooltipText)
  local b = AceGUI:Create("Button")
  b:SetText(label)
  b:SetWidth(w or 110)
  b:SetCallback("OnClick", cb)

  -- si on a un texte de tooltip, on branche GameTooltip
  if tooltipText then
    b:SetCallback("OnEnter", function(widget)
      GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
      GameTooltip:SetText(label)                     -- titre du tooltip
      GameTooltip:AddLine(tooltipText, 1,1,1, true)   -- description
      GameTooltip:Show()
    end)
    b:SetCallback("OnLeave", function()
      GameTooltip:Hide()
    end)
  end

  parent:AddChild(b)
  return b
end]]
local function addButton(parent, labelKey, widthWanted, onClick, tooltipText)
  local b = AceGUI:Create("Button")

  ------------------------------------------------------------
  -- 1) Texte + callback
  ------------------------------------------------------------
  b:SetText(i18n(labelKey))
  b:SetAutoWidth(true)                   -- largeur sur le texte
  b:SetCallback("OnClick", onClick)

  ------------------------------------------------------------
  -- 2) Largeur minimale éventuelle
  ------------------------------------------------------------
  if type(widthWanted) == "number" then               -- sécurité !
    if b.frame:GetWidth() < widthWanted then
      b:SetWidth(widthWanted)
    end
  end

  ------------------------------------------------------------
  -- 3) Tooltip (optionnel)
  ------------------------------------------------------------
  if tooltipText then
    b:SetCallback("OnEnter", function(widget)
      GameTooltip:SetOwner(widget.frame,"ANCHOR_RIGHT")
      GameTooltip:SetText(i18n(labelKey),1,1,0)
      GameTooltip:AddLine(tooltipText,1,1,1,true)
      GameTooltip:Show()
    end)
    b:SetCallback("OnLeave", GameTooltip_Hide)
  end

  parent:AddChild(b)
  return b
end

--------------------------------------------------------------------
--  Main GUI
--------------------------------------------------------------------
function NetherBot:ShowGUI()
if self.gui then                  -- le widget existe déjà
    self.gui:Show()               -- on le ré-affiche
    return
end

  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("NetherBot_title")); f:SetStatusText(i18n("Version"))
  f:SetLayout("Flow")
  f:SetWidth(400); f:SetHeight(400)
  f.frame:SetResizable(true); f.frame:SetMinResize(400,400)
  f.frame:SetScale(self.db.profile.scale or 1)
  f:SetCallback("OnClose", function(w)
    AceGUI:Release(w)
    self.gui = nil
end)
  self.gui = f

  local af = _G["NetherbotAdminFrame"]
  if af then
    af:ClearAllPoints()
    af:SetPoint("LEFT", f.frame, "RIGHT", 10, 0)
  end

  -------------------------------------------------- ligne 1
  addButton(f, "Follow",90,function() SendChatMessage(".npcbot command follow","SAY") end, i18n("Follow_tooltip"))
  addButton(f, "Stand", 90,function() SendChatMessage(".npcbot command standstill","SAY") end, i18n("Stand_tooltip"))
  addButton(f, "Stop",  90,function() SendChatMessage(".npcbot command stopfully","SAY") end, i18n("Stop_tooltip"))
  addButton(f, "Slack", 90,function() SendChatMessage(".npcbot command follow only","SAY") end, i18n("Slack_tooltip"))

  local sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)

  -------------------------------------------------- ligne 2
  addButton(f, "UnHide",90,function() SendChatMessage(".npcbot unhide","SAY") end, i18n("UnHide_tooltip"))
  addButton(f, "Hide",  90,function() SendChatMessage(".npcbot hide","SAY") end, i18n("Hide_tooltip"))
  addButton(f, "Recall",90,function() SendChatMessage(".npcbot recall teleport","SAY") end, i18n("Recall_tooltip"))
  addButton(f, "Unbind",90,function() SendChatMessage(".npcbot command unbind","SAY") end, i18n("Unbind_tooltip"))

  sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)

  -------------------------------------------------- ligne 3
  addButton(f,"Dist 30",90,function() SendChatMessage(".npcbot distance 30","SAY") end, i18n("Dist_30_tooltip"))
  addButton(f,"Dist 50",90,function() SendChatMessage(".npcbot distance 50","SAY") end, i18n("Dist_50_tooltip"))
  addButton(f,"Dist 85",90,function() SendChatMessage(".npcbot distance 85","SAY") end, i18n("Dist_85_tooltip"))

  sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)

  -------------------------------------------------- ligne 3.1
  addButton(
	f,
	"GearScore",
	110,
	function()
		local tgt = UnitName("target")
		if tgt then
		ChatFrame1EditBox:SetText(".npcbot gs")
		ChatEdit_SendText(ChatFrame1EditBox, 0)
		else
		print("|cffff0000[NetherBot]|r " .. ERR_SELECT_BOT)
		end
	end,
	i18n("GearScore_tooltip")   -- texte d’aide existant
  )
  
  sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)
  
  -------------------------------------------------- ligne 4
  addButton(f, "Spawn Bot",120,function() self:SpawnDialog() end, i18n("Spanw_bot_tooltip"))
  addButton(f, "Revive",    120,function() SendChatMessage(".npcbot revive","SAY") end, i18n("Revive_tooltip"))

  sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)

  -------------------------------------------------- ligne 5
  addButton(f, "Admin", 80, function() NetherBot:ToggleAdminFrame() end, i18n("Admin_tooltip"))
  addButton(f,"Lookup", 100, function() NetherBot:ToggleLookupFrame() end, i18n("Lookup_tooltip"))
  addButton(f,"RaidFrame",   100,function()
                               if TeamFrame:IsShown() then TeamFrame:Hide()
                               else initializeFramesAndBars(); TeamFrame:Show() end
                             end, i18n("Raidframe_tooltip"))
  -------------------------------------------------- ligne 6
  
  sep = AceGUI:Create("Heading"); sep:SetFullWidth(true); f:AddChild(sep)
  
  addButton(f, "OTHER_COMMANDS", 175, 
    function()
      if not NetherBot.otherFrame then
        NetherBot:CreateOtherCommandsFrame()
      else
        NetherBot.otherFrame:Show()
      end
    end,
    i18n("OTHER_COMMANDS_TOOLTIP")
  )

  f:Show()
end


function NetherBot:HideGUI()
  if self.gui then self.gui:Hide() end
end

------------------------------------------------------------------
--  FRAME DE CAPTURE LOOKUP DU CHAP ET SPAWN BOTS
------------------------------------------------------------------
function NetherBot:SpawnDialog()
  local dlg = AceGUI:Create("Frame")
  dlg:SetTitle(i18n("Spawn Bot"))
  dlg:SetStatusText(i18n("Spawn_bot_by_ID"))
  dlg:SetWidth(300); dlg:SetHeight(150)
  dlg:SetLayout("Flow")

  --  Empêche tout redimensionnement
  if dlg.EnableResize then          -- AceGUI >= r1132
    dlg:EnableResize(false)         -- API officielle
  else                              -- fallback sur le frame natif
    dlg.frame:SetResizable(false)
    if dlg.resizebutton then dlg.resizebutton:Hide() end
    if dlg.sizer_se     then dlg.sizer_se    :Hide() end
  end
  
  local eb = AceGUI:Create("EditBox")
  eb:SetLabel(i18n("Entry ID")); eb:SetWidth(160)
  dlg:AddChild(eb)

  local ok = AceGUI:Create("Button")
  ok:SetText("OK")
  ok:SetWidth(60)
  ok:SetHeight(19)
  ok:SetCallback("OnClick", function()
    
  local id = (eb:GetText() or ""):gsub("^%s*(.-)%s*$", "%1")  -- trim espaces

	if id == "" then
	print(i18n("FILL_ID_FIELD"))
	return            -- on laisse la fenêtre ouverte
	end
    dlg:Release()
  end)
  
  dlg:AddChild(ok)
end

------------------------------------------------------------------
--  Lance un lookup et ouvre / met à jour la fenêtre “Lookup-List”
------------------------------------------------------------------
function NetherBot:StartLookup(classId, className)
  wipe(lookupBuffer)                        -- vide le buffer
  self:ShowLookupWindow(i18n("Lookup").." – "..className)
  SendChatMessage(".npcbot lookup "..classId, "SAY")
end


--------------------------------------------------------------------
--  FRAME AUTRES COMMANDES
--------------------------------------------------------------------
function NetherBot:CreateOtherCommandsFrame()
  if otherFrame then otherFrame:Show() return end   -- déjà ouverte

  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("OTHER_COMMANDS"))
  f:SetWidth(660);  f:SetHeight(320)
  f:SetLayout("Flow")
  f:SetCallback("OnClose", function(w)
        AceGUI:Release(w)
        otherFrame, otherContainer = nil, nil
      end)

  --  positionné à droite de la GUI principale, si ouverte
  if self.gui and self.gui.frame:IsShown() then
    f.frame:SetPoint("LEFT", self.gui.frame, "RIGHT", 10, 0)
  end

  -- ---  Deux boutons haut  ------------------------------
  local function addCmdButton(label, cmd, help)
    local b = AceGUI:Create("Button")
    b:SetText(i18n(label))
    b:SetWidth(200)
    b:SetCallback("OnClick", function()
          wipe(otherBuffer)                 -- vide l’ancien contenu
          otherContainer:ReleaseChildren()
          SendChatMessage(cmd, "SAY")
        end)
    b:SetCallback("OnEnter", function(widget)
          GameTooltip:SetOwner(widget.frame,"ANCHOR_RIGHT")
          GameTooltip:SetText(i18n(label),1,1,0)
          GameTooltip:AddLine(help,1,1,1,true)
          GameTooltip:Show()
        end)
    b:SetCallback("OnLeave",function() GameTooltip:Hide() end)
    f:AddChild(b)
  end

  addCmdButton("LIST_SPAWNED",       ".npcbot list spawned",
               i18n("LIST_SPAWNED_TOOLTIP"))
  addCmdButton("LIST_SPAWNED_FREE",  ".npcbot list spawned free",
               i18n("LIST_SPAWNED_FREE_TOOLTIP"))

  -- ---  ScrollFrame pour le résultat  --------------------
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("List")
  scroll:SetFullWidth(true); scroll:SetFullHeight(true)
  f:AddChild(scroll)

  --  mémos globaux
  otherFrame, otherContainer = f, scroll
end

-----------------------------------------------------------------
--  ADMIN FRAME AceGUI
-----------------------------------------------------------------
--[[function NetherBot:CreateAdminFrame()
  if self.adminAce then return self.adminAce end         -- singleton

  local AceGUI = LibStub("AceGUI-3.0")

  ----------------------------------------------------------------
  -- 1) Cadre principal
  ----------------------------------------------------------------
  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("Admin"))
  f:SetWidth(400)
  f:SetHeight(220)
  f:SetLayout("Flow")
  f.frame:SetResizable(false)
  self.adminAce = f
  return f
end]]
function NetherBot:CreateAdminFrame()
  if self.adminAce then return self.adminAce end  -- singleton

  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("Admin"))
  f:SetWidth(400)
  f:SetHeight(220)
  f:SetLayout("Flow")
  f.frame:SetResizable(false)

  ----------------------------------------------------------------
  -- Position automatique quand la fenêtre apparaît
  ----------------------------------------------------------------
  f.frame:HookScript("OnShow", function(frame)
    frame:ClearAllPoints()
    if NetherBot.gui and NetherBot.gui.frame and NetherBot.gui.frame:IsShown() then
      -- Colle l’admin à droite de la main-frame, 10 px d’écart
      frame:SetPoint("TOPLEFT", NetherBot.gui.frame, "TOPRIGHT", 10, 0)
    else
      -- Sinon, on centre l’admin à l’écran
      frame:SetPoint("CENTER", UIParent, "CENTER")
    end
  end)

  self.adminAce = f
  return f
end

--------------------------------------------------------------------
-- 2) Boutons (Add, Remove, …) placés dans la fenêtre
--------------------------------------------------------------------
function NetherBot:PopulateAdminFrame()
  local f = self:CreateAdminFrame()
  if f._populated then return end      -- on ne le fait qu’une fois

--[[  local function addBtn(label, tooltip, cb, w)
    local b = AceGUI:Create("Button")
    b:SetText(i18n(label))
    b:SetWidth(w or 100)
    b:SetCallback("OnClick", cb)
    if tooltip then
      b:SetCallback("OnEnter", function(widget)
        GameTooltip:SetOwner(widget.frame,"ANCHOR_RIGHT")
        GameTooltip:SetText(i18n(label),1,1,0)
        GameTooltip:AddLine(tooltip,1,1,1,true)
        GameTooltip:Show()
      end)
      b:SetCallback("OnLeave", function() GameTooltip:Hide() end)
    end
    f:AddChild(b)
  end]]
-- Helper "élastique" : la largeur s’adapte au texte
--  ──────────────────────────────────────────────────
--  • label     → clé de locale (ou texte brut)
--  • tooltip   → texte de l’infobulle (facultatif)
--  • cb        → callback OnClick
--  • minWidth  → largeur mini souhaitée (facultatif)

local function addBtn(label, tooltip, cb, minWidth)
  local b = AceGUI:Create("Button")

  ------------------------------------------------------------
  -- 1) Texte, largeur auto et callback principal
  ------------------------------------------------------------
  b:SetText(i18n(label))
  b:SetAutoWidth(true)        -- ← adapte la taille au texte localisé
  b:SetCallback("OnClick", cb)

  -- Si vous tenez à un plancher de largeur :
  if minWidth then
    local w = b.frame:GetWidth()
    if w < minWidth then b:SetWidth(minWidth) end
  end

  ------------------------------------------------------------
  -- 2) Infobulle (inchangé)
  ------------------------------------------------------------
  if tooltip then
    b:SetCallback("OnEnter", function(widget)
      GameTooltip:SetOwner(widget.frame, "ANCHOR_RIGHT")
      GameTooltip:SetText(i18n(label), 1, 1, 0)
      GameTooltip:AddLine(tooltip, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    b:SetCallback("OnLeave", function() GameTooltip:Hide() end)
  end

  ------------------------------------------------------------
  -- 3) Ajout dans votre conteneur AceGUI
  ------------------------------------------------------------
  f:AddChild(b)   -- « f » est la frame AceGUI dans votre scope
  return b
end

  ----------------------------------------------------------------
  --  ligne 1
  ----------------------------------------------------------------
  addBtn("Add", i18n("Add_tooltip"), function()
      local tgt = UnitName("target")
      if tgt then
		-- SendChatMessage(".npcbot add","SAY")
		ChatFrame1EditBox:SetText(".npcbot add")
		ChatEdit_SendText(ChatFrame1EditBox, 0)
      else
		print("|cffff0000[NetherBot]|r " .. ERR_SELECT_BOT)
        StaticPopup_Show("NB_ADD")
      end
    end)

  addBtn("Remove",     i18n("Remove_tooltip"), function()
      local tgt = UnitName("target")
      if tgt then
		ChatFrame1EditBox:SetText(".npcbot remove")
		ChatEdit_SendText(ChatFrame1EditBox, 0)		
      else
	    print("|cffff0000[NetherBot]|r " .. ERR_SELECT_BOT)
        StaticPopup_Show("NB_REM")
      end
    end)

  addBtn("Recall", i18n("Recall_tooltip"), function()
	  local tgt = UnitName("target")
	  if tgt then
		ChatFrame1EditBox:SetText(".npcbot recall")
		ChatEdit_SendText(ChatFrame1EditBox, 0)	
	  else
		  print("|cffff0000[NetherBot]|r " .. ERR_SELECT_BOT)
		  StaticPopup_Show("NB_RECALL")
	  end
	end)

  addBtn("Recall_Spawn_Bt", i18n("Recall_Spawn_tooltip"), function()
		ChatFrame1EditBox:SetText(".npcbot recall spawns")
		ChatEdit_SendText(ChatFrame1EditBox, 0)	
	end)	

  addBtn("Recall_teleport_Bt", i18n("Recall_teleport_tooltip"), function()
		ChatFrame1EditBox:SetText(".npcbot recall teleport")
		ChatEdit_SendText(ChatFrame1EditBox, 0)	
	end)
  ----------------------------------------------------------------
  --  ligne 2
  ----------------------------------------------------------------
  addBtn("Bot-Info",   i18n("Info_tooltip"), function()
      wipe(infoBuffer)
      NetherBot:ShowInfoWindow()
	  ChatFrame1EditBox:SetText(".npcbot info")
	  ChatEdit_SendText(ChatFrame1EditBox, 0)	  
      DoEmote("BONK")
    end)

  addBtn("Move",       i18n("MOVE_TOOLTIP"),
         function() SendChatMessage(".npcbot move","SAY") end)

  addBtn("Delete",     i18n("Delete_tooltip"),
         function() StaticPopup_Show("NB_DEL_CONFIRM") end)

  ----------------------------------------------------------------
  --  ligne 3
  ----------------------------------------------------------------
  addBtn("Delete Free",i18n("DeleteFree_tooltip"),
         function() StaticPopup_Show("NB_DEL_FREE_CONFIRM") end, 0)

  addBtn("CREATE_BOT", i18n("CREATE_BOT_TOOLTIP"),
         function() NetherBot:ShowCreateBotFrame() end, 0)
		 
  --------------------	Set Free Bouton --------------------------
  addBtn("Set_Free",     i18n("Set_Free_tooltip"), function()
      local tgt = UnitName("target")
      if tgt then
		ChatFrame1EditBox:SetText(".npcbot free")
		ChatEdit_SendText(ChatFrame1EditBox, 0)		
      else
	    print("|cffff0000[NetherBot]|r " .. ERR_SELECT_BOT)
        StaticPopup_Show("NB_SET_FREE")
      end
    end)

  --------------------	Reload Bouton --------------------------
  addBtn("Conf_Reload",     i18n("Conf_Reload_tooltip"), function()
		ChatFrame1EditBox:SetText(".npcbot reloadconfig")
		ChatEdit_SendText(ChatFrame1EditBox, 0)		
    end)
  
  ----------------------------------------------------------------
  --  ligne 4 : Sort de résurrection (icône clickable)
  ----------------------------------------------------------------
  local rez = AceGUI:Create("Icon")
  rez:SetImage(select(3, GetSpellInfo(7328)))
  rez:SetImageSize(28,28)
  rez:SetWidth(36)
  rez:SetCallback("OnClick", function()
      SendChatMessage(".npcbot revive","SAY")
    end)
  rez:SetCallback("OnEnter", function(widget)
      GameTooltip:SetOwner(widget.frame,"ANCHOR_RIGHT")
      GameTooltip:SetText(i18n("Revive Bots"))
      GameTooltip:Show()
    end)
  rez:SetCallback("OnLeave", function() GameTooltip:Hide() end)
  f:AddChild(rez)

  f._populated = true
end

--------------------------------------------------------------------
-- 3) Helper pour (dé)montrer la fenêtre
--------------------------------------------------------------------
--[[function NetherBot:ToggleAdminFrame()
  local f = self:CreateAdminFrame()
  self:PopulateAdminFrame()

  if f.frame:IsShown() then f:Hide() else f:Show() end
end]]
function NetherBot:ToggleAdminFrame()
  -- 1. Si la fenêtre n’existe pas encore : on la crée, on la peuple et on l’affiche
  if not self.adminAce then
    local f = self:CreateAdminFrame()
    self:PopulateAdminFrame()
    f:Show()
    return
  end

  -- 2. Sinon : simple bascule visible / caché
  if self.adminAce.frame:IsShown() then
    self.adminAce:Hide()
  else
    self.adminAce:Show()
  end
end

--------------------------------------------------------------------
--  FRAME LOOKUP AceGUI
--------------------------------------------------------------------
local classTable = {           -- <Nom affiché> = entry
  ["Warrior"]=1, ["Paladin"]=2, ["Hunter"]=3, ["Rogue"]=4, ["Priest"]=5,
  ["Death Knight"]=6, ["Shaman"]=7, ["Mage"]=8, ["Warlock"]=9, ["Druid"]=11,
  ["Blademaster"]=12, ["Sphynx"]=13, ["Archmage"]=14, ["Dreadlord"]=15,
  ["Spellbreaker"]=16, ["DarkRanger"]=17, ["Necromancer"]=18, ["SeaWitch"]=19
}

-- -----------------------------------------------------------------
--  Création du cadre AceGUI
-- -----------------------------------------------------------------
function NetherBot:CreateLookupFrame()
  if self.lookupAce then                       -- déjà construit ?
    return self.lookupAce
  end
function NetherBot:ToggleLookupFrame()
  --------------------------------------------------------------------
  -- 1) 1er appel : la fenêtre n'existe pas encore ⇒ on la crée
  --------------------------------------------------------------------
  if not self.lookupAce then
    local f = self:CreateLookupFrame()   -- construit + remplit la frame
    self.lookupAce = f                   -- mémo (au cas où Create… ne l’a pas déjà fait)
    f:Show()                             -- on l’affiche immédiatement
    return                               -- …et on sort
  end

  --------------------------------------------------------------------
  -- 2) Appels suivants : simple bascule
  --------------------------------------------------------------------
  if self.lookupAce.frame:IsShown() then
    self.lookupAce:Hide()                -- actuellement visible → on cache
  else
    self.lookupAce:Show()                -- actuellement caché  → on montre
  end
end

  local AceGUI = LibStub("AceGUI-3.0")

  ----------------------------------------------------------------
  -- 1) FRAME PRINCIPALE
  ----------------------------------------------------------------
  local f = AceGUI:Create("Frame")
  f:SetTitle(i18n("Select class"))             -- titre localisé
  f:SetWidth(200)
  f:SetHeight(500)
  f:SetLayout("Fill")                          -- on y mettra un ScrollFrame
  f.frame:SetResizable(false)                  -- pas de redimensionnement

  -- Position dynamique (comme avant)
  f.frame:HookScript("OnShow", function(frame)
    frame:ClearAllPoints()
    if adminFrame and adminFrame:IsShown() then
      frame:SetPoint("TOPLEFT", adminFrame, "TOPRIGHT", 10, 0)
    elseif NetherBot.gui and NetherBot.gui.frame then
      frame:SetPoint("TOPLEFT", NetherBot.gui.frame, "TOPRIGHT", 10, 0)
    else
      frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
  end)

  ----------------------------------------------------------------
  -- 2) SCROLLFRAME qui contiendra les boutons de classes
  ----------------------------------------------------------------
  local scroll = AceGUI:Create("ScrollFrame")
  scroll:SetLayout("List")                     -- empile verticalement
  f:AddChild(scroll)

  ----------------------------------------------------------------
  -- 3) Boutons « classe » – un par entrée de classTable
  ----------------------------------------------------------------
  for cls, id in pairs(classTable) do
    local btn = AceGUI:Create("Button")
    btn:SetText(i18n(cls))
    btn:SetFullWidth(true)
    btn:SetCallback("OnClick", function()
      NetherBot:StartLookup(id, cls)
    end)
    scroll:AddChild(btn)
  end

  ----------------------------------------------------------------
  -- 4) Mémo du widget et retour
  ----------------------------------------------------------------
  self.lookupAce = f
  return f
end

-- -----------------------------------------------------------------
--  Petit helper pour ouvrir/fermer
-- -----------------------------------------------------------------
--[[function NetherBot:ToggleLookupFrame()
  local f = self:CreateLookupFrame()
  if f.frame:IsShown() then f:Hide() else f:Show() end
end]]
-----------------------------------------------------------------
--  Basculer visible/caché
-----------------------------------------------------------------
function NetherBot:ToggleLookupFrame()
  -- 1) premier appel : on crée la fenêtre puis on l'affiche
  if not self.lookupAce then
    self:CreateLookupFrame():Show()
    return
  end

  -- 2) appels suivants : simple on/off
  if self.lookupAce.frame:IsShown() then
    self.lookupAce:Hide()
  else
    self.lookupAce:Show()
  end
end


--------------------------------------------------------------------
--  RAID FRAME (TeamFrame) – code original conservé
--------------------------------------------------------------------
-- local TeamFrame = CreateFrame("Frame", "TeamFrame", UIParent)
TeamFrame = CreateFrame("Frame", "TeamFrame", UIParent)
TeamFrame:SetSize(350, 600)
TeamFrame:SetPoint("CENTER")
TeamFrame:Hide()

TeamFrame:SetMovable(true)
TeamFrame:EnableMouse(true)
TeamFrame:RegisterForDrag("LeftButton")
TeamFrame:SetScript("OnDragStart", TeamFrame.StartMoving)
TeamFrame:SetScript("OnDragStop",  TeamFrame.StopMovingOrSizing)

--  tables
local memberFrames, healthBars, manaBars, nameTexts, groupFrames = {},{},{},{},{}
------------------------------------------------
-- function initializeFramesAndBars()
initializeFramesAndBars = function()
  if not RAID_CLASS_COLORS then return end

  -- clear
  for _,f in ipairs(memberFrames) do f:Hide() end
  wipe(memberFrames); wipe(healthBars); wipe(manaBars); wipe(nameTexts); wipe(groupFrames)

  local n = GetNumRaidMembers()
  for i=1,n do
    local grp  = math.ceil(i/5)
    local pos  = i - ((grp-1)*5)
    if pos==1 then
      local gf = CreateFrame("Frame", nil, TeamFrame)
      gf:SetSize(80,20)
      local col = (grp-1)%2
      local row = math.floor((grp-1)/2)
      gf:SetPoint("TOPLEFT", TeamFrame, "TOP", 175*(col-1), 10 - row*230)
      gf:SetBackdrop({edgeFile="Interface/Tooltips/UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16,insets={4,4,4,4}})
      local t = gf:CreateFontString(nil,"OVERLAY","GameFontNormal")
      t:SetPoint("TOP",0,-3)
      t:SetText("Group "..grp)
      groupFrames[grp] = gf
    end

    local col,row = (grp-1)%2, math.floor((grp-1)/2)
    local mf = CreateFrame("Button", nil, TeamFrame, "SecureUnitButtonTemplate")
    mf:SetSize(150,42)
    mf:SetPoint("TOPLEFT", TeamFrame, "TOPLEFT", 10+175*col, -10-((row*230)+(pos-1)*42))
    mf:SetAttribute("unit", "raid"..i)
    mf:RegisterForClicks("AnyUp")
    SecureUnitButton_OnLoad(mf, "raid"..i)
    mf:SetBackdrop({bgFile="Interface/Tooltips/UI-Tooltip-Background",edgeFile="Interface/Tooltips/UI-Tooltip-Border",tile=true,tileSize=16,edgeSize=16,insets={4,4,4,4}})
    local _,class = UnitClass("raid"..i)
    local cc = RAID_CLASS_COLORS[class] or {r=1,g=1,b=1}
    mf:SetBackdropBorderColor(cc.r,cc.g,cc.b,0.8)
    mf:SetBackdropColor(cc.r,cc.g,cc.b,0.2)

    local pn = UnitName("raid"..i)
    local name = mf:CreateFontString(nil,"OVERLAY","GameFontNormal")
    name:SetPoint("TOP",5,-5)
    name:SetText(pn)
    name:SetTextColor(cc.r,cc.g,cc.b)

    local hp = CreateFrame("StatusBar", nil, mf)
    hp:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    hp:SetPoint("TOP", name, "BOTTOM", 0, -2)
    hp:SetSize(100,8)
    hp:SetMinMaxValues(0, UnitHealthMax("raid"..i))
    hp:SetValue(UnitHealth("raid"..i))

    local mp = CreateFrame("StatusBar", nil, mf)
    mp:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    mp:SetStatusBarColor(0,0,1)
    mp:SetPoint("TOP", hp, "BOTTOM", 0, 0)
    mp:SetSize(100,8)
    mp:SetMinMaxValues(0, UnitPowerMax("raid"..i))
    mp:SetValue(UnitPower("raid"..i))

    memberFrames[i]=mf; healthBars[i]=hp; manaBars[i]=mp; nameTexts[i]=name
  end
end

local function updateHealthMana(_,_,unit)
  for i=1,#healthBars do
    if unit=="raid"..i then
      healthBars[i]:SetMinMaxValues(0, UnitHealthMax(unit))
      healthBars[i]:SetValue(UnitHealth(unit))
      manaBars[i]:SetMinMaxValues(0, UnitPowerMax(unit))
      manaBars[i]:SetValue(UnitPower(unit))
    end
  end
end

TeamFrame:RegisterEvent("UNIT_HEALTH")
TeamFrame:RegisterEvent("UNIT_POWER_UPDATE")
TeamFrame:RegisterEvent("RAID_ROSTER_UPDATE")
TeamFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
TeamFrame:SetScript("OnEvent", function(self, event, unit)
  if event=="RAID_ROSTER_UPDATE" or event=="PLAYER_ENTERING_WORLD" then
    initializeFramesAndBars()
  else
    updateHealthMana(self,event,unit)
  end
end)

function NetherBot:ToggleRaid()
  if TeamFrame:IsShown() then TeamFrame:Hide() else initializeFramesAndBars(); TeamFrame:Show() end
end
NetherBot:RegisterChatCommand("nbraid", "ToggleRaid")