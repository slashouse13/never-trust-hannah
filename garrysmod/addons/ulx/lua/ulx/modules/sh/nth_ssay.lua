------------------------------ Ssay ------------------------------
function ulx.ssay( calling_ply, message )
	NTH.Headline:Show( message, 3 )

	if util.tobool( GetConVarNumber( "ulx_logChat" ) ) then
		ulx.logString( string.format( "(ssay from %s) %s", calling_ply:IsValid() and calling_ply:Nick() or "Console", message ) )
	end
end
local ssay = ulx.command( CATEGORY_NAME, "ulx ssay", ulx.ssay, "@!", true, true )
ssay:addParam{ type=ULib.cmds.StringArg, hint="message", ULib.cmds.takeRestOfLine }
ssay:defaultAccess( ULib.ACCESS_ADMIN )
ssay:help( "Send a BIG message to everyone in the middle of their screen." )
