pico-8 cartridge // http://www.pico-8.com
version 42
__lua__

-- PICO-8 Maze Tower Defense Game

#include grid.lua
#include cursor.lua
#include hud.lua
#include main.lua
#include waves.lua
#include units.lua
#include towers.lua
#include paths.lua
#include projectiles.lua
#include extras.lua

__gfx__
00aaaa0000aaaa009999999951111115111111111111111100000000001111000666666000000000000000000009999999990000000099999999900007000000
00aaaa000aa99aa0999999991111111115111151111111110880088001ccc71060000706000c770000000000009aa99999aa90000009aa99999aa90070000000
aa9999aaaa9449aa0999999011111111111111111115111188888ee81cc777716000070600ccc7700000000009a99aaaaa99a900009a99aaaaa99a9007000000
aa9449aaa94bb49a09999990111111111111111111111111888888e81cc77771060070600ccc00700000000c09a999999779a900009a999999779a9000000000
aa9449aaa94bb49a009999001111111111111111111115118888888801ccc710060070600cc70000000000cc99a999997777a990099a999997777a9900000000
aa9999aaaa9449aa0099990011111111111111111151111108e88880001c710000600600ccc700000000cccc9a99999977779a9009a99999977779a900000000
00aaaa000aa99aa000099000111111111511115111111111008888000001100000600600cc7c0cc000cccccc9a99999977779a9009a99999977779a900000000
00aaaa0000aaaa0000099000511111151111111111111111000880000000000000066000cccccccccccccccc9a99999997799a9009a99999997799a900000000
011111100999999000000000122212221aaaaa11666666611111100100000000ffffffffffffffff0099990099a999999999a990099a999999999a9900000000
1117711197999979000aa00021212121aaaaaaa16666666110610070001cc100ffffffffffffffff09aaaa9009aaa99999aaa900009aa9aaaaa9aa9000000000
117777119779977900aa7a0022122212aaeaeaa16566656110010000011c71100fffff0ffff00fff9a9977a909a99aaaaa99a900009a9aaaaaaa9a9000000000
17711771997777999aaaaaa921212121aaeaeaa165858561111110010ccc77c000f00f0fff07070f9a9997a9009aaaaaaaaa90000009aaaeaeaaa90000000000
1771177199777799999aa99912221222aaaaaaa165656561100100000cccccc00007070ff000000f0a9aa9a00009aaeaeaa9000000009aaeaeaa900000000000
117777119779977900a99a00212121211aaaaf221aaaa94400600670011cc110f00000fff00ff00f09aeea900000aaeaeaa0000000000aaaaaaa000000000000
1117711197999979000aa0002212221222f212224494144408000860001cc100fff00ffff0ffff0f00aaaa000000aaaaaaa00000000000a999a0000000000000
0111111009999990000000002121212122211111444111111001000000000000ffffffffffffffff00a99a0000000a999a000000000000000000000000000000
0006600000677600000000000000aa000aaa0000000bbbb0000bbbb0000000000000000000bb0000000000000009999999990000009990000099900000000000
066dd660078998700077700000888000008a800000bb78bb00bb78bb20000002000000000ba900a900090000009aa99999aa9000009a9999999a900000000000
06d66d6068988986007570000aa9800000898aa00bbb88bb0bbb88bb02aaaa2000aaaa00ba980a980098000809a99aaaaa99a9000009a99999a9000000000000
6d6d76d6798a989700777000a088800000a8a000033bb3000b3bbb3000aeea0022aeea22ba980a980098000809a999999779a90000099aaaaa99000000000000
6d6dd6d6798aa897066566000665a60006a5660033bbbb300b33bb0000aeea0022aeea220ba900a90009000099a999997777a9900009a99999a9000000000000
06d66d60689889860665660006656a000a6566000bbbb9cccc93bb0002aaaa2000aaaa0000bb0000000000009a99999977779a900009a99979a9000000000000
066dd66007899870066666000666660006666600cc9c0cccccc0c9cc200000020000000000000000000000009a99999977779a90009a9999799a900000000000
0006600000677600006660000066600000666000ccc0000000000ccc000000000000000000000000000000009a99999997799a90009a9999979a900000000000
066666606788887600e2e00000e2e0000cccccc00cccc940049cc940049cc940049cc940049449400494494099a999999999a99009a999999999a90000000000
66dddd66722ee22700eee00000222000c99cc99cc99c4994499449944994499449944994499999944a8998a409aaa99999aaa90009aaaaaaaaaaa90000000000
6ddeedd682e22e28ee222ee0e2ccc2e0c994499cc99499999999999999999999999999999992299998aaaa8909a999999999a90009a9aeeaeea9a90000000000
6de27ed68e2772e82e252e2022c1c220cc4994cccc49294cc492294cc492294cc492294c4922229449aaaa94009aaaa9aaaa9000009aaaaaaaaa900000000000
6de22ed68e2272e8ee222ee0e2ccc2e0cc4994cccc4994cccc4994ccc49294ccc492294c4922229449aaaa940009aaaaaaa900000009a99999a9000000000000
6ddeedd682e22e2800eee00000222000c994499cc994499cc994499c9999499c999999999992299998aaaa890000aeeaeea00000000091111190000000000000
66dddd66722ee22700e2e00000e2e000c99cc99cc99cc99cc99cc99c4994c99c49944994499999944a8998a40000aaaaaaa00000000092222290000000000000
066666606788887600000000000000000cccccc00cccccc00cccccc0049cccc0049cc940049449400494494000000aa9aa000000000099444990000000000000
00877000008770000008000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00075790000757900088850000888500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700007777000008779000087790000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777700077777000067778000677780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700777777000677770006777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777700777777000777770007777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77900990779909000099090000900990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00990000000009900000099000990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000008000000080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00087700000877000088850066688500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777570666775700668777067767770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777779777677796777777967777779000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77776770777777707777677877777778000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66667700077777006666778007777780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09909900099099000090900000909000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
