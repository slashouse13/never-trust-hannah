
local VIP = NTH:NewVIP("BJOEL")

VIP.Name            = "Billy Joel"
VIP.MaterialStar    = "nth/vips/billyjoel.vmt"
VIP.SoundIntro      = "nth/vips/intros/billyjoel.mp3"

function VIP:Assign(ply)
    if SERVER then
        if ply:IsRole(ROLE_INNOCENT) and math.random(1,100) <= 50 then
            -- 50% chance of becoming additional detective
            ply:SetRole(ROLE_DETECTIVE)
            ply:SetDefaultCredits()
        end
    end
end

VIP:Decorate("CanUseTraitorButtons", function(ply, prevResult)
    return true
end)
