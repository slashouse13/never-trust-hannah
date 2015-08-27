
local hitmarks = {}

NTH.HitMark = function(material, pos, width, height, duration, fadeTime)
	table.insert(hitmarks, {
		material = material,
		pos = pos,
		width = width,
		height = height,
		_start = CurTime(),
		_end = CurTime() + duration,
		fadeTime = fadeTime
	})
end

hook.Add( "HUDPaint", "NTH-HitMark-Draw", function()
	local now = CurTime()
	cam.Start3D( EyePos(), EyeAngles() )
	for _,hm in pairs(hitmarks) do
		if now > hm._end then
			table.RemoveByValue(hitmarks, hm)
			continue
		end

		local alpha = 255
		if now > hm._end - hm.fadeTime then
			alpha = 255 - (((now - (hm._end - hm.fadeTime)) / hm.fadeTime) * 255)
		end

		render.SetMaterial(hm.material)
		render.DrawSprite(hm.pos, hm.width, hm.height, Color(255,255,255,alpha))
	end
	cam.End3D()
end)

