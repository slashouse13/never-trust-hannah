-- Tryhard
local Achi = NTH:NewAchievement("tryhard")
Achi.Name = "Tryhard!"
Achi.Quote = "You're such a tryhard!"

Achi.ProgressPath = {Defusals = 2}
Achi.ProgressNotify = {Defusals = "Defused %s/%s C4 bombs"}

hook.Add("NTH-DisarmedC4", "NTH-Achi-16-Disarm", function(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply:IsActive() or ply:IsTraitor() then return end
    Achi:progressInc(ply, "Defusals")
end)

hook.Add("TTTEndRound", "NTH-Achi-16-RoundEnd", function()
    Achi:progressResetAll()
end)
