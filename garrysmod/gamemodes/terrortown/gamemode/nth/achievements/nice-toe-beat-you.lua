-- Nice toe beat you
local Achi = NTH:NewAchievement("nice-toe-beat-you")
Achi.Name = "Nice toe beat you"
Achi.Quote = "Let's not get off on the wrong foot"

Achi.ProgressPath = {BeatMeat = 101}
Achi.ProgressNotify = {BeatMeat = "You have greeted %s/101 people with your meat"}

hook.Add("DoPlayerDeath", "NTH-Achi-14-Death", function(victim, attacker, dmginfo)
    if not dmginfo then return end

    local wep = dmginfo:GetInflictor()
    if not wep or wep.ClassName ~= "weapon_nth_bigtoe" then return end

    Achi:persistProgressInc(attacker, "BeatMeat", 1)
end)
