-- Jihad-o-meter
local Achi = NTH:NewAchievement("jihad-o-meter")
Achi.Name = "Jihad-o-meter"
Achi.Quote = "I think this is called divine intervention."

Achi.ProgressPath = {SwordfishKills = 5}
Achi.ProgressNotify = {SwordfishKills = "%s/%s players exploded"}

hook.Add("DoPlayerDeath", "NTH-Achi-3-Death", function(ply, attacker, dmginfo)
    if not IsValid(attacker) or not attacker:IsPlayer() or not attacker:IsVIP("SWORDFISH") then return end
    -- attacker is swordfish
    if not attacker:IsSpec() then return end
    -- attacker is spectator
    if not attacker.propspec or not attacker.propspec.ent then return end
    -- attacker is prop speccing
    if not dmginfo:IsExplosionDamage() then return end
    -- damage is caused by explosion
    Achi:progressInc(attacker, "SwordfishKills")
end)

hook.Add("TTTPropspecStart", "NTH-Achi-3-Propspec", function(ply, ent)
    Achi:progressReset(ply, "SwordfishKills")
end)
