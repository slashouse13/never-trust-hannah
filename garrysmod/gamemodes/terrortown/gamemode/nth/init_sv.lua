include("resources_sv.lua") -- Resources, duh!

CreateConVar("nth_scoreboard_url", "", {FCVAR_REPLICATED, FCVAR_NOTIFY})

local oldInitCvars = GM.InitCvars
function GM:InitCvars(...)
    SetGlobalString("nth_scoreboard_url", GetConVarString("nth_scoreboard_url"))
    
    if oldInitCvars then
        return oldInitCvars(self, unpack({...}))
    end
end

-- Download clientside lua
AddCSLuaFile("vgui/ghtml_cl.lua")

AddCSLuaFile("init_sh.lua")
AddCSLuaFile("init_cl.lua")

AddCSLuaFile("vips_sh.lua")
AddCSLuaFile("vips_cl.lua")

AddCSLuaFile("achievement_banner_cl.lua")
AddCSLuaFile("achievements_cl.lua")
AddCSLuaFile("hitmark_cl.lua")

--AddCSLuaFile("toys/pepsi.lua")

-- Let's get busy
CreateConVar("nth_vip_min_players", 5)
CreateConVar("nth_achi_liveonly", 1)

include("init_sh.lua") -- NTH core stuff
include("db_sv.lua")
include("sync_sv.lua") -- Log player visits and other things

include("vips_sh.lua") -- VIP stuff
include("vips_sv.lua") -- VIP spawning hooks
include("achievements_sv.lua")

--include("toys/pepsi.lua")

concommand.Add("nth_pos", function(ply,cmd,args)
    local p = ply:GetPos()
    print("Pos:    x,y,z:", math.floor(p.x) ..",".. math.floor(p.y) ..",".. math.floor(p.z))
    p = ply:GetAngles()
    print("Angles: x,y,z:", math.floor(p.x) ..",".. math.floor(p.y) ..",".. math.floor(p.z))
end)

concommand.Add("nth_ents", function(ply,cmd,args)
    print("-------------------------------------------")
    local es = {}

    if #args > 0 then
        es = ents.FindByClass(args[1])
        MsgN(#es .. " entities found with class " .. args[1])
    else
        es = ents.FindInSphere(ply:GetPos(), 200)
        MsgN(#es .. " entities found next to " .. ply:Nick())
    end
    
    for _,ent in pairs(es) do
        local p = ent:GetPos()
        MsgC(COLOR_WHITE, "Ent ".. ent:MapCreationID() ..": ")
        MsgC(Color(255,255,0), ent:GetClass())
        MsgC(COLOR_RED, " (".. p.x ..", ".. p.y ..", ".. p.z ..")")
        MsgN("")
    end
    
    print("-------------------------------------------")
end)

-- This seems to reduce crashing... maybe
physenv.SetPerformanceSettings({MaxVelocity=500})

-- last thing's last
include("website_scoreboard_sv.lua") -- website scoreboard!

hook.Add("NTH-TC-CountTraitors", "NTH-TC-CountTraitors2", function(ent, trs, plys)
    print("Ent:", ent:MapCreationID(), ent, "Trs", trs, "plys", #plys)
end)

-- Call a hook whenever a player shoots a weapon
-- we can use this info for NOSCOPER
hook.Add("Initialize", "NTH-Initialize-WeaponShoot", function()
    for _,w in pairs(weapons.GetList()) do	
        if w.Base == "weapon_tttbase" then
            if not w.PrimaryAttack then
                w.PrimaryAttack = function(wep)
                    if wep.BaseClass.CanPrimaryAttack(wep) and IsValid(wep.Owner) then
                        hook.Call("NTH-Player-Shooting", nil, wep, wep.Owner)
                    end
                    return wep.BaseClass.PrimaryAttack(wep)
                end
            else
                local oldprimary = w.PrimaryAttack
                w.PrimaryAttack = function(wep)
                    hook.Call("NTH-Player-Shooting", nil, wep, wep.Owner)
                    if oldprimary then return oldprimary(wep) end
                end
            end
        end
    end
end)
