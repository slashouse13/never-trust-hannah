--[[
	##############################
	#       GMod AntiCheat       #
	#      sv_anticheat.lua      #
	##############################
--]]

AddCSLuaFile( "autorun/client/cl_anticheat.lua" )

local AntiCheat = {}
AntiCheat.Admins = {}
AntiCheat.Suspects = {}
AntiCheat.ScreenShots = {}

util.AddNetworkString( "AntiCheat.RequestScreenshot" )
util.AddNetworkString( "AntiCheat.SendChunk" )
util.AddNetworkString( "AntiCheat.Detected" )
util.AddNetworkString( "AntiCheat.Notify" )

function AntiCheat:Notify( msg )
	for _, pl in pairs( player.GetAll() ) do
		if ( pl:IsAdmin() ) then
			table.insert( AntiCheat.Admins, pl )
		end
	end
	net.Start( "AntiCheat.Notify" )
		net.WriteString( msg )
	net.Send( AntiCheat.Admins )
	table.Empty( AntiCheat.Admins )
end

function AntiCheat:CompileScreenshotChunks( chunks )
	table.sort( chunks, function(a, b) return a[2] < b[2] end )
	local str = ""
	for i=1, #chunks do	
		str = str .. chunks[i][5]
	end
	return assert( str )
end

net.Receive( "AntiCheat.Detected", function( len, pl )
	if ( timer.Exists( "AntiCheat_" .. pl:SteamID64() .. "_ScreenCapture" ) ) then return end
	table.insert( AntiCheat.Suspects, pl )
	if ( !file.Exists( "anticheat/" .. pl:SteamID64(), "DATA" ) ) then file.CreateDir( "anticheat/" .. pl:SteamID64() ) end
	AntiCheat:Notify( pl:Name() .. " has been suspected of cheating, Capturing screen." )
	timer.Create( "AntiCheat_" .. pl:SteamID64() .. "_ScreenCapture", 5, 12, function()
		net.Start( "AntiCheat.RequestScreenshot" )
		net.Send( pl )
	end )
	
	local f = file.Open( "anticheat/" .. pl:SteamID64() .. "/user.txt", "w", "DATA" )
	f:Write( "user:" .. pl:Name().. ",id:" .. pl:SteamID() .. ",hack:" .. net.ReadString() )
	f:Close()
end )

net.Receive( "AntiCheat.SendChunk", function( len, pl )
	local chunk = net.ReadTable();
	chunk[5] = net.ReadData(chunk[4])
	local ssID = chunk[1]
	
	if ( !AntiCheat.ScreenShots[pl:SteamID64()] ) then
		AntiCheat.ScreenShots[pl:SteamID64()] = {};
	end
	
	local playersScreenShots = AntiCheat.ScreenShots[pl:SteamID64()]
	
	if not playersScreenShots[ssID] then
		playersScreenShots[ssID] = {}
	end
	
	local screenshotChunks = playersScreenShots[ssID]
	
	table.insert( screenshotChunks, chunk );
	if ( #screenshotChunks == chunk[3] ) then
	    
	    local screenshotBinary = AntiCheat:CompileScreenshotChunks(screenshotChunks)
	    
		local id = timer.RepsLeft( "AntiCheat_" .. pl:SteamID64() .. "_ScreenCapture" ) or 0;
		local f = file.Open( "anticheat/" .. pl:SteamID64() .. "/" .. id .. ".txt", "wb", "DATA" );
		f:Write( screenshotBinary );
		f:Close();
	end
end )
