local Round = NTH:NewRound("pewpew")

Round.Name = "Pew Pew"
Round.RDM = true

NTH.AddSounds({
    PewLoop   = "nth/rounds/shakeit.mp3",
    PewEnd   = "nth/rounds/shakeit-end.mp3",
})

function Round:OnPrepare()
    if CLIENT then
        NTH.Marquee:SetText("RDM ROUND / PEW PEW PEW / SHAKE IT OFF / PEW PEW !! / NEWTON WOULD BE PROUD / ")
        NTH.Marquee:Show()
    end
end

function Round:OnBegin()
    if SERVER then
        for _,p in pairs(self:GetPlayingPlayers()) do
            p:SetRole(ROLE_INNOCENT)
        end
    end
end

function Round:OnBegun()
    if CLIENT then
        NTH.SoundLoop:Start(NTH.Sounds.PewLoop, 48)
    end

    if SERVER then
        hook.Add("PlayerCanPickupWeapon", "RDMRound-PlayerCanPickupWeapon", function(ply, wep)
            if wep.ClassName == "weapon_ttt_superpush" then
                return true
            end
            SafeRemoveEntity(wep)
            return false
        end)
    
        local plys = self:GetPlayingPlayers()
        for _,p in pairs(plys) do
            if not IsValid(p) then break end
            
            print("giving radar to", p:Nick())
            p:GiveEquipmentItem(EQUIP_RADAR)
            
            local weps = p:GetWeapons()
            for _,w in pairs(weps) do
                if IsValid(w) then
                    p:DropWeapon(w)
                    SafeRemoveEntity(w)
                end
            end
            
            p:Give("weapon_ttt_superpush")
            p:SelectWeapon("weapon_ttt_superpush")
            
        end
        net.Start("TTT_BoughtItem")
        net.WriteBit(true)
        net.WriteUInt(EQUIP_RADAR, 16)
        net.Send(plys)
    end
end

function Round:OnEnd()
    if CLIENT then
        NTH.SoundLoop:Stop()
        NTH.Sound:Play(NTH.Sounds.PewEnd)
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
