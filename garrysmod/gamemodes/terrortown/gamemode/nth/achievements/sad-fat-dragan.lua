-- Sad Fat Dragan
local Achi = NTH:NewAchievement("sad-fat-dragan")
Achi.Name = "Sad fat Dragan"
Achi.Quote = "With no friends"

Achi.ProgressPath = {MinutesBored = 30}
Achi.ProgressNotify = {MinutesBored = "You have been bored for %s minute(s)"}

timer.Create("NTH-Achi-20-SadFatDragan", 60, 0, function()
    local players = player.GetHumans()
    local humans = {}
    for _,ply in pairs(players) do
        if IsValid(ply) and not ply:IsBot() and ply:SteamID() ~= "BOT" then
            table.insert(humans, ply);
        end
    end
    
    if #humans > 1 then
        Achi:progressResetAll()
    else
        for _,ply in pairs(humans) do
            Achi:progressInc(ply, "MinutesBored")
        end
    end
end)

hook.Add("TTTBeginRound", "NTH-Achi-20-Begin", function()
    Achi:progressResetAll()
end)
