
if SERVER then
    hook.Add("TTTPrepareRound", "NTHMapMod-ttt_scarisland_b1-TTTPrepareRound", function()
        local e = ents.GetMapCreatedEntity(1436)
        if e then e:Remove() end -- Remove logo from the foam
    end)
end
