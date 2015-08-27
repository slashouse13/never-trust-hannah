
resource.AddFile("materials/nth/vips/badge.vmt")

util.AddNetworkString("nth_um_viplist")
NTH.SendVIPList = function(ply) -- pass nil as ply to broadcast to everyone
    if not ply then
        ply = player.GetAll()
    end
    
	local players = player.GetAll()
	net.Start("nth_um_viplist", ply)
	net.WriteUInt(#players, 8)
	for k, v in pairs(players) do
		net.WriteUInt(v:EntIndex(), 16)
        local vipKey = v:GetVIP()
        if not vipKey then
            vipKey = ""
        end
		net.WriteString(vipKey)
	end
	net.Send(ply)
end

hook.Add("SendFullStateUpdate", "SendVIPListOnSendFullStateUpdate", NTH.SendVIPList)

util.AddNetworkString("nth_um_reqviplist")
net.Receive("nth_um_reqviplist", function(len, ply)
    NTH.SendVIPList(ply)
end)

hook.Add("PlayerInitialSpawn", "SendVIPListOnPlayerInitialSpawn", function(ply)
    -- this seems very hacky. Why doesn't nth_um_reqviplist (above) suffice?
    timer.Simple(5, function()
        NTH.SendVIPList(ply)
    end)
end)

-- disconnected players must lose their VIP
hook.Add("PlayerDisconnected", "PlayerDisconnected-VIPLeft", function(ply)
    if IsValid(ply) and ply:IsVIP() then
        ply:SetVIP(nil)
        NTH.SendVIPList()
    end
end)

-- VIPs never persist after a round ends
hook.Add("TTTEndRound", "TTTEndRound-VIPCleanup", function()
    for _,ply in pairs(player.GetAll()) do
        ply:SetVIP(nil)
    end
    
    NTH.SendVIPList()
end)

hook.Add("PlayerSpawn", "NTH-VIP-Spawn", function(ply)
    ply:LoadoutVIPWeapons()
end)

-- Cheats (for debugging)
concommand.Add("nth_vip", function(ply,cmd,args)
    if cvars.Bool("sv_cheats") or ply:IsSuperAdmin() then
        if #args < 1 then
            ply:SetVIP(nil)
        else
            local vipKey = args[1]
            if not NTH.VIP[vipKey] then return end
            ply:SetVIP(vipKey)
            ulx.fancyLogAdmin(ply, "#A turned themselves into #s", NTH.VIP[vipKey].Name)
        end
        SendFullStateUpdate()
    end
end)

concommand.Add("nth_vip_all", function(ply)
    if cvars.Bool("sv_cheats") or ply:IsSuperAdmin() then
        local players = player.GetAll()
        
        local vipKeys = {}
        for key,_ in pairs(NTH.VIP) do
            table.insert(vipKeys, key)
        end
        
        -- choose a random VIP if we have enough players
        for _,ply in pairs(players) do
            ply:SetVIP(vipKeys[math.random(1, #vipKeys)])
        end
        
        SendFullStateUpdate()
    end
end)
