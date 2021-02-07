local Round = NTH:NewRound("meowoclock")

Round.Name = "Meow O'Clock"
Round.RDM = true

resource.AddFile("materials/nth/posters/meowoclock.vmt")

NTH.AddSounds({
    MOCLoop   = "nth/rounds/meowoclock.mp3",
    MOCIntro  = "nth/rounds/moc-intro.mp3",
    MOCOutro  = "nth/rounds/moc-outro.mp3"
})

local PosterMOC
if CLIENT then
    PosterMOC = NTH.Poster("nth/posters/meowoclock")
end

function Round:OnPrepare()
    if CLIENT then
        NTH.Marquee:SetText("RDM ROUND / MEOW MEOW MEOW / RDM ROUND / MEOW MEOW / RDM / ... / ")
        NTH.Marquee:Show()
        NTH.Sound:Play(NTH.Sounds.MOCIntro)
    end
end

function Round:OnBegin()
    if SERVER then
        for _,p in pairs(self:GetPlayingPlayers()) do
            p:SetRole(ROLE_INNOCENT)
            p:SetVIP("KIBA")
        end
    end
end

function Round:OnBegun()
    if CLIENT then
        NTH.SoundLoop:Start(NTH.Sounds.MOCLoop, 46)
        PosterMOC:Show(5)
    end
    
    if SERVER then
        local plys = self:GetPlayingPlayers()
        for _,p in pairs(plys) do
            if not IsValid(p) then break end
        
            p:GiveEquipmentItem(EQUIP_RADAR)
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
        NTH.Sound:Play(NTH.Sounds.MOCOutro)
        NTH.Marquee:Hide()
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
