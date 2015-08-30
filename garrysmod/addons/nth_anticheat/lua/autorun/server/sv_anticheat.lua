--[[
    ##############################
    #       GMod AntiCheat       #
    #      sv_anticheat.lua      #
    ##############################
--]]

AddCSLuaFile( "autorun/client/cl_anticheat.lua" )

AntiCheat = {}
AntiCheat.Suspects = {}
AntiCheat.ScreenShots = {}
AntiCheat.NextScreenShotID = 0

util.AddNetworkString("AntiCheat.RequestScreenshot")
util.AddNetworkString("AntiCheat.SSChunk")
-- util.AddNetworkString("AntiCheat.Detected")
-- util.AddNetworkString("AntiCheat.Notify")

function AntiCheat:RequestScreenshot(target, admin, reason, cb)

    -- create a screenshot request to be filled
    local ss = {
        id = AntiCheat.NextScreenShotID,
        target = target,
        admin = admin,
        timestamp = util.DateStamp(),
        chunks = {},
        reason = reason,
        callback = cb,
    }
    AntiCheat.NextScreenShotID = AntiCheat.NextScreenShotID + 1
    table.insert(self.ScreenShots, ss)

    -- notify target of the screenshot request they need to fulfil
    net.Start("AntiCheat.RequestScreenshot")
    net.WriteUInt(ss.id, 16)
    net.Send(target)
end

net.Receive("AntiCheat.SSChunk", function(len, ply)
    local chunk = net.ReadTable()

    local ss = nil
    for _,s in pairs(AntiCheat.ScreenShots) do
        if chunk.ssid == s.id then
            ss = s
            break
        end
    end

    if not ss then
        -- received a chunk of a screenshot we didn't ask for
        return
    end

    ss.chunks[chunk.idx] = net.ReadData(chunk.len)

    if table.Count(ss.chunks) == chunk.total then
        -- screenshot complete
        -- compile
        local binary = ""
        for i=1, #ss.chunks do  
            binary = binary .. ss.chunks[i]
        end

        local saveDir = "anticheat2/" .. ss.target:SteamID64()

        if not file.Exists(saveDir, "DATA") then
            file.CreateDir(saveDir)
        end

        local savePath = table.concat({
            saveDir,
            "/",
            ss.timestamp,
            "-",
            ss.id,
        })

        local f = file.Open(savePath .. ".jpg.txt", "wb", "DATA")
        f:Write(binary)
        f:Close()

        f = file.Open(savePath .. ".json.txt", "wb", "DATA")
        local meta = {
            timestamp   = ss.timestamp,
            player_name = ss.target:Nick(),
            player_id   = ss.target:SteamID(),
            player_id64 = ss.target:SteamID64(),
            reason      = ss.reason,
            id          = ss.id,
        }

        if ss.admin then
            meta.admin_name   = ss.admin:Nick()
            meta.admin_id     = ss.admin:SteamID()
            meta.admin_id64   = ss.admin:SteamID64()
        end

        f:Write(util.TableToJSON(meta))
        f:Close()

        -- remove from pending list
        table.RemoveByValue(AntiCheat.ScreenShots, ss)

        if ss.callback then
            ss.callback(meta)
        end
    end
end)

-- function AntiCheat:Notify( msg )
--  local admins = {}
--  for _, pl in pairs( player.GetAll() ) do
--      if ( pl:IsAdmin() ) then
--          table.insert( admins, pl )
--      end
--  end
--  net.Start("AntiCheat.Notify")
--  net.WriteString(msg)
--  net.Send(admins)
-- end

-- net.Receive( "AntiCheat.Detected", function( len, pl )
--  if ( timer.Exists( "AntiCheat_" .. pl:SteamID64() .. "_ScreenCapture" ) ) then return end
--  table.insert( AntiCheat.Suspects, pl )
--  if ( !file.Exists( "anticheat/" .. pl:SteamID64(), "DATA" ) ) then file.CreateDir( "anticheat/" .. pl:SteamID64() ) end
--  AntiCheat:Notify( pl:Name() .. " has been suspected of cheating, Capturing screen." )
--  timer.Create( "AntiCheat_" .. pl:SteamID64() .. "_ScreenCapture", 5, 12, function()
--      net.Start( "AntiCheat.RequestScreenshot" )
--      net.Send( pl )
--  end )
    
--  local f = file.Open( "anticheat/" .. pl:SteamID64() .. "/user.txt", "w", "DATA" )
--  f:Write( "user:" .. pl:Name().. ",id:" .. pl:SteamID() .. ",hack:" .. net.ReadString() )
--  f:Close()
-- end )


