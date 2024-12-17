-- Variables
game_state = 'title' -- 'title', 'normal', 'tower_menu', 'sell_menu', 'victory', 'defeat'
title_y = 0
title_lines = {}
title_line_spawn = 0
title_transition = false
show_game_name = false
game_difficulty = -1
exp_timer = 0
exp_x = 0
exp_y = 0
fmsc = 0

-- Playthrough Stats
units_killed = 0
elites_killed = 0
bosses_killed = 0
towers_built = 0
towers_sold = 0


-- Initialize grid and game elements
function _init()
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
    fmsc = 0
    sfx(6, 3)

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
        update_exp_fx()
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

function create_line(x, y, dir)
    return {
        x = x,
        y = y,
        spd = 1,
        dir = dir,
        col = 8 + flr(rnd(5)),
        len = flr(rnd(10)) + 2
    }
end

function update_title()
    if not title_transition then
        if title_line_spawn > 0 then
            title_line_spawn -= 1
        end

        if title_line_spawn == 0 then
            add(title_lines, create_line(-1, rnd(SCREEN_HEIGHT), 0))
            add(title_lines, create_line(-SCREEN_WIDTH, rnd(SCREEN_HEIGHT), 0.5))
            add(title_lines, create_line(rnd(SCREEN_WIDTH), -1, 0.75))
            add(title_lines, create_line(rnd(SCREEN_WIDTH), SCREEN_HEIGHT, 0.25))
            title_line_spawn = 5
        end
    else
        if title_line_spawn > 0 then
            title_line_spawn -= 1
        else
            if game_difficulty == -1 then
                title_transition = false
                game_difficulty = 0
                diff_sel = false
            else
                game_state = 'normal'
                sfx(-2, 3)
                sfx(9, 3)
                title_lines = {}
            end
        end
    end

    -- Update title lines
    for i in all(title_lines) do
        if title_transition then
            i.dir = atan2(i.x - 64, i.y - 80)
            i.spd = 4
        end

        i.x += cos(i.dir) * i.spd
        i.y += sin(i.dir) * i.spd
        if i.x < -10 or i.x > 138 or i.y < -10 or i.y > 138 then
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

    if game_difficulty ~= -1 then
        --  and (btnp(2) or btnp(3)) then
        if btnp(2) then
            game_difficulty = (game_difficulty - 1) % 3
        elseif btnp(3) then
            game_difficulty = (game_difficulty + 1) % 3
        end
    end
end

function update_exp_fx()
    if exp_timer > 0 then
        exp_timer -= 1
        if exp_timer % 3 == 0 then
            create_explosion(exp_x + rnd(16), exp_y + rnd(16), 1 + flr(rnd(3)), 0, nil)
        end

        if exp_timer == 0 and lives <= 0 then 
            game_state = 'defeat'
        end
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

    if game_difficulty >= 0 and (not title_transition or title_line_spawn % 2 == 0) then
        draw_selector(8, 47, 80 + 12 * game_difficulty)
        print("normal", 52, 80, 0)
        print("hard", 55, 92, 0)
        print("legendary", 46, 104, 0)
    end

    print("bY gAVIN AND jACE aTKIN", 20, 120, 7)
end

function draw_selector(width, x, y)
    for i = 0, width do
        circfill(x + i * 4, y + 4 * (i + t()) % 3, 5, 7)
    end
end

function draw_victory_screen()
    cls(1)
    camera()
    print("victory!", 44, 20, 10)
    draw_stats()
end

function draw_defeat_screen()
    cls(1)
    camera()
    print("defeat!", 49, 20, 8)
    draw_stats()
end

function draw_stats()
    spr(75 + game_difficulty, 5, 5)
    print("waves survived "..(wave_number - 2), 30, 30, 12)
    print("bosses killed  "..bosses_killed, 30, 40, 12)
    print("elites killed  "..elites_killed, 30, 50, 12)
    print("units killed   "..units_killed, 30, 60, 12)
    print("lives lost     "..(6 - lives), 30, 70, 12)
    print("towers built   "..towers_built, 30, 80, 12)
    print("towers sold    "..towers_sold, 30, 90, 12)

    print("press x or o to restart", 16, 106, 7)
end
