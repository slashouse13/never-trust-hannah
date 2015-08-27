
local plymeta = FindMetaTable( "Player" )
local entmeta = FindMetaTable( "Entity" )

plymeta.vip = nil

function plymeta:GetVIP()
    return self.vip
end

function plymeta:IsVIP(key)
    return (not key and self.vip) or (key and self.vip == key)
end

function plymeta:SetVIP(vip)
    local curVip = self:GetVIP()
    if curVip and NTH.VIP[curVip] then
        NTH.VIP[curVip]:Unassign(self)
    end

    if not vip or vip == "" or not NTH.VIP[vip] then
        self.vip = nil
        return
    end
    
    if vip and NTH.VIP[vip] then
        self.vip = vip
        NTH.VIP[vip]:Assign(self)
    end
end

function plymeta:LoadoutVIPWeapons()
    if not self:IsVIP() or not NTH.VIP[self.vip].Loadout then return end
    for _, cls in pairs(NTH.VIP[self.vip].Loadout) do
        if not self:HasWeapon(cls) then
            self:Give(cls)
        end
    end
end

NTH.VIP = {}

function NTH:NewVIP(key)
    local VIP = {}
    
    function VIP:Decorate(funcName, decorator)
        local prevFunc = plymeta[funcName] or entmeta[funcName]
        local vipKey = self.ID
        plymeta[funcName] = function(ply, ...)
            local args = {...}
            local result = (prevFunc or ply[funcName] or emptyFunc)(ply, unpack(args))
            
            if ply:GetVIP() == vipKey then
                result = decorator(ply, result, unpack(args))
            end
            return result
        end
    end
    
    function VIP:Override(funcName, override)
        local prevFunc = plymeta[funcName] or entmeta[funcName]
        local vipKey = self.ID
        plymeta[funcName] = function(ply, ...)
            local args = {...}
            local result = nil
            
            if ply:GetVIP() == vipKey then
                result = override(ply, prevFunc, unpack(args))
            else
                result = prevFunc(ply, unpack(args))
            end
            return result
        end
    end
    
    function VIP:Assign(ply) return end
    function VIP:Unassign(ply) return end
    
    VIP.ID = key
    self.VIP[key] = VIP
    
    VIP:Decorate("GetDisplayName", function()
        return VIP.Name
    end)
    VIP:Decorate("GetDisplayNameColour", function()
        return Color(228, 220, 0, 255)
    end)
    VIP:Decorate("GetChatDisplayNameColour", function()
        return Color(228, 220, 0, 255)
    end)
    
    return VIP
end

local function LoadVIPs()
    local vipFilePath = "terrortown/gamemode/nth/vips/"
    local files = file.Find(vipFilePath .. "*", "LUA")
    for _, name in pairs(files) do
        if SERVER then
            AddCSLuaFile(vipFilePath .. name)
        end
        include(vipFilePath .. name)
    end
    
    
    for _, VIP in pairs(NTH.VIP) do
        if SERVER then
            resource.AddFile("materials/" .. VIP.MaterialStar)
            resource.AddFile("sound/" .. VIP.SoundIntro)
        else -- CLIENT
            VIP.MaterialStarIndicator = Material(VIP.MaterialStar)
            util.PrecacheSound(VIP.SoundIntro)
        end
    end
    
end

LoadVIPs()
