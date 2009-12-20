-- Castlevania - Portrait of Ruin
-- Ghost record script, based on amaurea's one.

root_dir = ""
outprefix = root_dir.."ghost"
dumpfile = outprefix..".dump"
nomovie = not false
io.output(dumpfile)

emu.registerafter(function()
	if nomovie or movie.active() then
		igframe = memory.readdword(0x021119e0)
		mode = memory.readbyte(0x020f6284)
		fade = memory.readbytesigned(0x020f61fc)
		world = memory.readbyte(0x02111785)
		roomx, roomy = memory.readbyte(0x02111778), memory.readbyte(0x0211177a)
		camx, camy = memory.readdword(0x02111a08), memory.readdword(0x02111a0c)
		jo_posx, jo_posy = memory.readdwordsigned(0x020fcab0), memory.readdwordsigned(0x020fcab4) -- memory.readdwordsigned(0x020fcba4), memory.readdwordsigned(0x020fcba8)
		jo_hitx1, jo_hity1 = memory.readwordsigned(0x0213296e), memory.readwordsigned(0x02132970)
		jo_hitx2, jo_hity2 = memory.readwordsigned(0x02132972), memory.readwordsigned(0x02132974)
		jo_dir = memory.readbytesigned(0x020ff174)
		jo_pose = memory.readword(0x020fcb04)
		jo_blink = memory.readbyte(0x020fca9f)
		jo_visual = memory.readbyte(0x020fcaf5)
		ch_posx, ch_posy = memory.readdwordsigned(0x020fcc10), memory.readdwordsigned(0x020fcc14) -- memory.readdwordsigned(0x020fcd04), memory.readdwordsigned(0x020fcd08)
		ch_hitx1, ch_hity1 = memory.readwordsigned(0x02132982), memory.readwordsigned(0x02132984)
		ch_hitx2, ch_hity2 = memory.readwordsigned(0x02132986), memory.readwordsigned(0x02132988)
		ch_dir = memory.readbytesigned(0x020ffdd4)
		ch_pose = memory.readword(0x020fcc64)
		ch_blink = memory.readbyte(0x020fcbff)
		ch_visual = memory.readbyte(0x020fcc55)
		io.write(string.format("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			igframe, mode, fade, world, roomx, roomy, camx, camy,
			jo_posx, jo_posy, jo_hitx1, jo_hity1, jo_hitx2, jo_hity2, jo_dir, jo_pose, jo_blink, jo_visual,
			ch_posx, ch_posy, ch_hitx1, ch_hity1, ch_hitx2, ch_hity2, ch_dir, ch_pose, ch_blink, ch_visual))
	end
end)

emu.registerexit(function()
	io.input(io.stdout)
end)

gui.register(function()
	if not nomovie and not movie.active() then
		gui.text(12,24,"Please load the movie file now")
	end
end)
