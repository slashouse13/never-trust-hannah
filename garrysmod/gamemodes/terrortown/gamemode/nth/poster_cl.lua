
local matCache = {}
local hookNum = 0

NTH.Poster = function(materialPath)
    local mat = matCache[materialPath]
    if not mat then
        matCache[materialPath] = Material(materialPath)
        mat = matCache[materialPath]
    end
    
    return {
        Show = function(self, duration, fadeTime, animation)
            if mat:IsError() then
                print("not playing Poster because of error: "..materialPath)
                return
            end
            
            mat:SetInt("$frame", 0)
            local timeStart = CurTime()
            local timeEnd = timeStart + (duration or 10)
            local timeFade = timeEnd + (fadeTime or 2)
            local animation = animation
            
            if animation then
                for t,frame in pairs(animation) do
                    timer.Simple(t, function()
                        mat:SetInt("$frame", frame)
                    end)
                end
            end
            
            hookName = "HUDPaint-NTHPoster-"..hookNum
            hookNum = hookNum + 1
            
            hook.Add("HUDPaint", hookName, function()
                if CurTime() > timeFade then
                    hook.Remove(hookName)
                    return
                end

                local alpha = 255
                if CurTime() > timeEnd then
                    alpha = math.floor(math.ceil(((timeFade - CurTime())/2 * 255), 0), 255)
                end
                
                surface.SetMaterial(mat)
                surface.SetDrawColor(255, 255, 255, alpha);
                surface.DrawTexturedRect((ScrW()/2) - 256,(ScrH()/2) - 256, 512, 512)
            end)
            
            
        end
    }

end
