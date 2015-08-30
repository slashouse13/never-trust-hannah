
if SERVER then
	util.AddNetworkString("ulx.screenshot-ready")
end

function ulx.screenshot(calling_ply, target_ply, reason)

	if CLIENT then return end

    ulx.fancyLogAdmin(calling_ply, true, "#A requested screenshot from #T", target_ply)

    AntiCheat:RequestScreenshot(target_ply, calling_ply, reason, function(meta)
    	ulx.fancyLogAdmin(calling_ply, true, "Screenshot of #T is ready", target_ply)

    	net.Start("ulx.screenshot-ready")
    	net.WriteTable(meta)
    	net.Send(calling_ply)
	end)

end

local screenshot = ulx.command( "Utility", "ulx screenshot", ulx.screenshot, { "!screenshot", "!screen" }, true )
screenshot:addParam{ type=ULib.cmds.PlayerArg }
screenshot:addParam{ type=ULib.cmds.StringArg, hint="reason", ULib.cmds.optional }
screenshot:defaultAccess( ULib.ACCESS_ADMIN )
screenshot:help( "Request a screenshot from the player." )

if CLIENT then
	net.Receive("ulx.screenshot-ready", function(len)
		local ss = net.ReadTable()
		local url = table.concat({
			"http://nevertrusthannah.com/ingame/nth/#/anticheat/screens/",
			ss.player_id64,
			"/",
			ss.timestamp,
			"-",
			ss.id,
			"/"
		})

		print("opening", url)
		gui.OpenURL(url)
	end)
end
