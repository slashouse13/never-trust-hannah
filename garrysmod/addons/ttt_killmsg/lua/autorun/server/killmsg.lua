AddCSLuaFile("autorun/client/cl_killmsg.lua")

function PrintKillMsgOnDeath(victim, wep, attacker)
	if GetRoundState() == ROUND_ACTIVE then
		if (attacker:IsPlayer()) and (attacker ~= victim) and attacker:IsTraitor() then
			umsg.Start("KillMsg", victim)
				umsg.String(attacker:GetAKAName())
				umsg.Char(2)
			umsg.End()
		end
		if (attacker:IsPlayer()) and (attacker ~= victim) and attacker:IsDetective() then
			umsg.Start("KillMsg", victim)
				umsg.String(attacker:GetAKAName())
				umsg.Char(3)
			umsg.End()
		end
		if (attacker:IsPlayer()) and (attacker ~= victim) and !attacker:IsDetective() and !attacker:IsTraitor() then
			umsg.Start("KillMsg", victim)
				umsg.String(attacker:GetAKAName())
				umsg.Char(1)
			umsg.End()
		end
	end
end

hook.Add("PlayerDeath", "ChatKillMsg", PrintKillMsgOnDeath)
