-- chargé AVANT netherbot.lua
local L = LibStub("AceLocale-3.0"):NewLocale("NetherBot", "esES")
if not L then return end

L["Version"] = "v. Beta 2"
L["NetherBot"]           = "NetherBot"
L["Hide"]                = "Ocultar"
L["UnHide"]              = "Mostrar"
L["Follow"]              = "Seguir"
L["Stand"]               = "Quieto"
L["Stop"]                = "Detener"
L["Slack"]               = "Pasivo"
L["Recall"]              = "Llamar"
L["Unbind"]              = "Desvincular"
L["Spawn"]               = "Invocar"
L["Spawn Bot"]           = "Invocar Bot"
L["Revive"]              = "Revivir"
L["Revive Bots"]         = "Revivir Bots"
L["Admin"]               = "Admin"
L["Entry ID"]            = "ID del Bot"
L["Enter NPCBOT ID:"]    = "Introduce el ID del NPCBOT:"
L["Select class"]        = "Seleccionar clase"
-- L["Spawn BOT ID:"]       = "ID del bot a invocar:"
L["NetherBot_title"]     = "NetherBot – Herramienta para Trickerer NPCBOT por TheWarlock"
L["Add"]                 = "Añadir"
L["Remove"]              = "Eliminar"
L["Bot-Info"]            = "Info Bot"
L["Move"]                = "Mover"
L["Delete"]              = "Eliminar"
L["Rogue"]               = "Pícaro"
L["Spellbreaker"]        = "Rompehechizos"
L["Archmage"]            = "Archimago"
L["Dreadlord"]           = "Señor del Terror"
L["Lookup"]              = "Invocar un Bot"
L["RaidFrame"]           = "Vista de Banda"
L["Dist 30"]             = "Dist 30"
L["Dist 50"]             = "Dist 50"
L["Dist 85"]             = "Dist 85"
L["FILL_ID_FIELD"]       = "|cffff0000[NetherBot]|r Rellena el campo ID."
L["B_INVOQUER"]          = "Invocar"
L["INVOQUER_TOOLTIP"]    = "Haz clic para invocar este bot cerca de ti."
L["LOOKUP_ID_LABEL"]     = "ID BOT"
L["LOOKUP_NAME_LABEL"]   = "Nombre"
L["LOOKUP_RACE_LABEL"]   = "Raza"
L["LOOKUP_STATUS"]       = "Lista de Bots disponibles que puedes invocar"

L["Recall_Spawn_Bt"]         = "Mover Spawn"
L["Recall_Spawn_tooltip"]    = "Fuerza a todos tus bots inactivos a teletransportarse inmediatamente a su punto de aparición"
L["Recall_teleport_Bt"]      = "Mover Teleport"
L["Recall_teleport_tooltip"] = "Fuerza a todos tus bots a teletransportarse a tu posición"

L["Spawn_bot_by_ID"] = "Invoca un Bot por su ID"

L["Warrior"]      = "Guerrero"
L["Paladin"]      = "Paladín"
L["Hunter"]       = "Cazador"
L["Rogue"]        = "Pícaro"
L["Priest"]       = "Sacerdote"
L["Death Knight"] = "Caballero de la Muerte"
L["Shaman"]       = "Chamán" 
L["Mage"]         = "Mago" 
L["Warlock"]      = "Brujo"
L["Druid"]        = "Druida"
L["Blademaster"]  = "Maestro de Espadas"
L["Sphynx"]       = "Esfinge"
L["DarkRanger"]   = "Forestal Oscuro"
L["Necromancer"]  = "Nigromante"
L["SeaWitch"]     = "Bruja Marina"
L["Revive Bots"]  = "Resucitar Bots"

-- Tooltips
L["Follow_tooltip"]     = "Hace que el bot te siga"
L["Stand_tooltip"]      = "Hace que el bot deje de seguirte"
L["Stop_tooltip"]       = "Hace que el bot detenga toda acción"
L["Slack_tooltip"]      = "El bot te seguirá con distancia relajada."
L["UnHide_tooltip"]     = "Muestra todos los bots que habías ocultado."
L["Hide_tooltip"]       = "Oculta todos tus bots del campo de visión."
L["Unbind_tooltip"]     = "Elimina al bot; ya no te pertenecerá."
L["Dist_30_tooltip"]    = "Establece la distancia de seguimiento de los bots a 30 metros."
L["Dist_50_tooltip"]    = "Establece la distancia de seguimiento de los bots a 50 metros."
L["Dist_85_tooltip"]    = "Establece la distancia de seguimiento de los bots a 85 metros."
L["Spanw_bot_tooltip"]  = "Abre la ventana para invocar un bot introduciendo su ID."
L["Revive_tooltip"]     = "Revivir a todos tus bots caídos."

L["Admin_tooltip"]      = "Abre el panel de administración para gestionar tus bots (añadir, eliminar, info, etc.)."
L["Lookup_tooltip"]     = "Abre la ventana de búsqueda para seleccionar una clase o invocar rápidamente un bot por su ID."
L["Raidframe_tooltip"]  = "Muestra la ventana de banda que permite seguir la salud y maná de los miembros."

L["Add_tooltip"]        = "Añade el bot seleccionado a tu grupo."
L["Remove_tooltip"]     = "Si apuntas a un jugador: elimina todos sus bots.\nSi apuntas a un bot: elimina solo ese bot."
L["Recall_tooltip"]     = "Si apuntas a un jugador: llama a todos sus bots a su posición actual.\nSi apuntas a un bot: lo llama a tu posición."
L["Info_tooltip"]       = "Muestra información detallada del bot en la ventana Info."
L["MOVE_TOOLTIP"]       = "Ordena al bot seleccionado que se mueva a tu lado."
L["Delete_tooltip"]     = "Elimina permanentemente el bot seleccionado o por ID."
L["Delete Free"]        = "Eliminar bots libres"
L["DeleteFree_tooltip"] = "Elimina todos los bots libres presentes en el mundo."
L["ConfirmDeleteFree"]  = "¿Seguro que quieres eliminar todos los bots libres?"
L["Error_SelectBot"]    = "Por favor, selecciona un bot."

-- Creación de Bots
L["CREATE_BOT"]         = "Crear Bot"
L["CREATE_BOT_TOOLTIP"] = "Abre la ventana de creación de NPCBot"
L["BOT_NAME"]           = "Nombre del Bot"
L["BOT_CLASS"]          = "Clase del Bot"
L["BOT_RACE"]           = "Raza del Bot"
L["BOT_GENDER"]         = "Género"
L["BOT_SKIN"]           = "Piel"
L["BOT_FACE"]           = "Cara"
L["BOT_HAIRSTYLE"]      = "Peinado"
L["BOT_HAIRCOLOR"]      = "Color de Pelo"
L["BOT_FEATURES"]       = "Rasgos"
L["BOT_SOUNDSET"]       = "Conjunto de Voz"
L["BOT_NAME_TOOLTIP"]   = "Primera letra en mayúscula, espacios = _"
L["BOT_CREATE_TITLE"]   = "Creación de NPCBot"
L["BOT_CREATE8BUTTON"]  = "Crear"
L["BOT_FEATURES_TOOLTIP"] = "Hombres: barbas, bigotes, patillas, cuernos (tauren), colmillos decorados (trols)… Mujeres: pendientes, piercings, joyas frontales, cuernos (draenei)…"

L["CLASS_WARRIOR"]       = "Guerrero"
L["CLASS_PALADIN"]       = "Paladín"
L["CLASS_HUNTER"]        = "Cazador"
L["CLASS_ROGUE"]         = "Pícaro"
L["CLASS_PRIEST"]        = "Sacerdote"
L["CLASS_DEATHKNIGHT"]   = "Caballero de la Muerte"
L["CLASS_SHAMAN"]        = "Chamán"
L["CLASS_MAGE"]          = "Mago"
L["CLASS_WARLOCK"]       = "Brujo"
L["CLASS_DRUID"]         = "Druida"
L["CLASS_BLADEMASTER"]   = "Maestro de Espadas"
L["CLASS_SPHYNX"]        = "Esfinge"
L["CLASS_ARCHMAGE"]      = "Archimago"
L["CLASS_DREADLORD"]     = "Señor del Terror"
L["CLASS_SPELLBREAKER"]  = "Rompehechizos"
L["CLASS_DARKRANGER"]    = "Guardabosques Oscuro"
L["CLASS_NECROMANCER"]   = "Nigromante"
L["CLASS_SEAWITCH"]      = "Bruja del Mar"

L["RACE_HUMAN"]    = "Humano"
L["RACE_ORC"]      = "Orco"
L["RACE_DWARF"]    = "Enano"
L["RACE_NIGHTELF"] = "Elfo Nocturno"
L["RACE_UNDEAD"]   = "No-muerto"
L["RACE_TAUREN"]   = "Tauren"
L["RACE_GNOME"]    = "Gnomo"
L["RACE_TROLL"]    = "Trol"
L["RACE_BLOODELF"] = "Elfo de Sangre"
L["RACE_DRAENEI"]  = "Draenei"

L["GENDER_MALE"]   = "Masculino"
L["GENDER_FEMALE"] = "Femenino"

L["SOUNDSET_DEFAULT"]  = "Voz estándar"
L["SOUNDSET_VARIANT1"] = "Voz Variante 1"
L["SOUNDSET_VARIANT2"] = "Voz Variante 2"

L["SUMMARY_HEADER"]       = "Estas son las características de tu nuevo Bot"
L["SUMMARY_NAME_LABEL"]   = "Nombre"
L["SUMMARY_CLASS_LABEL"]  = "Clase"
L["SUMMARY_RACE_LABEL"]   = "Raza"
L["SUMMARY_GENDER_LABEL"] = "Género"
L["SUMMARY_SKIN_LABEL"]   = "Piel"
L["SUMMARY_FACE_LABEL"]   = "Cara"
L["SUMMARY_HAIR_LABEL"]   = "Pelo"
L["SUMMARY_COLOR_LABEL"]  = "Color"
L["SUMMARY_FEAT_LABEL"]   = "Rasgos"
L["SUMMARY_SS_LABEL"]     = "Voz"

L["NAME_UNDERSCORE"] = "|cffff0000[NetherBot]|r Sustituye los espacios por guiones bajos (_) en el nombre."
L["NAME_CAPS"]       = "|cffff0000[NetherBot]|r El nombre debe empezar con una letra MAYÚSCULA."
L["ERROR_MISSING_FIELDS"] = "Debes seleccionar: %s"

-- Ventana de otros comandos:
L["OTHER_COMMANDS"] = "Otros Comandos"
L["OTHER_COMMANDS_TOOLTIP"] = "Abre la ventana con otros comandos"
L["LIST_SPAWNED"] = "Lista Bots Invocados"
L["LIST_SPAWNED_TOOLTIP"] = "Muestra todos los bots actualmente invocados."
L["LIST_SPAWNED_FREE"] = "Lista Bots Libres"
L["LIST_SPAWNED_FREE_TOOLTIP"] = "Muestra todos los bots invocados y libres (owner = 0)."

L["BOT_ID"]         = "ID BOT"
L["NAME_LABEL"]     = "Nombre"
L["CLASS_LABEL"]    = "Clase"
L["LEVEL_LABEL"]    = "Nivel"
L["LOCATION_LABEL"] = "Ubicación"
L["STATE_LABEL"]    = "Estado"

L["Set_Free"] = "Liberar"
L["Set_Free_tooltip"] = "Libera el bot pero lo deja en el mundo"
L["Bot_Go"] = "Ir"
L["Bot_Go_tooltip"] = "Te teletransporta al lugar donde está el bot"
L["GearScore"] = "GearScore del Bot"
L["GearScore_tooltip"] = "Muestra el GearScore del bot seleccionado"
L["Conf_Reload"] = "Recargar Config"
L["Conf_Reload_tooltip"] = "Recarga la configuración de los Bots"