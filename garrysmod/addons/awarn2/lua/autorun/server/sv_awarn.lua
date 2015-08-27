AWarn = {}

AWarn.DefaultValues = { awarn_kick = 1, awarn_kick_threshold = 3, awarn_ban = 1, awarn_ban_threshold = 5, awarn_ban_time = 30, awarn_decay = 1, awarn_decay_rate = 30, awarn_reasonrequired = 1 }

function awarn_loadscript()
	awarn_tbl_exist()
	
	util.AddNetworkString("SendPlayerWarns")
	util.AddNetworkString("SendOwnWarns")
	util.AddNetworkString("AWarnMenu")
	util.AddNetworkString("AWarnClientMenu")
	util.AddNetworkString("AWarnOptionsMenu")
	util.AddNetworkString("AWarnNotification")
	util.AddNetworkString("AWarnNotification2")
	util.AddNetworkString("AWarnChatMessage")

end
hook.Add( "Initialize", "Awarn_Initialize", awarn_loadscript )


function awarn_checkkickban( ply )
	local kt = tonumber(GetGlobalInt( "awarn_kick_threshold", 3 ))
	local bt = tonumber(GetGlobalInt( "awarn_ban_threshold", 5 ))
	local btime = tonumber(GetGlobalInt( "awarn_ban_time", 30 ))
	
	local kickon = tobool(GetGlobalInt( "awarn_kick", 1 ))
	local banon = tobool(GetGlobalInt( "awarn_ban", 1 ))
	
	
	
	if banon then
		if tonumber(awarn_getwarnings( ply )) >= tonumber(bt) then
			ServerLog("AWarn: BANNING " .. ply:Nick() .. " FOR " .. btime .. " minutes!\n")
			for k, v in pairs(player.GetAll()) do AWSendMessage( v, "AWarn: " .. ply:Nick() .. " was banned for reaching the warning threshold" ) end
			timer.Simple(1, function() awarn_ban( ply, btime ) end )
			return
		end
	end
	
	if kickon then
		if awarn_getwarnings( ply ) >= tonumber(kt) then
			ServerLog("AWarn: KICKING " .. ply:Nick().. "\n")
			for k, v in pairs(player.GetAll()) do AWSendMessage( v, "AWarn: " .. ply:Nick() .. " was kicked for reaching the warning threshold" ) end
			timer.Simple(1, function() awarn_kick( ply ) end )
			return
		end
	end
	--print("DEBUG: " .. awarn_getwarnings( ply ))
end

function awarn_kick( ply )
	if ulx then
		ULib.kick( ply, "AWarn: Warning Threshold Met" )
	else
		ply:Kick( "AWarn: Warning Threshold Met" )
	end
end

function awarn_ban( ply, time )
	if ulx then
		ULib.kickban( ply, time, "AWarn: Ban Threshold Met" )
	else
		ply:Ban( time, "AWarn: Ban Threshold Met" )
	end
end


function awarn_decaywarns( ply )
	if tobool(GetGlobalInt( "awarn_decay", 1 )) then
		local dr = GetGlobalInt( "awarn_decay_rate", 30 )
		
		if awarn_getlastwarn( ply ) == "NONE" then
			--print("DEBUG: HAS NO WARNINGS")
		else
			--print("DEBUG: Has warnings on connect..")
			if tonumber(os.time()) >= tonumber(awarn_getlastwarn( ply )) + (dr*60) then
				--print("DEBUG: connection warning should be decayed")
				awarn_decwarnings(ply)
			end
			
			--print("DEBUG: " .. awarn_getwarnings( ply ) .. " warnings remaining.")
			if awarn_getwarnings( ply ) > 0 then
				--print("DEBUG: Creating timer.")
				timer.Create( ply:SteamID64() .. "_awarn_decay", dr*60, 1, function() if IsValid(ply) then awarn_decaywarns(ply) end end )
			end
		end
	end

end
hook.Add( "PlayerInitialSpawn", "awarn_decaywarns", awarn_decaywarns )

function awarn_welcomebackannounce( ply )
	if awarn_getwarnings( ply ) > 0 then
		local t1 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "Welcome back to the server, " .. ply:Nick() .. "." }
		net.Start("AWarnChatMessage") net.WriteTable(t1) net.Send( ply )
		local t2 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "Current Active Warnings: ", Color(255,0,0), tostring(awarn_getwarnings( ply )) }
		net.Start("AWarnChatMessage") net.WriteTable(t2) net.Send( ply )
		if tobool( GetGlobalInt("awarn_kick", 1) ) then
			local t3 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You will be kicked after: ", Color(255,0,0), GetGlobalInt("awarn_kick_threshold", 3), Color(255,255,255), " total active warnings." }
			net.Start("AWarnChatMessage") net.WriteTable(t3) net.Send( ply )
		end
		if tobool( GetGlobalInt("awarn_ban", 1) ) then
			local t4 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You will be banned after: ", Color(255,0,0), GetGlobalInt("awarn_ban_threshold", 7), Color(255,255,255), " total active warnings." }
			net.Start("AWarnChatMessage") net.WriteTable(t4) net.Send( ply )
		end
		local t5 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "Type !warn to see a list of your warnings." }
		net.Start("AWarnChatMessage") net.WriteTable(t5) net.Send( ply )
	end
end
hook.Add( "PlayerInitialSpawn", "awarn_welcomebackannounce", awarn_welcomebackannounce )

function awarn_notifyadmins( ply )
	if awarn_gettotalwarnings( ply ) > 0 then
		local total_warnings = awarn_gettotalwarnings( ply )
		local total_active_warnings = awarn_getwarnings( ply )
		timer.Simple(1, function()
			local t1 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), ply, " joins the server with (", Color(255,0,0), tostring(total_warnings), Color(255,255,255), ") total warnings and (", Color(255,0,0), tostring(total_active_warnings), Color(255,255,255), ") active warnings." }
			for k, v in pairs(player.GetAll()) do
				if awarn_checkadmin_view( v ) then
					net.Start("AWarnChatMessage") net.WriteTable(t1) net.Send( v )
				end
			end
		end )
	end
end
hook.Add( "PlayerInitialSpawn", "awarn_notifyadmins", awarn_notifyadmins )


function awarn_playerdisconnected( ply )
	timer.Remove( ply:SteamID64() .. "_awarn_decay" )
end
hook.Add( "PlayerDisconnected", "awarn_playerdisconnected", awarn_playerdisconnected )

function awarn_con_fetchwarns( ply, _, args )

    if not IsValid( ply ) then
        AWSendMessage( ply, "AWarn: This command can not be run from the server's console!")
        return
    end
    
	if not awarn_checkadmin_view( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	local target_ply = awarn_getUser( args[1] )
	
	if target_ply then
		awarn_sendwarnings( ply, target_ply )
	else
		AWSendMessage( ply, "AWarn: Player not found!")
	end
end
concommand.Add( "awarn_fetchwarnings", awarn_con_fetchwarns )

function awarn_con_fetchownwarns( ply, _, args )

    if not IsValid( ply ) then
        AWSendMessage( ply, "AWarn: This command can not be run from the server's console!")
        return
    end
    
	awarn_sendownwarnings( ply )
end
concommand.Add( "awarn_fetchownwarnings", awarn_con_fetchownwarns )

function awarn_con_changeconvarbool( ply, _, args )
	local allowed = { "awarn_kick", "awarn_ban", "awarn_decay", "awarn_reasonrequired" }

	if not awarn_checkadmin_options( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	if not table.HasValue( allowed, args[1] ) then
		AWSendMessage( ply, "AWarn: You can not set this CVar with this command.")
		return
	end
	
	if #args ~= 2 then
		return
	end
	
	if args[2] == "true" then
		awarn_saveservervalue( args[1], 0 )
		return
	end
	awarn_saveservervalue( args[1], 1 )
end
concommand.Add( "awarn_changeconvarbool", awarn_con_changeconvarbool )

function awarn_con_changeconvar( ply, _, args )
	local allowed = { "awarn_kick_threshold", "awarn_ban_threshold", "awarn_ban_time", "awarn_decay_rate" }

	if not awarn_checkadmin_options( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	if not table.HasValue( allowed, args[1] ) then
		AWSendMessage( ply, "AWarn: You can not set this CVar with this command.")
		return
	end
	
	if #args ~= 2 then
		return
	end
	
	if not tonumber(args[2]) then
		AWSendMessage( ply, "AWarn: You must pass this ConVar a number value.")
		return
	end
	
	if tonumber(args[2]) < 0 then
		AWSendMessage( ply, "AWarn: You must pass this ConVar a positive value.")
		return
	end

	awarn_saveservervalue( args[1], args[2] )
end
concommand.Add( "awarn_changeconvar", awarn_con_changeconvar )

function AWSendMessage( ply, message )
    if IsValid(ply) then
        ply:PrintMessage( HUD_PRINTTALK, message )
    else
        print( message )
    end
end

function AWarn_ChatWarn( ply, text, public )
    if (string.sub(string.lower(text), 1, 5) == "!warn") then
		local args = string.Explode( " ", text )
		if #args == 1 then
			ply:ConCommand( "awarn_menu" )
		else
			ply:ConCommand( "awarn_warn " .. table.concat( args, " ", 2 ) )
		end
		return false
    end
end
hook.Add( "PlayerSay", "AWarn_ChatWarn", AWarn_ChatWarn )

function awarn_con_warn( ply, _, args )

	if not awarn_checkadmin_warn( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
    
	if tonumber( args[1] ) then
		target_ply = Entity( tonumber(args[1]) )
	else
		if awarn_getUser( args[1] ) then
			args[1] = awarn_getUser( args[1] ):EntIndex()
            target_ply = Entity( tonumber(args[1]) )
		else
			AWSendMessage( ply, "AWarn: Player not found!")
			return
		end
	end
	
	if not IsValid(target_ply) then return end
	if not target_ply:IsPlayer() then return end
	local reason = table.concat( args, " ", 2 )
	
	
	if tobool(GetGlobalInt( "awarn_reasonrequired", 1 )) then
		if reason == "" then
			AWSendMessage( ply, "AWarn: You MUST include a reason. Disable this in the options.")
			return
		end
		
		if not reason then
			AWSendMessage( ply, "AWarn: You MUST include a reason. Disable this in the options.")
			return
		end
	end
	
	if not reason then reason = "NONE GIVEN" end
	if reason == "" then reason = "NONE GIVEN" end
	
	if target_ply then
		for k, v in pairs(player.GetAll()) do
			if v ~= target_ply then
				net.Start("AWarnNotification")
					net.WriteEntity( ply )
					net.WriteEntity( target_ply )
					net.WriteString( reason )
				net.Send( v )
			end
		end
        
		
		if IsValid(ply) then
            awarn_addwarning( target_ply:SteamID64(), reason, ply:Nick() )
            ServerLog( "[AWarn] " .. ply:Nick() .. " warned " .. target_ply:Nick() .. " for reason: " .. reason.. "\n" )
        else
            awarn_addwarning( target_ply:SteamID64(), reason, "[CONSOLE]" )
            ServerLog( "[AWarn] [CONSOLE] warned " .. target_ply:Nick() .. " for reason: " .. reason.. "\n" )
        end
		awarn_incwarnings( target_ply )
		
		local t1 = {}
        if IsValid( ply ) then
            t1 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You have been warned by ", ply, " for ", Color(150,40,40), reason, Color(255,255,255), "." }
        else
            t1 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You have been warned by ", Color(100,100,100), "[CONSOLE]", Color(255,255,255), " for ", Color(150,40,40), reason, Color(255,255,255), "." }
        end
		net.Start("AWarnChatMessage") net.WriteTable(t1) net.Send( target_ply )
		
		local t2 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "Current Active Warnings: ", Color(255,0,0), tostring(awarn_getwarnings( target_ply )) }
		net.Start("AWarnChatMessage") net.WriteTable(t2) net.Send( target_ply )
		
		if tobool( GetGlobalInt("awarn_kick", 1) ) then
			local t3 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You will be kicked after: ", Color(255,0,0), GetGlobalInt("awarn_kick_threshold", 3), Color(255,255,255), " total active warnings." }
			net.Start("AWarnChatMessage") net.WriteTable(t3) net.Send( target_ply )
		end
		
		if tobool( GetGlobalInt("awarn_ban", 1) ) then
			local t4 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "You will be banned after: ", Color(255,0,0), GetGlobalInt("awarn_ban_threshold", 7), Color(255,255,255), " total active warnings." }
			net.Start("AWarnChatMessage") net.WriteTable(t4) net.Send( target_ply )
		end
		
		local t5 = { Color(60,60,60), "[", Color(30,90,150), "AWarn", Color(60,60,60), "] ", Color(255,255,255), "Type !warn to see a list of your warnings." }
		net.Start("AWarnChatMessage") net.WriteTable(t5) net.Send( target_ply )
		
		if IsValid( ply ) then
            awarn_sendwarnings( ply, target_ply )
        end
			
	else
		AWSendMessage( ply, "AWarn: Player not found!")
	end

end
concommand.Add( "awarn_warn_sv", awarn_con_warn )

function awarn_con_warnid( ply, _, args )

	if not awarn_checkadmin_warn( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
    
	local reason = table.concat( args, " ", 2 )
	
	if tobool(GetGlobalInt( "awarn_reasonrequired", 1 )) then
		if reason == "" then
			AWSendMessage( ply, "AWarn: You MUST include a reason. Disable this in the options.")
			return
		end
		if not reason then
			AWSendMessage( ply, "AWarn: You MUST include a reason. Disable this in the options.")
			return
		end
	end
	
	if not reason then reason = "NONE GIVEN" end
	if reason == "" then reason = "NONE GIVEN" end
	
	net.Start("AWarnNotification2")
		net.WriteEntity( ply )
		net.WriteString( tostring(args[1]) )
		net.WriteString( reason )
	net.Broadcast()
        
		
	if IsValid(ply) then
		awarn_addwarning( args[1], reason, ply:Nick() )
		ServerLog( "[AWarn] " .. ply:Nick() .. " warned " .. tostring(args[1]) .. " for reason: " .. reason.. "\n" )
	else
		awarn_addwarning( args[1], reason, "[CONSOLE]" )
		ServerLog( "[AWarn] [CONSOLE] warned " .. tostring(args[1]) .. " for reason: " .. reason.. "\n" )
	end
	awarn_incwarningsid( args[1] )

end
concommand.Add( "awarn_warnid_sv", awarn_con_warnid )

function awarn_con_warn2( ply, _, args )
    if IsValid( ply ) then return end
    if (string.sub(string.lower(args[1]), 1, 5) == "steam") then
		if string.len(args[1]) == 7 then
			AWSendMessage( ply, "AWarn: Make sure you wrap the steamID in quotes!"  )
			return
		end
        args[1] = AWarn_ConvertSteamID( args[1] )
        awarn_con_warnid( nil, nil, args )
        return
    end
    awarn_con_warn( nil, nil, args )
end
concommand.Add( "awarn_warn", awarn_con_warn2 )

function awarn_con_remwarn( ply, _, args )

	if not awarn_checkadmin_remove( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	local target_ply = awarn_getUser( args[1] )
	
	if target_ply then
		awarn_decwarnings( target_ply, ply )
        if IsValid( ply ) then
            awarn_sendwarnings( ply, target_ply )
        end
	else
		AWSendMessage( ply, "AWarn: Player not found!")
	end

end
concommand.Add( "awarn_removewarn_sv", awarn_con_remwarn )

function awarn_con_remwarnid( ply, _, args )

	if not awarn_checkadmin_remove( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	local uid = args[1]
	awarn_decwarningsid( uid, ply )

end
concommand.Add( "awarn_removewarnid_sv", awarn_con_remwarnid )

function awarn_con_remwarn2( ply, _, args )
    if IsValid( ply ) then return end
    if (string.sub(string.lower(args[1]), 1, 5) == "steam") then
		if string.len(args[1]) == 7 then
			AWSendMessage( ply, "AWarn: Make sure you wrap the steamID in quotes!"  )
			return
		end
        args[1] = AWarn_ConvertSteamID( args[1] )
        awarn_con_remwarnid( nil, nil, args )
        return
    end
    awarn_con_remwarn( nil, nil, args )
end
concommand.Add( "awarn_removewarn", awarn_con_remwarn2 )

function awarn_con_delwarn( ply, _, args )

	if not awarn_checkadmin_delete( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	local target_ply = awarn_getUser( args[1] )
	
	if target_ply then
		awarn_delwarnings( target_ply, ply )
	else
		AWSendMessage( ply, "AWarn: Player not found!")
	end

end
concommand.Add( "awarn_deletewarnings_sv", awarn_con_delwarn )

function awarn_con_delwarnid( ply, _, args )

	if not awarn_checkadmin_delete( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	local uid = args[1]
	
	awarn_delwarningsid( uid, ply )

end
concommand.Add( "awarn_deletewarningsid_sv", awarn_con_delwarnid )

function awarn_con_delwarn2( ply, _, args )
    if IsValid( ply ) then return end
    if (string.sub(string.lower(args[1]), 1, 5) == "steam") then
		if string.len(args[1]) == 7 then
			AWSendMessage( ply, "AWarn: Make sure you wrap the steamID in quotes!"  )
			return
		end
        args[1] = AWarn_ConvertSteamID( args[1] )
        awarn_con_delwarnid( nil, nil, args )
        return
    end
    awarn_con_delwarn( nil, nil, args )
end
concommand.Add( "awarn_deletewarnings", awarn_con_delwarn2 )

function awarn_con_openmenu( ply, _, args )

    if not IsValid( ply ) then
        AWSendMessage( ply, "AWarn: This command can not be run from the server's console!")
        return
    end

	if not awarn_checkadmin_view( ply ) then
		net.Start("AWarnClientMenu")
		net.Send( ply )
		return
	end
	
	
	net.Start("AWarnMenu")
	net.Send( ply )

end
concommand.Add( "awarn_menu_sv", awarn_con_openmenu )


function awarn_con_openoptionsmenu( ply, _, args )

    if not IsValid( ply ) then
        AWSendMessage( ply, "AWarn: This command can not be run from the server's console!")
        return
    end

	if not awarn_checkadmin_options( ply ) then
		AWSendMessage( ply, "AWarn: You do not have access to this command.")
		return
	end
	
	
	net.Start("AWarnOptionsMenu")
	net.Send( ply )

end
concommand.Add( "awarn_options_sv", awarn_con_openoptionsmenu )

local files, dirs = file.Find("awarn/modules/*.lua", "LUA")
for k, v in pairs( files ) do
	ServerLog("AWarn: Loading module (" .. v .. ")\n")
	include( "awarn/modules/" .. v )
end
