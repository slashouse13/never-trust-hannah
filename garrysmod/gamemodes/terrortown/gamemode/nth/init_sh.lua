if not NTH then
    NTH = {}
end

NTH.Sounds = {}
NTH.AddSounds = function(sounds)
    for k,f in pairs(sounds) do
        if SERVER then
            resource.AddFile("sound/" .. f)
        else -- CLIENT
            util.PrecacheSound(f)
            NTH.Sounds[k] = f
        end
    end
end

if SERVER then
    NTH.AddFiles = function(files)
        for f=1, #files do
            resource.AddFile(files[f])
        end
    end
    
    NTH.GetPlayerBySteam64 = function(s64)
        for _,ply in pairs(player.GetAll()) do
            if IsValid(ply) and ply:IsPlayer() and ply:SteamID64(ply) == s64 then
                return ply
            end
        end
    end
    
    include("http_sv.lua")
end

AddCSLuaFile("marquee_cl.lua")
AddCSLuaFile("poster_cl.lua")
AddCSLuaFile("concommands_sh.lua")
AddCSLuaFile("rounds_sh.lua")
AddCSLuaFile("effects_sh.lua")
AddCSLuaFile("sound_sh.lua")
AddCSLuaFile("soundloop_sh.lua")
AddCSLuaFile("headline_sh.lua")
AddCSLuaFile("map_mods_sh.lua")

if CLIENT then
    include("marquee_cl.lua")
    include("poster_cl.lua")
end
include("concommands_sh.lua")
include("rounds_sh.lua")
include("effects_sh.lua")
include("sound_sh.lua")
include("soundloop_sh.lua")
include("headline_sh.lua")
include("map_mods_sh.lua")

-- for Christmas
MsgN("NTH is running in Christmas Mode")
AddCSLuaFile("themes/xmas.lua")
include("themes/xmas.lua")
