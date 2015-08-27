util.AddNetworkString("nth_achi_award")

-- Add resources
resource.AddFile("sound/nth/achievements/achi-get.mp3")
local achiMatDir = "materials/nth/achievements/"
for _,f in pairs(file.Find(achiMatDir .. "*.vmt", "GAME")) do
    resource.AddFile(achiMatDir .. f)
end


local plymeta = FindMetaTable("Player")

function plymeta:CountAchievements()
    if not self.Achievements then return 0 end
    local i = 0
    for _,_ in pairs(self.Achievements) do
        i = i + 1
    end
    return i
end

function plymeta:GetAchievements()
    return self.Achievements
end

function plymeta:HasAchievement(alias)
    return not not (self.Achievements and self.Achievements[alias])
end

function plymeta:SetAchievement(alias)
    if self.Achievements == nil then
        self.Achievements = {}
    end
    self.Achievements[alias] = true
end


-- When all progression paths are complete, this function is called
function plymeta:AwardAchievement(alias)
    if self:HasAchievement(alias) then return end
    local ply = self
    
    local achi = NTH.Achievements[alias]
    if not achi then return end
    
    -- log to webserver
    NTH.DB.query('CALL achiAward(?, ?)', {ply:SteamID64(), alias}, function(err)
        if err and NTHC.DB.enabled then
            ErrorNoHalt(ply:Nick() .. " (" .. ply:SteamID64() .. ") was awarded achievement " .. tostring(alias) .. " but error.\n")
            print(err)
            return
        end
        
        -- write a message on server console
        MsgC(COLOR_YELLOW, ply:GetDisplayName())
        if ply:GetVIP() then
            MsgC(COLOR_YELLOW, " (a.k.a. " .. ply:Nick() .. ")")
        end
        MsgC(COLOR_WHITE, " has been awarded ")
        MsgC(COLOR_YELLOW, achi.Name .. "\n")
        
        ply:SetAchievement(alias)
        -- clients notified who earned what
        net.Start("nth_achi_award")
        net.WriteUInt(ply:EntIndex(), 16)
        net.WriteString(alias)
        net.WriteString(achi.Name)
        net.WriteString(achi.Quote)
        net.Send(player.GetAll())
        
        hook.Call("NTH-AchievementAwarded", nil, ply, alias)
    end)
end


local AchiMeta = {}
AchiMeta.__index = AchiMeta
NTH.AchiMeta = AchiMeta

NTH.Achievements = {}

function NTH:NewAchievement(alias)
    local Achi = {alias=alias, Name="", Quote="", ProgressPath = {}, AchiProgress = {}}
    setmetatable(Achi, AchiMeta)
    self.Achievements[alias] = Achi
    return Achi
end

function AchiMeta:checkPrereqsMet(ply, prereqs)
    if not prereqs then return true end
    if not self.AchiProgress[ply] then return false end
    
    local met = true
    for key,value in pairs(prereqs) do
        if not self.AchiProgress[ply][key] or self.AchiProgress[ply][key] < value then
            met = false
        end
    end
    
    return met
end

util.AddNetworkString("nth_achi_progress_notify")
function AchiMeta:progressSet(ply, key, value, prereqs)
    if not GetConVar("sv_cheats"):GetBool() and (ply:IsBot() or ply:SteamID() == "BOT") then return end
    if ply:HasAchievement(self.alias) or not #self.ProgressPath or not self:checkPrereqsMet(ply, prereqs) then return end
    
    value = (value or 1)
    if value > self.ProgressPath[key] then
        value = self.ProgressPath[key]
    end
    
    if not self.AchiProgress[ply] then
        self.AchiProgress[ply] = {}
    elseif self.AchiProgress[ply][key] == value then
        -- nothing to do here
        return
    end

    self.AchiProgress[ply][key] = value
    
    -- show a message indicating progress
    MsgC(COLOR_YELLOW, ply:GetDisplayName())
    if ply.GetVIP and ply:GetVIP() then
        MsgC(COLOR_YELLOW, " (a.k.a. " .. ply:Nick() .. ")")
    end
    MsgC(COLOR_WHITE, " progressed ")
    MsgC(COLOR_YELLOW, tostring(value) .. "/" .. tostring(self.ProgressPath[key]))
    MsgC(COLOR_WHITE, " of ")
    MsgC(COLOR_YELLOW, key)
    MsgC(COLOR_WHITE, " towards ")
    MsgC(COLOR_YELLOW, self.Name .. "\n")

    if value > 0 and self.ProgressNotify and self.ProgressNotify[key] then
        net.Start("nth_achi_progress_notify")
        net.WriteString(self.Name)                  -- Achievement name
        net.WriteString(self.ProgressNotify[key])   -- Progress text (e.g. "Killed %s/%s")
        net.WriteString(key)                        -- Progress path key (e.g. "KillKiba")
        net.WriteTable(self.AchiProgress[ply])      -- Full table of player's progress for all progress paths
        net.WriteTable(self.ProgressPath)           -- Full table of achievement's progress path
        net.Send(ply)
    end
    
    -- does this complete the progression path for this achievement?
    local complete = true
    for k,v in pairs(self.ProgressPath) do
        if self.AchiProgress[ply][k] != v then
            complete = false
        end
    end
    
    if complete then
        ply:AwardAchievement(self.alias)
    end
end

function AchiMeta:progressReset(ply, key)
    if not self.ProgressPath then return end
    if ply:HasAchievement(self.alias) then return end
    
    if not self.AchiProgress[ply] then
        self.AchiProgress[ply] = {}
    end

    self.AchiProgress[ply][key] = 0
end

function AchiMeta:progressResetAll()
    if not self.ProgressPath then return end
    
    for _,ply in pairs(player.GetAll()) do
        for key,_ in pairs(self.ProgressPath) do
            self:progressReset(ply, key)
        end
    end
end

function AchiMeta:progressInc(ply, key, amt, prereqs)
    if not self.ProgressPath or not self:checkPrereqsMet(ply, prereqs) then return end
    
    if not self.AchiProgress[ply] then
        self.AchiProgress[ply] = {}
    end
    local newAmt = (self.AchiProgress[ply][key] or 0) + (amt or 1)
    if newAmt > self.ProgressPath[key] then
        newAmt = self.ProgressPath[key]
    end
    self:progressSet(ply, key, newAmt)
end

function AchiMeta:persistProgressInc(ply, key, amt, prereqs)
    if not self.ProgressPath or not self:checkPrereqsMet(ply, prereqs) then return end
    
    local Achi = self
    NTH.DB.query("SELECT achiProgressInc(?,?,?,?) as num", {ply:SteamID64(), self.alias, key, amt}, function(err, res)
        if err then return end
        
        Achi:progressSet(ply, key, res.num)
    end)
end

-- Let's find out what achievements are achievable today
local function LoadAchis()
    local achiFilePath = "terrortown/gamemode/nth/achievements/"
    
    MsgC(COLOR_PINK, "Loading Achievements ...\n")

    for _,f in pairs(file.Find(achiFilePath .. "*.lua", "LUA")) do
        include(achiFilePath .. f)
        MsgC(COLOR_PINK, " * " .. f .. "\n")
    end
    
    MsgC(COLOR_PINK, "Achievements loaded\n")
end
LoadAchis()

concommand.Add("nth_achi_reload", function(ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    LoadAchis()
end)

concommand.Add("nth_achi_reset", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    ply.Achievements = {}
    for _,achi in pairs(NTH.Achievements) do
        achi.AchiProgress[ply] = {}
    end
    print("Achievements reset for " .. ply:Nick())
end)

-- fetch achievements held by ply from the NTH DB
local function LoadPlayerAchis(ply)
    print("Loading achievements for "..ply:Nick())
    if not ply:SteamID64() then return end
    NTH.DB.queryAll("SELECT ag.*, a.alias FROM achi_gets ag JOIN achievements a ON a.id = ag.achievement_id WHERE user_id = ?", {ply:SteamID64()}, function(err, achis)
        if not IsValid(ply) then
            return
        end
        
        if err then
            ErrorNoHalt("Error fetching achievements for player: " .. ply:Nick() .. " [" .. ply:SteamID64() .. "]\n")
            print(err)
            return
        end

        MsgC(COLOR_PINK, ply:Nick() .. " has ".. #achis .. " achievements")
        if #achis > 0 then
            Msg(": ")
        end
        for idx,achi in pairs(achis) do
            MsgC(COLOR_YELLOW, achi.alias)
            if idx < #achis then
                Msg(", ")
            end
            ply:SetAchievement(achi.alias)
        end
        Msg("\n")
    end)
end

hook.Add("PlayerInitialSpawn", "NTH-LoadAchisOnPlayerSpawn", LoadPlayerAchis)
for _,p in pairs(player.GetAll()) do
    LoadPlayerAchis(p)
end
