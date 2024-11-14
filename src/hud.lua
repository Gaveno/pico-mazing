-- Constants
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
HUD_HEIGHT = 16

-- Variables
lives = 6
diamonds = 5
next_unit_type = nil

function draw_hud()
     -- Black background
    rectfill(0, 0, SCREEN_WIDTH - 1, HUD_HEIGHT, 0)

    -- Draw lives
    for i = 1, lives do
        local hi = (i - 1) % 3
        local hx = hi * 8 + hi
        local hy = ceil(i / 3 - 1) * 8
        spr(6, hx, hy) -- Heart
    end

    -- Draw diamonds
    for i = 1, min(diamonds+1, 19) do
        local di = (i - 1) % 9
        local dx = di * 8 --+ di
        local dy = ceil(i / 9 - 1) * 8
        if i == 18 and diamonds+1 >= 19 then
            spr(23, SCREEN_WIDTH - dx, dy)
        else
            spr(7, SCREEN_WIDTH - dx, dy) -- Diamond
        end
    end

    -- Draw wave information
    local hourglass_x = SCREEN_WIDTH / 2 - 12
    local hourglass_progress = max(0, (WAVE_PREP_TIME - wave_timer) / WAVE_PREP_TIME * 6)
    for i = 1, 6 do
        -- 1 -> x + 1, 6 0-17%, 17-100%
        -- 2 -> x + 1, 6 0-33%, 33-100%
        -- 3 -> x + 2, 4 0-49%, 49-100%
        -- 4 -> x + 2, 4 0-65%, 65-100%
        -- 5 -> x + 3, 2 0-81%, 81-100%
        -- 6 -> x + 3, 2 0-100%, 99-100%
        -- Top
        if hourglass_progress < i-0.5 then
            line(hourglass_x + ceil(i/2), i, hourglass_x + 7 - ceil(i/2), i, 14)
        end
        -- Bottom
        if hourglass_progress >= i-0.5 then
            line(hourglass_x + ceil(i/2), 15 - i, hourglass_x + 7 - ceil(i/2), 15 - i, 14)
        end
    end
    spr(8, hourglass_x, 0)
    spr(8, hourglass_x, 8, 1, 1, false, true)

    -- Draw next unit info
    if wave_number < 30 then
        next_unit_type.draw({lifetime = wave_timer}, 28, 0)
        print("x"..(get_wave_unit_total(wave_number)), 38, 2, 7)
        spr(9, 28, 8)
        print(wave_number, 38, 11, 7)
    end
end