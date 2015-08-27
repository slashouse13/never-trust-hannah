-- NTH scoreboard

local table = table
local math = math

local sb = nil

local tags = {
   {txt="sb_tag_friend", color=COLOR_GREEN},
   {txt="sb_tag_susp",   color=COLOR_YELLOW},
   {txt="sb_tag_avoid",  color=Color(255, 150, 0, 255)},
   {txt="sb_tag_kill",   color=COLOR_RED},
   {txt="sb_tag_miss",   color=Color(130, 190, 130, 255)}
};

GROUP_TERROR = 1
GROUP_NOTFOUND = 2
GROUP_FOUND = 3
GROUP_SPEC = 4

GROUP_COUNT = 4

local function ScoreGroup(p)
    if not IsValid(p) then return -1 end -- will not match any group panel

    if DetectiveMode() then
        if p:IsSpec() and (not p:Alive()) then
            if p:GetNWBool("body_found", false) then
                return GROUP_FOUND
            else
                local client = LocalPlayer()
                -- To terrorists, missing players show as alive
                if client:IsSpec() or client:IsActiveTraitor() or ((GAMEMODE.round_state != ROUND_ACTIVE) and client:IsTerror()) then
                    return GROUP_NOTFOUND
                else
                    return GROUP_TERROR
                end
            end
        end
    end

    return p:IsTerror() and GROUP_TERROR or GROUP_SPEC
end

local function ScoreboardRemove()
    timer.Remove("NTH-SB-Updater")
    if sb then
        sb:RemoveJSHooks()
        sb:Remove()
        sb = nil
    end
end
hook.Add("TTTLanguageChanged", "RebuildScoreboard", ScoreboardRemove)
net.Receive("nth_reload_scoreboard", function()
    ScoreboardRemove()
end)

function GM:ScoreboardCreate()
    ScoreboardRemove()

    sb = vgui.Create("GHTML")
    sb:OpenURL(NTHC.ScoreboardURL)
    sb:Dock(FILL)
    
    sb.UpdateScoreboard = function()
        local players = {}
        for _,p in pairs(player.GetAll()) do
            table.insert(players, {
                id = p:EntIndex(),
                group = ScoreGroup(p),
                name = p:Nick(),
                ping = p:Ping(),
                karma = math.Round(p:GetBaseKarma()),
                steamid = p:SteamID(),
                traitor = p:IsTraitor(),
                detective = p:IsDetective(),
                localplayer = (p == LocalPlayer()),
                muted = p:IsMuted(),
                vip = (p:IsVIP() and p:GetDisplayName()) or false,
                rank = p:GetRankName(),
                tag = (p.sb_tag and p.sb_tag.txt) or false,
            })
        end
        hook.Call("TTTScoreboardUpdate", nil, players)
    end
    
    sb.StartUpdateTimer = function()
        timer.Create("NTH-SB-Updater", 0.5, 0, function()
            sb.UpdateScoreboard()
        end)
    end
end

local function NotifyTimeLeft()
    local rounds_left = math.max(0, GetGlobalInt("ttt_rounds_left", 6))
    local time_left = math.floor(math.max(0, ((GetGlobalInt("ttt_time_limit_minutes") or 60) * 60) - CurTime()))
    hook.Call("NTH-SB-TimeLeft", nil, rounds_left, time_left)
end

hook.Add("NTH-SB-GetTimeLeft", "NTH-SB-GetTimeLeft", NotifyTimeLeft)
hook.Add("TTTEndRound", "NTH-TTTRoundEnd-SB-Timeleft", function()
    NotifyTimeLeft()
    timer.Simple(2, NotifyTimeLeft)
    hook.Call("NTH-SB-UpdateMeta")
end)

hook.Add("NTH-AchiAward", "NTH-SB-AchiAward", function(p)
    hook.Call("NTH-SB-UpdateMeta", nil, p:EntIndex())
end)

hook.Add("NTH-SB-GetAvailableTags", "NTH-SB-GetAvailableTags", function()
    local atags = {}
    for _,tag in ipairs(tags) do
        table.insert(atags, {
            txt = tag.txt,
            color = tag.color,
            name = LANG.GetTranslation(tag.txt)
        })
    end
    hook.Call("NTH-SB-AvailableTags", nil, atags)
end)

hook.Add("NTH-SB-ToggleMute", "NTH-SB-ToggleMute", function(id, mute)
    local p = player.GetByID(id)
    if IsValid(p) then p:SetMuted(mute) end
end)

hook.Add("NTH-SB-OpenProfile", "NTH-SB-OpenProfile", function(id)
    local p = player.GetByID(id)
    if IsValid(p) then
        p:ShowProfile()
    end
end)

hook.Add("NTH-SB-SetTag", "NTH-SB-SetTag", function(id, tagTxt)
    local p = player.GetByID(id)
    if IsValid(p) then
        p.sb_tag = nil
        for _,t in pairs(tags) do
            if t.txt == tagTxt then
                p.sb_tag = t
            end
        end
    end
end)

function GM:ScoreboardShow()
    self.ShowScoreboard = true
    if not sb then self:ScoreboardCreate() end
    gui.EnableScreenClicker(true)
    sb:SetVisible(true)
    sb:UpdateScoreboard(true)
    sb:StartUpdateTimer()
end

function GM:ScoreboardHide()
    self.ShowScoreboard = false
    gui.EnableScreenClicker(false)
    if sb then
        sb:SetVisible(false)
        sb:GetOpenURL(function(url)
            if url ~= NTHC.ScoreboardURL then
                sb:OpenURL(NTHC.ScoreboardURL)
            end
        end)
    end
end

function GM:GetScoreboardPanel() return sb end
function GM:HUDDrawScoreBoard() end
