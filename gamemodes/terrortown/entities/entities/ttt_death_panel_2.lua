if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("ttt_death_panel_2/client.lua")
	resource.AddFile("resource/fonts/bebasneue-regular.ttf")

	include("ttt_death_panel_2/server.lua")
end

if CLIENT then
	include("ttt_death_panel_2/client.lua")
end

ENT.Type = "point"
