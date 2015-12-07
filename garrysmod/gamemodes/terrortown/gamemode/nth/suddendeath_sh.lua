
AddCSLuaFile()

local SD = {}
NTH.SuddenDeath = SD

-- After 60 seconds of no killing, a countdown begins to end the round

if SERVER then
	function SD:EnableStarterTimer(triggerTime)
		SD:DisableStarterTimer() -- in case we're already running

		MsgN("SuddenDeath mode enabled")
		self.TriggerTime = triggerTime or 60
		self:ResetStarterTimer()
		
		hook.Add("PlayerDeath", "PlayerDeath-SuddenDeath", function()
			SD:ResetStarterTimer()
		end)

		hook.Add("Think", "Think-SuddenDeath", function()
			if CurTime() > SD.NextTrigger then
				SD:DisableStarterTimer()
				SD:StartCountdown(10)
			end
		end)
	end

	function SD:DisableStarterTimer()
		hook.Remove("PlayerDeath", "PlayerDeath-SuddenDeath")
		hook.Remove("Think", "Think-SuddenDeath")
	end

	function SD:ResetStarterTimer()
		MsgN("SuddenDeath countdown starts in " .. self.TriggerTime .. " seconds")
		self.NextTrigger = CurTime() + self.TriggerTime
	end

	util.AddNetworkString("nth_suddendeath_start")
	function SD:StartCountdown(t)
		t = (t or 60)
		local tEnd = CurTime() + t + 2

		MsgN("SuddenDeath countdown started. Everyone dies in "..t.." seconds")

		net.Start("nth_suddendeath_start")
		net.WriteUInt(t, 8)
		net.WriteUInt(tEnd, 32)
		net.Broadcast()

		hook.Add("Think", "Think-SuddenDeathRoundEnd", function()
			if CurTime() < tEnd then
				-- not time to die yet....
				return
			end

			SD:ForceRoundEnd()
		end)
	end

	function SD:StopCountdown()
		hook.Remove("Think", "Think-SuddenDeathRoundEnd")
	end

	function SD:ForceRoundEnd()
		SD:StopCountdown()
		-- everyone dies!
		for _,p in pairs(player.GetAll()) do
			if IsValid(p) and p:Alive() and not p:IsSpec() then
				p:Kill()
			end
		end
	end

	hook.Add("TTTEndRound", "TTTEndRound-SuddenDeathRoundEnd", function()
		-- when round ends, all sudden death stuff stops
		SD:DisableStarterTimer()
		SD:StopCountdown()
	end)
end

if CLIENT then
	surface.CreateFont("SuddenDeathCounterBlur", {font="Register", size=70, weight=500, blursize=2})
	surface.CreateFont("SuddenDeathCounter", {font="Register", size=70, weight=500})

	function formatTime(t)
		-- let's work around a gmod bug...
		local s = math.floor(t)
		local ms = t - s
		if ms > 0.99 then
			ms = 0.99
		end
		return string.FormattedTime(s+ms, "%02i:%02i:%02i")
	end

	local WorldEndTime = nil

	-- for testing
	WorldEndTime = CurTime() + 65

	hook.Add("HUDPaint", "Suddendeath-HUDPaint", function()

		local top = ScrH()/10

		surface.SetDrawColor(20,20,20,230)
		surface.DrawRect(0,top,ScrW(),100)
		local ftime = formatTime(WorldEndTime - CurTime())
		draw.SimpleText(ftime, "SuddenDeathCounterBlur", (ScrW()/2) + 2, top+2+20, Color(20,0,0), TEXT_ALIGN_CENTER)
		draw.SimpleText(ftime, "SuddenDeathCounter", ScrW()/2, top+20, Color(160,30,30), TEXT_ALIGN_CENTER)
	end)

	net.Receive("nth_suddendeath_start", function()
		local t = net.ReadUInt(8)
		local tEnd = net.ReadUInt(32)

		print("world will end in "..t)
	end)


end

if SERVER then
	--SD:StartCountdown(15)
end