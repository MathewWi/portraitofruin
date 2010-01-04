-- Castlevania: Portrait of Ruin
-- Simple RAM Display (good for livestreaming!)

gui.opacity(0.68)
gui.register(function()
	local frame = emu.framecount()
	local lagframe = emu.lagcount()
	local moviemode = ""

	local igframe = memory.readdword(0x021119e0)
	local jo_x = memory.readdwordsigned(0x020fcab0)
	local jo_y = memory.readdwordsigned(0x020fcab4)
	local jo_vx = memory.readdwordsigned(0x020fcabc)
	local jo_vy = memory.readdwordsigned(0x020fcac0)
	local jo_inv = memory.readbyte(0x020fcb45)
	local jo_mptimer = memory.readword(0x020fca98)
	local ch_x = memory.readdwordsigned(0x020fcc10)
	local ch_y = memory.readdwordsigned(0x020fcc14)
	local ch_vx = memory.readdwordsigned(0x020fcc1c)
	local ch_vy = memory.readdwordsigned(0x020fcc20)
	local ch_inv = memory.readbyte(0x020fcca5)
	local ch_mptimer = memory.readword(0x020fcbf8)
	local mp = memory.readword(0x02112170)
	local change_cooldown = memory.readdwordsigned(0x021115fc)

	moviemode = movie.mode()
	if not movie.active() then moviemode = "" end
	gui.text(1, 26, string.format("%d/%d%s\n%d\n\nJ(%6d,%6d) %d %04X\nC(%6d,%6d) %d %04X\nMP:%3d | %d",
		frame, igframe,
		(moviemode ~= "" and string.format(" (%s)", moviemode) or ""),
		lagframe,
		jo_vx, jo_vy, jo_inv, jo_mptimer,
		ch_vx, ch_vy, ch_inv, ch_mptimer,
		mp, change_cooldown
	))

	local base = 0x02100da8
	local dispy = 26
	for i = 0, 15 do
		if memory.readword(base) > 0 then -- hp
			gui.text(171, dispy, string.format("%X %03d %08X", i, memory.readword(base), memory.readdword(base-0xf8)))
			dispy = dispy + 10
		end
		base = base + 0x160
	end
end)
