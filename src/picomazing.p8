pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- PICO-8 Maze Tower Defense Game
-- Copyright (C) 2024 Gavin Atkin

#include grid.lua
#include cursor.lua
#include hud.lua
#include main.lua
#include waves.lua
#include units.lua
#include unit_types.lua
#include towers.lua
#include tower_types.lua
#include tower_menus.lua
#include paths.lua
#include projectiles.lua
#include extras.lua

__gfx__
00aaaa0000aaaa000000000051111115111111111111111100000000001111000666666000000000000000000009999999990000000099999999900007000000
00aaaa000aa99aa000aa00001111111115111151111111110880088001ccc71060000706000c770000000000009aa99999aa90000009aa99999aa90070000000
aa9999aaaa9449aa00aaaa0011111111111111111115111188888ee81cc777716000070600ccc7700000000009a99aaaaa99a900009a99aaaaa99a9007000000
aa9449aaa94bb49a00aaaaaa111111111111111111111111888888e81cc77771060070600ccc00700000000c09a999999779a900009a999999779a9000000000
aa9449aaa94bb49a00aaaaaa1111111111111111111115118888888801ccc710060070600cc70000000000cc99a999997777a990099a999997777a9900000000
aa9999aaaa9449aa00aaaa0011111111111111111151111108e88880001c710000600600ccc700000000cccc9a99999977779a9009a99999977779a900000000
00aaaa000aa99aa000aa0000111111111511115111111111008888000001100000600600cc7c0cc000cccccc9a99999977779a9009a99999977779a900000000
00aaaa0000aaaa0000000000511111151111111111111111000880000000000000066000cccccccccccccccc9a99999997799a9009a99999997799a900000000
000dd0000999999000000000122212221aaaaa11666666611111100100000000ffffffffffffffff0099990099a999999999a990099a999999999a9900000000
00dccd0097999979000aa00021212121aaaaaaa16666666110610070001cc100ffffffffffffffff09aaaa9009aaa99999aaa900009aa9aaaaa9aa9000000000
0dcc7cd09779977900aa7a0022122212aaeaeaa16566656110010000011c71100fffff0ffff00fff9a9977a909a99aaaaa99a900009a9aaaaaaa9a9000000000
dcc997cd997777999aaaaaa921212121aaeaeaa165858561111110010ccc77c000f00f0fff07070f9a9997a9009aaaaaaaaa90000009aaaeaeaaa90000000000
dc799ccd99777799999aa99912221222aaaaaaa165656561100100000cccccc00007070ff000000f0a9aa9a00009aaeaeaa9000000009aaeaeaa900000000000
0dc7ccd09779977900a99a00212121211aaaaf221aaaa94400600670011cc110f00000fff00ff00f09aeea900000aaeaeaa0000000000aaaaaaa000000000000
00dccd0097999979000aa0002212221222f212224494144408000860001cc100fff00ffff0ffff0f00aaaa000000aaaaaaa00000000000a999a0000000000000
000dd00009999990000000002121212122211111444111111001000000000000ffffffffffffffff00a99a0000000a999a000000000000000000000000000000
00000000aa0000aa005550000055500000666000000bbbb0000bbbb0000000000000000000bb0000000000000009999999990000009990000099900000000000
03000030aab00baa05666500056665000655560000bb78bb00bb78bb20000002000000000ba900a900090000009aa99999aa9000009a9999999a900000000000
003bb3000babbab05665665056aca65065c9c5600bbb88bb0bbb88bb02aaaa2000aaaa00ba980a980098000809a99aaaaa99a9000009a99999a9000000000000
00b33b0000b99b00565c565056c9c650659c9560033bb3000b3bbb3000aeea0022aeea22ba980a980098000809a999999779a90000099aaaaa99000000000000
00b33b0000b99b005665665056aca65065c9c56033bbbb300b33bb0000aeea0022aeea220ba900a90009000099a999997777a9900009a99999a9000000000000
003bb3000babbab00566650005666500065556000bbbb9cccc93bb0002aaaa2000aaaa0000bb0000000000009a99999977779a900009a99979a9000000000000
03000030aab00baa005550000055500000666000cc9c0cccccc0c9cc200000020000000000000000000000009a99999977779a90009a9999799a900000000000
00000000aa0000aa000000000000000000000000ccc0000000000ccc000000000000000000000000000000009a99999997799a90009a9999979a900000000000
066666606788887600e2e00000e2e0000cccccc00cccc940049cc940049cc940049cc940049449400494494099a999999999a99009a999999999a90000000000
66dddd66722ee22700eee00000222000c99cc99cc99c4994499449944994499449944994499999944a8998a409aaa99999aaa90009aaaaaaaaaaa90000000000
6ddeedd682e22e28ee222ee0e2ccc2e0c994499cc99499999999999999999999999999999992299998aaaa8909a999999999a90009a9aeeaeea9a90000000000
6de27ed68e2772e82e252e2022c1c220cc4994cccc49294cc492294cc492294cc492294c4922229449aaaa94009aaaa9aaaa9000009aaaaaaaaa900000000000
6de22ed68e2272e8ee222ee0e2ccc2e0cc4994cccc4994cccc4994ccc49294ccc492294c4922229449aaaa940009aaaaaaa900000009a99999a9000000000000
6ddeedd682e22e2800eee00000222000c994499cc994499cc994499c9999499c999999999992299998aaaa890000aeeaeea00000000091111190000000000000
66dddd66722ee22700e2e00000e2e000c99cc99cc99cc99cc99cc99c4994c99c49944994499999944a8998a40000aaaaaaa00000000092222290000000000000
066666606788887600000000000000000cccccc00cccccc00cccccc0049cccc0049cc940049449400494494000000aa9aa000000000099444990000000000000
00877000008770000008000000080000000066666660000000000000000000000000666666600000006666000000000000000000000000000000000000000000
00075790000757900088850000888500000066666660000000000000000000000000666666600000008686000000000000000000000000000000000000000000
00777700007777000008779000087790000065666560000000006666666000000000656665600000026666200000000000000000000000000000000000000000
07777700077777000067778000677780000165858561000000006666666000000000658585600000222222220000000000000000000000000000000000000000
77777700777777000677770006777700011265656562111001116566656111100111656565611110221111220000000000000000000000000000000000000000
7777770077777700077777000777770012221aaaaa122221122265858562222112221aaaaa122221aa2222aa0000000000000000000000000000000000000000
77900990779909000099090000900990222221aaa12222222222656565622222222111aaa1111222099999900000000000000000000000000000000000000000
00990000000009900000099000990000222222111222122222121aaaaa121222222aaa1111aaa222044004400000000000000000000000000000000000000000
000000000000000000080000000800002221222222112222221221aaa1221222122aaa1221aaa222eef00fee0000000000000000000000000000000000000000
0008770000087700008885006668850012212221212222222211221112211222012aaa1121aaa221ef0000fe0000000000000000000000000000000000000000
07777570666775700668777067767770122211121222222122121112111212210011112212111110e080080e0000000000000000000000000000000000000000
777777797776777967777779677777791aa199221aaa2210aaa299222299aaa00002222222220000e009900e0000000000000000000000000000000000000000
777767707777777077776778777777781aa9ff921aaa9900aaa9ff9129ff9aa00002222122220000330000330000000000000000000000000000000000000000
6666770007777700666677800777778001944499999990000009ff9999ff90000009ff9999f90000035335300000000000000000000000000000000000000000
09909900099099000090900000909000004444400044400000044449944440000000999099900000004444000000000000000000000000000000000000000000
00000000000000000000000000000000004444400000000000044440044440000000440004400000eeddddee0000000000000000000000000000000000000000
1cc71cccccc11cc1eeeeff40004ffeeeeeeeff40004ffeeeeeeeff40004ffeeeeeeeff40004ffeeeeeeff4000eeeeeee00000000000000000000000000000000
ccc71ccc77c1cc7ceeeff4000004ffeeeeeff4000004ffeeeeeff4000004ffeeeeeff4000004ffeeeeeeeee0004ffeee00000000000000000000000000000000
ccc771cc771cc777eeefff45554fffeeeeefff45554fffeeeeeff000554fffeeeeefff40004fffeeeefff40004fffeee00000000000000000000000000000000
1ccc71c7771cc777eee4ff48f84ff4eeeee4ff48f84ff4eeeee43000f84ff4eeeee4ff48084ff4eeeeeeeeeeeeeeeeee00000000000000000000000000000000
11cc7111111cccc1eeef4488f8844feeeeef4488f8844feeeeef3335f8844feeeee04488088440eeee04488088440eee00000000000000000000000000000000
111111cccc111111ee0fff99999fff0eee0fff99999fff0eee033359999fff0eee0000000000000ee0000000000000ee00000000000000000000000000000000
ccc71ccc77c1ccc7e304ff90909ff403e304ff90909ff403e3333390909ff403e300000000000003eeeeeeee0000003e00000000000000000000000000000000
cc771cc77771cc773334ff99999ff4333334ff99999ff433e3333599999ff4333335000000000533335000000000533300000000000000000000000000000000
cc771cc77771cc7733334fffffff433333555000ffff4333e3355000ffff43333355500000005333355500eeeeeeeee300000000000000000000000000000000
ccc71ccccc71ccc733533553335533533333300033553353ee333355335533533333300033553353333300033553353300000000000000000000000000000000
111111cc771111113335355333553533e333330033553533eeee335533553533e333330033553533333330033553533e00000000000000000000000000000000
11cc7111111cccc13330055333553000ee33355333553000eeee335533553000ee33355333553000eeeeeeeee553000e00000000000000000000000000000000
1ccc71cccc1cc77c30000044444dde00eeee444444444e00eeee444444444e00eeee444444444e00eee444444444e00e00000000000000000000000000000000
ccc771cc771cc777e000005555ddddeeeeee555555555eeeeeee555555555eeeeeee555555555eeeeeeeee555555eeee00000000000000000000000000000000
ccc71cc777c1cc77eeeeddd555ddddeeeeee5ddd5ddddeeeeeee5ddd5ddddeeeeeee5ddd5ddddeeeeee5dddeeeeeeeee00000000000000000000000000000000
1c711cc777c11cc1eeeeeeeeeddddeeeeeeeddddeddddeeeeeeeddddeddddeeeeeeeddddeddddeeeeeeddddeddddeeee00000000000000000000000000000000
11111111111111111000000111111111111111111111111111111111111111111111111111111111110000001111111111111111111111111111111100000000
11000000000000000000000001111111111111111100000000111000000000111111111111111111000000000011111111111111111111111111111100000000
10000000000000000007700000111111111111110000000000000000000000011111111111111110000077000001111111111111111111111111111100000000
10000777777777000777777000111111111111110000777700000007777000011111111111111110007777770001111111111111111111111111111100000000
00077777777777777777777700011111111111100077777777000777777770001111111111111100077777777000111111111111111111111111111100000000
0007777777777777777cc777000000000000000000777777777077777777700000000000000000000777bb777000000000000000000000001111111100000000
00777ccccccccc7777cccc7770000000000000000777bbbb7770777bbbb777000000000000000000777bbbb77700000000000000000000000011111100000000
00777cccccccccc777cccc7770777770000077770777bbbbb77777bbbbb777077707770000777777777bbbb77777077770000077707777000011111100000000
00777ccccccccccc777ccc7777777777707777777777bbbbb77777bbbbb7777777777777777777777777bbb77777777777707777777777770001111100000000
00777cccc777ccccc777777777777777777777777777bbbbbb777bbbbbb777777777777777777777777777777777777777777777777777770001111100000000
00777cccc7777cccc7cccc7777ccccc77777cccc7777bbbbbb777bbbbbb7777bbb7bbb7777bbbbbbb77bbbb777bb7bbbb77777bbb7bbbb777000111100000000
00777cccc7777cccc7cccc777cccccc777cccccccc77bbbbbb77bbbbbbb777bbbbbbbbb777bbbbbbb77bbbb7bbbbbbbbbb777bbbbbbbbb777000111100000000
00777cccc7777cccc7cccc77cccccc7777cccccccc77bbbbbbb7bbbbbbb77bbbbbbbbbb77bbbbbbb777bbbb7bbbbbbbbbb77bbbbbbbbbb777000111100000000
00777cccc777ccccc7cccc77cccc77777cccc77cccc7bbbbbbbbbbbbbbb77bbbb77bbbb77777bbbb777bbbb7bbbb77bbbb77bbbb77bbbb777000111100000000
00777ccccccccccc77cccc77cccc77777cccc77cccc7bbbbbbbbbb7bbbb77bbbb77bbbb7777bbbb7777bbbb7bbbb77bbbb77bbbb77bbbb777000111100000000
00777ccccccccccc77cccc77cccc77777cccc77cccc7bbbbbbbbbb7bbbb77bbbb77bbbb777bbbb77777bbbb7bbbb77bbbb77bbbb77bbbb777000111100000000
00777ccccccccc7777cccc77cccc77777cccc77cccc7bbbb7bbbb77bbbb77bbbb77bbbb777bbb777777bbbb7bbbb77bbbb77bbbb77bbbb777000111100000000
00777cccc777777777cccc77cccccc7777cccccccc77bbbb7bbbb77bbbb77bbbbbbbbbb77bbbbbbbb77bbbb7bbbb77bbbb77bbbbbbbbbb777000111100000000
00777cccc777777777cccc777cccccc777cccccccc77bbbb77bb777bbbb777bbbbbbbbb77bbbbbbbb77bbbb7bbbb77bbbb777bbbbbbbbb777000111100000000
00777cccc777770777cccc7777ccccc77777cccc7777bbbb77bb777bbbb7777bbb7bbbb77bbbbbbbb77bbbb7bbbb77bbbb7777bbb7bbbb777000111100000000
0007777777700000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bbbb777000111100000000
00077777777000007777777777777777707777777777777777777777777777777777777777777777777777777777777777777bbbbbbbb7770000111100000000
00000777700000000077770000777770000077770000777700770007777000077707777007777777700777707777007777777bbbbbbb77770001111100000000
10000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777700001111100000000
11100000000011110000000000000000010000000000000000000000000000000000000000000000000000000000000000077777777777000011111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000777777700000111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111110000000000000001111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000011111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111000000001111111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000
__label__
11111111111115111111111111111111111115111111111111111111111115111111111111111111111115111111111111111111111115111111111111111111
11111111115111111111111111111111115111111111111111111111115111111111111111111111115111111111111111111111115111111111111111111111
15111151111111111111111115111151111111111111111115111151111111111111111115111151111111111111111115111151111111111111111115111151
11111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111
11111111511111151111111111111111511111151111111111111111511111151111111111111111511111151111111111111111511111151111111111111111
11111111111111111511115111111111111111111511115111111111111111111511115111111111111111111511115111111111111111111511115111111111
11151111111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111511111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511
11511111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511111
11111111111111111511115000000111111111111511115111111111111111111511115111111111111111110000005111111111111111111511115111111111
11111111000000000000000000000001511111151111111100000000511000000000111111111111511111000000000011111111511111151111111111111111
51111110000000000000000007700000111111111111110000000000000000000000011151111115111110000077000001111115111111111111111151111115
11111110000777777777000777777000151111511111110000777700000007777000011111111111151110007777770001111111151111511111111111111111
11111100077777777777777777777700011111111115100077777777000777777770001111111111111100077777777000111111111111111115111111111111
1111110007777777777777777cc777000000000000000000777777777077777777700000000000000000000777bb777000000000000000000000001111111111
11111100777ccccccccc7777cccc7770000000000000000777bbbb7770777bbbb777000000000000000000777bbbb77700000000000000000000000011111111
11111100777cccccccccc777cccc7770777770000077770777bbbbb77777bbbbb777077707770000777777777bbbb77777077770000077707777000011111111
11111100777ccccccccccc777ccc7777777777707777777777bbbbb77777bbbbb7777777777777777777777777bbb77777777777707777777777770001111111
51111100777cccc777ccccc777777777777777777777777777bbbbbb777bbbbbb777777777777777777777777777777777777777777777777777770001111115
11111100777cccc7777cccc7cccc7777ccccc77777cccc7777bbbbbb777bbbbbb7777bbb7bbb7777bbbbbbb77bbbb777bb7bbbb77777bbb7bbbb777000111111
15111100777cccc7777cccc7cccc777cccccc777cccccccc77bbbbbb77bbbbbbb777bbbbbbbbb777bbbbbbb77bbbb7bbbbbbbbbb777bbbbbbbbb777000111151
11111100777cccc7777cccc7cccc77cccccc7777cccccccc77bbbbbbb7bbbbbbb77bbbbbbbbbb77bbbbbbb777bbbb7bbbbbbbbbb77bbbbbbbbbb777000111111
11111100777cccc777ccccc7cccc77cccc77777cccc77cccc7bbbbbbbbbbbbbbb77bbbb77bbbb77777bbbb777bbbb7bbbb77bbbb77bbbb77bbbb777000111111
11111100777ccccccccccc77cccc77cccc77777cccc77cccc7bbbbbbbbbb7bbbb77bbbb77bbbb7777bbbb7777bbbb7bbbb77bbbb77bbbb77bbbb777000111111
11111100777ccccccccccc77cccc77cccc77777cccc77cccc7bbbbbbbbbb7bbbb77bbbb77bbbb777bbbb77777bbbb7bbbb77bbbb77bbbb77bbbb777000111111
15111100777ccccccccc7777cccc77cccc77777cccc77cccc7bbbb7bbbb77bbbb77bbbb77bbbb777bbb777777bbbb7bbbb77bbbb77bbbb77bbbb777000111151
11111100777cccc777777777cccc77cccccc7777cccccccc77bbbb7bbbb77bbbb77bbbbbbbbbb77bbbbbbbb77bbbb7bbbb77bbbb77bbbbbbbbbb777000111111
11111100777cccc777777777cccc777cccccc777cccccccc77bbbb77bb777bbbb777bbbbbbbbb77bbbbbbbb77bbbb7bbbb77bbbb777bbbbbbbbb777000111111
11111100777cccc777770777cccc7777ccccc77777cccc7777bbbb77bb777bbbb7777bbb7bbbb77bbbbbbbb77bbbb7bbbb77bbbb7777bbb7bbbb777000111111
1115110007777777700000777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777bbbb777000151111
11111100077777777000007777777777777777707777777777777777777777777777777777777777777777777777777777777777777bbbbbbbb7770000111111
11111500000777700000000077770000777770000077770000777700770007777000077707777007777777700777707777007777777bbbbbbb77770001111511
11511110000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000077777777777700001511111
11111111100000000011110000000000000000010000000000000000000000000000000000000000000000000000000000000000077777777777000011111111
11111111511111151111111111111111511111151111111111111111511111151111111111111111511111151111111111111100000777777700000111111111
51111115111111111111111151111115111111111111111151111115111111111111111151111115111111111111111151111110000000000000001151111115
11111111151111511111111111111111151111511111111111111111151111511111111111111111151111511111111111111111100000000000011111111111
11111111111111111115111111111111111111111115111111111111111111111115111111111111111111111115111111111111111000000005111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111111111
11111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111111111111
11111111151111511111111111111111151111511111111111111111151111511111111111111111151111511111111111111111151111511111111111111111
51111115111111111111111151111115111111111111111151111115111111111111111151111115111111111111111151111115111111111111111151111115
11111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111
151111511111111111111111151111511bbbb1111111111115111151111111111111111115111151111111111111111115111151111111111111111115111151
11111111111511111111111111111111bb78bb111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111
1111111111111111111111111111111bbb88bb111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
111111111111151111111111111111133bb315111111111111111111111115111111111111111111111115111111111111111111111115111111111111111111
11111111115111111111111111111133bbbb31111111111111111111115111111111111111111111115111111111111111111111115111111111111111111111
1511115111111111111111111511115bbbb9cc111111111115111151111111111111111115111151111111111111111115111151111111111111111115111151
111111111111111151111115111111cc9c1ccc115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111
111111115111111511111111111111ccc11111151111111111111111511111151111111111111111511111151111111111111111511111151111111111111111
1111111111111111151111511bbbb111111111111511115111111111111111111511115111111111111111111511115111111111111111111511115111111111
111511111111111111111111bb78bb11111111111111111111151111111111111111111111151111111111111111111111151111111111111111111111151111
11111111111111111111111bbb88bb11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111511111111111111111b3bbb3511111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511
11511111111111111111111b33bb1111111111111111111111511111111111111111111111511111111111111111111111511111111111111111111111511111
1111111111111111151111cc93bb1111111111111511115111111111111111111511115111111111111111111511115111111111111111111511115111111111
1111111151111115111111ccc1c9cc11511111151111111111111111511111151111111111111111511111151111111111111111511111151111111111111111
511111151111111111111111511ccc1511111111111111115111111511111111bbbbbbbb51111115111111111111111151111115111111111111111151111115
111111111511115bbbb111111111111115111151111111111111111115111151b111111b11111111151111511111111111111111151111511111111111111111
11111111111111bb87bb11111111111111111111111511111111111111111111b115111b11111111111111111115111111111111111111111115111111111111
11111111111111bb88bbb1111111111111111111111111111111111111111111b111111b11111111111111111111111111111111111111111111111111111111
11111111111111113bb335111111111111111111111115111111111111111111b111151b11111111111111111111151111111111111111111111151111111111
1111111111111113bbbb33111111111111111111115111111111111111111111b151111b11111111111111111151111111111111111111111151111111111111
11111111151111cc9bbbb1111111111115111151111111111111111115111151b111111b11111111151111511111111111111111151111511111111111111111
51111115111111ccc1c9cc115111111511111111111111115111111511111111bbbbbbbb51111115111111111111111151111115111111111111111151111115
1111111111111111511ccc1511111111111111115111111511aaaa1111aaaa1156666665149cc941111111115111111511555111111111115111111511111111
15111151111111111111111115111151111111111111111115aaaa5111aaaa1166dddd6649944994131111311311113115666551111111111111111115111151
111111111115111111111111111111111115111111111111aa9999aaaa9999aa6ddeedd699999999113bb311113bb31156656651111511111111111111111111
11111111111bbbb111111111111111111111111111111111aa9449aaaa9449aa6de27ed6c492294c11b33b1111b33b11565c5651111111111111111111111111
1111111111bb78bb10611111111111111111151111111111aa9449aaaa9449aa6de22ed6c492294c11b33b1111b33b1156656651111115111111111111111111
111111111bbb88bb10011111111111111151111111111111aa9999aaaa9999aa6ddeedd699999999113bb311113bb31115666511115111111111111111111111
151111511b3bbb311111111115111151111111111111111115aaaa5111aaaa1166dddd6649944994131111311311113115555151111111111111111115111151
111111111b33bb115111111511111111111111115111111511aaaa1111aaaa1156666665149cc941111111115111111511111111111111115111111511111111
11111111cc93bb15116661111111111151555115149cc94111111111511111151111111111111111511111151111111111111111566666651111111111555111
11111111ccc1c9cc165556511311113115666511499449941111111111111111151111511111111111111111151111511111111166dddd661311113115666511
1115111111111ccc65c9c561113bb3115665665199999999111511111111111111111111111511111111111111111111111511116ddeedd6113bb31156656651
11111111111bbbb16598956111b33b11565c5651c492294c111111111111111111111111111111111111111111111111111111116de27ed611b33b11565c5651
1111151111bb78bb6889c56111b33b1156656651c492294c1bbbb5111111111111111111111115111111111111111111111115116de22ed611b33b1156656651
115111111bbb88b886555611113bb3111566651199999999bb87bb111111111111111111115111111111111111111111115111116ddeedd6113bb31115666511
11111111133bb88115666151131111311155511149944994bb88bbb111111111151111511111111111111111151111511111111166dddd661311113111555111
1111111133bb8b35111111111111111151111115149cc941113bb331511111151111111111111111511111151111111111111111566666651111111111111111
511111151bbbb9cc1bbbb111511bbbb5111bbbb1111111bbb3bb88336788887616666661aa1111aaaa1111aa1155511151111115111111111111111151111115
11111111cc9c1cccbb78bb1111bb78bb15bb87bb11111bb7cc9bbb88722ee22766dddd66aab11baaaab11baa1566651111111111151111511111111111111111
11111111ccc1111bbb88bb111bbb88bb11bb88bbb115bbb8ccc199cc88e22e286ddeedd61babbab11babbab15665665111111111111111111115111111111111
11111111111111133bb311111b3bbb3111113bb33111b3bbb31999cc8e8872e86de27ed611b99b1111b99b11565c565111111111111111111111111111111111
1111111111111133bbbb35111b33bb111113bb8b3311b33bb11999118e2772e86de22ed611b99b1111b99b115665665111111111111111111111151111111111
111111111111111bbbb9cc11cc93bb1111cc9b8bb15cc93bb111911182e22e286ddeedd61babbab11babbab11566651111111111111111111151111111111111
11111111151111cc9c1ccc11ccc1c9cc15ccc8c9cc1ccc1c9cc11111722ee22766dddd66aab11baaaab11baa1155511111111111151111511111111111111111
51111115111111ccc111111151111ccc1111181ccc111111ccc111156788887616666661aa1111aaaa1111aa1111111151111115111111111111111151111115
11111111111111115155511511666111116681115155511516666661111111115111111511111111111111115111111511555111115551115155511511111111
15111151111111111566651116555651165586111566651166dddd66111061111111111115111151111111111111111115666551156665111566651115111151
11111111111511115665665165c9c56165c8c561566566516ddeedd6111001111111111111111111111511111111111156656651566566515665665111111111
1111111111111111565c5651659c956165989561565c56516de27ed61111111111111111111111111111111111111111565c5651565c5651565c565111111111
11111111111115115665665165c9c56165c9c561566566516de22ed6111115111111111111111111111115111111111156656651566566515665665111111111
1111111111511111156665111655561116555611156665116ddeedd6115111111111111111111111115111111111111115666511156665111566651111111111
15111151111111111155511115666151116661111155511166dddd66111111111111111115111151111111111111111115555151115551111155511115111151
11111111111111115111111511111111111111115111111516666661111111115111111511111111111111115111111511111111111111115111111511111111
11111111511111151111111111111111511111151111111111e2e111511111151155511111aaaa1151e2e1151111111111111111511111151155511111111111
1111111111111111151111511111111111111111151111511172211111111111156665511aa99aa111eee1111511115111111111111111111566655111111111
111511111111111111111111111511111111111111111111e2ccc2e11111111156656651aa9449aaee222ee11111111111151111111111115665665111151111
11111111111111111111111111111111111111111111111122c1c22111111111565c5651a94bb49a2e252e21111111111111111111111111565c565111111111
111115111111111111111111111115111111111111111111e2ccc2e11111111156656651a94bb49aee222ee11111111111111511111111115665665111111511
115111111111111111111111115111111111111111111111112221111111111115666511aa9449aa11eee1111111111111511111111111111566651111511111
11111111111111111511115111111111111111111511115111e2e11111111111155551511aa99aa111e2e1111511115111111111111111111555515111111111
11111111511111151111111111111111511111151111111111111111511111151111111111aaaa11511111151111111111111111511111151111111111111111
51111115111111111111111151111115111111111111111151555115111111111111111151111115111111111155511151555115111111111155511151111115
11111111151111511111111111111111151111511111111115666511151111511111111111111111151111511566651115666511151111511566651111111111
11111111111111111115111111111111111111111115111156656651111111111115111111111111111111115665665156656651111111115665665111111111
111111111111111111111111111111111111111111111111565c565111111111111111111111111111111111565c5651565c565111111111565c565111111111
11111111111111111111151111111111111111111111151156656651111111111111151111111111111111115665665156656651111111115665665111111111
11111111111111111151111111111111111111111151111115666511111111111151111111111111111111111566651115666511111111111566651111111111
11111111151111511111111111111111151111511111111111555111151111511111111111111111151111511155511111555111151111511155511111111111
51111115111111111111111151111115111111111111111151111115111111111111111151111115111111111111111151111115111111111111111151111115
11111111111111115111111511111111111111115111111511555111115551115155511511555111111111115155511511111111111111115155511511111111
15111151111111111111111115111151111111111111111115666551156665111566651115666551111111111566651115111151111111111566651115111151
11111111111511111111111111111111111511111111111156656651566566515665665156656651111511115665665111111111111511115665665111111111
111111111111111111111111111111111111111111111111565c5651565c5651565c5651565c565111111111565c56511111111111111111565c565111111111
11111111111115111111111111111111111115111111111156656651566566515665665156656651111115115665665111111111111115115665665111111111
11111111115111111111111111111111115111111111111115666511156665111566651115666511115111111566651111111111115111111566651111111111
15111151111111111111111115111151111111111111111115555151115551111155511115555151111111111155511115111151111111111155511115111151
11111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111111111115111111511111111
11111111511111151111111111111111511111151155511112221222122212221222122212221222511111151155511111111111515551151155511111111111
11111111111111111511115111111111111111111566655121212121212121212121212121212121111111111566655111111111156665111566655111111111
11151111111111111111111111151111111111115665665122122212221222122212221222122212111111115665665111151111566566515665665111151111
1111111111111111111111111111111111111111565c56512121212121212121212121212121212111111111565c565111111111565c5651565c565111111111

__sfx__
00040000216211322101611052110161100611012111e600200001f00026600256002560011700107001b3001b3000f700294002a4002a4002a40006700067000000000000000000000000000000000000000000
00020000112201821034310251201c530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002542014610244200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00003d62020620196100961000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b2101121015210192101c2101f220251102412017610243202f410000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300000d1201e320233202c32031320383203e32006300041102831032310393103f3101420005110273102d310363103f31000000000000000000000000000000000000000000000000000000000000000000
8b0f00101c626001121c600081001011210112001120b2110b2110b2130b211012001c71023110107101b300190001900021000210000a3000a3000a3000a3000a30008000030000100003000070003060030600
211600001d4101b4121b4121b4101b4111b4121b4101d4101d4121f4111f4102241024412294122b4102e4122b41024411224101f4121f4121f4101f4111f4101f4121f4122241027412224101f4112741024410
6916000000413054130741207412074120741207412074120741207412074150741507412074120741207412074120741207412074120741207412074120a4120a4120a4120a4120f4120f4120f4100741005410
b11400201c613001131c600081001011210112001120b2110b2110b2130b211012001c7102311010710000001c613001121c600081001011210112001120b2110b2110b2130b2110b2000b2170b2000b20000000
__music__
01 48484344
00 48474344
00 48474344
00 47424344

