
NTH.AddSounds({
	MusicIWin = "nth/rounds/magicdance.mp3",
	MusicTWin = "nth/rounds/wedidntstartthefire.mp3"
})

local RoundMeta = {
	Name = "different",
	RDM = false,
}
RoundMeta.__index = RoundMeta
NTH.RoundMeta = RoundMeta

NTH.Rounds = {}

function NTH:NewRound(alias)
	local Round = {alias=alias}
	setmetatable(Round, RoundMeta)
	self.Rounds[alias] = Round
	return Round
end

-- Let's find out what rounds are available
local function LoadRounds()
	local roundFilePath = "terrortown/gamemode/nth/rounds/"
	
	if SERVER then
		MsgC(COLOR_PINK, "Loading Rounds ...\n")
	end

	for _,f in pairs(file.Find(roundFilePath .. "*.lua", "LUA")) do
		if SERVER then
			AddCSLuaFile(roundFilePath .. f)
			MsgC(COLOR_PINK, " * " .. f .. "\n")
		end
		include(roundFilePath .. f)
	end
	
	if SERVER then
		MsgC(COLOR_PINK, "Rounds loaded\n")
	end
end
LoadRounds()

function RoundMeta:OnPrepare()
end

function RoundMeta:OnBegin()
	if SERVER then
		SelectRoles()

		local players = self:GetPlayingPlayers()
		
		local vipKeys = {}
		for key,_ in pairs(NTH.VIP) do
			table.insert(vipKeys, key)
		end
		local key = vipKeys[math.random(1, #vipKeys)]
		
		-- choose a random VIP if we have enough players
		if #players >= cvars.Number('nth_vip_min_players') then
			local ply = players[math.random(1, #players)]
			ply:SetVIP(key)
			NTH.Sound:Play(NTH.VIP[key].SoundIntro)
			NTH.SendVIPList()
		end
	end
end

function RoundMeta:OnBegun()
end

function RoundMeta:OnEnd(args)
	if CLIENT and GetConVar("ttt_cl_nth_soundcues"):GetBool() then
		if args.winType == WIN_TRAITOR then
			print(args.winType)
			NTH.Sound:Play(NTH.Sounds.MusicTWin)
		else
			print(args.winType)
			NTH.Sound:Play(NTH.Sounds.MusicIWin)
		end
	end
end

if SERVER then

	NTH.RoundNext = nil
	
	function GetRandomRDMRound()
		local rdmRounds = {}
		for _,r in pairs(NTH.Rounds) do
			if r.RDM then
				table.insert(rdmRounds, r)
			end
		end
		return table.Random(rdmRounds)
	end
	
	function RoundMeta:WinCheck()
	   if GAMEMODE.MapWin == WIN_TRAITOR or GAMEMODE.MapWin == WIN_INNOCENT then
		  local mw = GAMEMODE.MapWin
		  GAMEMODE.MapWin = WIN_NONE
		  return mw
	   end

	   local traitor_alive = false
	   local innocent_alive = false
	   for k,v in pairs(player.GetAll()) do
		  if v:Alive() and v:IsTerror() then
			 if v:GetTraitor() then
				traitor_alive = true
			 else
				innocent_alive = true
			 end
		  end

		  if traitor_alive and innocent_alive then
			 return WIN_NONE --early out
		  end
	   end

	   if traitor_alive and not innocent_alive then
		  return WIN_TRAITOR
	   elseif not traitor_alive and innocent_alive then
		  return WIN_INNOCENT
	   elseif not innocent_alive then
		  -- ultimately if no one is alive, traitors win
		  return WIN_TRAITOR
	   end

	   return WIN_NONE
	end

	function RoundMeta:GetPlayingPlayers()
		local all = player.GetAll()
		local selected = {}
		for _, ply in pairs(all) do
			if IsValid(ply) and not ply:IsSpec() then
				table.insert(selected, ply)
			end
		end
		return selected
	end
	
	util.AddNetworkString("nth_round_activate")
	function RoundMeta:Activate()
		NTH.Round = self
		Msg("Round: ")
		MsgC(COLOR_PINK, self.alias)
		MsgN(" activated")
		net.Start("nth_round_activate")
		net.WriteString(self.alias)
		net.Send(player.GetAll())
	end
	
	util.AddNetworkString("nth_round_trigger")
	function NTH.RoundTrigger(event, args)
		if NTH.Round == nil then return end
		MsgC(COLOR_YELLOW, "Triggering ")
		MsgC(COLOR_PINK, NTH.Round.alias..":"..event.."()\n")
		net.Start("nth_round_trigger")
		net.WriteString(NTH.Round.alias)
		net.WriteString(event)
		net.WriteTable(args or {})
		net.Send(player.GetAll())
		hook.Call("NTH-RoundTrigger", GM, NTH.Round, event, args)
		if NTH and NTH.Round then
			return NTH.Round[event](NTH.Round, args)
		end
	end
	
	-- first things first...
	if not NTH.Round then
		NTH.Rounds.default:Activate()
	end
	
	-- here's the logic for what round comes next!
	function NTH.RoundSelect()
		MsgC(COLOR_YELLOW, "Selecting new round type ...\n")
		
		if NTH.RoundNext then
			NTH.Rounds[NTH.RoundNext]:Activate()
			NTH.RoundNext = nil
			return
		end
		
		local roundsLeft = GetGlobalInt("ttt_rounds_left")
		MsgC(COLOR_RED, "There are "..roundsLeft.." rounds left\n")
		if roundsLeft == 1 then
			--NTH.Rounds.dewdoritos:Activate()
			GetRandomRDMRound():Activate()
			--NTH.Rounds.meowoclock:Activate()

			return
		end
		
		NTH.Rounds.default:Activate()
	end
	
	concommand.Add("nth_round", function(ply, cmd, args)
		if not (cvars.Bool("sv_cheats") or not ply.IsSuperAdmin or ply:IsSuperAdmin()) then return end
		local alias = args[1]
		local round = NTH.Rounds[alias]
		if not round then return end
		NTH.RoundNext = alias
		ulx.fancyLogAdmin(ply, "#A has decreed that the next round will be #s", round.Name)
	end)

end

if CLIENT then
	net.Receive("nth_round_trigger", function()
		local round = net.ReadString()
		local event = net.ReadString()
		local args = net.ReadTable()
		if not NTH.Rounds[round] or not NTH.Rounds[round][event] then return end
		local r = NTH.Rounds[round]
		--MsgC(COLOR_YELLOW, "Triggered ")
		--MsgC(COLOR_PINK, round..":"..event.."()\n")
		hook.Call("NTH-RoundTrigger", GM, r, event, args)
		r[event](r, args)
	end)
	
	net.Receive("nth_round_activate", function()
		local alias = net.ReadString()
		if not NTH.Rounds[alias] then return end
		NTH.Round = NTH.Rounds[alias]
		--MsgC(COLOR_YELLOW, "Round activated: ")
		--MsgC(COLOR_PINK, alias .. "\n")
	end)

	hook.Add("NTH-RoundTrigger", "NTH-RoundTrigger-Scoring", function(round, event, args)
	    if event == "OnEnd" then
	        for _,ply in pairs(player.GetAll()) do
	            if ply:Alive() and not ply:IsSpec() then
	                ply:AnimApplyGesture(ACT_GMOD_TAUNT_DANCE, 1)
	            end
	        end
	    end
	end)

end

