
net.Receive("nth_um_viplist", function()
    local numIds = net.ReadUInt(8)
    
    for i=1, numIds do
        local eidx = net.ReadUInt(16)
        local vipKey = net.ReadString()
        local ply = player.GetByID(eidx)
        if IsValid(ply) and ply.SetVIP then
            ply:SetVIP(vipKey)
        end
    end
end)

surface.CreateFont("VIPBadgeName", {
    font = "BadaBoom BB",
    size = 26,
    weight = 800
})

local vipbadge = surface.GetTextureID("nth/vips/badge")

hook.Add("HUDPaint", "HUDPaint-VIP", function()
    local ply = LocalPlayer()
    local vip = ply:GetVIP()
    
    if not vip or not NTH.VIP[vip] then
        return
    end
    
    vip = NTH.VIP[vip]
    
    local badgeX = 156
    local badgeY = ScrH() - 256

    surface.SetDrawColor(COLOR_WHITE)
    
    surface.SetTexture(vipbadge)
    surface.DrawTexturedRect(badgeX, badgeY, 256, 256)
    surface.SetMaterial(vip.MaterialStarIndicator)
    surface.DrawTexturedRect(badgeX + 128, badgeY + 102, 110, 110)
    draw.SimpleText(string.upper(vip.Name), "VIPBadgeName", badgeX + 184, badgeY + 210, Color(50,50,50), TEXT_ALIGN_CENTER)
end)

hook.Add("PostDrawTranslucentRenderables", "PostDrawTranslucentRenderables-VIP", function()
    local client = LocalPlayer()
    local dir = client:GetForward() * -1
    local plys = player.GetAll()
   
	-- Draw VIP icons above players heads
	for i=1, #plys do
		local ply = plys[i]
        local vip = ply:GetVIP()
        if not vip then continue end
        
        if ply:Team() != TEAM_SPEC and ply != client then
            render.SetMaterial(NTH.VIP[vip].MaterialStarIndicator)
            local pos = ply:GetPos()
            pos.z = pos.z + 86
            render.DrawQuadEasy(pos, dir, 16, 16, COLOR_WHITE, 180)
        end
	end
end)

local function RequestVIPList()
    net.Start("nth_um_reqviplist")
    net.SendToServer()
end

RequestVIPList()
concommand.Add("nth_um_reqviplist", RequestVIPList)
