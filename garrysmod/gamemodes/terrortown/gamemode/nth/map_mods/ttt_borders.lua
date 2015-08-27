
--[[
Nice map. Shame about missing models & textures. This patch
should plug those holes nicely.

Could probably use some work in future to mitigate Hannah's
effect on the traitor tester. Needs testing.
]]--

if SERVER then
    NTH.AddFiles({
        "materials/models/props_foliage/arbre01_b.vmt",
        "materials/models/props_foliage/arbre01.vtf",
        "materials/metal/forest_metal01f.vmt",
        "materials/metal/forest_metal01f.vtf",
        "materials/vehicle/metaltraindam001c.vmt",
        "materials/vehicle/metaltraindam001c.vtf",
        "materials/vehicle/metaltraindam001c_normal.vtf",
        "materials/concrete/concretewall075b.vmt",
        "materials/concrete/concretewall075b.vtf",
        "models/props_foliage/tree_dry01.mdl"
    })
end
