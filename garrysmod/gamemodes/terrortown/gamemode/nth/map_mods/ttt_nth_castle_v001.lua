
-- if SERVER then
-- 	function setupCircus()
-- 		for _,e in pairs(ents.FindByName("circus_fall_stopper")) do
-- 			print("stopper:", e)
-- 			e:SetCustomCollisionCheck(true)
-- 			-- e:AddCallback("OnTrigger", function(ply)
-- 			-- 	print(ply, "touched fall stopper")

-- 			-- 	if not IsValid(ply) or not ply:IsPlayer() then return end

				
-- 			-- end)
-- 			hook.Add("ShouldCollide", "shouldcollide", function(e1, e2)
-- 				print("collide?", e1, e2)
-- 			end)
-- 		end
-- 	end

-- 	hook.Add("TTTPrepareRound", "NTHMapMod-ttt_nth_castle-TTTPrepareRound", setupCircus)

-- 	setupCircus()
-- end
