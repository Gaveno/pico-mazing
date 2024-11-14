-- Variables
game_state = 'normal' -- 'normal', 'tower_menu', 'sell_menu', 'victory', 'defeat'


-- Initialize grid and game elements
function _init()
    init_grid()

    -- Reset game variables
    lives = 6
    diamonds = 5
    wave_number = 1
    wave_timer = WAVE_PREP_TIME
    units = {}
    towers = {}
    explosions = {}
    projectiles = {}
    game_state = 'normal'
    cursor = {x = GRID_WIDTH/2, y = GRID_HEIGHT-4}
    next_unit_type = unit_types_list['Circle']

    -- Debug
    -- test_path = find_path(1, 1, GRID_WIDTH / 2, GRID_HEIGHT-1)
    -- printh("path length: "..#test_path)
end

function _update()
    update_cursor()
    if game_state == 'normal' then
        update_units()
        update_towers()
        update_projectiles()
        update_explosions()
        update_waves()
    elseif game_state == 'tower_menu' then
        update_tower_menu()
    elseif game_state == 'sell_menu' then
        update_sell_menu()
    elseif game_state == 'victory' then
        if btnp(5) or btnp(4) then
            _init()
        end
    end
end


function _draw()
    cls(11)
    draw_grid()
    draw_towers()
    draw_units()
    draw_projectiles()
    draw_explosions()
    draw_cursor()

    -- sprr(0, 8, 8, 0)
    -- sprr(0, 8, 16, 1)
    -- sprr(0, 8, 24, 2)
    -- sprr(0, 8, 32, 3)
    
    if game_state == 'tower_menu' then
        draw_tower_menu()
    elseif game_state == 'sell_menu' then
        draw_sell_menu()
    elseif game_state == 'victory' then
        draw_victory_screen()
    elseif game_state == 'defeat' then
        draw_defeat_screen()
    end

    camera()
    draw_hud()
end

function draw_victory_screen()
    -- rectfill(0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, 0) -- Black background
    cls(0)
    camera()
    print("Victory!", SCREEN_WIDTH / 2 - 20, SCREEN_HEIGHT / 2 - 10, 7)
    print("Press X or O to Restart", SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2, 7)
end

function draw_defeat_screen()
    -- rectfill(0, 0, SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1, 0) -- Black background
    cls(0)
    camera()
    print("Defeat - "..(wave_number - 1).." waves finished", SCREEN_WIDTH / 2 - 20, SCREEN_HEIGHT / 2 - 10, 7)
    print("Press X or O to Restart", SCREEN_WIDTH / 2 - 40, SCREEN_HEIGHT / 2, 7)
end
