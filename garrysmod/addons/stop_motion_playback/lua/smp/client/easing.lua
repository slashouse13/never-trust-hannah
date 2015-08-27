---
-- Lerp methods
---

function SMP.LerpLinear(s, e, p)

	return Lerp(p, s, e);

end

function SMP.LerpLinearVector(s, e, p)

	return LerpVector(p, s, e);

end

function SMP.LerpLinearAngle(s, e, p)

	return LerpAngle(p, s, e);

end