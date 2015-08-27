-- Happy Fat Dragan
local Achi = NTH:NewAchievement("happy-fat-dragan")
Achi.Name = "Happy fat Dragan"
Achi.Quote = "With all the friends"

Achi.ProgressPath = {MinutesHappy = 30}
Achi.ProgressNotify = {MinutesHappy = "You have been playing with lots of people for %s minute(s)"}

timer.Create("NTH-Achi-19-HappyFatDragan", 60, 0, function()
    local players = player.GetAll()
    
    if #players >= 28 then
        for _,ply in pairs(players) do
            Achi:progressInc(ply, "MinutesHappy")
        end
    end
end)
