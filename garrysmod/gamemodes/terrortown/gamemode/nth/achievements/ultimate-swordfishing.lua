-- Ultimate Swordfishing
local Achi = NTH:NewAchievement("ultimate-swordfishing")
Achi.Name = "Ultimate Swordfishing"
Achi.Quote = "Just like in the movie."

Achi.ProgressPath = {SwordfishIt = 1}

hook.Add("DoPlayerDeath", "NTH-Achi-21-Death", function(ply, attacker, dmginfo)
    if not IsValid(attacker) or not attacker:IsPlayer() or not attacker:IsVIP("SWORDFISH") then return end
    -- attacker is swordfish
    if not attacker:IsSpec() then return end
    -- attacker is spectator
    if not dmginfo:IsExplosionDamage() then return end
    -- damage is caused by explosion
    if not attacker.propspec or not attacker.propspec.ent then return end
    -- we're a helicopter bomb, right?
    if attacker.propspec.ent:GetModel() != "models/combine_helicopter/helicopter_bomb01.mdl" then return end
    -- ok, that works
    Achi:progressSet(attacker, "SwordfishIt")
end)
