
--[[
On this map, the ground is covered with a trigger_hurt set
to 100 damage (it actually takes 2 ticks to kill someone).
This is used to kill players which fall when the hotel is
demolished or if they somehow manage to survive a fall
from a rooftop.

It will kill people who descend to the floor via spiderman
gun - but hey, screw 'em, we don't want people running
around down there anyway.

The core problem is that when a player falls from a roof,
they won't take 100 fall damage, as they will have taken a
single tick of the trigger_hurt before they hit the ground.

Solution: keep the trigger_hurt in place, but change the
damage amount and type to: 1000 "fall" damage (type 32),
rather than 100 "generic" damage (type 0).

See damage type table here:
https://developer.valvesoftware.com/wiki/Trigger_hurt

This will allow us to correctly award fall-damage related
achievements for this map.
]]--

if SERVER then
    local btnOrig
    local btnDemo
    local demolished = false

    hook.Add("TTTPrepareRound", "NTHMapMod-ttt_rooftops_a2-TTTPrepareRound", function()
        demolished = false
        local entis = ents.FindByClass("trigger_hurt")
        for _,ent in pairs(entis) do
            if IsValid(ent) then
                ent:SetKeyValue("damagetype", "32") -- fall damage
                ent:SetKeyValue("damage", "1000") -- insta kill
            end
        end
        
        local e = ents.GetMapCreatedEntity(2256)
        if e then e:Remove() end -- Remove traitor check
        
        btnOrig = ents.GetMapCreatedEntity(2257) -- Move hotel detonation button outside of map
        btnOrig:SetPos(Vector(0,0,-2000))
        
        btnDemo = ents.GetMapCreatedEntity(2237) -- This prop_physics is the new demolision button
    end)
    
    hook.Add("PlayerUse", "NTHMapMod-ttt_rooftops_a2-PlayerUse", function(ply, ent)
        if not demolished and IsValid(ent) and IsValid(btnDemo) and ent == btnDemo and IsValid(btnOrig) and IsValid(ply) and ply:IsPlayer() and (ply:IsActiveTraitor() or (ply:IsActive() and ply:IsVIP("BJOEL"))) then
            demolished = true
            btnOrig:Input("Press", ply, ply)
            hook.Call("NTHMapMod-ttt_rooftops_a2-HotelDemolished", nil, ply)
        end
    end)
end
