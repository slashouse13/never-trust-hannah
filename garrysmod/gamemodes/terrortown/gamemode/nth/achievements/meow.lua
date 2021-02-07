-- Meow
local Achi = NTH:NewAchievement("meow")
Achi.Name = "Meow"
Achi.Quote = "Meow Meow Meow Meow Meow"

Achi.ProgressPath = {KillKiba = 5}
Achi.ProgressNotify = {KillKiba = "Killed %s/%s Kiba's"}

hook.Add("DoPlayerDeath", "NTH-Achi-7-Kill", function(ply, attacker, dmginfo)
    if IsValid(ply) and ply:IsPlayer() and ply:IsVIP("KIBA") and IsValid(attacker) and attacker:IsPlayer() and attacker:IsVIP("KIBA") and ply ~= attacker then
        Achi:progressInc(attacker, "KillKiba")
    end
end)

hook.Add("TTTEndRound", "NTH-Achi-7-RoundEnd", function()
    Achi:progressResetAll()
end)
