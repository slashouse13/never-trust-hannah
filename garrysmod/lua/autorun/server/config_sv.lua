AddCSLuaFile()
NTHC = {}

NTHC.DamageLogs = {
    RDM_Manager_Enabled = true,
    Use_MySQL           = true,
    Enable_Autoslay     = true
}

NTHC.ScoreboardURL = nil

NTHC.DamageLogsDB = {
	ip          = "127.0.0.1",
	username    = "",
	password    = "",
	database    = "nth_tttdlogs",
	port        = 3306
}

NTHC.DB = {
    enabled     = true,              -- record stats to DB
    ip          = '127.0.0.1',
    username    = 'root',
    password    = 'cameron89',
    database    = 'nth'
}

NTHC.Web = {
    enabled     = false,
    endpoint    = "http://nevertrusthannah.com/x/ttt/"
}