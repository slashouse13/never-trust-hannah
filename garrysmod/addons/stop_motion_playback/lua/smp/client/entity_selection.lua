
SMP.Entity = nil;
SMP.TouchedEntities = {};

function SMP.SelectEntity(entity)
	SMP.Entity = entity;
	if not table.HasValue(SMP.TouchedEntities, entity) then
		table.insert(SMP.TouchedEntities, entity);
	end
	SMP.Menu:RebuildFrameItems();
end

hook.Add("EntityRemoved", "SMPSelectionEntityRemoved", function(ent)
	if SMP.Entity == ent then
		SMP.Entity = nil;
		SMP.Menu:RebuildFrameItems();
	end
	if table.HasValue(SMP.TouchedEntities, ent) then
		table.RemoveByValue(SMP.TouchedEntities, ent);
	end
end);