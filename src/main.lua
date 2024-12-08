-- Variables
game_state = 'title' -- 'title', 'normal', 'tower_menu', 'sell_menu', 'victory', 'defeat'
title_y = 0
title_lines = {}
title_line_spawn = 0
title_transition = false
show_game_name = false
game_difficulty = -1

-- Playthrough Stats
units_killed = 0
elites_killed = 0
bosses_killed = 0
towers_built = 0
towers_sold = 0


-- Initialize grid and game elements
function _init()
    printh("---- Game start ----")
    init_grid()

    -- Reset game variables
    lives = 6
    diamonds = 5
    wave_number = 1
    wave_timer = WAVE_PREP_TIME
    wave_running = false
    units = {}
    towers = {}
    explosions = {}
    projectiles = {}
    title_lines = {}
    title_line_spawn = 0
    title_transition = false
    game_state = 'title'
    game_difficulty = -1
    cursor = {x = GRID_WIDTH/2, y = GRID_HEIGHT-4}
    next_unit_type = unit_types_list['Walker']
    wave_spawning_unit_type = next_unit_type
    title_y = -32

    -- Playthrough Stats
    units_killed = 0
    bosses_killed = 0
    towers_built = 0
    towers_sold = 0
    lives_lost = 0

    prep_wave()
end

function _update()
    update_cursor()
    if game_state == 'title' then
        update_title()
    elseif game_state == 'normal' then
        update_units()
        update_towers()
        update_projectiles()
        update_explosions()
        update_waves()
    elseif game_state == 'tower_menu' then
        update_tower_menu()
    elseif game_state == 'sell_menu' then
        update_sell_menu()
    elseif game_state == 'victory' or game_state == 'defeat' then
        if btnp(5) or btnp(4) then
            _init()
        end
    end

    if btnp(5) and btnp(4) then
        show_game_name = (not show_game_name)
    end
end

function update_title()
    if not title_transition then
        if title_line_spawn > 0 then
            title_line_spawn -= 1
        end

        if title_line_spawn == 0 then
            local line_left = {
                x = -1,
                y = rnd(SCREEN_HEIGHT),
                spd = 1,
                dir = 0,
                col = 8 + flr(rnd(5)),
                len = flr(rnd(10)) + 2
            }
            add(title_lines, line_left)
            local line_right = {
                x = SCREEN_WIDTH,
                y = rnd(SCREEN_HEIGHT),
                spd = 1,
                dir = 0.5,
                col = 8 + flr(rnd(5)),
                len = flr(rnd(10)) + 2
            }
            add(title_lines, line_right)
            local line_top = {
                x = rnd(SCREEN_WIDTH),
                y = -1,
                spd = 1,
                dir = 0.75,
                col = 8 + flr(rnd(5)),
                len = flr(rnd(10)) + 2
            }
            add(title_lines, line_top)
            local line_bottom = {
                x = rnd(SCREEN_WIDTH),
                y = SCREEN_HEIGHT,
                spd = 1,
                dir = 0.25,
                col = 8 + flr(rnd(5)),
                len = flr(rnd(10)) + 2
            }
            add(title_lines, line_bottom)
            title_line_spawn = 5
        end
    else
        if title_line_spawn > 0 then
            title_line_spawn -= 1
        else
            if game_difficulty == -1 then
                title_transition = false
                game_difficulty = 0
            else
                game_state = 'normal'
                title_lines = {}
            end
        end
    end

    -- Update title lines
    for i in all(title_lines) do
        if title_transition then
            local text_y = 80
            local text_x = SCREEN_WIDTH / 2
            i.dir = atan2(i.x - text_x, i.y - text_y)
            i.spd = 4
        end

        i.x += cos(i.dir) * i.spd
        i.y += sin(i.dir) * i.spd
        if i.x < -10 or i.x > SCREEN_WIDTH + 10 or i.y < -10 or i.y > SCREEN_HEIGHT + 10 then
            del(title_lines, i)
        end
    end

    if title_y < 30 then
        title_y += 3

        if btnp(5) or btnp(4) then
            title_y = 30
        end

        return
    end

    if btnp(5) or btnp(4) then
        title_transition = true
        title_line_spawn = 30
        sfx(5, 0, 0, 18)
    end

    if game_difficulty ~= -1 and (btnp(2) or btnp(3)) then
        game_difficulty = (game_difficulty + 1) % 2
    end
end


function _draw()
    cls(11)
    draw_grid()
    spr(96, 6 * CELL_SIZE, 18 * CELL_SIZE, 2, 2)
    spr(96, 8 * CELL_SIZE, 18 * CELL_SIZE, 2, 2)
    draw_towers()
    draw_units()
    draw_projectiles()
    draw_explosions()
    if show_game_name then
        palt(0, false)
        palt(1, true)
        spr(128, 6, 30, 15, 4)
        palt()
    end
    draw_cursor()

    if game_state == 'title' then
        draw_title()
        return
    elseif game_state == 'tower_menu' then
        draw_tower_menu()
    elseif game_state == 'sell_menu' then
        draw_sell_menu()
    elseif game_state == 'victory' then
        draw_victory_screen()
        return
    elseif game_state == 'defeat' then
        draw_defeat_screen()
        return
    end

    if not show_game_name then
        camera()
        draw_hud()
        draw_boss_healthbar()
    end
end

function draw_title()
    cls(1)
    camera()

    for i in all(title_lines) do
        local line_length = 8
        local prev_x = i.x + cos(i.dir + 0.5) * i.len
        local prev_y = i.y + sin(i.dir + 0.5) * i.len
        line(prev_x, prev_y, i.x, i.y, i.col)
    end

    palt(0, false)
    palt(1, true)
    spr(128, 6, -sin(percent_range(title_y, 0, 30) / 4) * 30, 15, 4)
    palt()

    if title_y >= 30 and game_difficulty == -1 then
        if not title_transition or title_line_spawn % 2 == 0 then
            draw_selector(12, 37, 80)
            print("press x or o", 37, 80, 0)
        end
    end

    if game_difficulty >= 0 then
        draw_selector(6, 50, 80 + 12 * game_difficulty)
        print("normal", 52, 80, 0)
        print("hard", 55, 92, 0)
    end

    print("bY gAVIN AND jACE aTKIN", 20, 120, 7)
end

function draw_selector(width, x, y)
    for i = 0, width, 1 do
        circfill(x + i * 4, y + 4 * (i + t()) % 3, 5, 7)
    end
end

function draw_victory_screen()
    cls(1)
    camera()
    print("victory!", SCREEN_WIDTH / 2 - 20, 20, 10)
    draw_stats()
end

function draw_defeat_screen()
    cls(1)
    camera()
    print("defeat!", SCREEN_WIDTH / 2 - 15, 20, 8)
    draw_stats()
end

function draw_stats()
    print("waves survived "..(wave_number - 2), 30, 30, 12)
    print("bosses killed  "..bosses_killed, 30, 40, 12)
    print("elites killed  "..elites_killed, 30, 50, 12)
    print("units killed   "..units_killed, 30, 60, 12)
    print("lives lost     "..(6 - lives), 30, 70, 12)
    print("towers built   "..towers_built, 30, 80, 12)
    print("towers sold    "..towers_sold, 30, 90, 12)

    print("press x or o to restart", 16, 106, 7)
end
