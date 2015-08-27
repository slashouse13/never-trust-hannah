
-- let's get some groundwork out of the way

local plymeta = FindMetaTable( "Player" )

AccessorFunc(plymeta, "kibaLastMeow", "KibaLastMeow", FORCE_NUMBER)

function plymeta:KibaMeow()
    return
end

local kibaMeowPart = "nth/vips/kiba/m"

-- add Kiba sounds
for i=1,9 do
    if SERVER then
        resource.AddFile("sound/" .. kibaMeowPart .. tostring(i) .. ".mp3")
    else -- CLIENT
        util.PrecacheSound(kibaMeowPart .. tostring(i) .. ".mp3")
    end
end

if SERVER then
    util.AddNetworkString("nth_um_meow")
    -- when a Kiba player meows
    net.Receive("nth_um_meow", function(len, ply)
        if ply:GetVIP() == "KIBA" then
            ply:KibaMeow()
        end
    end)
else -- CLIENT
    -- when local player meows
    hook.Add("PlayerStartVoice", "PlayerStartVoice-KibaMeow", function(ply)
        if IsValid(ply) and ply.KibaMeow and ply.GetVIP and ply:GetVIP() == "KIBA" then
            ply:KibaMeow()
        end
    end)
    -- when another Kiba meows
    net.Receive("nth_um_meow", function()
        local eidx = net.ReadUInt(16)
        local ply = player.GetByID(eidx)
        if IsValid(ply) and ply.GetVIP and ply.KibaMeow then
            ply:KibaMeow()
        end
    end)
end

-- ok, here we go...

local VIP = NTH:NewVIP("KIBA")

VIP.Name            = "Kiba"
VIP.MaterialStar    = "nth/vips/kiba.vmt"
VIP.SoundIntro      = "nth/vips/intros/kiba.mp3"
VIP.Loadout         = {"weapon_nth_kibaclaws"}

if SERVER then
    hook.Add("PlayerCanPickupWeapon", "NTH-Kiba-PlayerCanPickupWeapon", function(ply, wep)
        if not ply:IsVIP("KIBA") then
            return nil
        end

        if table.HasValue(VIP.Loadout, wep.ClassName) then
            -- VIPs can always pick up items in their loadout
            return true
        end
        
        return false
    end)
end

function VIP:Assign(ply)
    ply:SetJumpPower(400)
    if SERVER then
        ply:StripWeapons()
        ply:LoadoutVIPWeapons()
    end
end

function VIP:Unassign(ply)
    ply:SetJumpPower(160)
end

VIP:Decorate("GetRunSpeed", function()
    return 350
end)

VIP:Decorate("CanUseVoiceChat", function()
    return false
end)

VIP:Decorate("KibaMeow", function(ply, prevResult)
    -- spam prevention
    local t = CurTime()
    local mt = ply:GetKibaLastMeow()
    if mt and t < mt + 1 then
        return
    end
    ply:SetKibaLastMeow(CurTime())
    
    if SERVER then
        net.Start("nth_um_meow")
        net.WriteUInt(ply:EntIndex(), 16)
        local sendTo = {}
        local plys = player.GetAll()
        for i=1,#plys do
            local listener = plys[i]
            -- this bit is mostly ripped off from gamemsg.lua
            if (not IsValid(ply)) or (not IsValid(listener)) or (listener == ply) then
                continue
            end
            if ply:IsSpec() and (not listener:IsSpec()) and GetRoundState() == ROUND_ACTIVE then
                continue
            end
            if listener:IsSpec() and listener.mute_team == ply:Team() then
                continue
            end
            if ply:IsSpec() and listener:IsSpec() then
                table.insert(sendTo, listener)
                continue
            end
            if ply:IsActiveTraitor() then
                if ply.traitor_gvoice or listener:IsActiveTraitor() then
                    table.insert(sendTo, listener)
                    continue
                else
                    -- unless traitor_gvoice is true, normal innos can't hear speaker
                    continue
                end
            end
            table.insert(sendTo, listener)
        end
        net.Send(sendTo)
    else -- CLIENT
        if ply == LocalPlayer() then
            -- this is us, better tell the server
            net.Start("nth_um_meow")
            net.SendToServer()
        else
            -- not us, but we should add their face to the talkie list
            local rem = g_AddPlayerVoicePanel(ply, LocalPlayer())
            timer.Simple(1, function()
                if rem then
                    rem()
                end
            end) -- remove panel after 1 second
        end
        if not GetConVar("nth_kiba_mute"):GetBool() then
            NTH.Sound:Play(kibaMeowPart .. tostring(math.random(1, 9)) .. ".mp3")
        end
    end
end)

VIP:Decorate("CalculateFallDamage", function(ply, prevResult, speed)
    if speed < 600 then return 0 end
    return math.pow(0.02 * (speed - 600), 1.75)
end)

VIP:Decorate("FiddleChatMessage", function(ply, prevResult, text, isRadioMsg)
    return "Meow"
end)
