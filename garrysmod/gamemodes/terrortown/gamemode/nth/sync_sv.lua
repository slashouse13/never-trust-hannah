
-- This is for logging players who play on the server.
-- It's some neccessary evil in order to implement achievements.

hook.Add("PlayerSpawn", "NTH-S-PlayerSpawn", function(ply)
    NTH.DB.query("CALL tttSpawn(?)", {ply:SteamID64()})
end)

hook.Add("PlayerDeath", "NTH-S-PlayerDeath", function(victim, weapon, attacker)
    if GetRoundState() != ROUND_ACTIVE then return end
    if not IsValid(victim) or not victim:IsPlayer() then return end
    -- log victim's death
    NTH.DB.query("CALL tttDeath(?)", {victim:SteamID64()})
end)

hook.Add("PlayerKilled", "NTH-S-PlayerKilled", function(victim, attacker, dmginfo)
    if GetRoundState() != ROUND_ACTIVE then return end
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if victim == attacker then return end
    
    if NTH.Round.RDM then
        NTH.DB.query("CALL tttNNKK(?)", {attacker:SteamID64()})
        return
    end
    
    -- log attacker's kill, but was it RDM or not RDM?
    local rdm = (victim:IsTraitor() == attacker:IsTraitor())
    if rdm and dmginfo and WasAvoidable(attacker, victim, dmginfo) then
        return
    end

    if rdm then
        NTH.DB.query("CALL tttNKK(?)", {attacker:SteamID64()})
    else
        NTH.DB.query("CALL tttNNKK(?)", {attacker:SteamID64()})
    end
end)

hook.Add("TTTEndRound", "NTH-S-TTTEndRound", function()
    for _,ply in pairs(player.GetAll()) do
        if ply:Alive() and not ply:IsSpec() then
            NTH.DB.query("CALL tttSurvival(?)", {ply:SteamID64()})
        end
    end
end)

local rdmParticipants = 0
hook.Add("NTH-RoundTrigger", "NTH-RoundTrigger-Scoring", function(round, event, args)
    if round.RDM and event == "OnBegin" then
        rdmParticipants = #round:GetPlayingPlayers()
    end
    if round.RDM and event == "OnEnd" then
        local alivePlayers = {}
        for _,ply in pairs(player.GetAll()) do
            if ply:Alive() and not ply:IsSpec() then
                table.insert(alivePlayers, ply)
            end
        end
        if #alivePlayers == 1 then
            NTH.DB.query("CALL tttSurvivals(?,?)", {
                alivePlayers[1]:SteamID64(),
                math.max(rdmParticipants-1, 0)
            })
            MsgC(COLOR_YELLOW, "Awarding " .. rdmParticipants .. " suvivals to " .. alivePlayers[1]:Nick() .. "\n")
        end
    end
end)
