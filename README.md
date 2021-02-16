## ttt death panel 2

shows killer info on death with verbose (and overengineered) death messages like:\
\- You were shot in the head with a Deagle by Player (Traitor)\
\- You were shot in the crotch with a Shotgun by Player (Detective)\
\- You were blown up with an Incendiary Grenade by Player (Innocent)\
\- You were blown up with an explosive barrel by Player (Traitor)\
\- You were incinerated with a Flare gun by Player (Traitor)\
\- You fell to your death

![](https://cdn.discordapp.com/attachments/383927930641842186/805088334786330624/unknown.png)

this is named "death panel 2" because it's inspired by an older addon called "death panel": https://web.archive.org/web/20160811170715/http://facepunch.com/showthread.php?t=1282806

this uses the Bebas Neue font: https://github.com/dharmatype/Bebas-Neue

#### linux and osx clients

you have to install the Bebas Neue font because of a bug with gmod: https://github.com/Facepunch/garrysmod-issues/issues/415

on linux, you have to put the ttf file in a directory like `~/.local/share/fonts/`

on osx, idk lol just look up "how to install ttf on mac"

#### compatibility with other addons

this should be compatible with other ttt addons that are written properly

i've found this to be not fully compatible with some steam workshop weapon addons because they don't set the correct entities for `CTakeDamageInfo`'s `attacker` and `inflictor` fields\
they won't crash or cause errors, but inaccurate information will be displayed by the panel on death

for a weapon addon to be fully compatible with this addon, it must follow this simple standard for setting correct values for `CTakeDamageInfo`:

* `attacker` is who to credit for killing someone, `inflictor` is what was used to kill someone
  * if i dropped a banana peel and somebody slips and breaks their neck because of it,\
  then i was the "attacker" while the banana peel was the "inflictor"
* `attacker` should typically be a player, an npc, or the world
* `attacker` should NEVER be a weapon or projectile
  * seriously stop doing this, this prevents kills with your weapon from being credited properly
  * use common sense: if you threw a rock at someone, the rock is NOT the attacker, you are
* `inflictor` should be the weapon or projectile that was used to deal damage
  * Steven shooting Jeremy with a revolver:\
  `attacker` = Steven, `inflictor` = revolver, `victim` = Jeremy
  * Steven hitting Jeremy with a thrown spear:\
  `attacker` = Steven, `inflictor` = spear, `victim` = Jeremy
  * Steven planting a bomb and blowing it up next to Jeremy:\
  `attacker` = Steven, `inflictor` = bomb, `victim` = Jeremy
  * Steven's sentry gun shooting Jeremy:\
  `attacker` = Steven, `inflictor` = sentry gun, `victim` = Jeremy
  * Jeremy stepping on a bear trap left by Steven:\
  `attacker` = Steven, `inflictor` = bear trap, `victim` = Jeremy
* `inflictor` can also just be the attacker if the damage was dealt immediately using a weapon that's currently held by the attacker
  * cool: instant damage (e.g. guns, melee weapons)
  * not cool:\
  damage over time (e.g. poison damage, fire damage)\
  has travel time (e.g. projectiles, grenades)\
  indirect damage (e.g. turrets, booby-traps)
  * basically, this is only cool to do if the attacker can't switch weapons before the damage is actually dealt
* weapon addons that don't follow this standard are written incorrectly, so any issues they cause with this addon are none of my fault
