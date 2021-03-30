local botdebug = false -- for testing purposes only

util.AddNetworkString("ttt_death_panel")

local function getdeathcause(killinfo, attacker)
	local dmgtype = killinfo.type

	if not dmgtype then
		return
	end

	local band = bit.band
	local function is_dmg(x)
		return band(dmgtype, x) > 0
	end

	local cause
	local causer = killinfo.causer

	if killinfo.pushed2death then
		cause = 1
	elseif is_dmg(DMG_FALL) then
		cause = killinfo.damage > 40 and 2 or 3

		if not attacker:IsPlayer() then
			causer = nil
		end
	elseif is_dmg(DMG_BULLET) then
		cause = 4

		if causer == "player" then
			causer = nil
		end
	elseif is_dmg(DMG_DROWN) then
		cause = 5
	elseif is_dmg(DMG_BLAST) then
		cause = 6
	elseif is_dmg(DMG_BURN + DMG_DIRECT) then
		cause = 7
	elseif killinfo.weapon and killinfo.weapon.Projectile then
		cause = 8
	elseif is_dmg(DMG_CLUB) then
		cause = 9
	elseif is_dmg(DMG_SLASH) then
		cause = 10
	elseif is_dmg(DMG_SONIC) then
		cause = 11
	elseif is_dmg(DMG_PHYSGUN) then
		cause = 12
	elseif is_dmg(DMG_CRUSH) then
		cause = 13
	end

	return cause, causer
end

local function WriteUIntClamped(int, bits)
	net.WriteUInt(math.Clamp(isnumber(int) and int or 0, 0, 2 ^ bits - 1), bits)
end

local function playerdeath(victim, attacker, killinfo)
	local hitter = attacker
	local role = 0
	if IsValid(attacker) and attacker:IsPlayer() then
		role = (
			attacker.GetBaseRole
			and attacker:GetBaseRole()
			or attacker:GetRole()
		) + 1
	else
		attacker = Entity(0)
		hitter = killinfo.type
	end

	if victim == killinfo.inflictor and victim == attacker then
		victim.dp2_hits = nil
	end

	local hits, totaldmg
	local _hits = victim.dp2_hits and victim.dp2_hits[hitter]
	if _hits then
		victim.dp2_hits = nil

		hits = _hits[1]
		totaldmg = math.floor(_hits[2] + 0.5)
	end

	local cause, causer = getdeathcause(killinfo, attacker)

	net.Start("ttt_death_panel")
	WriteUIntClamped(
		role > 0 and attacker:EntIndex() - 1,
		math.ceil(math.log(game.MaxPlayers()) / math.log(2))
	)
	WriteUIntClamped(role, 2)

	WriteUIntClamped(hits, 8)
	WriteUIntClamped(totaldmg, 16)

	WriteUIntClamped(cause, 4)

	if cause == 4 then
		WriteUIntClamped(killinfo.cpart, 5)
	end

	if isstring(causer) then
		net.WriteBool(false)
		net.WriteString(causer)
	else
		net.WriteBool(true)
		WriteUIntClamped(causer, 8)
	end

	if role > 0 then
		WriteUIntClamped(attacker.dp2_killstreak, 8)
	end

	if botdebug and victim:IsBot() then
		return net.Broadcast()
	end

	return net.Send(victim)
end

hook.Add("PlayerDeath", "ttt_death_panel_PlayerDeath", function(victim, inflictor, attacker)
	if GetRoundState() ~= ROUND_ACTIVE then
		return
	end

	local prevks
	if IsValid(attacker)
		and attacker:IsPlayer()
		and attacker ~= victim
	then
		prevks = attacker.dp2_killstreak or 0

		attacker.dp2_killstreak = prevks + 1
	end

	local killinfo = {
		attacker = attacker,
		inflictor = inflictor,
	}

	victim.dp2_killinfo = killinfo

	timer.Simple(0, function() -- wait for PostEntityTakeDamage to be called
		if not killinfo then
			return -- ???
		end

		local attacker2 = killinfo.attacker

		if attacker ~= attacker2
			and IsValid(attacker2)
			and attacker2:IsPlayer()
			and attacker2 ~= victim
		then
			if IsValid(attacker) then
				attacker.dp2_killstreak = prevks
			end

			attacker2.dp2_killstreak = (attacker2.dp2_killstreak or 0) + 1
		end

		if not IsValid(victim) then
			return
		end

		victim.dp2_killinfo = nil

		return playerdeath(victim, attacker2, killinfo)
	end)
end)
local part2cpart = {
	function(pos, ang, hitpos, hitbox)
		local mins, maxs = hitbox[3], hitbox[4]

		local fwd, rgt, up = ang:Forward(), ang:Right(), ang:Up()

		fwd:Mul((mins[1] + maxs[1]) * 0.5)
		fwd:Sub(maxs[2] * rgt)
		fwd:Add((mins[3] + maxs[3]) * 0.5 * up)

		pos:Add(fwd)
		pos:Sub(hitpos)
		pos:Normalize()

		local dp = rgt:Dot(pos)

		if dp < 0 then
			up:Mul(math.abs(mins[3] - maxs[3]) * 0.5)
			up:Add(math.abs(mins[2] - maxs[2]) * rgt)
			up:Normalize()

			if dp < rgt:Dot(up) * -0.95 then
				return 2
			end
		end

		return 1
	end,
	3,
	function(pos, ang, hitpos)
		pos:Sub(hitpos)
		pos:Normalize()

		if ang:Right():Dot(pos) < 0 then
			return 8
		end

		return 7
	end,
	function(pos, ang, hitpos, hitbox)
		local mins, maxs = hitbox[3], hitbox[4]

		local fwd, rgt, up = ang:Forward(), ang:Right(), ang:Up()

		local vec = (mins[1] + maxs[1]) * 0.5 * fwd
		vec:Sub(mins[2] * rgt)
		vec:Add((mins[3] + maxs[3]) * 0.5 * up)

		pos:Add(vec)

		local diff = pos - hitpos
		diff:Normalize()

		local len, wid, hgt =
			math.abs(mins[1] - maxs[1]),
			math.abs(mins[2] - maxs[2]),
			math.abs(mins[3] - maxs[3])

		if up:Dot(diff) < 0 then
			local rad = wid / 5.2

			local line = wid * 0.35 - rad

			up:Mul(hgt * 0.5)
			rgt:Mul(-line)
			rgt:Add(up)

			hitpos:Sub(pos)

			local rgtup = rgt - up
			local hitup = hitpos - up
			local hitrgt = hitpos - rgt

			local distsq

			if hitup:Dot(rgtup) < 0.0001 then
				hitpos:Add(up)
				up:Mul(-1)

				distsq = up:Cross(hitpos):LengthSqr() / (hgt * hgt * 0.25)

				rad = rad * 1.15
			elseif hitrgt:Dot(rgtup) < 0 then
				distsq = rgtup:Cross(hitup):LengthSqr() / (line * line)
			else
				distsq = hitrgt:LengthSqr()
			end

			if distsq < (rad * rad) then
				return 5
			end
		else
			fwd:Mul(len * -0.5)
			up:Mul(hgt * 0.5)

			hitpos:Sub(pos)
			hitpos:Add(fwd)
			hitpos:Add(up)

			fwd:Mul(2)

			local distsq = fwd:Cross(hitpos):LengthSqr() / (len * len)

			if distsq < wid * wid * 0.3 then
				return 6
			end
		end

		return 4
	end,
	9,
	10,
	11,
	12,
	13,
	14,
	_hitgroups = {
		[HITGROUP_HEAD] = 1,
		[HITGROUP_CHEST] = 15,
		[HITGROUP_STOMACH] = 4,
		[HITGROUP_LEFTARM] = 16,
		[HITGROUP_RIGHTARM] = 16,
		[HITGROUP_LEFTLEG] = 17,
		[HITGROUP_RIGHTLEG] = 17,
	}
}

local causerignore, causeralias, mdl2causer
local function posttakedamagedeath(victim, attacker, dmginfo)
	local weapon = util.WeaponFromDamage(dmginfo)
	weapon = IsValid(weapon) and weapon
	local inflictor = dmginfo:GetInflictor()
	inflictor = IsValid(inflictor) and inflictor
	local causer

	local pushwep, pushed2death
	local push = victim.was_pushed
	if push
		and push.att == attacker
		and math.max(push.t or 0, push.hurt or 0) > CurTime() - 4
	then
		pushwep = push.wep
	end

	if not weapon then
		local igniteinfo = victim.dp2_igniteinfo

		if igniteinfo
			and attacker == igniteinfo.att
			and inflictor == igniteinfo.infl
			and dmginfo:IsDamageType(DMG_DIRECT)
		then
			weapon = IsValid(igniteinfo.wep) and igniteinfo.wep
		end
	end

	if weapon then
		causer = WepToEnum(weapon)

		if not (causer and EnumToWep(causer)) then
			causer = weapon:GetClass()
		end
	elseif inflictor and inflictor.ScoreName then
		causer = inflictor.ScoreName
	elseif inflictor or pushwep then
		if inflictor then
			causer = WepToEnum(inflictor)

			if not (causer and EnumToWep(causer)) then
				causer = inflictor:GetClass()

				causerignore = causerignore or {
					entityflame = true,
					env_beam = true,
					env_explosion = true,
					env_fire = true,
					env_physexplosion = true,
					env_physimpact = true,
					point_hurt = true,
					trigger = true,
					trigger_hurt = true,
					trigger_impact = true,
					trigger_vphysics_motion = true,
					ttt_flame = true,
				}

				if causerignore[causer] then
					causer = nil
				end
			end
		end

		if pushwep and not causer then
			causer = pushwep
			pushed2death = true
		end

		if not causer then
			goto done
		end

		if not causeralias then
			causeralias = {
				ttt_cse_proj = "vis_name",
				ttt_decoy = "decoy_name",
				ttt_physhammer = "weapon_ttt_phammer",

				func_physbox = "prop_physics",
				func_physbox_multiplayer = "prop_physics",
				func_pushable = "prop_physics",
				physics_prop = "prop_physics",
				prop_physics_multiplayer = "prop_physics",
				prop_physics_override = "prop_physics",
				prop_physics_respawnable = "prop_physics",
				prop_ragdoll = "prop_physics",
				simple_physics_prop = "prop_physics",

				_mdl_oildrum001_explosive = "_dp2_ebarrel",

				_mdl_bed = "_dp2_bed",
				_mdl_furniturebed001a = "_dp2_bedframe",
				_mdl_pot01a = "_dp2_ketpot",
				_mdl_pot02a = "_dp2_cookpot",
				_mdl_bananna = "_dp2_banana",
				_mdl_bananna_bunch = "_dp2_banana",
				_mdl_orange = "_dp2_orange",
				_mdl_axe = "_dp2_axe",
				_mdl_paper_towels = "_dp2_tpaper",
				_mdl_goldfish = "_dp2_golfdish",

				_mdl_tnt = "_dp2_tnt",
				_mdl_tnttimed = "_dp2_tnt",
				_mdl_amp = "_dp2_amp",

				_mdl_breenbust = "_dp2_bust",
				_mdl_breenclock = "_dp2_clock",
				_mdl_breenglobe = "_dp2_globe",

				_mdl_hgibs = "_dp2_skull",
				_mdl_hgibs_rib = "_dp2_rib",
				_mdl_hgibs_scapula = "_dp2_scapula",
				_mdl_hgibs_spine = "_dp2_spine",

				_mdl_bowling_ball = "_dp2_bowlb",
				_mdl_bowling_pin = "_dp2_bowlp",
			}

			local basegrenadefn = util.WeaponForClass("weapon_tttbasegrenade")
			basegrenadefn = basegrenadefn and basegrenadefn.GetGrenadeName

			local swep, grenadename
			local function getgrenadename()
				if swep.GetGrenadeName then
					grenadename = swep:GetGrenadeName()
				end
			end

			local function each(k, v)
				if not v then
					return
				end

				if v.GetGrenadeName
					and v.GetGrenadeName ~= basegrenadefn
				then
					swep = v
					ProtectedCall(getgrenadename)

					if isstring(grenadename) then
						causeralias[grenadename] = k
					end

					swep, grenadename = nil, nil
				end

				if not k then
					return
				end

				if isstring(v.AmmoType) then
					causeralias[k] = "ammo_" .. v.AmmoType:lower()
				end
			end

			for _, v in pairs(weapons.GetList()) do
				each(v.ClassName or v.Classname, v)
			end
			for k, v in pairs(scripted_ents.GetList()) do
				each(k, v.t)
			end

			if _G.DP2_CAUSERALIAS then
				for k, v in pairs(_G.DP2_CAUSERALIAS) do
					causeralias[k] = v
				end
			end
		end

		causer = causeralias[causer] or causer

		local mdl = causer == "prop_physics" and inflictor:GetModel()

		if not mdl then
			goto done
		end

		mdl = mdl:match("/([^/]+)%.mdl$") or mdl

		local alias = causeralias["_mdl_" .. mdl]

		if alias then
			causer = alias
			goto done
		end

		mdl2causer = mdl2causer or {
			oildrum = "_dp2_barrel",
			barrel = "_dp2_barrel",
			crate = "_dp2_crate",
			chair = "_dp2_chair",
			bench = "_dp2_bench",
			table = "_dp2_table",
			desk = "_dp2_desk",
			couch = "_dp2_couch",
			door = "_dp2_door",
			wheel = "_dp2_wheel",
			microwave = "_dp2_mwave",
			dryer = "_dp2_dryer",
			bottle = "_dp2_bottle",
			stool = "_dp2_stool",
			rock = "_dp2_rock",
			bucket = "_dp2_bucket",
			stove = "_dp2_stove",
			toilet = "_dp2_toilet",
			fridge = "_dp2_fridge",
			refrigerator = "_dp2_fridge",
			shelf = "_dp2_shelf",
			shelves = "_dp2_shelf",
			doll = "_dp2_doll",
			coffee_mug = "_dp2_mug",
			coffeemug = "_dp2_mug",
			computer = "_dp2_computer",
			monitor = "_dp2_monitor",
			keyboard = "_dp2_keyboard",
			console = "_dp2_console",
			file_cabinet = "_dp2_fcab",
			filecabinet = "_dp2_fcab",
			file_box = "_dp2_filebox",
			suitcase = "_dp2_scase",
			sofa = "_dp2_couch",
			radio = "_dp2_radio",
			bicycle = "_dp2_bicycle",
			trash_can = "_dp2_tcan",
			trashcan = "_dp2_tcan",
			turtle = "_dp2_turtle",
			vending_machine = "_dp2_vendmac",
			vendingmachine = "_dp2_vendmac",
			basket = "_dp2_basket",
			cinderblock = "_dp2_cblock",
			cynderblock = "_dp2_cblock",
			potted_plant = "_dp2_potplant",
			plant0 = "_dp2_potplant",
			claypot = "_dp2_pot",
			pottery = "_dp2_pot",
			paintcan = "_dp2_paintcan",
			pizza_box = "_dp2_pizzabox",
			fire_extinguisher = "_dp2_fexting",
			frame0 = "_dp2_pframe",
			car_battery = "_dp2_cbatt",
			canister = "_dp2_canister",
			drawer = "_dp2_drawer",
			dresser = "_dp2_dresser",
			gascan = "_dp2_gascan",
			counter = "_dp2_counter",
			pushcart = "_dp2_cart",
			laundry_cart = "_dp2_cart",
			barricade = "_dp2_barr",
			buoy = "_dp2_buoy",
			trafficcone = "_dp2_cone",
			tire = "_dp2_tire",
			hook = "_dp2_hook",
			cardboard_box = "_dp2_cbox",
			binder = "_dp2_binder",
			clipboard = "_dp2_cboard",
			newspaper = "_dp2_npaper",
			harpoon = "_dp2_harpoon",
			beam = "_dp2_beam",
			trashbin = "_dp2_tbin",
			dumpster = "_dp2_dumpster",
			pallet = "_dp2_pallet",
			kennel = "_dp2_kennel",
			magnet = "_dp2_magnet",
			lamp = "_dp2_lamp",
			lamppost = "_dp2_lamppost",
			sawblade = "_dp2_saw",
			radiator = "_dp2_radiator",
			heater = "_dp2_radiator",
			bathtub = "_dp2_bathtub",
			fence = "_dp2_fence",
			bedframe = "_dp2_bedframe",
			mattress = "_dp2_mattress",
			shoe0 = "_dp2_shoe",
			cactus = "_dp2_cactus",
			wrench = "_dp2_wrench",
			watermelon = "_dp2_wmelon",
			["tick-tack-toe_block"] = "_dp2_ticblock",
		}

		for k, v in pairs(mdl2causer) do -- prop kills are rare anyway
			if mdl:find(k, 1, true) then
				causer = v
				break
			end
		end

		::done::
	end

	local lasthit = victim.dp2_lasthit
	local cpart

	if lasthit and lasthit[1] == engine.TickCount() then
		if #lasthit > 2 then
			local counts = {}

			for i = 2, #lasthit do
				local hinfo = lasthit[i]
				local part = hinfo[1]

				local vals = counts[part]

				if vals then
					vals[#vals + 1] = hinfo
				else
					counts[part] = {
						hinfo,
					}
				end
			end

			local mode
			local maxcount = 0

			for _, v in pairs(counts) do
				local count = #v

				if count > maxcount
					or (count == maxcount and math.random(2) == 1)
				then
					mode = v
					maxcount = count
				end
			end

			lasthit = mode[math.random(#mode)]
		else
			lasthit = lasthit[2]
		end

		cpart = part2cpart[lasthit[1]] or 0

		if isfunction(cpart) then
			local pos, ang = victim:GetBonePosition(lasthit[2])

			if pos ~= victim:GetPos() then
				cpart = cpart(
					pos, ang, lasthit[3],
					victim.dp2_hitboxes[lasthit[4] + 1]
				) or 0
			end
		end

		if cpart == 0 then
			cpart = part2cpart._hitgroups[lasthit[5]] or 0
		end
	end

	local killinfo = victim.dp2_killinfo

	killinfo.attacker = attacker
	killinfo.weapon = weapon
	killinfo.inflictor = inflictor
	killinfo.causer = causer
	killinfo.type = dmginfo:GetDamageType()
	killinfo.damage = dmginfo:GetDamage()
	killinfo.cpart = cpart
	killinfo.pushed2death = pushed2death
end

hook.Add("PostEntityTakeDamage", "ttt_death_panel_PostEntityTakeDamage", function(victim, dmginfo)
	if not victim:IsPlayer() then
		return
	end

	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker)
		and not attacker:IsWorld()
		and not attacker:IsPlayer()
	then -- attempt to salvage compatibility with shitty addons
		local owner = attacker:GetOwner() or nil

		attacker = owner
			and IsValid(owner)
			and owner:IsPlayer()
			and owner
			or attacker
	end

	local hitter = attacker
	if not (IsValid(attacker) and attacker:IsPlayer()) then
		attacker = Entity(0)
		hitter = dmginfo:GetDamageType()

		local inflictor = dmginfo:GetInflictor()

		local owner = inflictor
			and IsValid(inflictor)
			and inflictor:GetNWEntity("spec_owner", nil)
			or nil

		if owner and IsValid(owner) and owner:IsPlayer() then
			local propspec = owner and owner.propspec or nil

			if propspec
				and propspec.t > 0
				and CurTime() - propspec.t + 0.15 < 3
			then
				attacker = owner
				hitter = attacker
			end
		end
	end

	local damage = dmginfo:GetDamage()
	if damage > 0 then
		local hitters = victim.dp2_hits
		if not hitters then
			hitters = setmetatable({}, {__mode = "k"})

			victim.dp2_hits = hitters
		end

		local hits = hitters[hitter]
		if not hits then
			hits = {0, 0}

			hitters[hitter] = hits
		end

		hits[1] = hits[1] + 1
		hits[2] = hits[2] + damage
	end

	local igniteinfo = victim.ignite_info
	if igniteinfo
		and igniteinfo.att == attacker
		and igniteinfo.infl == dmginfo:GetInflictor()
		and not (
			victim.dp2_igniteinfo
			and igniteinfo == victim.dp2_igniteinfo.src
		)
	then
		local infl = igniteinfo.infl
		victim.dp2_igniteinfo = {
			att = attacker,
			infl = infl,
			wep = util.WeaponFromDamage(dmginfo)
				or infl ~= attacker and infl
				or nil,
			src = igniteinfo,
		}
	end

	if victim.dp2_killinfo then
		posttakedamagedeath(victim, attacker, dmginfo)
	end
end)

local bone2part, tracedata, vec
hook.Add("PlayerTraceAttack", "ttt_death_panel_PlayerTraceAttack", function(victim, dmginfo, dir, trace)
	if not dmginfo:IsBulletDamage() then
		return
	end

	local hitboxes = victim.dp2_hitboxes

	if not hitboxes then
		bone2part = bone2part or {
			["ValveBiped.Bip01_Head1"] = 1,
			["ValveBiped.Bip01_Neck1"] = 2,
			["ValveBiped.Bip01_Spine2"] = 3,
			["ValveBiped.Bip01_Pelvis"] = 4,
			["ValveBiped.Bip01_L_UpperArm"] = 5,
			["ValveBiped.Bip01_R_UpperArm"] = 5,
			["ValveBiped.Bip01_L_Forearm"] = 6,
			["ValveBiped.Bip01_R_Forearm"] = 6,
			["ValveBiped.Bip01_L_Hand"] = 7,
			["ValveBiped.Bip01_R_Hand"] = 7,
			["ValveBiped.Bip01_L_Thigh"] = 8,
			["ValveBiped.Bip01_R_Thigh"] = 8,
			["ValveBiped.Bip01_L_Calf"] = 9,
			["ValveBiped.Bip01_R_Calf"] = 9,
			["ValveBiped.Bip01_L_Foot"] = 10,
			["ValveBiped.Bip01_R_Foot"] = 10,
			["ValveBiped.Bip01_L_Toe0"] = 10,
			["ValveBiped.Bip01_R_Toe0"] = 10,
		}

		local set = victim:GetHitboxSet()

		hitboxes = {set = set}

		for i = 1, victim:GetHitBoxCount(set) do
			local bone = victim:GetHitBoxBone(i - 1, set)

			local mins, maxs = victim:GetHitBoxBounds(i - 1, set)

			hitboxes[i] = {
				(bone + 1) or 0,
				bone2part[victim:GetBoneName(bone)] or 0,
				mins, maxs,
			}
		end

		victim.dp2_hitboxes = hitboxes
	end

	local traceres
	::done::
	if traceres then
		local hitbox = hitboxes[traceres.HitBox + 1]

		local hitinfo = {
			hitbox[2],
			hitbox[1] - 1,
			traceres.HitPos,
			traceres.HitBox,
			traceres.HitGroup,
		}

		local lasthit = victim.dp2_lasthit

		local tick = engine.TickCount()

		if lasthit and lasthit[1] == tick then
			lasthit[#lasthit + 1] = hitinfo
		elseif not lasthit or #lasthit > 2 then
			victim.dp2_lasthit = {
				tick,
				hitinfo,
			}
		else
			lasthit[1] = tick
			lasthit[2] = hitinfo
		end

		return
	end

	if bit.band(trace.Contents, CONTENTS_HITBOX) > 0 then
		traceres = trace
		goto done
	end

	-- valve: // Half of the shotgun pellets are hulls that make it easier to hit targets with the shotgun.

	local hitpos = trace.HitPos

	local td = tracedata
	if not td then
		td = {
			mask = CONTENTS_SOLID + CONTENTS_MONSTER + CONTENTS_HITBOX,
			output = {},
		}
		tracedata = td
	end

	if not vec then
		vec = Vector()
	end
	local vec = vec
	vec:Set(dir)
	vec:Mul(75)
	vec:Add(hitpos)

	td.start = hitpos
	td.filter = dmginfo:GetAttacker()
	td.endpos = vec

	traceres = util.TraceLine(td)

	if traceres.Entity == victim then
		goto done
	end

	local vicorig = victim:GetPos()

	local meanpos = (trace.StartPos + hitpos) * 0.5

	local nearest
	local nearest_dp = 0

	for i = 1, #hitboxes do
		local pos = victim:GetBonePosition(hitboxes[i][1] - 1)

		if pos and pos ~= vicorig then
			vec:Set(meanpos)
			vec:Sub(pos)
			vec:Normalize()

			local dp = dir:Dot(vec)

			if dp < nearest_dp then
				nearest = pos
				nearest_dp = dp
			end
		end
	end

	if nearest then
		vec:Set(hitpos)
		vec:Sub(nearest)
		vec:Normalize()
		vec:Mul(32)
		nearest:Sub(vec)

		td.start = hitpos
		td.endpos = nearest
		td.ignoreworld = true

		util.TraceLine(td)

		td.ignoreworld = false

		if traceres.Entity == victim then
			goto done
		end
	end
end)

hook.Add("TTTBeginRound", "ttt_death_panel_TTTBeginRound", function()
	for _, v in pairs(player.GetAll()) do
		v.dp2_killinfo = nil
		v.dp2_hits = nil
		v.dp2_igniteinfo = nil
		v.dp2_hitboxes = nil -- maybe this doesn't need to be done every round
		v.dp2_killstreak = nil
	end
end)
