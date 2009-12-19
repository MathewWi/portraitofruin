-- Castlevania - Portrait of Ruin
-- Ghost replay prototype

require("gd")
-- require("bit")

root_dir = "D:\\gocha\\work\\"
ghost_files = { "1.ghost", "2.ghost" }
ghost_trans = { 0.75, 0.75 }
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
		e.camx = io.read("*n")
		e.camy = io.read("*n")
		e.jo_posx = io.read("*n")
		e.jo_posy = io.read("*n")
		e.jo_dir = io.read("*n")
		e.jo_pose = io.read("*n")
		e.jo_blink = (io.read("*n")~=0)
		e.jo_visual = io.read("*n")
		e.ch_posx = io.read("*n")
		e.ch_posy = io.read("*n")
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

emu.registerafter(function()
	for i = 1, #ghost do
		if ghost[i].offset <= #ghost[i].data then
			ghost[i].offset = ghost[i].offset + 1
		end
	end
end)

gui.register(function()
	local e = {}
	e.igframe = memory.readdword(0x021119e0)
	e.mode = memory.readbyte(0x020f6284)
	e.fade = memory.readbytesigned(0x020f61fc)
	e.world = memory.readbyte(0x02111785)
	e.roomx, e.roomy = memory.readbyte(0x02111778), memory.readbyte(0x0211177a)
	e.camx, e.camy = memory.readdword(0x02111a08), memory.readdword(0x02111a0c)
	e.jo_posx, e.jo_posy = memory.readdword(0x020fcba4), memory.readdword(0x020fcba8)
	e.jo_dir = memory.readbytesigned(0x020ff174)
	e.jo_pose = memory.readword(0x020fcb04)
	e.jo_blink = (memory.readbyte(0x020fca9f)~=0)
	e.jo_visual = memory.readbyte(0x020fcaf5)
	e.ch_posx, e.ch_posy = memory.readdword(0x020fcd04), memory.readdword(0x020fcd08)
	e.ch_dir = memory.readbytesigned(0x020ffdd4)
	e.ch_pose = memory.readword(0x020fcc64)
	e.ch_visual = memory.readbyte(0x020fcc55)
	e.ch_blink = (memory.readbyte(0x020fcbff)~=0)

	e.fade = math.abs(e.fade)
	if e.fade > 16 then e.fade = 16 end
	e.fade = (16 - e.fade) / 16.0
	e.jo_visible = (bit.band(e.jo_visual, 0x80)==0)
	e.ch_visible = (bit.band(e.ch_visual, 0x80)==0)

	local this = e

	clientToScreen = function(x, y)
		return math.floor((x - this.camx) / 0x1000), math.floor((y - this.camy) / 0x1000)
	end

	local drawpose = function(gdpose, x, y, n, reverse, opacity)
		if opacity == nil then opacity = 1.0 end
		local xi, yi = (n % 0x10), math.floor(n / 0x10)
		if not reverse then
			gui.gdoverlay(x - 32, y - 56, gdpose.l, xi * 64, yi * 64, 64, 64, opacity)
		else
			gui.gdoverlay(x - 32, y - 56, gdpose.r, (15 - xi) * 64, yi * 64, 64, 64, opacity)
		end
	end

	if this.mode ~= 2 or this.fade == 0 then
		return
	end

	for i = 1, #ghost do
		if ghost[i].offset <= #ghost[i].data then
			local e = ghost[i].data[ghost[i].offset]
			if e.mode == 2 and (this.world == e.world and this.roomx == e.roomx and this.roomy == e.roomy) then
				local jo_posx, jo_posy = clientToScreen(e.jo_posx, e.jo_posy)
				local ch_posx, ch_posy = clientToScreen(e.ch_posx, e.ch_posy)
				if e.jo_visible then
					drawpose(jo_gdpose, jo_posx, jo_posy, e.jo_pose, e.jo_dir >= 0, ghost_trans[i] * this.fade * (e.jo_blink and 0.5 or 1.0))
				end
				if e.ch_visible then
					drawpose(ch_gdpose, ch_posx, ch_posy, e.ch_pose, e.ch_dir >= 0, ghost_trans[i] * this.fade * (e.ch_blink and 0.5 or 1.0))
				end
			end
		end
	end
end)
