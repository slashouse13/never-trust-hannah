
if SERVER then
   resource.AddFile("models/weapons/c_bigtoe.mdl")
   resource.AddFile("materials/models/weapons/bigtoe/bigtoetexture.vmt")
   resource.AddFile("materials/models/weapons/bigtoe/toen.vtf")
   resource.AddFile("materials/models/weapons/bigtoe/toed.vtf")
   resource.AddFile("materials/vgui/ttt/icon_weapon_nth_bigtoe.vmt")
   resource.AddFile("materials/vgui/ttt/icon_weapon_nth_bigtoe.vtf")

   local customSkins = file.Find("materials/models/weapons/bigtoe/*.vmt", "GAME")
   for _,s in pairs(customSkins) do
      resource.AddFile("materials/models/weapons/bigtoe/" .. s)
   end
end

local customToes = {
   ["76561197961558956"] = {mat = "gareth",     name = "Gareth's Golden Toe"  }, -- Gareth
   ["76561198053757224"] = {mat = "tarik",      name = "Tarik's Big Toe"      }, -- Tarik
   ["76561198138301137"] = {mat = "grace",      name = "Grace's Big Toe"      }, -- Gracie
   ["76561198078453986"] = {mat = "puppycat2",  name = "Puppycat's Big Toe"   }, -- Puppycat
   ["76561198115139525"] = {mat = "helen",      name = "Helen's Big Toe"      }, -- Helen
   ["76561198036674533"] = {mat = "jcp",        name = "Artist's Big Toe"     }, -- John Clese
   ["76561198155643390"] = {mat = "jcp",        name = "Artist's Big Toe"     }, -- SlashDotPaw
   ["76561198059069063"] = {mat = "dan",        name = "Dan's Big Toe"        }, -- Dan The Spooder Owl
   ["76561198072995827"] = {mat = "hammade",    name = "Hammade's Big Toe"    }, -- Hammade
}


AddCSLuaFile()

if CLIENT then
   SWEP.PrintName			= "A Big Toe"

   SWEP.Slot				= 6

   SWEP.Icon = "vgui/ttt/icon_weapon_nth_bigtoe"
   SWEP.ViewModelFOV = 70

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Not to be confused with a leg of ham."
   };
end

SWEP.UseHands        = true
SWEP.HoldType = "melee2"
-- SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/c_bigtoe.mdl"
SWEP.WorldModel = "models/weapons/c_bigtoe.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {}

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.Base				= "weapon_tttbase"
SWEP.Weight			= 1
SWEP.DrawCrosshair		= false
SWEP.Primary.Damage = 30
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Delay = 0.44
SWEP.Primary.Ammo		= "none"
SWEP.Primary.MaxReach = 100
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo		= "none"
SWEP.Secondary.Delay = 1
SWEP.Secondary.MaxReach = 100

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true -- only buyable once

SWEP.NoSights = true
SWEP.IsSilent = true

SWEP.AutoSpawnable = false

SWEP.AllowDrop = true

local sound_single = Sound("Weapon_Crowbar.Single")

function SWEP:SetupDataTables()
   self:NetworkVar("String", 0, "CustomName")
end

function SWEP:WasBought(ply)
   local id = ply:SteamID64()

   if not customToes[id] then return end
   local c = customToes[id];

   self:SetMaterial("models/weapons/bigtoe/" .. c.mat)
   self:SetCustomName(c.name)
end

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
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

-- function SWEP:SecondaryAttack()
--    self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
--    self.Weapon:SetNextSecondaryFire( CurTime() + 0.1 )

--    if self.Owner.LagCompensation then
--       self.Owner:LagCompensation(true)
--    end

--    local tr = self.Owner:GetEyeTrace(MASK_SHOT)

--    if tr.Hit and IsValid(tr.Entity) and tr.Entity:IsPlayer() and (self.Owner:EyePos() - tr.HitPos):Length() < self.Secondary.MaxReach then
--       local ply = tr.Entity

--       if SERVER and (not ply:IsFrozen()) then
--          local pushvel = tr.Normal * GetConVar("ttt_crowbar_pushforce"):GetFloat()

--          pushvel = pushvel / 2
--     	 pushvel.z = 300 -- always launch

--          ply:SetVelocity(ply:GetVelocity() + pushvel)
--          self.Owner:SetAnimation( PLAYER_ATTACK1 )

--          ply.was_pushed = {att=self.Owner, t=CurTime()} --, infl=self}
--       end

--       self.Weapon:EmitSound(sound_single)      
--       self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )

--       self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
--    end
   
--    if self.Owner.LagCompensation then
--       self.Owner:LagCompensation(false)
--    end
-- end
