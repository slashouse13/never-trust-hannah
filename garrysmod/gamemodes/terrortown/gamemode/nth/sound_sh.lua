
local S = {}

if SERVER then
    function S:Play(soundPath, ply)
        umsg.Start("nth_um_sound", ply)
        umsg.String(soundPath)
        umsg.End()
    end
else -- CLIENT
    function S:Play(soundPath)
        surface.PlaySound(soundPath)
    end
    
    usermessage.Hook("nth_um_sound", function(um)
        S:Play(um:ReadString())
    end)
end

NTH.Sound = S
