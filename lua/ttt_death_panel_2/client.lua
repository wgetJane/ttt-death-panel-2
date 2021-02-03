local delay_time = 0
local fadein_time = 0.5
local display_time = 5
local fadeout_time = 2.5

local bottom_align = 80

local killmsgs = {
	_hitboxes = {
		" in the head",
		" in the face",
		" in the neck",
		" in the pelvis",
		" in the crotch",
		" in the ass",
		" in the chest",
		" in the back",
		" in the upper arm",
		" in the forearm",
		" in the hand",
		" in the thigh",
		" in the calf",
		" in the foot",
		" in the torso",
		" in the arm",
		" in the leg",
	},

	shot = {
		"You were shot%s",
	},

	slash = {
		"You were stabbed%s",
	},
	slash_world = {
		"You were slashed to death%s",
	},

	proj = {
		"You caught %s%s from",
	},
	proj_world = {
		"You caught %s%s",
	},

	club = {
		"You were clubbed to death%s",
		"You were beaten to death%s",
		"You were clobbered to death%s",
		"You were bludgeoned to death%s",
		"You were walloped to death%s",
		"You were bashed to death%s",
	},

	burn = {
		"You were burnt to a crisp%s",
		"You were incinerated%s",
		"You were torched%s",
		"You were fried%s",
		"You were roasted%s",
		"You were toasted%s",
	},

	boom = {
		"You were blown up%s",
	},

	drown = {
		"You were drowned%s",
	},
	drown_nocauser = {
		"You drowned",
	},

	tele = {
		"You were telefragged%s",
	},

	crush = {
		"You were crushed%s",
	},

	push = {
		"You were pushed%s",
	},
	push_nocauser = {
		"You were pushed to your death%s",
	},

	fall = {
		"You fell after being pushed%s",
	},
	fall_short = {
		"You broke your legs after being pushed%s",
	},
	fall_nocauser = {
		"You fell to your death",
	},
	fall_short_nocauser = {
		"You broke your legs",
	},

	stomp = {
		"You were stomped on by a falling",
		"You were crushed by the weight of",
		"Your head was landed on by",
	},
	stomp_world = {
		"You were stomped on",
	},
	other = {
		"You were killed%s",
	},
	other_nocauser = {
		"You died",
	},
}

local causeroverride = {
	_dp2_ebarrel = "explosive barrel",
	_dp2_bed = "bed",
	_dp2_bedframe = "bed frame",
	_dp2_ketpot = "tea kettle",
	_dp2_cookpot = "cooking pot",
	_dp2_banana = "banana",
	_dp2_orange = "orange",
	_dp2_axe = "axe",
	_dp2_tpaper = "toilet paper",
	_dp2_golfdish = "goldfish",
	_dp2_tnt = "TNT",
	_dp2_amp = "Amplifier",
	_dp2_bust = "bust",
	_dp2_clock = "clock",
	_dp2_globe = "globe",
	_dp2_skull = "human skull",
	_dp2_rib = "human rib",
	_dp2_scapula = "human scapula",
	_dp2_spine = "human spine",
	_dp2_bowlb = "bowling ball",
	_dp2_bowlp = "bowling pin",
	_dp2_barrel = "barrel",
	_dp2_crate = "crate",
	_dp2_chair = "chair",
	_dp2_bench = "bench",
	_dp2_table = "table",
	_dp2_desk = "desk",
	_dp2_couch = "couch",
	_dp2_door = "door",
	_dp2_wheel = "wheel",
	_dp2_mwave = "microwave",
	_dp2_dryer = "dryer",
	_dp2_bottle = "bottle",
	_dp2_stool = "stool",
	_dp2_rock = "rock",
	_dp2_bucket = "bucket",
	_dp2_stove = "stove",
	_dp2_toilet = "toilet",
	_dp2_fridge = "fridge",
	_dp2_shelf = "shelf",
	_dp2_doll = "doll",
	_dp2_mug = "coffee mug",
	_dp2_computer = "computer",
	_dp2_monitor = "monitor",
	_dp2_keyboard = "keyboard",
	_dp2_console = "console",
	_dp2_fcab = "filing cabinet",
	_dp2_filebox = "file box",
	_dp2_scase = "suitcase",
	_dp2_radio = "radio",
	_dp2_bicycle = "bicycle",
	_dp2_tcan = "trash can",
	_dp2_turtle = "turtle",
	_dp2_vendmac = "vending machine",
	_dp2_basket = "basket",
	_dp2_cblock = "cinder block",
	_dp2_potplant = "potted plant",
	_dp2_pot = "pot",
	_dp2_paintcan = "paint can",
	_dp2_pizzabox = "box of pizza",
	_dp2_fexting = "fire extinguisher",
	_dp2_pframe = "picture frame",
	_dp2_cbatt = "car battery",
	_dp2_canister = "propane canister",
	_dp2_drawer = "drawer",
	_dp2_dresser = "dresser",
	_dp2_gascan = "gas can",
	_dp2_counter = "counter",
	_dp2_cart = "cart",
	_dp2_barr = "barricade",
	_dp2_buoy = "buoy",
	_dp2_cone = "traffic cone",
	_dp2_tire = "tire",
	_dp2_hook = "hook",
	_dp2_cbox = "cardboard box",
	_dp2_cboard = "clipboard",
	_dp2_binder = "binder",
	_dp2_npaper = "newspaper",
	_dp2_harpoon = "harpoon",
	_dp2_beam = "beam",
	_dp2_tbin = "trash bin",
	_dp2_dumpster = "dumpster",
	_dp2_pallet = "wooden pallet",
	_dp2_kennel = "dog kennel",
	_dp2_magnet = "magnet",
	_dp2_lamp = "lamp",
	_dp2_lamppost = "lamppost",
	_dp2_saw = "sawblade",
	_dp2_radiator = "radiator",
	_dp2_bathtub = "bathtub",
	_dp2_fence = "fence",
	_dp2_mattress = "mattress",
	_dp2_shoe = "shoe",
	_dp2_cactus = "cactus",
	_dp2_wrench = "wrench",
	_dp2_wmelon = "watermelon",
	_dp2_ticblock = "tick-tack-toe block",
	func_breakable = "breakable object",
	player = "fellow terrorist",
}

local indefwords = {
	a = true,
	an = true,
	the = true,
	another = true,
	some = true,
	something = true,
	somebody = true,
	someone = true,
	no = true,
	nothing = true,
	nobody = true,
	none = true,
	any = true,
	anything = true,
	anybody = true,
	anyone = true,
	every = true,
	everything = true,
	everyone = true,
	what = true,
	whatever = true,
	who = true,
	whoever = true,
	whom = true,
	whomever = true,
	each = true,
	either = true,
	both = true,
	several = true,
	various = true,
}

local consonantsound = {
	mac10 = true,

	ewe = true,
	oaxaca = true,
	one = true,
	once = true,
	onceler = true,
	oncest = true,
	onesie = true,
	ouija = true,
}

local vowelsound = {
	["11"] = true,

	heir = true,
	heirdom = true,
	heirless = true,
	heirloom = true,
	heirress = true,
	honest = true,
	honestly = true,
	honesty = true,
	honor = true,
	honorable = true,
	honorably = true,
	honorary = true,
	honour = true,
	honourable = true,
	honourably = true,
	hour = true,
	hourglass = true,
	hourly = true,
	yttrium = true,
}

do -- dumb workaround since you can't get these strings with language.GetPhrase
	local f = file.Open("resource/language/npc-ents_english.txt", "rb", "GAME")

	if not f then
		goto done
	end

	local lshift = bit.lshift
	local bufsize = 2 ^ 12 - 2
	local buf = {}
	local parts = {}
	local str

	local b1, b2 = f:ReadByte(), f:ReadByte()
	local be

	if b1 == 0xFF and b2 == 0xFE then -- utf-16 le bom
		be = false
	elseif b1 == 0xFE and b2 == 0xFF then -- utf-16 be bom
		be = true
	elseif b1 == 0xEF and b2 == 0xBB and f:ReadByte() == 0xBF then -- utf-8 bom
		str = f:Read(f:Size())
		goto isutf8
	elseif b1 == 0x22 and b2 == 0 then -- utf-16 le
		f:Seek(0)
		be = false
	elseif b1 == 0 and b2 == 0x22 then -- utf-16 be
		f:Seek(0)
		be = true
	elseif b1 == 0x22 and b2 ~= 0 then -- utf-8
		f:Seek(0)
		str = f:Read(f:Size())
		goto isutf8
	else
		f:Close()
		goto done
	end

	while f:Tell() < f:Size() do
		local bytes = {(f:Read(bufsize) or ""):byte(1, bufsize)}

		local n, pos, endpos = 0, 1, #bytes

		local c1, c2, c, h
		while pos < endpos do
			c1, c2 = bytes[pos + 1], bytes[pos]
			pos = pos + 2

			if be then
				c1, c2 = c2, c1
			end
			c = lshift(c1, 8) + c2

			if c > 0xD7FF and c < 0xE000 then
				h = lshift(c - 0xD800, 10)

				c1, c2 = bytes[pos + 1], bytes[pos]
				pos = pos + 2

				if be then
					c1, c2 = c2, c1
				end
				c = lshift(c1, 8) + c2

				c = c + h - 0x2400
			end

			n = n + 1
			buf[n] = c
		end

		if n > 0 then
			parts[#parts + 1] = utf8.char(unpack(buf, 1, n))
		end
	end

	str = table.concat(parts)

	::isutf8::

	local kv = util.KeyValuesToTable(str)

	if kv and kv.tokens then
		kv = kv.tokens
	else
		f:Close()
		goto done
	end

	local overrides = causeroverride
	local getphrase = language.GetPhrase

	for k, v in pairs(kv) do
		if not overrides[k] and getphrase(k) == k then
			overrides[k] = v
		end
	end

	f:Close()
	::done::
end

timer.Simple(0, function()
	if _G.DP2_CAUSEROVERRIDE then
		for k, v in pairs(_G.DP2_CAUSEROVERRIDE) do
			causeroverride[k] = v
		end
	end
end)

local function definefonts()
	local fontdata = {
		font = "Bebas Neue",
		extended = true,
		size = 28,
	}

	surface.CreateFont("dp2_BebasNeue_28", fontdata)

	fontdata.size = 48
	surface.CreateFont("dp2_BebasNeue_48", fontdata)

	fontdata.size = 80
	surface.CreateFont("dp2_BebasNeue_80", fontdata)

	fontdata.font =
		system.IsLinux() and "DejaVu Sans"
		or system.IsOSX() and "Helvetica"
		or "Tahoma"
	fontdata.size = 16
	surface.CreateFont("dp2_Tahoma_16", fontdata)
end

local panel_existing
local function removepanel(_, pnl)
	if IsValid(pnl) then
		pnl:Remove()

		if pnl == panel_existing then
			panel_existing = nil
		end
	end
end

local function DeathPanel(ply, role, hits, totaldmg, cause, causer, killstreak, hitbox)
	if definefonts then
		definefonts()
		definefonts = nil
	end

	if role > 0 and IsValid(ply) and ply:IsPlayer() then
		if DetectiveMode() and ScoreGroup(ply) == GROUP_SPEC then
			role = 4
		end
	else
		role = 0
		ply = Entity(0)
	end

	local width, height = 0, 0

	local panel = vgui.Create("Panel")

	local bg = vgui.Create("Panel", panel)

	local causestr = role == 0 and (
			killmsgs[cause .. "_world"]
			or not causer and killmsgs[cause .. "_nocauser"]
		) or killmsgs[cause]
	causestr = causestr[math.random(#causestr)]

	local art
	if causer then
		local causerl = causer and causer:lower()
		local firstword = causerl and causerl:match("^%S+")

		art = not firstword and "a "
			or indefwords[firstword] and ""
			or consonantsound[firstword] and "a "
			or vowelsound[firstword] and "an "
			or causer:find("^[FHLMNRSX]%L") and "an "
			or causer:find("^[U]%L") and "a "
			or causer:find("^[Ee]u") and "a "
			or causer:find("^[Uu][bcfklrstv][aeiou]") and "a "
			or causer:find("^[Uu]ni[^mn]") and "a "
			or causerl:find("^[aeiou]") and "an "
			or "a "
	end

	if cause:sub(1, 4) == "proj" then
		causestr = causestr:format(
				art or "a ",
				causer or "projectile"
			)
	else
		causestr = causestr:format(
				(hitbox and killmsgs._hitboxes[hitbox] or "")
				.. (causer and (" %s %s%s"):format(
						role > 0 and "with" or "by", art, causer
					) or "")
				.. (role > 0 and " by" or "")
			)
	end

	local grey = Color(240, 232, 224)
	local yellow = Color(224, 180, 16)
	local rolecol = ({
		Color(32, 180, 16),
		Color(192, 40, 32),
		Color(16, 96, 192),
		Color(136, 152, 16),
	})[role] or yellow

	local pad = 8

	local lbl_cause = vgui.Create("DLabel", panel)
	lbl_cause:SetFont(role > 0 and "dp2_BebasNeue_28" or "dp2_BebasNeue_48")
	lbl_cause:SetText(causestr)
	lbl_cause:SetTextColor(grey)

	local lbl_cause_w = lbl_cause:GetContentSize()
	local lbl_cause_h = role > 0 and 18 or 32
	lbl_cause:SetPos(pad, pad - lbl_cause_h * 0.5)
	lbl_cause:SetSize(lbl_cause_w, lbl_cause_h * 2)

	width = math.max(width, lbl_cause_w + pad * 2)
	height = height + lbl_cause_h + pad * 2

	if role > 0 then
		local av_w, av_h = 92, 92

		local av = vgui.Create("AvatarImage", panel)
		av:SetPos(pad, height)
		av:SetSize(av_w, av_h)
		av:SetPlayer(ply, 184)

		local nick = ply:Nick()

		local lbl_nick = vgui.Create("DLabel", panel)
		lbl_nick:SetFont("dp2_BebasNeue_48")
		lbl_nick:SetText(nick)
		lbl_nick:SetTextColor(yellow)

		local lbl_nick_w = lbl_nick:GetContentSize()
		local lbl_nick_h = 32
		lbl_nick:SetPos(av_w + pad * 2, height - lbl_nick_h * 0.5)
		lbl_nick:SetSize(lbl_nick_w, lbl_nick_h * 2)

		width = math.max(width, av_w + lbl_nick_w + pad * 3)

		local rolename = LANG.TryTranslation(
			({"innocent", "traitor", "detective", "Spectator"})[role]
		)

		local lbl_role = vgui.Create("DLabel", panel)
		lbl_role:SetFont("dp2_BebasNeue_80")
		lbl_role:SetText(rolename)
		lbl_role:SetTextColor(rolecol)

		local lbl_role_w = lbl_role:GetContentSize()
		local lbl_role_h = 50
		lbl_role:SetPos(av_w + pad * 2, height + av_h - lbl_role_h * 1.5)
		lbl_role:SetSize(lbl_role_w, lbl_role_h * 2)

		width = math.max(width, av_w + lbl_role_w + pad * 3)

		height = height + av_h + pad

		print(("%s %s (%s)"):format(causestr, nick, rolename))
	else
		print(causestr)
	end

	local dpanel_bg = vgui.Create("DPanel", bg)
	dpanel_bg:SetBackgroundColor(Color(0, 0, 10, 200))

	local drawhits = hits > 0
	local drawks = killstreak > 1

	if drawhits or drawks then
		local bg2 = vgui.Create("Panel", panel)
		bg2:SetPos(0, height)

		local dpanel_bg2 = vgui.Create("DPanel", bg2)
		dpanel_bg2:SetPos(0, -2)
		dpanel_bg2:SetBackgroundColor(Color(0, 0, 10, 232))

		local x = pad
		local lbl, lbl_w, lbl_h

		if drawhits then
			for _, v in pairs({
				"Damage taken: ",
				totaldmg,
				" in ",
				hits,
				hits == 1 and " hit " or " hits ",
			}) do
				lbl = vgui.Create("DLabel", bg2)
				lbl:SetFont("dp2_Tahoma_16")
				lbl:SetText(v)
				lbl:SetTextColor(isnumber(v) and rolecol or grey)

				lbl_w, lbl_h = lbl:GetContentSize()
				lbl_h = lbl_h * 0.5
				lbl:SetPos(x, pad - lbl_h * 0.5)
				lbl:SetSize(lbl_w, lbl_h * 2)

				x = x + lbl_w
			end
		end

		if drawks then
			local lbl_ksnum_w, lbl_kstxt_w

			local lbl_ksnum = vgui.Create("DLabel", bg2)
			lbl_ksnum:SetFont("dp2_Tahoma_16")
			lbl_ksnum:SetText(killstreak)
			lbl_ksnum:SetTextColor(yellow)

			lbl_ksnum_w, lbl_h = lbl_ksnum:GetContentSize()
			lbl_h = lbl_h * 0.5
			lbl_ksnum:SetSize(lbl_ksnum_w, lbl_h * 2)

			local lbl_kstxt = vgui.Create("DLabel", bg2)
			lbl_kstxt:SetFont("dp2_Tahoma_16")
			lbl_kstxt:SetText(" killstreak")
			lbl_kstxt:SetTextColor(grey)

			lbl_kstxt_w, lbl_h = lbl_kstxt:GetContentSize()
			lbl_h = lbl_h * 0.5
			lbl_kstxt:SetSize(lbl_kstxt_w, lbl_h * 2)

			if drawhits then
				x = math.max(
					width - pad,
					x + 32 + lbl_ksnum_w + lbl_kstxt_w
				)

				lbl_ksnum:SetPos(
					x - lbl_kstxt_w - lbl_ksnum_w,
					pad - lbl_h * 0.5
				)

				lbl_kstxt:SetPos(
					x - lbl_kstxt_w,
					pad - lbl_h * 0.5
				)
			else
				lbl_ksnum:SetPos(x, pad - lbl_h * 0.5)

				x = x + lbl_ksnum_w

				lbl_kstxt:SetPos(x, pad - lbl_h * 0.5)

				x = x + lbl_kstxt_w
			end
		end

		width = math.max(width, x + pad)

		bg:SetSize(width, height)
		dpanel_bg:SetSize(width, height + 2)

		height = height + lbl_h + pad * 2

		bg2:SetSize(width, lbl_h + pad * 2)
		dpanel_bg2:SetSize(width, lbl_h + pad * 2 + 2)
	else
		bg:SetSize(width, height)
		dpanel_bg:SetSize(width, height)
	end

	panel:SetSize(width, height)
	panel:CenterHorizontal()
	panel:AlignBottom(bottom_align)

	local x, y = panel:GetPos()
	panel:AlignBottom(-height)
	panel:MoveTo(x, y, fadein_time, delay_time, 0.3)

	panel:AlphaTo(0, fadeout_time, delay_time + fadein_time + display_time, removepanel)

	local pnl_ex = panel_existing
	panel_existing = panel

	if IsValid(pnl_ex) then -- not sure why this would happen in a normal game, but just in case
		panel.panel_existing = pnl_ex

		local to_y = y

		while IsValid(pnl_ex) do
			local ex = pnl_ex:GetPos()
			local _, eh = pnl_ex:GetSize()

			pnl_ex:Stop()
			pnl_ex:AlphaTo(0, fadeout_time, 0, removepanel)
			pnl_ex:MoveTo(ex, to_y - eh - pad, fadein_time * 1.1, delay_time, 0.3)

			pnl_ex = pnl_ex.panel_existing
			to_y = to_y - eh - pad
		end
	end
end

local cause2str = {
	"other",
	"push",
	"fall",
	"fall_short",
	"shot",
	"drown",
	"boom",
	"burn",
	"proj",
	"club",
	"slash",
	"tele",
	"stomp",
	"crush",
}

net.Receive("ttt_death_panel", function()
	local idx = net.ReadUInt(math.ceil(math.log(game.MaxPlayers()) / math.log(2))) + 1
	local role = net.ReadUInt(2)
	local hits = net.ReadUInt(8)
	local totaldmg = net.ReadUInt(16)
	local cause = cause2str[net.ReadUInt(4) + 1]

	local hitbox
	if cause == "shot" then
		hitbox = net.ReadUInt(5)
	end

	local causer = net.ReadBool() and net.ReadUInt(8) or net.ReadString()

	local killstreak = role > 0 and net.ReadUInt(8) or 0

	if causer == 0 or causer == "" then
		causer = nil
	elseif causeroverride[causer] then
		local override = causeroverride[causer]
		causer = override ~= "" and override or nil
	else
		local wname

		if isnumber(causer) then
			wname = EnumToWep(causer)
		elseif isstring(causer) then
			local wep = util.WeaponForClass(causer)
			wname = wep and wep.PrintName
		end

		local name = wname or causer

		local trans = LANG.TryTranslation(name)

		causer = trans ~= name and trans or language.GetPhrase(name)
	end

	return DeathPanel(
		Entity(role > 0 and idx or 0), role,
		hits, totaldmg,
		cause, causer,
		killstreak,
		hitbox
	)
end)
