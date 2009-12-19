-- Castlevania - Portrait of Ruin
-- Ghost record script, based on amaurea's one.

outprefix = "ghost"
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
		jo_posx, jo_posy = memory.readdword(0x020fcba4), memory.readdword(0x020fcba8)
		jo_dir = memory.readbytesigned(0x020ff174)
		jo_pose = memory.readword(0x020fcb04)
		jo_blink = memory.readbyte(0x020fca9f)
		jo_visual = memory.readbyte(0x020fcaf5)
		ch_posx, ch_posy = memory.readdword(0x020fcd04), memory.readdword(0x020fcd08)
		ch_dir = memory.readbytesigned(0x020ffdd4)
		ch_pose = memory.readword(0x020fcc64)
		ch_visual = memory.readbyte(0x020fcc55)
		ch_blink = memory.readbyte(0x020fcbff)
		io.write(string.format("%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
			igframe, mode, fade, world, roomx, roomy, camx, camy,
			jo_posx, jo_posy, jo_dir, jo_pose, jo_blink, jo_visual,
			ch_posx, ch_posy, ch_dir, ch_pose, ch_blink, ch_visual))
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
