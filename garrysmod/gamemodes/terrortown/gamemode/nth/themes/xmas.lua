
if SERVER then
    -- add some resources here...
    NTH.AddFiles({
        "materials/nth/themes/xmas/icon_health.vmt",
    
        "materials/models/cloud/xmastree/bauble.vmt",
        "materials/models/cloud/xmastree/bluecracker.vmt",
        "materials/models/cloud/xmastree/goldcracker.vmt",
        "materials/models/cloud/xmastree/greencracker.vmt",
        "materials/models/cloud/xmastree/leaf.vmt",
        "materials/models/cloud/xmastree/leaf2.vmt",
        "materials/models/cloud/xmastree/lights.vmt",
        "materials/models/cloud/xmastree/redcracker.vmt",
        "materials/models/cloud/xmastree/star.vmt",
        "materials/models/cloud/xmastree/tinsel.vmt",
        "materials/models/cloud/xmastree/tinsel2.vmt",
        "materials/models/cloud/xmastree/tinsels.vmt",
        "materials/models/cloud/xmastree/tinsel3.vtf",

        "materials/models/cloud/santahat/kn_santahat.vmt",

        "materials/katharsmodels/present/type-1/present_one_all.vmt",
        "materials/katharsmodels/present/type-1/present_three_all.vmt",
        "materials/katharsmodels/present/type-1/present_five_all.vmt",
        
        "models/cloud/kn_xmastree.mdl",
        "models/cloud/kn_santahat.mdl",

        "models/katharsmodels/present/type-1/big/present.mdl",
        "models/katharsmodels/present/type-1/normal/present.mdl",
        "models/katharsmodels/present/type-1/normal/present2.mdl",
        "models/katharsmodels/present/type-1/normal/present3.mdl",
        
        "sound/nth/themes/xmas/joytotheworld.mp3",
        "sound/nth/themes/xmas/xtree.mp3",
    })
end

local mdlPresentType1Big1path = "models/katharsmodels/present/type-1/big/present.mdl"
local mdlPresentType1Big1 = Model(mdlPresentType1Big1path)

-- let's fuck around with the health station
hook.Add("InitPostEntity", "NTH-Xmas-InitPostEntity", function(ent)
    local hsWep = weapons.GetStored("weapon_ttt_health_station")
    hsWep.WorldModel = mdlPresentType1Big1path
    hsWep.Icon = "nth/themes/xmas/icon_health"

    local hsEnt = scripted_ents.GetStored("ttt_health_station").t
    hsEnt.Model = mdlPresentType1Big1

    local hsInit = hsEnt.Initialize
    function hsEnt:Initialize()
        self:SetModel(self.Model)
        hsInit(self)
    end
end)

if SERVER then

    local mdlTree = Model("models/cloud/kn_xmastree.mdl")
    
    local smallPresents = {
        Model("models/katharsmodels/present/type-1/normal/present.mdl"),
        Model("models/katharsmodels/present/type-1/normal/present2.mdl"),
        Model("models/katharsmodels/present/type-1/normal/present3.mdl")
    }
    
    local treePositions = {
        de_dolls = {
            {95,940,112},
            {656,-240,137},
            {-635,205,-276},
            {-773,-904,-704},
            {736,935,-496}
        },
        cs_rat_cuisine_b1 = {
            {-2656,-145,848},
            {-1343,1823,896},
            {73,431,1794}
        },
        ttt_67thway_v3 = {
            {-46,944,76}, -- in the road central reservation (T room side)
            {-46,-62,76}, -- in the road central reservation (farm side)
            {-1082,442,-447} -- in traitor room
        },
        ttt_67thway_v4 = {
            {-46,944,76}, -- in the road central reservation (T room side)
            {-46,-62,76}, -- in the road central reservation (farm side)
            {-848,464,-447} -- outisde traitor tester room
        },
        ttt_airbus_b3 = {
            {6,254,192} -- airbus lobby
        },
        ttt_bank_b3 = {
            {828,760,-256}, -- lobby
            {663,760,-64}, -- boss office
            {-586,874,-690} -- vault
        },
        ttt_borders = {
            {-2157,394,304}, -- main building
            {-7269,-4284,520} -- tree sign underground
        },
        ttt_canyon_a4 = {
            {1105,-12,1152}, -- cave
            {-1546,1911,1536}, -- tallest roof
            {-3930,-440,704}
        },
        ttt_chaser_v2 = {
            {-991,49,104}, -- ammo room
            {-490,1233,-144} -- canteen
        },
        ttt_christmas_pool_v1a = {
            {0,145,1782} -- lobby
        },
        ttt_clue = {
            {144,325,0},
            {705,-681,0}
        },
        ttt_community_pool = {
            {0,371,68} -- lobby
        },
        ttt_concentration_b2 = {
            {-871,-1172,35} -- showers
        },
        ttt_cruise = {
            {-315,-708,192}, -- bar
            {-906,-298,24} -- lobby
        },
        ttt_crummycradle_a4 = {
            {1548,-1599,1885}, -- bar
            {943,326,1885} -- central building
        },
        ttt_eek_v6 = {
            {930,-23,1464},
            {-1133,532,1432},
            {179,-467,1464},
            {-364,512,1938}
        },
        ttt_ferrostruct = {
            {-663,-1571,-64},
            {1248,-1912,-344},
            {-1693,-521,108}
        },
        ttt_floodlights = {
            {-1236,208,512},
            {712,-52,128},
            {-570,1860,128}
        },
        ttt_lordcharles_mansion_v3 = {
            {-95,8,64},
            {411,550,64},
            {431,204,64},
            {-108,230,200}
        },
        ttt_lost_temple_v2 = {
            {-3,-312,-1412},
            {3404,-1558,-1444}
        },
        ttt_main_street_b3a = {
            {881,268,76},
            {1131,-26,440},
            {-1720,-532,68},
            {818,-1836,712}
        },
        ttt_mc_skyislands = {
            {404,-1975,640},
            {2900,-497,480},
            {636,27,160}
        },
        ttt_minecraft_b5 = {
            {-608,-314,-1248},
            {-1911,712,992}
        },
        ttt_plaza_b6 = {
            {1059,892,64},
            {-1377,-919,64}
        },
        ttt_rapture = {
            {-4707,-660,16}
        },
        ttt_ratistry = {
            {-120,133,64},
            {-311,-909,256}
        },
        ttt_richland = {
            {460,283,16},
            {-982,-74,176},
            {146,1825,-64}
        },
        ttt_rooftops_a2 = {
            {799,-1184,1032},
            {1286,2427,768},
            {605,-37,64},
            {1079,392,64}
        },
        ttt_roy_the_ship = {
            {-2490,174,525},
            {-2695,2237,824},
            {-2184,2092,960}
        },
        ttt_scarisland_b1 = {
            {1012,1603,-380},
            {-175,420,-436},
            {2803,1662,-934}
        },
        ttt_schooldayv2 = {
            {-849,847,16},
            {709,301,180},
            {-44,-51,-325}
        },
        ["ttt_skytower_b1-1"] = {
            {258,-257,-584}
        },
        ttt_slender_v2 = {
            {1208,2265,64}, -- lightsout room
            {-2607,224,64} -- bathroom
        },
        ttt_stadium = {
            {389,254,192}, -- lobby
            {-2236,1375,192}, -- snack central
            {1047,2479,192} -- fan zone
        },
        ttt_summermansion_b2 = {
            {-1300,-448,48},
            {-2685,-2496,48},
            {-1018,-3008,18}
        },
        ttt_terrorception = {
            {408,906,0},
            {-170,-2359,0},
            {309,310,256}
        },
        ttt_terrortrainb2 = {
            {-326,552,74},
            {-245,3187,-49}
        },
        ttt_thepit = {
            {-5,-3,384},
            {-324,1222,512},
            {-434,-182,1},
            {-677,-259,1}
        },
        ttt_urban_ruins_v1 = {
            {417,-420,389},
            {-627,-1737,521}
        },
        ttt_whitehouse_b2 = {
            {2626,-841,64},
            {1960,-174,64},
            {758,-94,64},
            {339,-889,-447},
            {-107,-838,64}
        },
        
        ttt_aircraft_v1b = {
            {464,1438,384},
            {140,-397,0},
            {0,-2224,72}
        },
        ttt_amsterville = {
            {815,2449,128},
            {2880,450,-71},
            {3352,2685,-64}
        },
        ttt_bb_canalwarehousev2_r3 = {
            {712,-2188,0},
            {652,832,0},
            {-1960,-349,0},
            {-2948,-3584,256}
        },
        ttt_bb_outpost57_b5 = {
            {1986,193,1056},
            {-128,-2668,0},
            {2695,3991,60}
        },
        ttt_bb_suburbia_b3 = {
            {-1001,-1592,88},
            {995,-1412,88},
            {212,1754,88},
            {-2114,146,86}
        },
        ttt_bb_teenroom_b2 = {
            {721,929,192},
            {-358,-690,64},
            {1316,-876,1320}
        },
        ttt_bunker = {
            {-1809,-1802,48},
            {-2541,-2151,-1544},
            {1787,-549,-1056}
        },
        ttt_camel_v1 = {
            {-315,-159,136},
            {-360,1142,160},
            {-437,-618,520}
        },
        ttt_casino_b2 = {
            {900,693,-478},
            {934,1718,-270},
            {13,1073,-398},
            {-477,1267,-414}
        },
        ttt_christmastown = {
            {771,-1951,-115},
            {-127,-2708,-126},
            {-769,-2162,-126},
            {-1739,-644,8},
            {-363,-1546,8}
        },
        ttt_cluedo_b5 = {
            {-3,1214,44},
            {-506,-443,64},
            {209,-620,-124}
        },
        ttt_community_bowling_v5a = {
            {-1939,-524,44},
            {1078,-794,44},
            {1602,227,68},
            {697,2109,104}
        },
        ttt_cyberia_a3 = {
            {126,796,88},
            {660,892,96},
            {751,905,264}
        },
        ttt_district_a4 = {
            {705,1407,80},
            {-586,185,80},
            {-445,1552,-408}
        },
        ttt_enclave_b1 = {
            {1332,-2165,0},
            {1041,-1930,280}
        },
        ttt_fastfood_a6 = {
            {826,528,8},
            {-33,2192,8},
            {1153,2216,8}
        },
        ttt_forest_final = {
            {-658,-927,16},
            {-566,3067,0}
        },
        ttt_forgotten_forge = {
            {1346,-262,1},
            {-276,948,1}
        },
        ttt_foundation_a1 = {
            {1018,-1745,392},
            {674,-401,264}
        },
        ttt_lunar_base_v2a = {
            {-30,693,141},
            {2470,704,141},
            {1281,2959,95}
        },
        ttt_mars_colony_a1 = {
            {-862,-111,0},
            {-1514,1001,0}
        },
        ttt_metropolis = {
            {1374,-1006,1280},
            {2495,711,1408},
            {1488,192,1280}
        },
        ttt_minecraftcity_v4 = {
            {-339,-453,32},
            {-5,-1273,480},
            {92,559,320}
        },

        ttt_mw2_rust = {
            {976,-968,-6},
            {795,164,-26},
            {694,880,-26},
            {-273,338,-26},
            {-1022,-62,-24},
            {-53,-470,104},
            {-277,35,212},
            {-708,-1094,-20},
            {143,-1053,-18},
            {391,-262,-20},
            {-28,327,204},
            {-589,867,-26},
            {-628,-13,202}
        },

        ttt_glacier = {
            {608,212,1},
            {-1175,732,0}
        },
        ttt_horizon_v1 = {
            {-1265,64,640},
            {687,61,64},
            {-110,293,224}
        },
        ttt_skyscraper = {
            {626,330,464},
            {-220,-377,272},
            {975,-96,160}
        },
        ttt_equilibre = {
            {47,-1148,-22},
            {280,538,199},
            {-3347,558,-121},
            {-695,959,-28}
        }
    }

    local function placePresent(position)
        local entP = ents.Create("prop_physics") 
        local ang = Vector(0,0,1):Angle();
        ang.pitch = ang.pitch + 90;
        ang:RotateAroundAxis(ang:Up(), math.random(0,360))
        entP:SetAngles(ang)
        entP:SetModel(smallPresents[math.random(1,#smallPresents)])
        entP:SetPos(position)
        entP:Spawn()
        entP:GetPhysicsObject():SetMass(7)
    end
    
    local function placeTree(pos)
        local entT = ents.Create("prop_dynamic") 
        local ang = Vector(0,0,1):Angle();
        ang.pitch = ang.pitch + 90;
        ang:RotateAroundAxis(ang:Up(), math.random(0,360))
        entT:SetAngles(ang)
        entT:SetModel(mdlTree)
        pos.z = pos.z + 4
        entT:SetPos(pos)
        entT:Spawn()

        pos.z = pos.z + 100
        local entL = ents.Create("light_dynamic")
        entL:SetPos(pos)
        entL:SetKeyValue("distance", "300")
        entL:SetKeyValue("brightness", "8")
        entL:SetColor(Color(4,4,0))
        entL:Spawn()
        
        pos.z = pos.z - 40
        local entB = ents.Create("ttt_traitor_button")
        entB:SetPos(pos)
        entB:SetKeyValue("wait", "15")
        entB:SetKeyValue("description", "Bring JOY to the world")
        --entB:SetKeyValue("RemoveOnPress", "1")
        --entB:SetKeyValue("OnPressed", "BringJoy")
        function entB:OnPressed(ply)
            local pos = self:GetPos()
            placePresent(Vector(pos.x + 35, pos.y, pos.z))
            placePresent(Vector(pos.x, pos.y + 35, pos.z))
            placePresent(Vector(pos.x - 17, pos.y - 17, pos.z))
            placePresent(Vector(pos.x - 35, pos.y, pos.z))
            placePresent(Vector(pos.x, pos.y - 35, pos.z))
            placePresent(Vector(pos.x + 17, pos.y + 17, pos.z))
            
            pos.z = pos.z - 20
            
            local effect = EffectData()
            effect:SetOrigin(pos)
            util.Effect("Explosion", effect)
            
            util.BlastDamage(entT, ply, pos, 550, 100)
            entT:EmitSound("nth/themes/xmas/xtree.mp3", 500, 100)
        end
        entB:Spawn()
        
        return entT
    end
    
    -- add trees to some maps
    local treesPlaced = {}
    hook.Add("TTTPrepareRound", "NTH-Xmas-PrepRound", function()
        treesPlaced = {}
        local trees = treePositions[game.GetMap()]
        if not trees then return end
    
        for t=1,#trees do
            treesPlaced[placeTree(Vector(unpack(trees[t])))] = true
        end
    end)
    
    -- if someone dies to the christmas tree and the round ends - play joy to the world
    hook.Add("DoPlayerDeath", "NTH-Xmas-PlayerDeath", function(ply, attacker, dmginfo)
        local inflictor = dmginfo:GetInflictor()
        if not inflictor or not treesPlaced[inflictor] then return end
        NTH.Round.MusicOverride("nth/themes/xmas/joytotheworld.mp3")
    end)

    local function SetXmasLanguage()
        umsg.Start("nth_theme_xmas_lang")
        umsg.End()
    end
    
    hook.Add("PlayerSpawn", "NTH-Xmas-SetLanguageOnSpawn", SetXmasLanguage)
else -- CLIENT
    util.PrecacheSound("nth/themes/xmas/joytotheworld.mp3")

    usermessage.Hook("nth_theme_xmas_lang", function()
        --print("Setting lang to xmas")
        NTH.DefaultServerLanguage = "xmas"
        LANG.SetActiveLanguage("xmas")
    end)

end
