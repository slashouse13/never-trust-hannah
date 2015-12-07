
AddCSLuaFile()

local VendModel = Model("models/props_interiors/vendingmachinepepsi1a.mdl")

if SERVER then
    concommand.Add("nth_pepsi", function(ply)
        local pos = ply:GetPos()
        local ang = ply:GetAngles()
        
        timer.Simple(2, function()
        
            pos.z = pos.z + 49
            local entT = ents.Create("prop_physics") 
            entT:SetModel(VendModel)
            entT:SetPos(pos)
            entT:SetAngles(ang)
            entT:Spawn()

            pos = pos + (ang:Forward() * 32)
            local entL = ents.Create("light_dynamic")
            entL:SetPos(pos)
            entL:SetKeyValue("distance", "300")
            entL:SetKeyValue("brightness", "8")
            entL:SetColor(Color(1,1,5))
            entL:SetParent(entT)
            entL:Spawn()
            
            timer.Simple(5, function()
                entT:Remove()
                entL:Remove()
            end)
        
        
        end)
    end)
    

end
