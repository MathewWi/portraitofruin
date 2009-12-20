
require("gd")
if not bit then require("bit") end

root = ""
jogl = gd.createFromPng(root.."jonadb.png"):gdStr()
jogr = gd.createFromPng(root.."jonadb-r.png"):gdStr()
chgl = gd.createFromPng(root.."chardb.png"):gdStr()
chgr = gd.createFromPng(root.."chardb-r.png"):gdStr()

function joDrawSprite(x, y, n, reverse)
	local xi, yi = (n % 0x10), math.floor(n / 0x10)
	if not reverse then
		gui.gdoverlay(x, y, jogl, xi * 64, yi * 64, 64, 64)
	else
		gui.gdoverlay(x, y, jogr, (15 - xi) * 64, yi * 64, 64, 64)
	end
end

function chDrawSprite(x, y, n, reverse)
	local xi, yi = (n % 0x10), math.floor(n / 0x10)
	if not reverse then
		gui.gdoverlay(x, y, chgl, xi * 64, yi * 64, 64, 64)
	else
		gui.gdoverlay(x, y, chgr, (15 - xi) * 64, yi * 64, 64, 64)
	end
end

emu.registerafter(function()
	jo_spr_after = memory.readword(0x020fcb04)
	ch_spr_after = memory.readword(0x020fcc64)
end)

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
	-- jo blinking? 020fca9f
	-- ch blinking? 020fcbff
	camx = math.floor(memory.readdword(0x02111a08) / 0x1000)
	camy = math.floor(memory.readdword(0x02111a0c) / 0x1000)
	jo_x = math.floor(memory.readdword(0x020FCBA4) / 0x1000)
	jo_y = math.floor(memory.readdword(0x020FCBA8) / 0x1000)
	jo_dir = ((memory.readbytesigned(0x020ff174)<0) and -1 or 0)
	jo_spr = memory.readword(0x020fcb04)
	jo_hitx1 = memory.readword(0x0213296e)
	jo_hity1 = memory.readword(0x02132970)
	jo_hitx2 = memory.readword(0x02132972)
	jo_hity2 = memory.readword(0x02132974)
	ch_x = math.floor(memory.readdword(0x020FCD04) / 0x1000)
	ch_y = math.floor(memory.readdword(0x020FCD08) / 0x1000)
	ch_dir = ((memory.readbytesigned(0x020ffdd4)<0) and -1 or 0)
	ch_spr = memory.readword(0x020fcc64)
	ch_hitx1 = memory.readword(0x02132982)
	ch_hity1 = memory.readword(0x02132984)
	ch_hitx2 = memory.readword(0x02132986)
	ch_hity2 = memory.readword(0x02132988)
	gui.text(164, 10, string.format("area: %d %d %d", area, room_x, room_y))
	gui.text(164, 20, string.format("J: %d %04X", memory.readbyte(0x020fcb02), jo_spr))
	gui.text(164, 30, string.format("C: %d %04X", memory.readbyte(0x020fcd02), ch_spr))
	gui.text(164, 40, string.format("J: %d, %d", (jo_spr%0x10)*64, math.floor(jo_spr/0x10)*64))
	gui.text(164, 50, string.format("C: %d, %d", (ch_spr%0x10)*64, math.floor(ch_spr/0x10)*64))
	if memory.readbyte(0x020f6284) ~= 2 then
		return
	end
	fade = math.abs(memory.readbytesigned(0x020f61fc)) -- 16=white -16=black?
	if fade > 16 then fade = 16 end
	fade = (16 - fade) / 16.0
	if jo_visible then
		gui.opacity(0.68*1 * fade)
		joDrawSprite( 64 + jo_x - camx - 32, jo_y - camy - 48 - 8, jo_spr, jo_dir >= 0)
		joDrawSprite(-64 + jo_x - camx - 32, jo_y - camy - 48 - 8, jo_spr, jo_dir < 0)
gui.opacity(1.0*0 * fade)
joDrawSprite( 0 + jo_x - camx - 32, jo_y - camy - 48 - 8, jo_spr, jo_dir >= 0)

		gui.opacity(1 * fade)
		gui.box(jo_x - camx - 32, jo_y - camy - 48 - 8, jo_x - camx + 31, jo_y - camy + 15 - 8, "clear", "#ff000080")
		gui.box(jo_hitx1 - camx, jo_hity1 - camy, jo_hitx2 - camx, jo_hity2 - camy, "clear", "green")
		gui.opacity(1 * fade)
	end
	if ch_visible then
		gui.opacity(0.68*1 * fade)
		chDrawSprite( 64 + ch_x - camx - 32, ch_y - camy - 48 - 8, ch_spr, ch_dir >= 0)
		chDrawSprite(-64 + ch_x - camx - 32, ch_y - camy - 48 - 8, ch_spr, ch_dir < 0)

		gui.opacity(1 * fade)
		gui.box(ch_x - camx - 32, ch_y - camy - 48 - 8, ch_x - camx + 31, ch_y - camy + 15 - 8, "clear", "#ff000080")
		gui.box(ch_hitx1 - camx, ch_hity1 - camy, ch_hitx2 - camx, ch_hity2 - camy, "clear", "green")
		gui.opacity(1 * fade)
	end
	
	if jo_spr_after and jo_spr ~= jo_spr_after then print("Jonathan: "..tostring(jo_spr)..", "..tostring(jo_spr_after)) end
	if ch_spr_after and ch_spr ~= ch_spr_after then print("Charlotte: "..tostring(ch_spr)..", "..tostring(ch_spr_after)) end
end)
