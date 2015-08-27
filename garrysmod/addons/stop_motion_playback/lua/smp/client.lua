
local DEBUG = false

--include("client/data.lua")
--include("client/entity_selection.lua")
include("client/positioning.lua");
include("client/modifiers.lua");
include("client/easing.lua");

function SMP.DestroyScene()
    if SMP.SceneData and SMP.SceneData.Entities then
        for _, e in pairs(SMP.SceneData.Entities) do
            if IsValid(e.doll) then
                SafeRemoveEntity(e.doll)
            end
        end
    end
end

function SMP.AddScene(scene)

    local sceneStart = SMP.SceneData.LastSceneEnd

    for _, e in pairs(scene.Entities) do
    
        for _, f in pairs(e.Frames) do
            f.Position = (f.Position * 4) + SMP.SceneData.LastSceneEnd
            SMP.SceneData.LastFrame = math.max(SMP.SceneData.LastFrame, f.Position)
        end
    
        local options = (SMP.SceneParams.modelLookup or {})[e.Model]
        e.Options = options
        
        if not options then
            print("No options found for Entity.Model ", e.Model)
            e.doll = ClientsideModel()
        elseif options.typ == "rag" then
            local doll = ClientsideRagdoll(options.mdl)
            doll:SetNoDraw(true)
            doll:DrawShadow( true )
            doll:SetCollisionGroup(COLLISION_GROUP_NONE)

            for i = 0, 15 do
                local p = doll:GetPhysicsObjectNum(i)
                if p and IsValid(p) then
                    p:EnableMotion(false)
                    p:EnableCollisions(false)
                    p:EnableGravity(false)
                end
            end
            
            for i = 0, doll:GetBoneCount() - 1 do
                doll:ManipulateBonePosition(i, Vector(0, 0, 0));
                doll:ManipulateBoneAngles(i, Angle(0, 0, 0));
                doll:ManipulateBoneScale(i, Vector(1, 1, 1));
            end
            
            e.doll = doll
            
        elseif options.typ == "prop" then
            local doll = ClientsideModel(options.mdl)
            doll:SetNoDraw(true)
            doll:SetCollisionGroup(COLLISION_GROUP_NONE)
            
            for i = 0, doll:GetBoneCount() - 1 do
                doll:ManipulateBonePosition(i, Vector(0, 0, 0));
                doll:ManipulateBoneAngles(i, Angle(0, 0, 0));
                doll:ManipulateBoneScale(i, Vector(1, 1, 1));
            end
            
            e.doll = doll
        end
        
        if options.camera then
            e.isCamera = true
        end
        
        table.insert(SMP.SceneData.Entities, e)
        
    end
    
    SMP.SceneData.LastSceneEnd = SMP.SceneData.LastFrame
    
    for _, e in pairs(scene.Entities) do
        e.Entrance = sceneStart
        e.Exit = SMP.SceneData.LastSceneEnd
    end
    
end

function SMP.Setup(params)
    SMP.SceneData = {}
    SMP.SceneData.Entities = {}
    SMP.SceneData.LastFrame = 0
    SMP.SceneData.LastSceneEnd = 0
    
    if params.audioTrack then
        SMP.Audio = CreateSound(LocalPlayer(), params.audioTrack)
    end
    
    SMP.SceneParams = params
end

function SMP.MakeVisible(bool)
    for _, e in pairs(SMP.SceneData.Entities) do
        if e.isCamera then
            e.doll:SetNoDraw(true)
        else
            e.doll:SetNoDraw(not bool)
        end
    end
end

local pb = {Position = nil};

function SMP.UpdateCamera()
    SMP.Camera = nil
    for _, e in pairs(SMP.SceneData.Entities) do
        if pb.Position ~= nil and e.isCamera and e.Entrance <= pb.Position and e.Exit > pb.Position then
            SMP.Camera = e
        end
    end
end

SMP.PreRender = function()

    if pb.Position == nil then return end
    
    local oldPos = math.floor(pb.Position)
    pb.Position = pb.Position + FrameTime() * pb.PlaybackRate
    local newPos = math.floor(pb.Position)

    if newPos > pb.PlaybackLength then
        pb.Position = nil
        return
    end

    if newPos ~= oldPos then
        if DEBUG then
            LocalPlayer():ChatPrint("Pos: " .. newPos)
        end
        for _, ent in pairs(SMP.SceneData.Entities) do
            if newPos >= ent.Entrance and newPos <= ent.Exit then
                if not ent.isCamera then ent.doll:SetNoDraw(false) end
                SMP.PositionEntity(ent, newPos)
            else
                ent.doll:SetNoDraw(true)
            end
        end
    end
    
    SMP.UpdateCamera()

end

hook.Add("Think", "SMPPreRender", SMP.PreRender)

function SMP.StartPlayback()
    hook.Remove("RenderScene", "NTH-Cutscene-RenderScene")

	pb.Position = 0
	pb.PlaybackRate = 60
	pb.PlaybackLength = SMP.SceneData.LastSceneEnd
    SMP.PreRender()
    SMP.MakeVisible(true)
    
    if SMP.Audio then
        SMP.Audio:Play()
    end
    
    SMP.UpdateCamera()
    
    if SMP.Camera then
        local view = {}
        view.drawhud = DEBUG
        view.drawviewmodel = false
        view.x = 0
        view.y = 0
        view.w = ScrW()
        view.h = ScrH()
        view.fov = 90
        
        hook.Add("RenderScene", "NTH-Cutscene-RenderScene", function( Origin, Angles )
            if SMP.Camera == nil then return false end
            view.origin = SMP.Camera.doll:GetPos()
            view.angles = SMP.Camera.doll:GetAngles()
            
            
            
            render.Clear( 0, 0, 0, 255, true, true )
            render.RenderView( view )
            
            if SMP.SceneParams.renderFx then
                SMP.SceneParams.renderFx(pb.Position)
            end
            
            return true
        end)
    end
end

function SMP.StopPlayback(player)
    hook.Remove("RenderScene", "NTH-Cutscene-RenderScene")
	pb.Position = nil
    
    if SMP.Audio then
        SMP.Audio:Stop()
        SMP.Audio = nil
    end
end
