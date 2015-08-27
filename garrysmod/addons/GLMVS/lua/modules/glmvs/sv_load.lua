module( "GLMVS", package.seeall )

--[[---------------------------------------------------------
Name: ManageResources
Desc: Adds/Manages all of the required resources that GLMVS requires.
-----------------------------------------------------------]]
function ManageResources()
	-- Add the network strings.
	util.AddNetworkString( "GLMVS_AdminGroupMult" )
	util.AddNetworkString( "GLMVS_ReceiveVotes" )
	util.AddNetworkString( "GLMVS_ReceiveMapInfo" )
	util.AddNetworkString( "GLMVS_GroupMultInfo" )
	util.AddNetworkString( "GLMVS_UpdateVotes" )

	-- Resource workshop the GLMVS Content
	resource.AddFile("maps/noicon.png")
    resource.AddFile("materials/noicon.png")
    resource.AddFile("materials/gui/mvcirclegradient.vmt")
    resource.AddFile("materials/icon128/padlock.png")
    resource.AddFile("resource/fonts/bebasneue.ttf")

	-- Add the images
	for _, info in ipairs( MapList ) do
		if file.Exists( "materials/nth/mapicons/" ..info.Map.. ".png", "MOD" ) then
			resource.AddFile( "materials/nth/mapicons/" ..info.Map.. ".png" )
		end
	end

	-- Get the JSON files
	--MapsPlayed	= GFile.GetJSONFile( ReturnSettingVariable( "MapFileDB" ) )
	--MapCount	= GFile.GetJSONFile( "mapcounts.txt" )
	GroupMult	= GFile.GetJSONFile( "groupmult.txt" )
end

--[[---------------------------------------------------------
Name: ManageMaps
Desc: Adds/Manages the locked maps and such.
-----------------------------------------------------------]]
function ManageMaps()
	-- Count the table length of maplist.
	CountMapList = table.Count( MapList )

	-- Handle locked, removed or anything to the maps.
	for mapid, info in ipairs( MapList ) do
		if not PLSendInfo[ mapid ] then PLSendInfo[ mapid ] = {} end

		if info.MinPlayers and ( info.MinPlayers > 1 ) then
			TrueCountMapList = TrueCountMapList + 1
		end

		if IsNonExistentMap( info.Map ) then
			info.Removed = 1
			PLSendInfo[ mapid ].Removed = 1
			CountMapList = CountMapList - 1
			GDebug.NotifyByConsole( 3, info.Map, " does not exist on the server. Client can't vote for this map." )
		elseif info.Map == CurrentMap then
			info.Locked = 1
			PLSendInfo[ mapid ].Locked = 1
			CountMapsPlayed = CountMapsPlayed + 1
		end
	end

    --[[ NTH doesn't use this
	-- Reset the maplock threshold before sending it. Check if the minimum of maps are there.
	if CountMapsPlayed >= math.floor( CountMapList * math.max( 0, math.min( 1, MapLockThreshold ) ) ) then
		MapsPlayed = {}
		CountMapsPlayed = 1

		for id, sendinf in ipairs( PLSendInfo ) do
			local istrue = ( MapList[ id ].Map ~= CurrentMap ) and 0 or 1

			MapList[ id ].Locked = istrue
			sendinf.Locked = istrue
		end

		GFile.SetJSONFile( ReturnSettingVariable( "MapFileDB" ), MapsPlayed )
		GDebug.NotifyByConsole( 0, "Minimum locked maps requirement has been reached! Restarting the list." )
	end
    ]]--
    
    local unlockedMaps = {}
    for mapid, info in ipairs( MapList ) do
        if not tobool(info.Locked) and not tobool(info.Removed) then
            table.insert(unlockedMaps, mapid)
        end
    end
    
    local randomMaps = {}
    local maxMaps = GetConVar("nth_num_voteable_maps"):GetInt()
    for i=1,maxMaps do
        if #unlockedMaps == 0 then break end
        randomMaps[table.remove(unlockedMaps, math.random(1, #unlockedMaps))] = true
    end
    
    for id, sendinf in ipairs( PLSendInfo ) do
        if not randomMaps[id] then
            MapList[ id ].Locked = 1
            sendinf.Locked = 1
        else
            MapList[ id ].Locked = 0
            sendinf.Locked = 0
        end
    end

	-- Sorty sort sort! 
	table.sort( MapList, SortMaps )
end


-- Keep track of the most players in-game.
hook.Add( "PlayerInitialSpawn", "GLMVS_TrackSendInfo", function( pl )
	-- Keep track of the most players in-game.
	local curplayers = #player.GetAll()
	if ( curplayers > MaxPlayerCount ) then
		MaxPlayerCount = curplayers
	end

	-- Send the player the required info.
	for mapid, info in ipairs( MapList ) do
		if ( info.Votes > 0 ) then
			if not PLSendInfo[ mapid ] then PLSendInfo[ mapid ] = {} end
			PLSendInfo[ mapid ].Votes = info.Votes
		end
	end

	-- Send it now!
	net.Start( "GLMVS_ReceiveMapInfo" )
		net.WriteTable( PLSendInfo )
	net.Send( pl )

	-- Send in the group multipliers.
	net.Start( "GLMVS_GroupMultInfo" )
		net.WriteTable( GroupMult )
	net.Send( pl )

end )


--[[---------------------------------------------------------
Name: SyncGroupMult
Desc: Forces everyone to sync by the group multiplier.
-----------------------------------------------------------]]
net.Receive( "GLMVS_GroupMultInfo", function( len, pl )
	if not IsUserGroupAdmin( pl ) then return end

	GroupMult = net.ReadTable( GLMVS.GroupMult )
	GFile.SetJSONFile( "groupmult.txt", GroupMult )
	SyncGroupMult()
end )

function SyncGroupMult()
	net.Start( "GLMVS_GroupMultInfo" )
		net.WriteTable( GroupMult )
	net.Broadcast()
end