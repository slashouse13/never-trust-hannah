local Achi = NTH:NewAchievement("instinct")
Achi.Name = "Instinct"
Achi.Quote = "You didn't trust Hannah, not even for half a second."

Achi.ProgressPath = {KillHannahInstinctively = 1}

local doable = false
hook.Add("TTTBeginRound", "NTH-Achi-2-Begin", function()
    doable = true
    timer.Simple(1, function()
        doable = false
    end)
end)

hook.Add("DoPlayerDeath", "NTH-Achi-2-Kill", function(victim, attacker, dmginfo)
    -- are we too late?
    if not doable then return end
    -- victim must be hannah
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not victim:IsVIP("HANNAH") then return end
    -- killing yourself doesn't count
    if victim == attacker then return end
    -- ok, so this qualifies for this part of the achievement
    Achi:progressSet(attacker, "KillHannahInstinctively")
end)
