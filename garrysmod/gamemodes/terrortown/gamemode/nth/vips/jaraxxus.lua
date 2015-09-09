
local VIP = NTH:NewVIP("JARAXXUS")

VIP.Name            = "Jaraxxus"
VIP.MaterialStar    = "nth/vips/jaraxxus.vmt"
VIP.SoundIntro      = "nth/vips/intros/jaraxxus.mp3"

hook.Add("EntityTakeDamage", "VIP-JARAXXUS-EntityTakeDamage", function(ply, dmg)
    if not ply or not IsValid(ply) or not ply:IsPlayer() or not ply:IsVIP("JARAXXUS") then return end
    
    if dmg:IsDamageType(DMG_BURN) then
        dmg:SetDamage(0)
        dmg:SetDamageType(DMG_GENERIC)
    end
end)

hook.Add("NTH-TGTurtle-Spawned", "NTH-TGTurtle-Spawned-Jaraxxus", function(turtle, proj)
    if not IsValid(proj) or not proj.GetThrower or not proj.GetCooked then return end
    local ply = proj:GetThrower()
    if not IsValid(ply) or not ply.IsVIP then return end

    if ply:IsVIP("JARAXXUS") and proj:GetCooked() then
        turtle:Ignite(30)
        turtle.is_infernal = true;
    end
end)

hook.Add("NTH-TGTurtle-Died", "NTH-TGTurtle-Died-Jaraxxus", function(entNPC, corpse)
    if not entNPC.is_infernal then return end

    local flame = ents.Create("ttt_flame")
    flame:SetPos(corpse:GetPos())
    local dmgowner = entNPC:GetNWEntity("Thrower")
    print("Creating flame belonging to ", dmgowner)
    if IsValid(dmgowner) and dmgowner:IsPlayer() then
        flame:SetDamageParent(dmgowner)
        flame:SetOwner(dmgowner)
    end
    flame.fireparams = {size=500, growth=1}
    flame.next_hurt = CurTime()
    flame:SetDieTime(CurTime() + 500)
    -- flame:SetExplodeOnDeath(explode)
    flame:SetDamageOverride(8)
    flame:SetDamageRadius(120)

    flame:SetParent(corpse)
    corpse:SetColor(Color(40,0,0,255))
    flame:Spawn()
end)

if SERVER then
    local infernals
    infernals = {}
    
    timer.Remove("NTH-InfernalTrail")
    timer.Create("NTH-InfernalTrail", 1, 0, function()
        for _,p in pairs(infernals) do
            if not p or not IsValid(p) or not p:IsPlayer() or not p:Alive() or p:Team() ~= TEAM_TERROR then
                continue
            end
            
            if p:WaterLevel() > 0 then
                local dmg = DamageInfo()
                dmg:SetDamageType(DMG_DROWN)
                dmg:SetDamage(math.random(4,6))
                dmg:SetInflictor(p)
                dmg:SetAttacker(p)
                p:TakeDamageInfo(dmg)
            else
                p:Ignite(1)
            end
            
        end
    end)
    
    timer.Create("NTH-InfernalTrail2", 0.2, 0, function()
        for _,p in pairs(infernals) do
            if not p or not IsValid(p) or not p:IsPlayer() or not p:Alive() or p:Team() ~= TEAM_TERROR then
                continue
            end
            
            if p:WaterLevel() > 0 then
                -- do nothing
            else
            
                local flame = ents.Create("ttt_flame")
                flame:SetPos(p:GetPos())
                flame:SetDamageParent(p)
                flame:SetOwner(p)
                flame:SetDieTime(CurTime() + 1)
                flame:SetDamageOverride(1)
                flame:SetDamageRadius(44)
                flame:Spawn()
                flame.fireparams = {size=20, growth=1}
                flame.next_hurt = CurTime()
                
                flame:SetVelocity(Vector(0,0,0))
                flame.FromJaraxxus = true

            end
            
        end
    end)

    function VIP:Assign(ply)
        table.insert(infernals, ply)
    end

    function VIP:Unassign(ply)
        if IsValid(ply) and ply.Extinguish then
            ply:Extinguish()
            local es = ents.FindInSphere(ply:GetPos(), 100)
            for _,e in pairs(es) do
                if IsValid(e) and e:GetClass() == "ttt_flame" and e.FromJaraxxus then
                    e:SetDieTime(CurTime())
                end
            end
        end
        table.RemoveByValue(infernals, ply)
    end
end
