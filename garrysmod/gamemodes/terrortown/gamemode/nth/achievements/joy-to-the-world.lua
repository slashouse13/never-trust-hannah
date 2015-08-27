-- Joy to the World!
local Achi = NTH:NewAchievement("joy-to-the-world")
Achi.Name = "Joy to the World!"
Achi.Quote = "Christmas is saved!"

Achi.ProgressPath = {SantaKilledLastGrinchUsingTree = 1, InnocentsWin = 1}

hook.Add("DoPlayerDeath", "NTH-Achi-22-Kill", function(victim, attacker, dmginfo)
    -- is the round already over? / not started yet?
    if GetRoundState() != ROUND_ACTIVE then return end
    -- was attacker Santa and was victim a Grinch?
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not victim:IsTraitor() or not attacker:IsDetective() then return end
    -- was the inflicting object a tree?
    local treeEnt = dmginfo:GetInflictor()
    if not IsValid(treeEnt) then return end
    local treeModel = treeEnt:GetModel()
    if treeModel != "models/cloud/kn_xmastree.mdl" then return end
    -- are there no more living traitors?
    local allTraitorsDead = true
    for _,ply in pairs(player.GetAll()) do
        if ply != victim and ply:IsActiveTraitor() then
            allTraitorsDead = false
        end
    end
    if not allTraitorsDead then return end
    -- ok, so this qualifies for this part of the achievement
    Achi:progressSet(attacker, "SantaKilledLastGrinchUsingTree")
end)

hook.Add("TTTEndRound", "NTH-Achi-22-RoundEnd", function(how)
    if how == WIN_INNOCENT then
        for _,ply in pairs(player.GetAll()) do
            Achi:progressSet(ply, "InnocentsWin", 1, {SantaKilledLastGrinchUsingTree=1})
        end
    end
    
    Achi:progressResetAll()
end)
