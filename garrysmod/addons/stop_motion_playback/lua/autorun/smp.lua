
---
-- Query functions for tables
---

function table.First(self, fn)

	for key, value in pairs(self) do
		local success = fn(value);
		if success then
			return value;
		end
	end

	return nil;

end

function table.Where(self, fn)

	local results = {};

	for key, value in pairs(self) do
		local passes = fn(value);
		if passes then
			table.insert(results, value);
		end
	end

	return results;
	
end

---
-- SMP Entry point.
---

if not SMP then
	SMP = {}
end

if SERVER then
	AddCSLuaFile("smp.lua");
    include("smp/server.lua");
else
	include("smp/client.lua");
end