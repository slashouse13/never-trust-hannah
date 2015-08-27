
local VIP = NTH:NewVIP("SWORDFISH")

VIP.Name            = "Swordfish"
VIP.MaterialStar    = "nth/vips/swordfish.vmt"
VIP.SoundIntro      = "nth/vips/intros/swordfish.mp3"

VIP:Decorate("CanExplodeProps", function(ply)
    return ply:GetBaseKarma() >= 1000 
end)

VIP:Decorate("ExplodedProp", function(ply)
    KARMA.GivePenaltyRealtime(ply, 20)
end)
