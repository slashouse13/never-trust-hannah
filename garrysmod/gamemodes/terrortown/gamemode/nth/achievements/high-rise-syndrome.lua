-- High Rise Syndrome
local Achi = NTH:NewAchievement("high-rise-syndrome")
Achi.Name = "High Rise Syndrome"
Achi.Quote = "Curiosity killed the cat."

Achi.ProgressPath = {DieFromFallingAsKiba = 1}

hook.Add("DoPlayerDeath", "NTH-Achi-4-Fall", function(ply, attacker, dmginfo)
    if IsValid(ply) and ply:IsPlayer() and ply:IsVIP("KIBA") and dmginfo:IsFallDamage() and (ply:Health() + math.ceil(dmginfo:GetDamage())) >= 100 then
        Achi:progressSet(ply, "DieFromFallingAsKiba", 1)
    end
end)
