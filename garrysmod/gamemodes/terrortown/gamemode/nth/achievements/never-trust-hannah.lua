local Achi = NTH:NewAchievement("never-trust-hannah")
Achi.Name = "Never Trust Hannah"
Achi.Quote = "She's always the fucking traitor, bitch."

Achi.ProgressPath = {Trusted = 1}

hook.Add("DoPlayerDeath", "NTH-Achi-1-Kill", function(victim, attacker, dmginfo)
    -- is the round already over? / not started yet?
    if GetRoundState() != ROUND_ACTIVE then return end
    -- attacker must be traitor hannah
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not attacker:IsActiveTraitor() or not attacker:IsVIP("HANNAH") then return end
    -- killing yourself doesn't count (if that's even possible with a knife)
    if victim == attacker then return end
    -- victim must be holstered
    local vWep = victim:GetActiveWeapon()
    if not IsValid(vWep) or vWep:GetClass() != "weapon_ttt_unarmed" then return end
    -- victim must be killed with a knife
    local aWep = dmginfo:GetInflictor()
    if not IsValid(aWep) or aWep:GetClass() != "weapon_ttt_knife" then return end
    -- only 2 players alive
    local activePlayers = 0
    for _,ply in pairs(player.GetAll()) do
        if ply:IsActive() then
            activePlayers = activePlayers + 1
        end
    end
    if activePlayers != 2 then return end
    -- ok, so this qualifies for this part of the achievement
    Achi:progressSet(attacker, "Trusted")
end)
