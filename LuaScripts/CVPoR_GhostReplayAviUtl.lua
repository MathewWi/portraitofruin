-- Castlevania - Portrait of Ruin
-- Ghost replay prototype for AviUtl

require("gd")
require("bit")

copytable = function(t)
	if t == nil then return nil end
	local c = {}
	for k,v in pairs(t) do
		c[k] = v
	end
	setmetatable(c,debug.getmetatable(t))
	return c
end

root_dir = ""
ghost_files = { "0.ghost", "1.ghost" }
ghost_trans = { 0, 0.75 }
jo_gdpose, ch_gdpose = {}, {}
jo_gdpose.l = gd.createFromPng(root_dir.."jonadb.png"):gdStr()
jo_gdpose.r = gd.createFromPng(root_dir.."jonadb-r.png"):gdStr()
ch_gdpose.l = gd.createFromPng(root_dir.."chardb.png"):gdStr()
ch_gdpose.r = gd.createFromPng(root_dir.."chardb-r.png"):gdStr()

ghost = {}
for i, v in ipairs(ghost_files) do
	io.input(root_dir..v)
	ghost[i] = { data = {} }
	local f = 1
	while true do
		local tmp = io.read("*n")
		if tmp == nil then
			break
		end
		local e = {}
		e.igframe = tmp
		e.mode = io.read("*n")
		e.fade = io.read("*n")
		e.world = io.read("*n")
		e.roomx = io.read("*n")
		e.roomy = io.read("*n")
		e.jo_posx = io.read("*n")
		e.jo_posy = io.read("*n")
		e.jo_hitx1 = io.read("*n")
		e.jo_hity1 = io.read("*n")
		e.jo_hitx2 = io.read("*n")
		e.jo_hity2 = io.read("*n")
		e.jo_dir = io.read("*n")
		e.jo_pose = io.read("*n")
		e.jo_blink = (io.read("*n")~=0)
		e.jo_visual = io.read("*n")
		e.ch_posx = io.read("*n")
		e.ch_posy = io.read("*n")
		e.ch_hitx1 = io.read("*n")
		e.ch_hity1 = io.read("*n")
		e.ch_hitx2 = io.read("*n")
		e.ch_hity2 = io.read("*n")
		e.ch_dir = io.read("*n")
		e.ch_pose = io.read("*n")
		e.ch_blink = (io.read("*n")~=0)
		e.ch_visual = io.read("*n")

		e.jo_visible = (bit.band(e.jo_visual, 0x80)==0)
		e.ch_visible = (bit.band(e.ch_visual, 0x80)==0)

		table.insert(ghost[i].data, e)
		f = f + 1
	end
	ghost[i].offset = 1
end
io.input(io.stdin)

function func_proc()
	local f = aviutl.get_frame() + 1
	if f > #ghost[1].data then
		return
	end
	local this = copytable(ghost[1].data[f])
	this.fade = math.abs(this.fade)
	if this.fade > 16 then this.fade = 16 end
	this.fade = (16 - this.fade) / 16.0
	-- this.jo_visible = (bit.band(this.jo_visual, 0x80)==0)
	-- this.ch_visible = (bit.band(this.ch_visual, 0x80)==0)

	local ycp_edit = aviutl.get_ycp_edit()

	clientToScreen = function(x, y)
		return math.floor((x - this.camx) / 0x1000), math.floor((y - this.camy) / 0x1000)
	end

	local drawpose = function(ycp, gdpose, x, y, n, reverse, opacity)
		if opacity == nil then opacity = 1.0 end
		local xi, yi = (n % 0x10), math.floor(n / 0x10)
		if not reverse then
			aviutl.gdoverlay(ycp, x - 32, y - 56 + 192, gdpose.l, xi * 64, yi * 64, 64, 64, math.floor(4096*(1.0-opacity)))
		else
			aviutl.gdoverlay(ycp, x - 32, y - 56 + 192, gdpose.r, (15 - xi) * 64, yi * 64, 64, 64, math.floor(4096*(1.0-opacity)))
		end
	end

	if this.mode ~= 2 or this.fade == 0 then
		return
	end

	for i = 1, #ghost do
		ghost[i].offset = f
		if ghost[i].offset <= #ghost[i].data then
			local e = ghost[i].data[ghost[i].offset]
			if e.mode == 2 and (this.world == e.world and this.roomx == e.roomx and this.roomy == e.roomy) then
				local jo_posx, jo_posy = clientToScreen(e.jo_posx, e.jo_posy)
				local ch_posx, ch_posy = clientToScreen(e.ch_posx, e.ch_posy)
				if e.jo_visible then
					drawpose(ycp_edit, jo_gdpose, jo_posx, jo_posy, e.jo_pose, e.jo_dir >= 0, ghost_trans[i] * this.fade * (e.jo_blink and 0.5 or 1.0))
				end
				if e.ch_visible then
					drawpose(ycp_edit, ch_gdpose, ch_posx, ch_posy, e.ch_pose, e.ch_dir >= 0, ghost_trans[i] * this.fade * (e.ch_blink and 0.5 or 1.0))
				end
			end
		end
	end
end

function func_exit()
end
