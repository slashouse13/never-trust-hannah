
if SERVER then
    util.AddNetworkString("nth_reload_scoreboard")
    concommand.Add("nth_reload_scoreboard", function(ply,cmd,args)
        if not (cvars.Bool("sv_cheats") or not ply.IsSuperAdmin or ply:IsSuperAdmin()) then return end
        print("Reloading scoreboard for all players.")
        net.Start("nth_reload_scoreboard")
        net.Broadcast()
    end)
    -- see ../cl_scoreboard.lua for where this is received
end
