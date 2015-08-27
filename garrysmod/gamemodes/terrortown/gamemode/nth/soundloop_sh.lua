
local SL = {}

if SERVER then
    function SL:Start(soundPath, loopTime)
        umsg.Start("nth_um_soundloopstart")
        umsg.String(soundPath)
        umsg.Short(loopTime)
        umsg.End()
    end
    
    function SL:Stop()
        umsg.Start("nth_um_soundloopstop")
        umsg.End()
    end
    
else -- CLIENT
    function SL:Start(soundPath, loopTime)
        self:Stop()
        self.sound = CreateSound(LocalPlayer(), soundPath)
        local sound = self.sound
        timer.Create("NTHSoundLoop", loopTime, 0, function()
            sound:Stop()
            sound:Play()
        end)
        sound:PlayEx(1, 100)
    end

    function SL:Stop()
        if self.sound then
            self.sound:Stop()
            self.sound = nil
        end
        timer.Destroy("NTHSoundLoop")
    end
    
    usermessage.Hook("nth_um_soundloopstart", function(um)
        SL:Start(um:ReadString(), um:ReadShort())
    end)
    usermessage.Hook("nth_um_soundloopstop", function(um)
        SL:Stop()
    end)
    
end

NTH.SoundLoop = SL
