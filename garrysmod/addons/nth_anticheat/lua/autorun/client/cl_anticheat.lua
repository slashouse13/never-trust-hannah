--[[
    ##############################
    #       GMod AntiCheat       #
    #      cl_anticheat.lua      #
    ##############################
--]]

-- local AntiCheat = {}
-- AntiCheat.Hacks = { "[AHack]", "[AnXition]", "[B-Hacks]", "[Blue Bot]", "[damnBot]", "[FMurder]", "[mApex]", "[Murder Buddy]", "Aimbot", "TrafficHelper", "Wallhack" }
-- AntiCheat.CVars = { 'woodhack_aimbot', 'woodhack_wallhack', 'mapex_box', 'mapex_antiafk', 'mapex_traitor', 'AHack_Aimbot_Active', 'AHack_ESP_Active' }
-- AntiCheat.AddText = chat.AddText;

-- function chat.AddText( ... )
--  AntiCheat.AddText( ... )
--  local args = { ... }
--  for _, arg in ipairs( args ) do
--      if ( type(arg) == "string" ) then
--          for _, name in ipairs( AntiCheat.Hacks ) do
--              if ( string.StartWith( arg, name ) )then
--                  AntiCheat:Detected( name )
--                  return
--              end
--          end
--      end
--  end
-- end

-- function AntiCheat:Detected( hack )
--  if ( AntiCheat.Suspect ) then return end
--  net.Start( "AntiCheat.Detected" )
--      net.WriteString( hack )
--  net.SendToServer()
--  AntiCheat.Suspect = true
-- end

-- function AntiCheat.CVarCheck()
--  for _, CVar in ipairs( AntiCheat.CVars ) do
--      if ( GetConVar( CVar ) != nil ) then
--           AntiCheat:Detected( CVar )
--      end
--  end
-- end
-- timer.Create( "AntiCheat.CVarCheck", 5, 0, AntiCheat.CVarCheck )

net.Receive("AntiCheat.RequestScreenshot", function(len)
    local ssid = net.ReadUInt(16)

    local data = render.Capture({
        format = "jpeg",
        h = ScrH(),
        w = ScrW(),
        quality = 65,
        x = 0,
        y = 0
    })

    local chunks = math.ceil( data:len() / 18000 )
    
    for i=1, chunks do
        local startpos = ( ( i - 1 ) * 18000 ) + 1
        local endpos = ( startpos + 18000 ) - 1
        local chunkStr = data:sub(startpos, endpos)

        net.Start("AntiCheat.SSChunk")
        net.WriteTable({
            ssid    = ssid,             -- requested screenshot id
            idx     = i,                -- chunk index
            total   = chunks,           -- total number of chunks
            len     = chunkStr:len(),   -- length (in bytes) of this chunk data
        })
        net.WriteData(chunkStr, chunkStr:len())
        net.SendToServer()
    end
end)

-- function AntiCheat.Notify()
--  chat.AddText( Color( 152, 152, 80 ), "[AntiCheat] ", Color( 250, 250, 250 ), net.ReadString() )
-- end
-- net.Receive( "AntiCheat.Notify", AntiCheat.Notify )
