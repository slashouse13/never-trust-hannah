
function ulx.friends( calling_ply, target_ply )

	umsg.Start( "ulx_getfriends", target_ply )
		umsg.Entity( calling_ply )
	umsg.End()
	
end
local friends = ulx.command( "Utility", "ulx friends", ulx.friends, { "!friends", "!listfriends" }, true )
friends:addParam{ type=ULib.cmds.PlayerArg }
friends:defaultAccess( ULib.ACCESS_ADMIN )
friends:help( "Print a player's connected steam friends." )

if ( CLIENT ) then

	local friendstab = {}
	
	usermessage.Hook( "ulx_getfriends", function( um )
	
		for k, v in pairs( player.GetAll() ) do
			if v:GetFriendStatus() == "friend" then
				table.insert( friendstab, v:Nick() )
			end
		end
		
		net.Start( "ulx_recfriends" )
			net.WriteEntity( um:ReadEntity() )
			net.WriteTable( friendstab )
		net.SendToServer()
		
		table.Empty( friendstab )
		
	end )
	
end

if ( SERVER ) then

	util.AddNetworkString( "ulx_recfriends" )
	
	net.Receive( "ulx_recfriends", function( len, ply )
	
		local calling, tabl = net.ReadEntity(), net.ReadTable() 
		local tab = table.concat( tabl, ", " )
		
		if ( string.len( tab ) == 0 and table.Count( tabl ) == 0 ) then			
			ulx.fancyLog( {calling}, "#T is not friends with anyone on the server", ply )
		else
			ulx.fancyLog( {calling}, "#T is friends with #s", ply, tab )
		end
		
	end )
	
end
