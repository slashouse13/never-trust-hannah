-- Fuck You Billy Joel
local Achi = NTH:NewAchievement("fuck-you-billy-joel")
Achi.Name = "Fuck you Billy Joel"
Achi.Quote = "Get out of that room and sing us a song you fuck!"

-- btn 1547 on ttt_67thway_v3
-- btn 1508 on ttt_67thway_v4
local buttons = {
    ttt_67thway_v3 = 1548,
    ttt_67thway_v4 = 1509
}

local btnId = buttons[game.GetMap()]
local btnUsed = false

local isPlayerInFloodRoom = function(ply)
    return IsValid(ply) and ply:IsActive() and ply:GetPos():WithinAABox(Vector(-903,-153,-504), Vector(-632,228,-360))
end

local isPlayerInTRoom = function(ply)
    return IsValid(ply) and ply:IsActive() and ply:GetPos():WithinAABox(Vector(-1392,-224,-500), Vector(-929,495,-360))
end

Achi.ProgressPath = {BillyInTRoomAndDrownUnprevented = 1}

hook.Add("TTTEndRound", "NTH-Achi-11-RoundEnd", function()
    btnUsed = false
    Achi:progressResetAll()
end)

hook.Add("NTH-TraitorButtonPressed", "NTH-Achi-11-TraitorButtonPressed", function(btn, ply)
    if not btnId then return end
    if btn:MapCreationID() != btnId then return end
    -- ok, so someone pressed the flood-release. Achi not obtainable this round.
    btnUsed = true
end)

hook.Add("DoPlayerDeath", "NTH-Achi-11-DoPlayerDeath", function(ply, attacker, dmg)
    if btnUsed then return end
    -- Flood-release button not yet pressed
    if not btnId then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if dmg:GetDamageType() != 16384 or not isPlayerInFloodRoom(ply) then return end
    -- ok, a player just died in the flood room
    -- was billy in the T room?
    for _,bj in pairs(player.GetAll()) do
        if bj:IsActive() and bj:IsVIP("BJOEL") and isPlayerInTRoom(bj) then
            Achi:progressSet(bj, "BillyInTRoomAndDrownUnprevented")
        end
    end
end)
