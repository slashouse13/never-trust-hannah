-- 67th Waste of Time
local Achi = NTH:NewAchievement("67th-waste-of-time")
Achi.Name = "67th Waste of Time"
Achi.Quote = "Why bother?"

Achi.ProgressPath = {RanOver = 67}
Achi.ProgressNotify = {RanOver = "You have been ran over %s times"}

hook.Add("DoPlayerDeath", "NTH-Achi-8-Death", function(victim, attacker, dmginfo)
    if game.GetMap() != "ttt_67thway_v3" then return end
    if not IsValid(victim) or not victim:IsPlayer() then return end
    
    victim:GetPos():WithinAABox(Vector(-300,-2200,100), Vector(220,3050,500))
    -- we were standing on the road...
    
    local inflictor = dmginfo:GetInflictor()
    if not inflictor or inflictor:GetClass() != "trigger_hurt" then return end
    -- killed by a trigger_hurt (only cars use these currently on 67th way)
    
    local nearCar = false
    local es = ents.FindInSphere(victim:GetPos(), 200)
    for _,e in pairs(es) do
        if e:GetClass() == "func_tracktrain" then
            nearCar = true
        end
    end
    if not nearCar then return end
    -- we were near a func_tracktrain (almost certainly a car)
    
    Achi:persistProgressInc(victim, "RanOver", 1)
end)
