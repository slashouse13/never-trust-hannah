
local function UpdateWebsite(event, data)
    NTH.WEB(
        "realtime-report/"..event,
        data,
        function()
            print("Updated Website: " .. event)
        end
    )
end

local function WebPlayerInfo(p)
    local pinfo = {
        name    = p:GetDisplayName(),
        realname= p:Nick(),
        steamid = p:SteamID64(),
        --uid     = p:UniqueID(),
        vip     = p:GetVIP(),
        role    = p:GetRole() or ROLE_NONE,
        identd  = p:GetNWBool("body_found"),
        gone    = not p:IsConnected(),
        --score   = p:GetNTHScore(),
        karma   = p:GetBaseKarma(),
        rank    = p:GetUserGroup()
    }
    
    if pinfo.role == ROLE_TRAITOR and GetRoundState() == ROUND_ACTIVE and not pinfo.identified then
        pinfo.role = ROLE_INNOCENT
    end
    
    return pinfo
end

local lastWinner = WIN_NONE
local function WebRoundInfo()
    local players = {}
    for idx,p in ipairs(player.GetAll()) do
        table.insert(players, WebPlayerInfo(p))
    end
    
    local info = {
        map         = game.GetMap(),
        servername  = GetHostName(),
        maxplayers  = game.MaxPlayers(),
        playercount = #player.GetHumans(),
        lastwinner  = lastWinner,
        roundstate  = GetRoundState(),
    }
    
    return {info = info, players = players}
end

local function UpdateWebsiteRoundInfo()
    UpdateWebsite("info", WebRoundInfo())
end

local function UpdateWebsitePlayerInfo(ply)
    UpdateWebsite("player", WebPlayerInfo(ply))
end

hook.Add("NTHIdentBody",        "NW-NTHIdentBody",          UpdateWebsitePlayerInfo) -- does this hook exist?
hook.Add("TTTPrepareRound",     "NW-TTTPrepareRound",       UpdateWebsiteRoundInfo)
hook.Add("TTTEndRound",         "NW-TTTEndRound",           UpdateWebsiteRoundInfo) -- also need to record last win
hook.Add("TTTBeginRound",       "NW-TTTBeginRound",         UpdateWebsiteRoundInfo)
hook.Add("PlayerInitialSpawn",  "NW-PlayerInitialSpawn",    UpdateWebsitePlayerInfo)
hook.Add("PlayerDisconnected",  "NW-PlayerDisconnected",    UpdateWebsiteRoundInfo) -- also need to record gone
hook.Add("InitPostEntity",      "NW-InitPostEntity",        UpdateWebsiteRoundInfo)
-- and update automatically every 20 seconds
timer.Create('AutoUpdateWebsiteRoundInfo', 20, 0,           UpdateWebsiteRoundInfo)
