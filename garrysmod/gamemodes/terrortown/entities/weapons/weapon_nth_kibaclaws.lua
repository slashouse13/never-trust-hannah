
AddCSLuaFile()

if CLIENT then
   SWEP.PrintName			= "Claws"

   SWEP.Slot				= 0

   SWEP.Icon = "vgui/ttt/icon_cbar"   
   SWEP.ViewModelFOV = 90
end


SWEP.UseHands			= false
SWEP.HoldType			= "fist"
SWEP.Base				= "weapon_tttbase"
SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/v_knife_t.mdl"
SWEP.Weight			= 5
SWEP.DrawCrosshair		= false
SWEP.ViewModelFlip		= false
SWEP.Primary.Damage = 20
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay = 0.15
SWEP.Primary.Ammo		= "none"
SWEP.Primary.MaxReach = 180
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 0.3
SWEP.Secondary.MaxReach = 250

SWEP.Kind = WEAPON_MELEE

SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.AutoSpawnable = false

SWEP.AllowDrop = false

local sound_single = Sound("Weapon_Crowbar.Single")

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
end

local matScratch = nil
if SERVER then
	resource.AddFile("materials/nth/misc/scratch.png")
else
	matScratch = Material("nth/misc/scratch.png", "unlitgeneric")
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not IsValid(self.Owner) then return end

   if self.Owner.LagCompensation then -- for some reason not always true
      self.Owner:LagCompensation(true)
   end

   local spos = self.Owner:GetShootPos()
   local sdest = spos + (self.Owner:GetAimVector() * self.Primary.MaxReach)

   local tr_main = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner, mask=MASK_SHOT_HULL})
   local hitEnt = tr_main.Entity

   self.Weapon:EmitSound(sound_single)

   if IsValid(hitEnt) or tr_main.HitWorld then
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetSurfaceProp(tr_main.SurfaceProps)
         edata:SetHitBox(tr_main.HitBox)
         --edata:SetDamageType(DMG_CLUB)
         edata:SetEntity(hitEnt)

         if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
     		if NTH and NTH.HitMark then
     			local size = math.Rand(16,32)
     			NTH.HitMark(matScratch, tr_main.HitPos, size, size, 0.8, 1.3)
     		end
            util.Effect("BloodImpact", edata)

            -- does not work on players rah
            --util.Decal("Blood", tr_main.HitPos + tr_main.HitNormal, tr_main.HitPos - tr_main.HitNormal)

            -- do a bullet just to make blood decals work sanely
            -- need to disable lagcomp because firebullets does its own
            self.Owner:LagCompensation(false)
            self.Owner:FireBullets({Num=1, Src=spos, Dir=self.Owner:GetAimVector(), Spread=Vector(0,0,0), Tracer=0, Force=1, Damage=0})
         else
            util.Effect("Impact", edata)
         end
      end
   else
      self.Weapon:SendWeaponAnim( ACT_VM_MISSCENTER )
   end


   if CLIENT then
      -- used to be some shit here
   else -- SERVER

      -- Do another trace that sees nodraw stuff like func_button
      local tr_all = nil
      tr_all = util.TraceLine({start=spos, endpos=sdest, filter=self.Owner})
      
      self.Owner:SetAnimation( PLAYER_ATTACK1 )

      if hitEnt and hitEnt:IsValid() then
         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self.Owner)
         dmg:SetInflictor(self.Weapon)
         dmg:SetDamageForce(self.Owner:GetAimVector() * 1500)
         dmg:SetDamagePosition(self.Owner:GetPos())
         dmg:SetDamageType(DMG_CLUB)

         hitEnt:DispatchTraceAttack(dmg, spos + (self.Owner:GetAimVector() * 3), sdest)
      end
   end

   if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
   end
end

function SWEP:SecondaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )

   if self.Owner.LagCompensation then
      self.Owner:LagCompensation(true)
   end

   local tr = self.Owner:GetEyeTrace(MASK_SHOT)

   if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (self.Owner:EyePos() - tr.HitPos):Length() < self.Secondary.MaxReach then
      local ply = tr.Entity

      if SERVER and (not ply:IsFrozen()) then
         local pushvel = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()

         pushvel = pushvel / 2
    	 pushvel.z = 300 -- always launch

         ply:SetVelocity(ply:GetVelocity() + pushvel)
         self.Owner:SetAnimation( PLAYER_ATTACK1 )

         ply.was_pushed = {att=self.Owner, t=CurTime()} --, infl=self}
      end

      self.Weapon:EmitSound(sound_single)      
      self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

      self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   end
   
   if self.Owner.LagCompensation then
      self.Owner:LagCompensation(false)
   end
end

function SWEP:OnDrop()
	self:Remove()
end


-- SCK code
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false

SWEP.ViewModelBoneMods = {
	["v_weapon.Left_Index02"] = { scale = Vector(1, 1, 1), pos = Vector(-3.146, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Pinky02"] = { scale = Vector(1, 1, 1), pos = Vector(-1.78, -0.09, -0.03), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Middle02"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-1.298, -0.672, -0.033), angle = Angle(0, 0, 0) },
	["v_weapon.knife_Parent"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Index02"] = { scale = Vector(1, 1, 1), pos = Vector(-2.139, -1.851, 0.144), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Arm"] = { scale = Vector(1, 1, 1), pos = Vector(-1.3, -0.932, -0.55), angle = Angle(44.362, 18.516, -20.514) },
	["v_weapon.Right_Index01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-0.195, -0.238, 0.03), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Pinky01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.L_wrist_helper"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-24.477, 1.026, -25.458) },
	["v_weapon.Right_Ring01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Thumb01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, -0.176, 0), angle = Angle(12.442, 30.386, 4.494) },
	["v_weapon.R_wrist_helper"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(8.597, 5.893, 0) },
	["v_weapon.Right_Thumb02"] = { scale = Vector(1, 1, 1), pos = Vector(-1.708, -0.053, -0.029), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Pinky02"] = { scale = Vector(1, 1, 1), pos = Vector(-1.364, -0.914, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Middle01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Arm"] = { scale = Vector(1, 1, 1), pos = Vector(-0.02, -0, 0), angle = Angle(12.862, 7.907, -14.551) },
	["v_weapon.Left_Index01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Pinky01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Middle02"] = { scale = Vector(1, 1, 1), pos = Vector(-1.599, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Middle01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Ring02"] = { scale = Vector(0.554, 0.554, 0.554), pos = Vector(-1.351, -1.007, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(10.137, -32.317, -29.859) },
	["v_weapon.Left_Ring02"] = { scale = Vector(1, 1, 1), pos = Vector(-1.959, -0.205, 0.09), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Thumb03"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(-1.441, -0.12, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Ring01"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["v_weapon.Right_Hand"] = { scale = Vector(0.85, 0.85, 0.85), pos = Vector(0, 0, 0), angle = Angle(30.663, 33.951, 8.854) },
	["v_weapon.Left_Thumb_02"] = { scale = Vector(0.166, 0.166, 0.166), pos = Vector(-0.51, 0, 0.061), angle = Angle(0, 0, 0) },
	["v_weapon.Left_Thumb01"] = { scale = Vector(0.596, 0.596, 0.596), pos = Vector(-0.035, -0.149, 0.356), angle = Angle(44.901, -22.594, 0) }
}

SWEP.VElements = {
	["r.index.hook+"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Right_Hand", rel = "", pos = Vector(0.398, 0.025, -0.445), angle = Angle(0.986, -109.152, -87.383), size = Vector(0.082, 0.082, 0.082), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.index.hook++++++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Left_Hand", rel = "", pos = Vector(1.718, 0.563, -0.796), angle = Angle(11.204, -82.206, -74.581), size = Vector(0.034, 0.034, 0.034), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.thumb.hook++++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Left_Middle01", rel = "element_name", pos = Vector(-1.227, -0.945, -0.076), angle = Angle(-70.323, 163.595, 0.955), size = Vector(0.087, 0.087, 0.087), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Right_Middle01", rel = "", pos = Vector(-0.253, 3.292, -0.477), angle = Angle(94.627, 73.587, 16.163), size = Vector(0.072, 0.072, 0.072), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.index.hook+++++++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Left_Hand", rel = "", pos = Vector(1.894, -0.529, -0.644), angle = Angle(11.204, -82.206, -74.581), size = Vector(0.034, 0.034, 0.034), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.index.hook++++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Left_Hand", rel = "", pos = Vector(1.544, -0.983, -0.803), angle = Angle(11.204, -82.206, -74.581), size = Vector(0.034, 0.034, 0.034), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.thumb.hook+++++++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Left_Middle01", rel = "element_name", pos = Vector(-1.315, -1.274, 1.286), angle = Angle(-93.913, 150.983, 0.736), size = Vector(0.072, 0.072, 0.072), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.index.hook"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Right_Hand", rel = "", pos = Vector(1.366, 0.806, -0.57), angle = Angle(0.986, -109.152, -87.383), size = Vector(0.028, 0.028, 0.028), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.index.hook++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Right_Hand", rel = "", pos = Vector(1.771, -0.223, -0.368), angle = Angle(0.986, -109.152, -87.383), size = Vector(0.028, 0.028, 0.028), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.thumb.hook+++++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Left_Middle01", rel = "element_name", pos = Vector(-2.458, -2.154, -0.322), angle = Angle(-78.488, 159.58, 5.195), size = Vector(0.063, 0.063, 0.063), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["element_name"] = { type = "Quad", bone = "v_weapon.Left_Hand", rel = "", pos = Vector(2.953, 0.013, 0.002), angle = Angle(-28.896, -1.497, -104.497), size = 0.01, draw_func = nil},
	["r.thumb.hook+++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Left_Middle01", rel = "element_name", pos = Vector(-1.142, -1.267, 0.971), angle = Angle(-80.547, 175.406, 13.85), size = Vector(0.082, 0.082, 0.082), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook++++++++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Left_Middle01", rel = "element_name", pos = Vector(-1.147, -1.191, 0.573), angle = Angle(-70.323, 163.595, 0.955), size = Vector(0.087, 0.087, 0.087), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook+++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Right_Middle01", rel = "", pos = Vector(0.07, 2.186, 1.133), angle = Angle(86.266, 65.617, 9.779), size = Vector(0.072, 0.072, 0.072), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook++"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Right_Middle01", rel = "", pos = Vector(-0.01, 1.945, 0.811), angle = Angle(85.902, 65.617, 7.568), size = Vector(0.078, 0.078, 0.078), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook+"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Right_Middle01", rel = "", pos = Vector(-0.01, 1.866, 0.252), angle = Angle(85.902, 65.617, 7.568), size = Vector(0.087, 0.087, 0.087), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.thumb.hook"] = { type = "Model", model = "models/props_junk/meathook001a.mdl", bone = "v_weapon.Right_Middle01", rel = "", pos = Vector(0.07, 1.94, -0.229), angle = Angle(85.902, 65.617, 7.568), size = Vector(0.087, 0.087, 0.087), color = Color(30, 30, 30, 255), surpresslightning = false, material = "models/balloon/balloon", skin = 0, bodygroup = {} },
	["r.index.hook+++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Right_Hand", rel = "", pos = Vector(1.771, 0.46, -0.346), angle = Angle(0.986, -109.152, -87.383), size = Vector(0.028, 0.028, 0.028), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} },
	["r.index.hook+++++"] = { type = "Model", model = "models/balloons/balloon_classicheart.mdl", bone = "v_weapon.Left_Hand", rel = "", pos = Vector(0.453, 0.173, -1.167), angle = Angle(0.085, -84.231, -73.25), size = Vector(0.082, 0.082, 0.082), color = Color(255, 214, 251, 255), surpresslightning = false, material = "models/barnacle/roots", skin = 0, bodygroup = {} }
}


