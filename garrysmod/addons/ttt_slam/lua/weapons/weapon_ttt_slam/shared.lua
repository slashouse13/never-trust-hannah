if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName = "S.L.A.M."
   SWEP.Slot = 7
   SWEP.Icon = "vgui/ttt/icon_slam"
end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "slam"

SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = .5
SWEP.Primary.Automatic = false
SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.FiresUnderwater = false

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 64
SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel	= "models/weapons/w_slam.mdl"

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP2
   
-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = false

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { nil }

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Equipment menu information is only needed on the client
if CLIENT then
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[
A mine, with a red laser, placeable on walls.
		
When the red laser is crossed by innocents or 
detectives, the mine explodes. Can be shot and
destroyed by everyone.]]
   };
end

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
    return true
end 
     
function SWEP:OnRemove()
    if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
    end
end
     
function SWEP:PrimaryAttack()
	self:TripMineStick()
	self.Weapon:EmitSound( Sound( "Weapon_SLAM.SatchelThrow" ) )
	self.Weapon:SetNextPrimaryFire(CurTime()+(self.Primary.Delay))
end
     
function SWEP:TripMineStick()
 if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end
 
 
      local ignore = {ply, self.Weapon}
      local spos = ply:GetShootPos()
      local epos = spos + ply:GetAimVector() * 80
      local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
 
      if tr.HitWorld then
         local mine = ents.Create("npc_tripmine")
         if IsValid(mine) then
 
            local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, mine)
 
            if tr_ent.HitWorld then
 
               local ang = tr_ent.HitNormal:Angle()
               ang.p = ang.p + 90
 
               mine:SetPos(tr_ent.HitPos + (tr_ent.HitNormal * 3))
               mine:SetAngles(ang)
               mine:SetOwner(ply)
               mine:Spawn()
 
                                mine.fingerprints = self.fingerprints
								
                                self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH )
                               
                                local holdup = self.Owner:GetViewModel():SequenceDuration()
                               
                                timer.Simple(holdup,
                                function()
                                if SERVER then
                                        self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH2 )
                                end    
                                end)
                                       
                                timer.Simple(holdup + .1,
                                function()
                                        if SERVER then
                                                if self.Owner == nil then return end
                                                if self.Weapon:Clip1() == 0 && self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
												self:Remove()
                                                else
                                                self:Deploy()
                                                end
                                        end
                                end)                       

                                self.Planted = true
								
	self:TakePrimaryAmmo( 1 )
                               
                        end
            end
         end
      end
end

function SWEP:SecondaryAttack()
    return false
end  

function SWEP:Reload()
   return false
end