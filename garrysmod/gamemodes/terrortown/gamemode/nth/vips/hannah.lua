
local VIP = NTH:NewVIP("HANNAH")

VIP.Name            = "Hannah"
VIP.MaterialStar    = "nth/vips/hannah.vmt"
VIP.SoundIntro      = "nth/vips/intros/hannah.mp3"

function VIP:Assign(ply)
    if SERVER then
        if ply:IsRole(ROLE_INNOCENT) and math.random(1,100) <= 20 then
            -- 20% chance of becoming additional traitor
            ply:SetRole(ROLE_TRAITOR)
            ply:SetDefaultCredits()
        end
    end
end

VIP:Decorate("GetRankName", function()
    return "Admin"
end)

VIP:Decorate("TraitorTest", function()
    return false
end)

VIP:Decorate("KilledBy", function(ply, prevResult, killer)
    if IsValid(killer) and IsValid(ply) and ply:IsTraitor() == killer:IsTraitor() then
        killer:Ignite(30)
    end
end)

VIP:Decorate("CanPinRagdolls", function()
    return true
end)
