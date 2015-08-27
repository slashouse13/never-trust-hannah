
local sideTex = surface.GetTextureID("nth/achievements/achi-banner-side")

local colBg = Color(0, 49, 66)
local colBd = Color(224, 222, 66)

surface.CreateFont("AchiTitleBig", {font="BadaBoom BB", size=60})
surface.CreateFont("AchiQuoteBig", {font="coolvetica", size=24})

local AchievementBanner = {}
AchievementBanner.__index = AchievementBanner

function AchievementBanner:Create(title, quote, icon)
    local a = {}
    setmetatable(a, AchievementBanner)
    
    a.Title = title
    a.Quote = quote
    a.Icon = icon

    a.MaxWidth = 500 -- before smaller screens can't see it

    local t = CurTime()
    
    a.DrawIconStart = t
    a.DrawIconEnd = t + 2
    a.DrawBannerStart = t + 1
    a.DrawBannerEnd = t + 2
    a.DrawTextStart = t + 1.5
    a.DrawTextEnd = t + 2
    
    t = t + 10 -- How long does the achievement bar stay up?
    
    a.UndrawStart = t
    a.UndrawTextStart = t
    a.UndrawTextEnd = t + 0.5
    a.UndrawBannerStart = t
    a.UndrawBannerEnd = t + 1
    a.UndrawIconStart = t + 1
    a.UndrawIconEnd = t + 1.7
    a.UndrawEnd = t + 1.5
    
    hook.Add("HUDPaint", "HUDPaint-Achievement-" .. tostring(t), function()
        if CurTime() < a.UndrawEnd then
            a:Draw()
        else
            hook.Remove("HUDPaint", "HUDPaint-Achievement-" .. tostring(t))
        end
    end)
    
    return a
end

function AchievementBanner:Draw()
    local t = CurTime()
    
    if t > self.UndrawEnd then
        return
    end

    if t < self.UndrawStart then
        self.DrawIconProgress = NTH.Effects.EaseOutElastic(math.TimeFraction(self.DrawIconStart, self.DrawIconEnd, CurTime()))
        self.DrawBannerProgress = NTH.Effects.EaseOutCubic(math.TimeFraction(self.DrawBannerStart, self.DrawBannerEnd, CurTime()))
        self.DrawTextProgress = NTH.Effects.EaseInOutCubic(math.TimeFraction(self.DrawTextStart, self.DrawTextEnd, CurTime()))
    else
        self.DrawIconProgress = 1-NTH.Effects.EaseOutSine(math.TimeFraction(self.UndrawIconStart, self.UndrawIconEnd, CurTime()))
        self.DrawBannerProgress = 1-NTH.Effects.EaseInCubic(math.TimeFraction(self.UndrawBannerStart, self.UndrawBannerEnd, CurTime()))
        self.DrawTextProgress = 1-NTH.Effects.EaseInOutCubic(math.TimeFraction(self.UndrawTextStart, self.UndrawTextEnd, CurTime()))
    end

    surface.SetFont("AchiTitleBig")
    local width = surface.GetTextSize(self.Title) + 24
    surface.SetFont("AchiQuoteBig")
    width = math.max(width, surface.GetTextSize(self.Quote) + 24)
    
    local barWidth = (width + 64) * self.DrawBannerProgress
    
    local x = ((ScrW() / 2) - (width / 2)) + 48
    local y = math.min(ScrH() * 0.75, ScrH() - 400)

    if t > self.DrawBannerStart and t < self.UndrawIconStart then
        surface.SetDrawColor(COLOR_WHITE)
    
        surface.SetTexture(sideTex)
        surface.DrawTexturedRect(x + barWidth - 64, y, 128, 128)
        
        surface.SetDrawColor(colBg)
        surface.DrawRect(x - 64, y + 16, barWidth, 96)
        
        surface.SetDrawColor(colBd)
        surface.DrawRect(x - 64, y + 16, barWidth, 4)
        surface.DrawRect(x - 64, y + 108, barWidth, 4)
    end
    
    surface.SetDrawColor(COLOR_WHITE)
    
    surface.SetTexture(self.Icon)
    local scale = 128 * self.DrawIconProgress
    surface.DrawTexturedRectRotated(
        x - 64,
        y + 64,
        scale,
        scale,
        360 * self.DrawIconProgress
    )
    
    local textAlphaColour = Color(255,255,255,255 * self.DrawTextProgress)
    if CurTime() > self.DrawTextStart then
        draw.SimpleText(self.Title, "AchiTitleBig", x + (width / 2), y + 50, textAlphaColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(self.Quote, "AchiQuoteBig", x + (width / 2), y + 90, textAlphaColour, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

NTH.AchievementBanner = AchievementBanner
