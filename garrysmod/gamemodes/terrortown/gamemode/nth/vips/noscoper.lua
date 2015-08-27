
local VIP = NTH:NewVIP("NOSCOPER")

VIP.Name            = "=N0SC0P3R="
VIP.MaterialStar    = "nth/vips/noscoper.vmt"
VIP.SoundIntro      = "nth/vips/intros/noscoper.mp3"

--[[

TOTO: INCLUDE ALL RESOURCES
    SOUNDS
    MATERIALS
    FONTS (RESOURCES)
]]--

local function isWeaponScoped(cls)
    for _,w in pairs({"weapon_ttt_silencedsniper", "weapon_ttt_crossbow", "weapon_zm_rifle"}) do
        if cls == w then
            return true
        end
    end
    return false
end

for i=1,3 do
    if SERVER then
        resource.AddFile("sound/nth/vips/noscoper/dub" .. tostring(i) .. ".mp3")
    else -- CLIENT
        util.PrecacheSound("nth/vips/noscoper/dub" .. tostring(i) .. ".mp3")
    end
end

local MLGArt = {
    {mat=nil,path="nth/mlg/frog",frames=10,speed=22,size=0.4,loop=true},
    {mat=nil,path="nth/mlg/snoop",frames=40,speed=20,size=0.65,loop=true},
    {mat=nil,path="nth/mlg/chicken",frames=41,speed=10,size=0.5,loop=true},
    {mat=nil,path="nth/mlg/oldhump",frames=26,speed=26,size=0.5,width=0.5,loop=true},
    {mat=nil,path="nth/mlg/wow",frames=35,speed=15,size=0.6,sound="nth/vips/noscoper/wow.mp3",soundpos=0.17,loop=false}
}
local MLGSounds = {
    "nth/vips/noscoper/weed.mp3",
    "nth/vips/noscoper/triple.mp3",
    "nth/vips/noscoper/horn.mp3",
    "nth/vips/noscoper/kill1.mp3",
    "nth/vips/noscoper/kill2.mp3",
    "nth/vips/noscoper/kill3.mp3",
    "nth/vips/noscoper/camera.mp3",
    "nth/vips/noscoper/whereyouat.mp3",
}

if SERVER then
    resource.AddFile("sound/nth/vips/noscoper/2sad.mp3")
    resource.AddFile("sound/nth/vips/noscoper/sanic.mp3")
    resource.AddFile("materials/nth/mlg/sanic.vmt")
    resource.AddFile("resource/fonts/comicbd.ttf")
    for k,a in pairs(MLGArt) do
        resource.AddFile("materials/"..a.path..".vmt")
        if a.sound then resource.AddFile("sound/"..a.sound) end
    end
    for k,a in pairs(MLGSounds) do
        resource.AddFile("sound/"..a)
    end
end

if CLIENT then

    util.PrecacheSound("nth/vips/noscoper/2sad.mp3")
    util.PrecacheSound("nth/vips/noscoper/sanic.mp3")
    
    local sanicMat = Material("nth/mlg/sanic")
    for k,a in pairs(MLGArt) do
        a.mat = Material(a.path)
        if a.sound then util.PrecacheSound(a.sound) end
    end
    for k,a in pairs(MLGSounds) do
        util.PrecacheSound(a)
    end
    

    local view = {}
    view.drawhud = false

    
    local baseFOV = nil
    
    local function resetView()
        view.x = 0
        view.y = 0
        view.w = ScrW()
        view.h = ScrH()
        view.fov = baseFOV
    end

    local NS_RENDER_VIEW = 1
    local NS_RENDER_DRAW = 2
    local NS_RENDER_HUD = 3
    
    local renderStack = {}
    
    local function runRenderStack(typ)
        resetView()
        local ct = CurTime()
        for i,v in ipairs(renderStack) do
            if ct > v.stop then
                table.remove(renderStack, i)
            elseif v.typ == typ and ct >= v.start and ct <= v.stop then
                v.func((ct - v.start) / (v.stop - v.start))
            end
        end
    end
    
    local function RenderStackPush(typ, func, duration, delay)
        table.insert(renderStack, {
            typ = typ,
            start = CurTime() + (delay or 0),
            stop = CurTime() + (delay or 0) + duration,
            func = func
        })
    end

    --------------------------------------------------------
    
    
    local function NSFlareMonochrome(pos)
        DrawColorModify( {
         [ "$pp_colour_addr" ] = 0,
         [ "$pp_colour_addg" ] = 0,
         [ "$pp_colour_addb" ] = 0,
         [ "$pp_colour_brightness" ] = 0,
         [ "$pp_colour_contrast" ] = 0.95,
         [ "$pp_colour_colour" ] = 0,
         [ "$pp_colour_mulr" ] = 0,
         [ "$pp_colour_mulg" ] = 0,
         [ "$pp_colour_mulb" ] = 0
        } )
    
        DrawSunbeams(0, 0.12, NTH.Effects.EaseOutBack(pos) * 0.05,0.5,0.5)
        DrawBloom( 0.75, 20, 20, 20, 1, 1, 1, 1, 5 )
    end
    
    local function NSStimulate(r, g, b)
        return function(pos)
            DrawColorModify( {
             [ "$pp_colour_addr" ] = 0.05 * r,
             [ "$pp_colour_addg" ] = 0.05 * g,
             [ "$pp_colour_addb" ] = 0.05 * b,
             [ "$pp_colour_brightness" ] = 0,
             [ "$pp_colour_contrast" ] = 0.9,
             [ "$pp_colour_colour" ] = NTH.Effects.EaseOutBack(pos) * 3,
             [ "$pp_colour_mulr" ] = 0.8 * r,
             [ "$pp_colour_mulg" ] = 0.8 * g,
             [ "$pp_colour_mulb" ] = 0.8 * b
            } )
            DrawSharpen(NTH.Effects.EaseOutBack(pos * 3.2), 1.2)
            DrawBloom( 1.2 - NTH.Effects.EaseOutBack(pos) , 2, 9, 9, 1, 1, 1, 1, 1 )
        end
    end
    
    local function NSWobble(dir)
        return function(pos)
            if dir then
                view.angles[3] = NTH.Effects.EaseInOutSine(pos) * 20
            else
                view.angles[3] = -(NTH.Effects.EaseInOutSine(pos) * 20)
            end
        end
    end
    
    local function NSSpin(dir)
        return function(pos)
            if dir then
                view.angles[3] = pos * 360
            else
                view.angles[3] = 360 - (pos * 360)
            end
        end
    end
    
    local function NSArt(art)
        if not art then
            art = MLGArt[math.random(#MLGArt)]
        end
        local size = ScrH() * art.size
        local x = math.random(ScrW()-(size * (art.width or 1)))-1
        local y = math.random(ScrH()-size)-1
        local start = CurTime()
        local soundplayed = false
        
        local loopEnded = false
        local lastFrame = 0
        
        return function(pos)
            if not art.loop and loopEnded then
                return
            end
        
            if art.sound and not soundplayed and pos > art.soundpos then
                soundplayed = true
                NTH.Sound:Play(art.sound)
            end
            
            local frame = ((CurTime() - start) * art.speed) % art.frames
            if not art.loop and  frame < lastFrame then
                loopEnded = true
                return
            end
            
            lastFrame = frame
            surface.SetDrawColor(COLOR_WHITE)
            surface.SetMaterial(art.mat)
            if not art.mat:IsError() then
                art.mat:SetInt("$frame", frame)
            end
            surface.DrawTexturedRect(x, y, size * (art.width or 1), size)
        end
    end
    
    local function NSSanic()
        local size = math.Round(ScrH()*0.3)
        local sw, sh = ScrW()-size, ScrH()-size
        local x, y = math.Round(math.random(sw)), math.Round(math.random(sh))
        local mx, my = math.random()+0.5, math.random()+0.5
        
        return function(pos)
            x = x + (mx * 70)
            y = y + (my * 50)
            if x > sw then mx = -1 end
            if x < 0 then mx = 1 end
            if y > sh then my = -1 end
            if y < 0 then my = 1 end
            surface.SetDrawColor(COLOR_WHITE)
            surface.SetMaterial(sanicMat)
            surface.DrawTexturedRectRotated(x + (size/2), y + (size/2), size, size, -(pos*10000)%360)
        end
    end
    
    local function NSWarpBack(pos)
        view.fov = baseFOV + 30 - (NTH.Effects.EaseOutBack(pos) * 30)
    end

    surface.CreateFont("NoscoperComic", {
        font = "Comic Sans MS",
        size = 200,
        weight = 600
    })
    
    
    local function NSSampleText(txt)
        local col = Color(math.random(255),math.random(255),math.random(255))
        local x1, x2, y1, y2 = math.random(ScrW()), math.random(ScrW()), math.random(ScrH()), math.random(ScrH())
        local xdiff, ydiff = x2 - x1, y2 - y1
        local textData = {
            text = txt,
            font = "NoscoperComic",
            pos = {x1, y1},
            color = col,
            xalign = TEXT_ALIGN_CENTER
        }
        
        return function(pos)
            textData.pos[1] = x1 + (xdiff*pos)
            textData.pos[2] = y1 + (ydiff*pos)
            draw.Text(textData)
        end
    end
    
    local function NSScatterText(txt)
        local col = Color(math.random(255),math.random(255),math.random(255))
        local textData = {
            text = txt,
            font = "NoscoperComic",
            pos = {math.random(ScrW()), math.random(ScrH())},
            color = col,
            xalign = TEXT_ALIGN_CENTER
        }
        local lastSwitch = 0
        
        return function(pos)
            if pos - lastSwitch > 0.02 then
                textData.pos[1] = math.random(ScrW())
                textData.pos[2] = math.random(ScrH())
                lastSwitch = pos
            end
            draw.Text(textData)
        end
    end
    
    local rekCount = 0
    local rekTensity = 0
    local rekking = false
    local rekTionary = {
        "#REKT",
        "Sample Text",
        "Tample Sext",
        "rekt m8",
        "git gud nub",
        "top kek m8",
        "#getrekt69",
        "ayy lmao",
        "ayyyyyyyy",
        "thanks mr skeltal",
        "( ͡° ͜ʖ ͡°)"
    }
    
    local function pickEffects(density)
        local segmentLength = 4 / density
        local timeToFill = 4
        local offset = 0
        
        if math.random() > 0.8 then
            RenderStackPush(NS_RENDER_VIEW, NSSpin(math.random()>=0.5), 4, 0)
        else
            while timeToFill > 0.01 do
                local rnd = math.random()
                timeToFill = timeToFill - segmentLength
                if rnd >= 0.3 then
                    RenderStackPush(NS_RENDER_VIEW, NSWobble(math.random()>=0.5), segmentLength, offset)
                else
                    RenderStackPush(NS_RENDER_VIEW, NSWarpBack, segmentLength, offset)
                end
                offset = offset + segmentLength
            end
        end
        
        timeToFill = 4
        offset = 0
        while timeToFill > 0.01 do
            local rnd = math.random()
            timeToFill = timeToFill - segmentLength
            if rnd >= 0.5 then
                RenderStackPush(NS_RENDER_DRAW, NSStimulate(math.random()+0.5,math.random()+0.5,math.random()+0.5), segmentLength, offset)
            else
                RenderStackPush(NS_RENDER_DRAW, NSFlareMonochrome, segmentLength, offset)
            end
            offset = offset + segmentLength
        end
        
        local mlgCopy = table.Copy(MLGArt)
        local rekTionaryCopy = table.Copy(rekTionary)

        RenderStackPush(NS_RENDER_HUD, NSSampleText(table.remove(rekTionaryCopy, math.random(#rekTionaryCopy))), 4)
        RenderStackPush(NS_RENDER_HUD, NSScatterText(table.remove(rekTionaryCopy, math.random(#rekTionaryCopy))), 4)        
        for i = 1,math.min(rekTensity,3) do
            RenderStackPush(NS_RENDER_HUD, NSArt(table.remove(mlgCopy, math.random(#mlgCopy))), 4, 0)
        end
        
        if math.random() >= 0.8 then
            RenderStackPush(NS_RENDER_HUD, NSSanic(), 1.7, 0)
            NTH.Sound:Play("nth/vips/noscoper/sanic.mp3")
        end
    end

    
    local dubNum = 1
    local function playDub()
        NTH.Sound:Play("nth/vips/noscoper/dub"..dubNum..".mp3")
        if dubNum == 1 then dubNum = 2 else dubNum = 1 end
    end
    
    local function checkRekt()
        if rekCount > 0 then
            rekCount = rekCount - 1
            timer.Simple(4, checkRekt)
            pickEffects(rekTensity)
            playDub()
        else
            NTH.Sound:Play("nth/vips/noscoper/dub3.mp3")
            RenderStackPush(NS_RENDER_VIEW, NSWarpBack, 3)
            rekking = false
        end
    end
    
    local specScopers = {}
    
    local function playSpecDub(ply, ss)
        if IsValid(ply) then
            ply:EmitSound("nth/vips/noscoper/dub"..ss.dubNum..".mp3", SNDLVL_180dB)
        end
        if ss.dubNum == 1 then ss.dubNum = 2 else ss.dubNum = 1 end
    end
    
    local function checkSpecRekt(ply)
        if not specScopers[ply] then
            specScopers[ply] = {}
        end
        local ss = specScopers[ply]
        
        if ss.rekCount > 0 then
            ss.rekCount = ss.rekCount - 1
            playSpecDub(ply, ss)
            timer.Simple(4, function()
                checkSpecRekt(ply)
            end)
        else
            if IsValid(ply) then
                ply:EmitSound("nth/vips/noscoper/dub3.mp3", SNDLVL_180dB)
            end
            ss.rekking = false
        end
    end
    
    local function specRekt(ply)
        if not specScopers[ply] then
            specScopers[ply] = {}
        end
        local ss = specScopers[ply]
        
        if ss.rekking then
            ss.rekCount = ss.rekCount + 1
        else
            ss.rekking = true
            ss.dubNum = 1
            playSpecDub(ply, ss)
            ss.rekCount = 1
            timer.Simple(4, function()
                checkSpecRekt(ply)
            end)
        end
    end
    
    local function gedRekt()
        util.ScreenShake( Vector( 0,0,0 ), 30, 100, 4, 1000 )
        
        if rekking then
            rekCount = rekCount + 1
            rekTensity = math.min(rekTensity + 1, 3)
        else
            rekking = true
            dubNum = 1
            rekTensity = 2
            rekCount = 1
            timer.Simple(4, checkRekt)
            pickEffects(rekTensity)
            playDub()
        end
    end
    
    function VIP:Assign(ply)
        if ply == LocalPlayer() then
            
            baseFOV = 125
            resetView()
        
            hook.Remove("RenderScene", "NTH-Noscoper-RenderScene")
            hook.Add( "RenderScene", "NTH-Noscoper-RenderScene", function( Origin, Angles )
                view.origin = Origin
                view.angles = Angles
                runRenderStack(NS_RENDER_VIEW)
                render.Clear( 0, 0, 0, 255, true, true )
                render.RenderView( view )
                runRenderStack(NS_RENDER_DRAW)
                render.RenderHUD(0,0,view.w,view.h)
                return true
            end )
            
            
            hook.Remove("HUDPaint", "NTH-Noscoper-HUDPaint")
            hook.Add( "HUDPaint", "NTH-Noscoper-HUDPaint", function( Origin, Angles )
                runRenderStack(NS_RENDER_HUD)
            end )
        end
    end
    
    function VIP:Unassign(ply)
        if ply == LocalPlayer() then
            rekCount = 0
            hook.Remove("RenderScene", "NTH-Noscoper-RenderScene")
            hook.Remove("HUDPaint", "NTH-Noscoper-HUDPaint")
        end
    end

    -- aimbot stuff goes here -----------------------------------------
    
    local function AngleTo(ply, pos)
        local myAngs = ply:GetAngles()
        local needed = (pos - ply:GetShootPos()):Angle()
        myAngs.p = math.NormalizeAngle(myAngs.p)
        needed.p = math.NormalizeAngle(needed.p)
        myAngs.y = math.NormalizeAngle(myAngs.y)
        needed.y = math.NormalizeAngle(needed.y)
        local p = math.NormalizeAngle(needed.p - myAngs.p)
        local y = math.NormalizeAngle(needed.y - myAngs.y)
        return math.abs(p) + math.abs(y), {p = p, y = y}
    end
    
    local function SpotIsVisible(ply, pos, ent)
        local tracedata = {}
        tracedata.start = ply:GetShootPos()
        tracedata.endpos = pos
        tracedata.filter = {ply, ent}
        local trace = util.TraceLine(tracedata)
        return trace.HitPos:Distance(pos) < 0.005
    end
    
    hook.Add("Think", "NTH-Noscoper-Headtrack", function()
        local ply = LocalPlayer()
        if not ply:IsVIP("NOSCOPER") then return end
        
        local wep = ply:GetActiveWeapon()

        if not isWeaponScoped(wep.ClassName) then return end
        
        if wep:GetIronsights() then return end
        
        local trace = ply:GetEyeTrace(MASK_SHOT)
        local ent = trace.Entity
        if not IsValid(ent) or ent.NoTarget or not ent:IsPlayer() then return end
        
        local pos, ang = ent:GetBonePosition(ent:LookupBone("ValveBiped.Bip01_Head1"))
        pos = pos + Vector(0, 0, 3)

        local total, needed = 300, {300, 300}
       
        local tarSpeed = ent:GetVelocity() * 0.013
        local plySpeed = ply:GetVelocity() * 0.013
        total, needed = AngleTo(ply, pos - plySpeed + tarSpeed)

        if SpotIsVisible(ply, pos, ent) then
            local myAngles = ply:GetAngles()
            local NewAngles = Angle(myAngles.p + needed.p, myAngles.y + needed.y, 0)
            ply:SetEyeAngles(NewAngles)
        end
    end)
    
    net.Receive("nth_noscoped", function()
        local victim = player.GetByID(net.ReadUInt(16))
        local attacker = player.GetByID(net.ReadUInt(16))
        local snd = player.GetByID(net.ReadString())
        if not attacker or not IsValid(attacker) or not attacker:IsVIP("NOSCOPER") then return end
        
        if LocalPlayer() == attacker then
            gedRekt()
            NTH.Sound:Play(table.Random(MLGSounds))
        elseif not LocalPlayer():IsVIP("NOSCOPER") then
            specRekt(attacker)
            if IsValid(attacker) then
                attacker:EmitSound(table.Random(MLGSounds), SNDLVL_180dB)
            end
        end
    end)
    
    net.Receive("nth_noscoper_dead", function()
        local victim = player.GetByID(net.ReadUInt(16))
        if LocalPlayer() == victim then
            NTH.Sound:Play("nth/vips/noscoper/2sad.mp3")
            rekTensity = 0
            rekCount = 0
            rekking = false
        elseif not LocalPlayer():IsVIP("NOSCOPER") then
            if not specScopers[victim] then
                specScopers[victim] = {}
            end
            local ss = specScopers[victim]
            ss.rekCount = 0
            ss.rekking = false
            if IsValid(victim) then
                victim:EmitSound("nth/vips/noscoper/2sad.mp3", SNDLVL_65dB)
            end
        end
    end)
    
else -- SERVER
    
    function VIP:Assign(ply)
        if not IsValid(ply) then return end
        
        local weps = ply:GetWeapons()
        for _,w in pairs(weps) do
            if IsValid(w) and w.Kind and w.Kind == WEAPON_HEAVY then
                ply:DropWeapon(w)
            end
        end
        
        ply:Give("weapon_zm_rifle")
        ply:GiveAmmo(20, "357")
        ply:SelectWeapon("weapon_zm_rifle")
    end
    
    util.AddNetworkString("nth_noscoped")
    hook.Add("PlayerDeath", "PlayerDeath-Noscoper", function(victim, inflictor, attacker)
        if not IsValid(victim) or not IsValid(attacker) or not attacker.IsVIP or not attacker:IsVIP("NOSCOPER") then return end
        local wep = attacker:GetActiveWeapon()
        if not wep or not IsValid(wep) or not wep:GetClass() then return end
        if not isWeaponScoped(wep:GetClass()) then return end
        
        local snd = table.Random(MLGSounds)
        
        net.Start("nth_noscoped")
        net.WriteUInt(victim:EntIndex(), 16)
        net.WriteUInt(attacker:EntIndex(), 16)
        net.WriteString(snd)
        net.Send(player.GetAll())
    end)
    
    util.AddNetworkString("nth_noscoper_dead")
    hook.Add("PlayerDeath", "PlayerDeath-NoscoperDead", function(victim, inflictor, attacker)
        if not IsValid(victim) or not victim:IsVIP("NOSCOPER") then return end
        net.Start("nth_noscoper_dead")
        net.WriteUInt(victim:EntIndex(), 16)
        net.Send(player.GetAll())
    end)
    
    concommand.Add("nth_noscoped", function(ply)
        local snd = table.Random(MLGSounds)
        
        for _,p in pairs(player.GetAll()) do
            if p:IsVIP("NOSCOPER") then
                net.Start("nth_noscoped")
                net.WriteUInt(ply:EntIndex(), 16)
                net.WriteUInt(p:EntIndex(), 16)
                net.WriteString(snd)
                net.Send(ply)
            end
        end
    end)
    
end

VIP:Decorate("FiddleChatMessage", function(ply, prevResult, text, isRadioMsg)
    local trans = {
        ["[Ee]"] = "3",
        ["[Oo]"] = "0",
        ["[Ii]"] = "1",
        ["[Aa]"] = "4",
        ["[Tt]"] = "7",
    }
    for pattern, replace in pairs(trans) do
        text = string.gsub(text, pattern, replace)
    end
    return text
end)
