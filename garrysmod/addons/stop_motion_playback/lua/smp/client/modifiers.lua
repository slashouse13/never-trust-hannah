
function SMP.LoadModifiers()

	SMP.Modifiers = {};

	local path = "smp/modifiers/";
	local files, dirs = file.Find(path .. "*.lua", "LUA");

	for _, f in pairs(files) do

		_G["MOD"] = {};

		include(path .. f);

		SMP.Modifiers[f:sub(1, -5)] = _G["MOD"];

		_G["MOD"] = nil;

	end

end

SMP.LoadModifiers();

