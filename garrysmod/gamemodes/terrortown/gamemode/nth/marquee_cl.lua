
surface.CreateFont("MarqueeFont", {font="BadaBoom BB", size=32})

local matCache = {}

local M = {}

function M:Precache(mat, options)
    if not matCache[mat] then
        matCache[mat] = Material(mat, options)
    end
    return matCache[mat]
end

function M:SetMat(mat)
    self.mat = self:Precache(mat)
end

function M:SetText(text)
    self.text = text
    surface.SetFont("MarqueeFont")
    self.textWidth = surface.GetTextSize(text)
end

function M:Show()
    local m = self

    local textData = {
        text = m.text,
        font = "MarqueeFont",
        pos = {0, 7},
        color = Color(50,50,50)
    }
    
    local w = ScrW()
    local h = ScrH()
    local pos = 0
    local dropProg = 0
    local dropPos = 0
    local opening = true
    m.closing = false
    
    hook.Add("HUDPaintBackground", "NTH-Marquee-Paint", function()
        if opening and dropPos < 1 then
            dropProg = dropProg + FrameTime()*0.5
            dropPos = NTH.Effects.EaseInOutSine(dropProg)
            if dropPos >= 1 then
                opening = false
            end
        end
        
        if m.closing then
            dropProg = dropProg - FrameTime()*0.5
            dropPos = NTH.Effects.EaseInOutSine(dropProg)
            if dropPos <= 0 then
                hook.Remove("HUDPaintBackground", "NTH-Marquee-Paint")
            end
        end
        
        surface.SetMaterial(m.mat)
        surface.SetDrawColor(COLOR_WHITE)
        local dx = 0
        while dx < w do
            surface.DrawTexturedRect(dx, ((dropPos*44)-44), 256, 64)
            surface.DrawTexturedRect(dx, (h-(dropPos*44)),256,64)
            dx = dx + 256
        end
        
        textData.pos[1] = pos
        while textData.pos[1] < w do
            textData.pos[1] = textData.pos[1] + m.textWidth
        end
        
        while textData.pos[1] > -m.textWidth do
            textData.pos[2] = ((dropPos*44)-44) + 7
            draw.Text(textData)
            textData.pos[2] = (h-(dropPos*44)) + 7
            draw.Text(textData)
            textData.pos[1] = textData.pos[1] - m.textWidth
        end
        
        pos = pos - FrameTime()*60
    end)
end

function M:Hide()
    self.closing = true
end

M:SetMat("nth/posters/tape")

NTH.Marquee = M
