if SERVER then
   AddCSLuaFile( "shared.lua" );
   resource.AddFile("sound/siege/jihad.wav");
   resource.AddFile("sound/siege/big_explosion.wav");
end

if CLIENT then
   SWEP.PrintName                       = "Jihad"
   SWEP.Slot                            = 7

   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Jihad Bomb",
      desc  = "Left click goes boom!"
   };

   resource.AddFile("vgui/ttt/icon_c4")
   SWEP.Icon = "vgui/ttt/icon_c4"
end

SWEP.Base = "weapon_tttbase"
//SWEP.HoldType = "slam"
SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = { ROLE_TRAITOR }

SWEP.Author			= "Stingwraith"
SWEP.Contact		= "stingwraith123@yahoo.com"
SWEP.Purpose		= "Sacrifice yourself for Allah."
SWEP.Instructions	= "Left Click to make yourself EXPLODE. Right click to taunt."
SWEP.DrawCrosshair		= false

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true		// Spawnable in singleplayer or by server admins

resource.AddFile("models/weapons/v_c4.mdl")
resource.AddFile("models/weapons/w_c4.mdl")
SWEP.ViewModel			= "models/weapons/v_jb.mdl"
SWEP.WorldModel			= "models/weapons/w_jb.mdl"

SWEP.ViewModelFlip      = false

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Primary.Delay			= 5

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end   

function SWEP:Initialize()
    util.PrecacheSound("siege/big_explosion.wav")
    util.PrecacheSound("siege/jihad.wav")
end


/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + 3)
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Owner:GetPos() )
		effectdata:SetNormal( self.Owner:GetPos() )
		effectdata:SetMagnitude( 8 )
		effectdata:SetScale( 1 )
		effectdata:SetRadius( 16 )
	util.Effect( "Sparks", effectdata )
	
	self.BaseClass.ShootEffects( self )
	
	
	-- The rest is only done on the server
	if (SERVER) then
		timer.Simple(2, function()
            if IsValid(self) then
                self:Asplode()
            end
        end)
		self.Owner:EmitSound( "siege/jihad.wav" )
	end

end

-- The asplode function
function SWEP:Asplode()
    -- if nobody is holding the bomb, it won't blow up
    if not self.Owner or not IsValid(self.Owner) then return end
    -- Make an explosion at your position
	local ent = ents.Create("env_explosion")
    ent:SetPos(self.Owner:GetPos())
    ent:SetOwner(self.Owner)
    ent:Spawn()
    ent:SetKeyValue("iMagnitude", "250")
    ent:Fire("Explode", 0, 0)
    ent:EmitSound("siege/big_explosion.wav", 500, 100)
    self.Owner:Kill()
    -- no more salvaging exploded jihads
    self:Remove()
end


/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()	
	
	self.Weapon:SetNextSecondaryFire( CurTime() + 1 )
	
	local TauntSound = Sound( "vo/npc/male01/overhere01.wav" )

	self.Weapon:EmitSound( TauntSound )
	
	// The rest is only done on the server
	if (!SERVER) then return end
	
	self.Weapon:EmitSound( TauntSound )


end
