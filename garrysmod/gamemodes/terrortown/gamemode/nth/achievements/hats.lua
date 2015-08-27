-- Hats
local Achi = NTH:NewAchievement("hats")
Achi.Name = "Hats"
Achi.Quote = "This guy's got hats"

Achi.ProgressPath = {DemolishedHotel = 1, SurviveRound = 1}

hook.Add("NTHMapMod-ttt_rooftops_a2-HotelDemolished", "NTH-Achi-18-HotelDemolished", function(ply)
    Achi:progressSet(ply, "DemolishedHotel")
end)

hook.Add("TTTEndRound", "NTH-Achi-18-RoundEnd", function(how)
    for _,ply in pairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            Achi:progressSet(ply, "SurviveRound", 1, {DemolishedHotel=1})
        end
    end
    
    Achi:progressResetAll()
end)
