
local VIP = NTH:NewVIP("JARAXXUS")

VIP.Name            = "Jaraxxus"
VIP.MaterialStar    = "nth/vips/jaraxxus.vmt"
VIP.SoundIntro      = "nth/vips/intros/jaraxxus.mp3"

if SERVER then
    resource.AddFile("sound/nth/vips/jaraxxus/oblivion.wav")
else -- CLIENT
    util.PrecacheSound("nth/vips/jaraxxus/oblivion.wav")
end

if SERVER then
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
        if IsValid(dmgowner) and dmgowner:IsPlayer() then
            flame:SetDamageParent(dmgowner)
            flame:SetOwner(dmgowner)
        end
        flame.fireparams = {size=500, growth=1}
        flame.next_hurt = CurTime()
        flame:SetDieTime(CurTime() + 500)
        flame:SetDamageOverride(8)
        flame:SetDamageRadius(120)

        flame:SetParent(corpse)
        corpse:SetColor(Color(40,0,0,255))
        flame:Spawn()
    end)
for _,p in pairs(player.GetAll()) do p:Give("weapon_ttt_confgrenade") end
    hook.Add("NTH-BaseGrenade-CookedInFace", "NTH-BaseGrenade-CookedInFace-Jaraxxus", function(wep)
        local ply = wep.Owner
        if not IsValid(ply) or not ply:IsVIP("JARAXXUS") then return end
        
        ply:EmitSound("nth/vips/jaraxxus/oblivion.wav")

        timer.Simple(0.1, function()
            local pos = ply:GetPos()
            local radius = 400
            local phys_force = 4500
            local push_force = 256

            StartFires(pos, nil, 10, 20, false, ply)

            -- pull physics objects and push players
            for k, target in pairs(ents.FindInSphere(pos, radius)) do
              if IsValid(target) and target ~= ply then
                 local tpos = target:LocalToWorld(target:OBBCenter())
                 local dir = (tpos - pos):GetNormal()
                 local phys = target:GetPhysicsObject()

                 if target:IsPlayer() and (not target:IsFrozen()) and ((not target.was_pushed) or target.was_pushed.t != CurTime()) then

                    -- always need an upwards push to prevent the ground's friction from
                    -- stopping nearly all movement
                    dir.z = math.abs(dir.z) + 1

                    local push = dir * push_force

                    -- try to prevent excessive upwards force
                    local vel = target:GetVelocity() + push
                    vel.z = math.min(vel.z, push_force)

                    target:SetVelocity(vel)

                    target.was_pushed = {att=ply, t=CurTime()}

                 elseif IsValid(phys) then
                    phys:ApplyForceCenter(dir * -1 * phys_force)
                 end
              end
            end

            local phexp = ents.Create("env_physexplosion")
            if IsValid(phexp) then
              phexp:SetPos(pos)
              phexp:SetKeyValue("magnitude", 100) --max
              phexp:SetKeyValue("radius", radius)
              -- 1 = no dmg, 2 = push ply, 4 = push radial, 8 = los, 16 = viewpunch
              phexp:SetKeyValue("spawnflags", 1 + 2 + 16)
              phexp:Spawn()
              phexp:Fire("Explode", "", 0.2)
            end
        end)
    end)


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
