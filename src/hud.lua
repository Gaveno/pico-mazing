-- Constants
SCREEN_WIDTH = 128
SCREEN_HEIGHT = 128
HUD_HEIGHT = 16

-- Variables
lives = 6
diamonds = 5
next_unit_type = nil
diamond_wave = 0

function draw_hud()
     -- Black background
    rectfill(0, 0, SCREEN_WIDTH - 1, HUD_HEIGHT, 0)

    -- Draw lives
    for i = 1, lives do
        local hi = (i - 1) % 3
        local hx = hi * 8 + hi
        local hy = ceil(i / 3 - 1) * 8
        spr(6, hx, hy)
    end

    -- Draw diamonds
    local tower_cost = 0
    if game_state == 'tower_menu' then
        tower_cost = tower_types[tower_menu_index].cost
        diamond_wave = (diamond_wave + 1) % 100
    end

    local total = min(diamonds-1, 15)

    for i = 0, total do
        local di = i % 8
        local dx = 8 + di * 8
        local dy = flr(i / 8) * 8
        if tower_cost ~= 0 and tower_cost >= diamonds-i or i == 15 then
            dy += sin((diamond_wave - i) % 10 / 10)
        end

        if i == 15 and diamonds > 15 then
            spr(23, SCREEN_WIDTH - dx, dy)
        else
            spr(7, SCREEN_WIDTH - dx, dy)
        end
    end

    -- Draw wave information
    local hourglass_x = SCREEN_WIDTH / 2 - 12
    local hourglass_progress = max(0, (WAVE_PREP_TIME - wave_timer) / WAVE_PREP_TIME * 6)
    for i = 1, 6 do
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
    if wave_number <= 35 then
        next_unit_type.draw({lifetime = wave_timer, elite = contains(elite_waves, wave_number)}, 28, 0)
        print("x"..(get_wave_unit_total(wave_number)), 38, 2, 7)
        spr(9, 28, 8)
        print(wave_number, 38, 11, 7)
    end
end