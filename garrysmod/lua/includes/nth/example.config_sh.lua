AddCSLuaFile()
NTHC = {}

NTHC.DamageLogs = {
    RDM_Manager_Enabled = true,
    Use_MySQL           = false,
    Enable_Autoslay     = true
}

NTHC.ScoreboardURL = "http://nevertrusthannah.com/ingame/scoreboard.html"

if SERVER then include("config_sv.lua") end
