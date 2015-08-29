-- this hack allows weapons to use custom materials
-- since GM:OnViewModelChanged is broken in TTT and
-- all other viewmodel hooks as broken on client side

local lastWep = nil

hook.Add("PreDrawViewModel", "PreDrawViewModel-CustomSkin", function(vm, ply, wep)
	if lastWep == wep then return end
	if not ply or not IsValid(ply) or not wep or not IsValid(wep) then return end
  	
  	lastWep = wep
  	vm:SetMaterial(wep:GetMaterial())
end)
