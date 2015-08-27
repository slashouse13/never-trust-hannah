local modPath = "terrortown/gamemode/nth/map_mods/" .. game.GetMap() .. ".lua"
if file.Exists(modPath, "LUA") then
    if SERVER then
        MsgC(COLOR_RED, "Loading map mod for: ")
        MsgN(game.GetMap())
        
        AddCSLuaFile(modPath)
    end
    include(modPath)
end
