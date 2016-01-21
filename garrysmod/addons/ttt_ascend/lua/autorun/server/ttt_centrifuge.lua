
hook.Add("InitPostEntity", "lh_gyro", function () 

	if(game.GetMap() == "ttt_centrifuge") then

		print("ttt_centrifuge: Random Gyro Timer Started.")
	
		local lh_gyro = nil
		
		for k,v in pairs(ents.FindByClass("func_rotating")) do
			if(v:GetName() == "asc_gyro") then
				lh_gyro = v
			end
		end

		lh_gyro:Fire( "stop" )
		
		timer.Create("lh_GyroTimer", 20, 0, function() 
		
			local n = math.Rand(0,100)
		
			if (n < 35) then startGyro() end
		
		end)

		
		function startGyro( )

			local ent = nil
		
			for k,v in pairs(ents.FindByClass("func_rotating")) do
				if(v:GetName() == "asc_gyro") then
					ent = v
				end
			end		
			
			local tbl = ent:GetKeyValues()
			
			if (tbl["speed"] > 0)then  return end		
			ent:Fire( "start" )

			timer.Simple( 15, function() 
			
				ent:Fire( "stop" )
			
			end)

		end
		

	end

end)

hook.Add("PostCleanupMap", "lh_gyroRe", function()
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		if(v:GetName() == "asc_gyro") then
			v:Fire("stop")
		end
	end	
	
end)