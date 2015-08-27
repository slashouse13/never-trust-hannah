-- KOS Bread
local Achi = NTH:NewAchievement("kos-bread")
Achi.Name = "KOS Bread"
Achi.Quote = "Can I ask you a question?"

Achi.ProgressPath = {KOSBread = 1}

hook.Add("EntityTakeDamage", "NTH-Achi-23-EntityTakeDamage", function(victim, dmginfo)
    -- this is only available on crummy cradle
    if game.GetMap() == "ttt_crummycradle_a2" then return end
    -- is the round already over? / not started yet?
    if GetRoundState() != ROUND_ACTIVE then return end
    local ply = dmginfo:GetAttacker()
    -- got to be a valid player doing the damage
    if not IsValid(victim) or not IsValid(ply) or not ply:IsPlayer() then return end
    -- we've got to be alive, or this doesn't count
    if ply:IsSpec() or not ply:Alive() then return end
    -- killing bread, right?
    if victim:GetModel() != "models/bread/bread.mdl" then return end
    -- got to be doing more than 0 damage
    if dmginfo:GetDamage() < 1 then return end
    -- ok, bread is dead
    victim:Remove()
    -- ok, so this qualifies for this part of the achievement
    Achi:progressSet(ply, "KOSBread")
end)
