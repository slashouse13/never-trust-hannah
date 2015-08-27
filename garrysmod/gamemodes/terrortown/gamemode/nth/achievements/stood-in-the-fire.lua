-- Stood in the Fire
local Achi = NTH:NewAchievement("stood-in-the-fire")
Achi.Name = "Stood in the Fire"
Achi.Quote = "INFERNO!"

Achi.ProgressPath = {DiedToJaraFire = 1}

hook.Add("PlayerDeath", "NTH-Achi-24-PlayerDeath", function(ply, inflictor, attacker)
    if not inflictor or not IsValid(inflictor) then return end
    if inflictor:GetClass() ~= "env_fire" then return end
    local p = inflictor:GetParent()
    if not p or not IsValid(p) then return end
    if p:GetClass() ~= "ttt_flame" then return end
    if not p.FromJaraxxus then return end
    Achi:progressSet(ply, "DiedToJaraFire")
end)
