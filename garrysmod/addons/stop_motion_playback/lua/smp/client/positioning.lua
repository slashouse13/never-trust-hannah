
-- Get all entities that have frames, as well as the currently selected entity
function SMP.GetEntities(player)

	local entities = {};

	for _, frame in pairs(SMP.SceneData.Frames) do
		if frame.Player == player and not table.HasValue(entities, frame.Entity) then
			table.insert(entities, frame.Entity);
		end
	end

	if not table.HasValue(entities, player.SMHData.Entity) then
		table.insert(entities, player.SMHData.Entity);
	end

	return entities;

end

-- If the position has no frame, gets the frame before the position, the frame after the position and the difference percentage
-- otherwise returns only the frame at the position.
function SMP.GetPositionFrames(frames, framepos)

	local closestPrevFramePos = 9999999;
	local closestPrevFrame = nil;
	local closestNextFramePos = 9999999;
	local closestNextFrame = nil;

	for _, frame in pairs(frames) do

		local diff = frame.Position - framepos;
		local aDiff = math.abs(diff);
		if diff < 0 and aDiff < closestPrevFramePos then
			closestPrevFramePos = aDiff;
			closestPrevFrame = frame;
		elseif diff > 0 and aDiff < closestNextFramePos then
			closestNextFramePos = math.abs(diff);
			closestNextFrame = frame;
		elseif diff == 0 then
			return frame, nil;
		end

	end

	if not closestPrevFrame and closestNextFrame then
		return closestNextFrame, nil;
	elseif closestPrevFrame and not closestNextFrame then
		return closestPrevFrame, nil;
	end

	local perc = (framepos - closestPrevFrame.Position) / (closestNextFrame.Position - closestPrevFrame.Position);
	perc = math.EaseInOut(perc, closestPrevFrame.EaseOut, closestNextFrame.EaseIn);
	return closestPrevFrame, closestNextFrame, perc;

end

-- Return a table of bone positions from the frames for the given frame position. Used for onion skinning.
function SMP.GetFrameBonePositions(entity, frames, framepos)
	
	local frame1, frame2, perc = SMP.GetPositionFrames(frames, framepos);

	if not frame2 then
		frame2 = frame1;
		perc = 0;
	end

	local bones = {};

	for id, data in pairs(frame1.EntityData["physbones"]) do
		local data2 = frame2.EntityData["physbones"][id];
		local boneId = entity:TranslatePhysBoneToBone(id);
		local bone = {};
		bone.Pos = SMP.LerpLinearVector(data.Pos, data2.Pos, perc);
		bone.Ang = SMP.LerpLinearAngle(data.Ang, data2.Ang, perc);
		bones[boneId] = bone;
	end

	for id, data in pairs(frame1.EntityData["bones"]) do
		-- TODO
	end

	return bones;

end

function SMP.PositionEntity(entity, framepos)

    -- get frames which belong to this entity
	local frames = entity.Frames

	local frame1, frame2, perc = SMP.GetPositionFrames(frames, framepos);

	if not frame2 then
		for name, mod in pairs(SMP.Modifiers) do
			mod:Load(player, entity.doll, frame1.EntityData[name]);
		end
		return;
	end

	for name, mod in pairs(SMP.Modifiers) do
		mod:LoadBetween(player, entity.doll, frame1.EntityData[name], frame2.EntityData[name], perc);
	end

end

function SMP.PositionEntities(player, framepos)
	local entities = SMP.GetEntities(player);
	for _, entity in pairs(entities) do
		SMP.PositionEntity(player, entity, framepos);
	end
end