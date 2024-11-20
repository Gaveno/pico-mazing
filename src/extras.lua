-- function spr_r(s,x,y,a,w,h)
--     sw=(w or 1)*8
--     sh=(h or 1)*8
--     sx=(s%8)*8
--     sy=flr(s/8)*8
--     x0=flr(0.5*sw)
--     y0=flr(0.5*sh)
--     a=a/360
--     sa=sin(a)
--     ca=cos(a)
--     for ix=0,sw-1 do
--         for iy=0,sh-1 do
--         dx=ix-x0
--         dy=iy-y0
--         xx=flr(dx*ca-dy*sa+x0)
--         yy=flr(dx*sa+dy*ca+y0)
--             if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
--                 pset(x+ix,y+iy,sget(sx+xx,sy+yy))
--             end
--         end
--     end
-- end

function sprr(n, x, y, r, w, h)
    nw = (w or 1) * 8
    nh = (h or 1) * 8
    nx = (n % 8) * 8
    ny = flr(n / 8) * 8

    if r == 0 then
        spr(n, x, y, w, h)
    elseif r == 1 then
        -- Rotate left 90 degrees
        for i = 0, nw - 1 do
            for j = 0, nh - 1 do
                pset(x + j, y + nh - i, pget(nx + i, ny + j))
            end
        end
    elseif r == 2 then
        spr(n, x, y, w, h, true, true)
    elseif r == 3 then
        -- Rotate left 270 degrees
        for i = 0, nw - 1 do
            for j = 0, nh - 1 do
                pset(x + nw - j, y + i, pget(nx + i, ny + j))
            end
        end
    end
end

function lerp(x, x1, x2)
    return x1 + x * (x2 - x1)
end

function percent_range(x, x1, x2)
    return (x - x1) / (x2 - x1)
end

function lookup(map, key, default)
    if map[key] then
        return map[key]
    end

    return default
end