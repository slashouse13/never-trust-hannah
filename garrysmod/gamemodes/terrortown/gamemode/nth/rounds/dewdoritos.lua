local Round = NTH:NewRound("dewdoritos")

Round.Name = "Dew & Doritos"
Round.RDM = true

resource.AddFile("materials/nth/posters/dewdoritos.vmt")

NTH.AddSounds({
    DewDoritosIntro = "nth/rounds/dewdoritos.mp3"
})

local DNDPoster
if CLIENT then
    DNDPoster = NTH.Poster("nth/posters/dewdoritos")
end

function Round:OnPrepare()
    if CLIENT then
        
        NTH.Marquee:SetText("RDM ROUND / FUCK EACH OTHER UP, LIKE I CARE / RDM ROUND / SURVIVE AND ALL THE GIRLS WILL LOVE YOU / RDM ROUND / REK ALL THE SKRUBS / RDM ROUND / RIOT! RIOT! RIOT! / ")
        NTH.Marquee:Show()
        
        DNDPoster:Show(15, 0, {
            [0] = 0,
            [2] = 1,
            [4] = 2,
            [6] = 3,
            [8] = 4,
            [10] = 5,
            [13.5] = 6,
        })
        NTH.Sound:Play(NTH.Sounds.DewDoritosIntro)
    end
end

function Round:OnBegin()
    if SERVER then
        for _,p in pairs(self:GetPlayingPlayers()) do
            p:SetRole(ROLE_INNOCENT)
            p:SetVIP("NOSCOPER")
        end
    end
end

function Round:OnBegun()
    if SERVER then
        hook.Add("PlayerCanPickupWeapon", "RDMRound-PlayerCanPickupWeapon", function(ply, wep)
            if wep.ClassName == "weapon_zm_rifle" then
                return true
            end
            SafeRemoveEntity(wep)
            return false
        end)
    
        local plys = self:GetPlayingPlayers()
        for _,p in pairs(plys) do
            if not IsValid(p) then break end
        
            p:GiveEquipmentItem(EQUIP_RADAR)
            
            local weps = p:GetWeapons()
            for _,w in pairs(weps) do
                if IsValid(w) and w.ClassName ~= "weapon_zm_rifle" then
                    p:DropWeapon(w)
                    SafeRemoveEntity(w)
                end
            end
        end
        
        net.Start("TTT_BoughtItem")
        net.WriteBit(true)
        net.WriteUInt(EQUIP_RADAR, 16)
        net.Send(plys)
    end
end

function Round:OnEnd()
    if CLIENT then
        NTH.Marquee:Hide()
    end
    
    if SERVER then
        hook.Remove("PlayerCanPickupWeapon", "RDMRound-PlayerCanPickupWeapon")
    end
end

if SERVER then
    function Round:WinCheck()
        local alive = 0
        for _,p in pairs(player.GetAll()) do
            if p:Alive() and p:IsTerror() then
                alive = alive + 1
            end
        end
        
        if alive <= 1 then
            return WIN_INNOCENT
        end
    end
end
