-- Dance Magic Dance
local Achi = NTH:NewAchievement("dance-magic-dance")
Achi.Name = "Dance Magic Dance"
Achi.Quote = "Jump Magic Jump"

Achi.ProgressPath = {GoombaT = 1}

hook.Add("DoPlayerDeath", "NTH-Achi-13-Death", function(ply, attacker, dmginfo)
    if GetRoundState() != ROUND_ACTIVE then return end
    -- round is active
    if not IsValid(attacker) or not attacker:IsPlayer() or attacker:IsTraitor() then return end
    -- attacker is innocent/detective
    if not IsValid(ply) or not ply:IsPlayer() or not ply:IsTraitor() then return end
    -- victim is traitor
    if not attacker:IsActive() then return end
    -- attacker is active and playing
    if dmginfo:GetDamageType() != DMG_CRUSH + DMG_PHYSGUN then return end
    -- damage is caused by falling on someone's head
    
    local activeTraitors = 0
    for _,ply in pairs(player.GetAll()) do
        if ply:IsActiveTraitor() then
            activeTraitors = activeTraitors + 1
        end
    end

    if activeTraitors > 1 then return end
    -- no traitors left
    Achi:progressSet(attacker, "GoombaT")
end)
