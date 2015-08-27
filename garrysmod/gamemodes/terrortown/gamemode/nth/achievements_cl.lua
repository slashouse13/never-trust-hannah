
local achiGetSound = "nth/achievements/achi-get.mp3"
util.PrecacheSound(achiGetSound)

local achiMatDir = "nth/achievements/"
NTH.AchievementTextures = {}
for _,f in pairs(file.Find("materials/" .. achiMatDir .. "*.vmt", "GAME")) do
    local alias = string.sub(f, 1, -5)
    NTH.AchievementTextures[alias] = surface.GetTextureID("nth/achievements/" .. alias)
end

local lastSoundPlayed = 0
NTH.AchiAward = function(ply, alias, name, quote)
    if not ply or not IsValid(ply) or not ply:IsPlayer() then return end

    hook.Call("NTH-AchiAward", nil, ply, alias, name, quote)
    
    if ply == LocalPlayer() then
        NTH.AchievementBanner:Create(name, quote, NTH.AchievementTextures[alias])
    end
    
    if CurTime() > lastSoundPlayed + 1 then
        surface.PlaySound(achiGetSound)
        lastSoundPlayed = CurTime()
    end
    
    local msg = {}
    table.insert(msg, Color(255,255,0))
    table.insert(msg, ply:GetDisplayName())
    if ply.GetVIP and ply:GetVIP() then
        table.insert(msg, Color(255,255,100))
        table.insert(msg, " (a.k.a. " .. ply:Nick() .. ")")
    end
    table.insert(msg, COLOR_WHITE)
    table.insert(msg, " has earned the achievement ")
    table.insert(msg, Color(255,255,0))
    table.insert(msg, name)
    chat.AddText(unpack(msg))
    
    chat.AddText(Color(255,255,100), "» " .. quote)
end

net.Receive("nth_achi_award", function()
    local ply = player.GetByID(net.ReadUInt(16))
    NTH.AchiAward(ply, net.ReadString(), net.ReadString(), net.ReadString())
end)

net.Receive("nth_achi_progress_notify", function()
    local achiName = net.ReadString()
    local progressMsg = net.ReadString()
    local key = net.ReadString()
    local progress = net.ReadTable()
    local progressPath = net.ReadTable()

    local msg = {}
    table.insert(msg, COLOR_WHITE)
    table.insert(msg, "» ")
    table.insert(msg, Color(255,255,0))
    table.insert(msg, string.format(progressMsg, progress[key], progressPath[key]))
    table.insert(msg, COLOR_WHITE)
    table.insert(msg, " for ")
    table.insert(msg, Color(255,255,0))
    table.insert(msg, achiName)

    chat.AddText(unpack(msg))
end)

concommand.Add("nth_achi_test", function(ply, cmd, args)
    NTH.AchiAward(ply, "high-rise-syndrome", "High Rise Syndrome", "Curiosity killed the cat.")
end)
