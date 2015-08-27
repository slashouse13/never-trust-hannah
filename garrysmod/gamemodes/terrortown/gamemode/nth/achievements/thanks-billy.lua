-- Thanks Billy
local Achi = NTH:NewAchievement("thanks-billy")
Achi.Name = "Thanks Billy!"
Achi.Quote = "That was a close one!"

-- btn 1547 on ttt_67thway_v3
-- btn 1508 on ttt_67thway_v4
local buttons = {
    ttt_67thway_v3 = 1548,
    ttt_67thway_v4 = 1509
}

local btnId = buttons[game.GetMap()]

local isPlayerInFloodRoom = function(ply)
    return IsValid(ply) and ply:IsActive() and ply:GetPos():WithinAABox(Vector(-903,-153,-504), Vector(-632,228,-360))
end

local getPlayersInFloodRoom = function()
    local inside = {}
    for _,ply in pairs(player.GetAll()) do
        if isPlayerInFloodRoom(ply) then
            table.insert(inside, ply)
        end
    end
    return inside
end

Achi.ProgressPath = {DrowningInFloodRoom = 1, BillyIntervenes = 1, StillAliveInFloodRoom = 1}

hook.Add("TTTEndRound", "NTH-Achi-10-RoundEnd", function()
    Achi:progressResetAll()
end)

hook.Add("NTH-TraitorButtonPressed", "NTH-Achi-10-TraitorButtonPressed", function(btn, ply)
    if not btnId then return end
    if btn:MapCreationID() != btnId then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if not ply:IsVIP("BJOEL") or not ply:IsActive() then return end
    for _,victim in pairs(getPlayersInFloodRoom()) do
        if ply != victim then
            Achi:progressSet(victim, "BillyIntervenes", 1)
        end
    end
    timer.Start("NTH-Achi-10-DangerOver")
end)

timer.Create("NTH-Achi-10-DangerOver", 4, 0, function()
    timer.Stop("NTH-Achi-10-DangerOver")
    for _,victim in pairs(getPlayersInFloodRoom()) do
        if victim:IsActive() then
            Achi:progressSet(victim, "StillAliveInFloodRoom", 1, {BillyIntervenes=1,DrowningInFloodRoom=1})
        end
    end
    Achi:progressResetAll()
end)
timer.Stop("NTH-Achi-10-DangerOver")

hook.Add("EntityTakeDamage", "NTH-Achi-10-EntityTakeDamage", function(ply, dmg)
    if not btnId then return end
    if not IsValid(ply) or not ply:IsPlayer() then return end
    if dmg:GetDamageType() != 16384 or not isPlayerInFloodRoom(ply) then return end
    Achi:progressSet(ply, "DrowningInFloodRoom")
    timer.Start("NTH-Achi-10-DangerOver")
end)
