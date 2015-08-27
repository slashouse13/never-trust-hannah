-- 100% Win Rate
local Achi = NTH:NewAchievement("100pct-win-rate")
Achi.Name = "100% Win Rate"
Achi.Quote = "Ok, so you're good at this map. We get it."

Achi.ProgressPath = {WinsWithoutDying = 8}
Achi.ProgressNotify = {WinsWithoutDying = "Won %s/%s rounds without dying"}

hook.Add("DoPlayerDeath", "NTH-Achi-5-Death", function(victim, attacker, dmginfo)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    -- deaths outside of a normal round don't count
    if GetRoundState() != ROUND_ACTIVE then return end
    -- ok, sorry, you died - progress reset
    Achi:progressReset(victim, "WinsWithoutDying")
end)

hook.Add("TTTEndRound", "NTH-Achi-5-RoundEnd", function(how)
    for _,ply in pairs(player.GetAll()) do
        if (how == WIN_TRAITOR) == ply:IsTraitor() and ply:Alive() and not ply:IsSpec() then
            Achi:progressInc(ply, "WinsWithoutDying")
        end
    end
end)
