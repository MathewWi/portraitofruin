
require("gd")
if not bit then require("bit") end

root = ""
_jogl = gd.createFromPng(root.."jonadb.png")
jogl = _jogl:gdStr()
_jogr = gd.createFromPng(root.."jonadb-r.png")
jogr = _jogr:gdStr()
--[[
jogl = {}
jogr = {}
for i = 0, 0x0f do
	local small = gd.createFromPng("D:\\gocha\\work\\blank64.png")
	joglm:alphaBlending(true)
	small:alphaBlending(true)
	small:saveAlpha(true)
	gd.copyMerge(small, joglm, 0, 0, (i % 0x10)*64, math.floor(i/0x10)*64, 64, 64, 50)
	jogl[i+1] = small
	jogr[i+1] = small
end
]]

gui.register(function()
	jo_visible = bit.band(memory.readbyte(0x020fcaf5), 0x80)==0
	ch_visible = bit.band(memory.readbyte(0x020fcc55), 0x80)==0
	room_x = memory.readbyte(0x02111778)
	room_y = memory.readbyte(0x0211177a)
	area = memory.readbyte(0x02111785)
	-- world: 02111784
	-- camera 021119fc 02111a08 02111f90
	-- jo ani sheet 020fcaf0
	-- jo ani pat#? 020fcafc
	-- jo ani pat#? 020fcafe
	-- jo ani timer 020fcb02
	-- ch ani sheet 020fcc50 ...
	camx = math.floor(memory.readdword(0x02111a08) / 0x1000)
	camy = math.floor(memory.readdword(0x02111a0c) / 0x1000)
	jo_x = math.floor(memory.readdword(0x020FCBA4) / 0x1000)
	jo_y = math.floor(memory.readdword(0x020FCBA8) / 0x1000)
	jo_dir = ((memory.readbytesigned(0x020ff174)<0) and -1 or 0)
	jo_spr = memory.readword(0x020fcb04)
	ch_x = math.floor(memory.readdword(0x020FCD04) / 0x1000)
	ch_y = math.floor(memory.readdword(0x020FCD08) / 0x1000)
	ch_dir = ((memory.readbytesigned(0x020ffdd4)<0) and -1 or 0)
	gui.text(164, 10, string.format("area: %d %d %d", area, room_x, room_y))
	gui.text(164, 20, string.format("%d %d %d %04X", memory.readbyte(0x020fcaf0), memory.readbyte(0x020fcafc), memory.readbyte(0x020fcafe), memory.readbyte(0x020fcb04)))
	if jo_visible then
		if jo_spr >= 0 and jo_spr <= 0x0f then
		-- y 9 px lower?
			local x, y = (jo_spr % 0x10), math.floor(jo_spr / 0x10)
			if jo_dir < 0 then
				gui.gdoverlay(jo_x - camx - 32, jo_y - camy - 48, jogl, x*64, y*64, 64, 64)
			else
				gui.gdoverlay(jo_x - camx - 32, jo_y - camy - 48, jogr, (15-x)*64, y*64, 64, 64)
			end
		end
		gui.box(jo_x - camx - 32, jo_y - camy - 48, jo_x - camx + 31, jo_y - camy + 15, "#ff000020", "#ff000080")
-- 		gui.box(jo_x - camx - 32, jo_y - camy - 63, jo_x - camx + 31, jo_y - camy, "#ff000020", "#ff000080")
	end
	if ch_visible then
		gui.box(ch_x - camx - 32, ch_y - camy - 63, ch_x - camx + 31, ch_y - camy, "#0000ff20", "#0000ff80")
	end
end)
