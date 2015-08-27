local P = {}

if SERVER then
    function P:Show(text, duration, fadeTime)
        umsg.Start("nth_um_headlineshow")
        umsg.String(text)
        umsg.Short(duration or 10)
        umsg.Short(fadeTime or 2)
        umsg.End()
    end
    
else -- CLIENT
    local fontSize = math.floor(ScrW() / 15)
    surface.CreateFont("HeadlineFont", {font="BadaBoom BB", size=fontSize})

    function P:Show(text, duration, fadeTime)
        self.text = text
        self.timeStart = CurTime()
        self.timeEnd = self.timeStart + (duration or 10)
        self.timeFade = self.timeEnd + (fadeTime or 2)
        self.active = true
    end

    hook.Add("HUDPaint", "HUDPaint-NTHHeadline", function()
        if not P.active then
            return
        end
        
        if not P.text or CurTime() > P.timeFade or CurTime() < P.timeStart then
            P.active = false
            return
        end
        
        local alpha = 255
        if CurTime() > P.timeEnd then
            alpha = math.floor(math.ceil(((P.timeFade - CurTime())/2 * 255), 0), 255)
        end
        
        draw.SimpleTextOutlined(P.text, "HeadlineFont", ScrW()/2, ScrH()/6, Color(0,0,0,alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, math.ceil(fontSize / 40), Color(255,255,255,alpha))
    end)
    
    usermessage.Hook("nth_um_headlineshow", function(um)
        P:Show(um:ReadString(), um:ReadShort(), um:ReadShort())
    end)
end

NTH.Headline = P
