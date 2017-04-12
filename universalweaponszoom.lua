--[[
* Purpose of this file *
This is the main script of Universal Weapons Zoom.

* Credits *
Scripting: Captain Fatbelly

!! PLEASE DON'T STEAL THIS CODE !!
]]

surface.CreateFont("hl2",{
	font = "HalfLife2",
	size = 40,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
})

local ply
local d = false
local cd = false
local f = 0
local dFOV = 0
local zFOV = 0
local bl = {}
local scopeTexs = {Material("scope/gdcw_parabolicsight"),Material("scope/gdcw_scopesight"),Material("scope/gdcw_svdsight")}
local scopeTexNames = {"gdcw_parabolicsight","gdcw_scopesight","gdcw_svdsight"}
uwz_enabled = CreateClientConVar("uwz_enabled","1",true,false)
uwz_key = CreateClientConVar("uwz_key","17",true,false)
uwz_default = CreateClientConVar("uwz_default","75",true,false)
uwz_zoom = CreateClientConVar("uwz_zoom","25",true,false)
uwz_crosshair = CreateClientConVar("uwz_crosshair","0",true,false)
uwz_recoil = CreateClientConVar("uwz_recoil","1",true,false)
uwz_animation = CreateClientConVar("uwz_animation","1",true,false)
uwz_animationspeed = CreateClientConVar("uwz_animationspeed","20",true,false)
uwz_scope = CreateClientConVar("uwz_scope","1",true,false)
uwz_scopetex = CreateClientConVar("uwz_scopetex","1",true,false)
local scopeMat = scopeTexs[uwz_scopetex:GetInt()]

hook.Add("Initialize","uwz_initialize",function()
	CreateBL()
	local c = (file.Read("captainfatbelly/uwz.txt", "DATA") ~= nil and file.Read("captainfatbelly/uwz.txt", "DATA") or "")
	bl = SplitStr(SplitStr(c,"\n")[2],",")
end)

hook.Add("HUDPaint","uwz_paint",function()
	if uwz_enabled:GetInt() == 1 and d then
		local ang = ply:EyeAngles()
		if uwz_recoil:GetInt() == 1 then
			ang = ang+ply:GetViewPunchAngles()
		end
		render.RenderView({
			origin = ply:GetPos()+ply:GetViewOffset(),
			angles = ang,
			x = 0,
			y = 0,
			w = ScrW(),
			h = ScrH(),
			fov = f,
			drawviewmodel = false
		})
	 	if uwz_crosshair:GetInt() == 1 and dc then
	 		surface.SetFont("hl2")
			local w,h = surface.GetTextSize("Q")
	 		draw.SimpleText("Q","hl2",ScrW()/2,ScrH()/2-h/2,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP)
	 	end
		if uwz_scope:GetInt() == 1 then
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(scopeMat)
			surface.DrawTexturedRect(ScrW()/2-ScrH()/2,ScrH()/2-ScrH()/2,ScrH(),ScrH())
	 	end
	end
end)

hook.Add("Think","uwz_think",function()
	ply = client or LocalPlayer()

	if !IsValid(ply) then return end
	if uwz_enabled:GetInt() ~= 1 then return end

	dFOV = uwz_default:GetInt()
	zFOV = uwz_zoom:GetInt()
	dc = d

	if IsValid(ply:GetActiveWeapon()) and !ply:InVehicle() then
		if ply:GetActiveWeapon():GetClass() ~= "weapon_crossbow" then
			local found = false
			for k,v in pairs(bl) do
				if ply:GetActiveWeapon():GetClass() == v or ply:GetActiveWeapon():GetClass() == k then
					found = true
				end
			end
			if input.IsKeyDown(uwz_key:GetInt()) then
				if !found and f ~= zFOV then
					d = true
					if uwz_animation:GetInt() == 1 then
						f = Lerp(uwz_animationspeed:GetInt()*FrameTime(), f, zFOV)
					else
						f = zFOV
					end
				end
			else
				if uwz_animation:GetInt() == 1 then
					f = Lerp(uwz_animationspeed:GetInt()*FrameTime(), f, dFOV)
				else
					f = dFOV
				end
				if f >= dFOV-1 then
					d = false
				end
			end
		end
	end
end)

hook.Add("PopulateToolMenu","uwz_menu",function()
	spawnmenu.AddToolMenuOption("Options","Captain Fatbelly","uwz","Universal Weapons Zoom","","",CreatePanel)
end)

function CreatePanel(p)
	local Panel
	if p then
		Panel = p
	else
		Panel = controlpanel.Get("Universal Weapons Zoom")
	end
	Panel:ClearControls()

	Panel:AddControl("CheckBox",{
		Label = "Enable Universal Weapons Zoom?",
		Command = "uwz_enabled"
	})
	Panel:AddControl("Numpad",{
	  Label = "Toggle Zoom Key",
	  Command = "uwz_key"
	})
	Panel:AddControl("Slider",{
	  Label = "Default FOV",
	  Command = "uwz_default",
	  Type = "Integer",
	  Min = "75",
	  Max = "90"
	})
	Panel:AddControl("Slider",{
	  Label = "Zoom FOV",
	  Command = "uwz_zoom",
	  Type = "Integer",
	  Min = "15",
	  Max = "65"
  	})
  	Panel:AddControl("CheckBox",{
		Label = "Enable Crosshair?",
		Command = "uwz_crosshair"
	})
	Panel:AddControl("CheckBox",{
		Label = "Weapon Recoil?",
		Command = "uwz_recoil"
	})
	Panel:AddControl("CheckBox",{
		Label = "Animate Zoom?",
		Command = "uwz_animation"
	})
	Panel:AddControl("Slider",{
	  Label = "Animation Speed",
	  Command = "uwz_animationspeed",
	  Type = "Integer",
	  Min = "10",
	  Max = "30"
	})
	Panel:ControlHelp("10 is the slowest, 30 is the fastest")
	Panel:AddControl("CheckBox",{
		Label = "Draw Scope?",
		Command = "uwz_scope"
	})
	local params = {
		Label = "Scope",
		Height = 128,
		Width = 128,
		Rows = 3,
		ConVar = "uwz_scopetex",
		Options = {}
	}
	for k,v in pairs(scopeTexNames) do
		params.Options[v] = {Material = "scope/"..v,uwz_scopetex = k}
	end
	Panel:AddControl("MaterialGallery",params)
	-- blacklist, test 1
	-- params = {
	-- 	Label = "Blacklisted Weapons",
	-- 	MenuButton = 0,
	-- 	Height = 150,
	-- 	Options = {}
	-- }
	-- for k,v in pairs(bl) do
	-- 	params.Options[v] = {uwz_add = v}
	-- end
	-- Panel:AddControl("ListBox",params)
	-- test 2
	-- local CheckList = vgui.Create("DListView")
	-- CheckList:SetTooltip(false)
	-- CheckList:SetSize(100,150)
	-- CheckList:SetMultiSelect(false)
	-- CheckList:AddColumn("Blacklisted Weapons")
	-- Panel:AddItem(CheckList)
	-- for k,v in pairs(bl) do
	-- 	CheckList:AddLine(v)
	-- end
	Panel:AddControl("Label",{
		Text = "BLACKLIST:"
	})
	Panel:AddControl("Label",{
		Text = "Add/remove weapons to the blacklist by modifying garrysmod/data/captainfatbelly/uwz.txt"
	})
	-- add
	-- Panel:AddControl("Button",{
	-- 	Label = "Add Weapon",
	-- 	Text = "Add Weapon",
	-- 	Command = "uwz_add"
	-- })
	-- remove
	-- Panel:AddControl("Button",{
	-- 	Label = "Remove Weapon",
	-- 	Text = "Remove Weapon",
	-- 	Command = "uwz_remove"
	-- })
	Panel:AddControl("Label",{
	  Text = "CREDITS:"
	})
	Panel:AddControl("Label",{
	  Text = "Scripting: Captain Fatbelly"
	})
	Panel:AddControl("Label",{
	  Text = "Version 1.0.2"
	})
end

cvars.AddChangeCallback("uwz_scopetex",function(cv,ov,nv)
	scopeMat = scopeTexs[uwz_scopetex:GetInt()]
end)

concommand.Add("uwz_add",function(ply,cmd,args)
	-- local wc = unpack(args)
	-- if wc then
	-- 	AddToBlacklist(wc)
	-- 	PrintTable(bl)
	-- 	CreatePanel()
	-- 	return
	-- end
	-- local w,h = 230,110
	-- local x,y = gui.MousePos()
	-- local p = vgui.Create("DFrame")
	-- p:SetSize(w,h)
	-- p:SetPos(x-w*0.5,y-h*0.5)
	-- p:MakePopup()
	-- p:ShowCloseButton(true)
	-- p:SetTitle("Add Weapon to Blacklist")
	-- p.Paint = function(p)
	-- 	draw.RoundedBox(8,0,0,w,h,Color(56,56,56,240))
	-- end
	-- label
	-- local l = vgui.Create("DLabel",p)
	-- l:SetText("Weapon:")
	-- l:SetPos(12,40)
	-- l:SizeToContents()
	-- combobox
	-- local cb = vgui.Create("DComboBox",p)
	-- cb:SetSize(140,16)
	-- cb:SetPos(70,40)
	-- cb.OnSelect = function(p,i,v)
	-- 	wc = v
	-- end
	-- local choices = {}
	-- for _,w in pairs(weapons.GetList()) do
	-- 	table.insert(choices,{
	-- 		class = w.ClassName
	-- 	})
	-- end
	-- table.sort(choices,function(a,b) return a.class < b.class end)
	-- for _,choice in ipairs(choices) do
	-- 	cb:AddChoice(choice.class,choice.class)
	-- end
	-- add
	-- local b = vgui.Create("DButton",p)
	-- b:SetText("OK")
	-- b:SetSize(100,21)
	-- b:SetPos(w/2-50,70)
	-- b.DoClick = function(b)
	-- 	p:Close()
	-- 	if wc then
	-- 		RunConsoleCommand("uwz_add",wc)
	-- 		AddToBlacklist(wc)
	-- 		CreatePanel()
	-- 	end
	-- end
	-- cancel
	-- local b = vgui.Create("DButton",p)
	-- b:SetText("Cancel")
	-- b:SetSize(50,21)
	-- b:SetPos(100,70)
	-- b.DoClick = function(b)
	-- 	p:Close()
	-- end
end)

concommand.Add("uwz_remove",function(ply,cmd,args)
end)

function AddToBlacklist(w)
	-- table.insert(bl,w)
	CreatePanel()
end

function RemoveFromBlacklist(w)
	-- table.RemoveByValue(bl,w)
	CreatePanel()
end

function GetEyesPos()
	local ei = ply:LookupAttachment("eyes")
	return ply:GetAttachment(ei).Pos
end

function GetEyesAng()
	local ei = ply:LookupAttachment("eyes")
	return ply:GetAttachment(ei).Ang
end

function CreateBL()
	if !file.Exists("captainfatbelly", "DATA") then
		file.CreateDir("captainfatbelly")
	end
	if !file.Exists("captainfatbelly/uwz.txt", "DATA") then
		file.Write("captainfatbelly/uwz.txt","- Universal Weapons Zoom weapons blacklist: add classes of weapons seperated by commas on the 2nd line, no spaces -\nweapon_physcannon")
	end
end

function SplitStr(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end