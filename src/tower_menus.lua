-- Variables
building_coroutine = nil
found_build_path = false

function tower_set(x, y, t)
    towers[x .. ',' .. y] = t
end

function update_tower_menu()
    process_tower_build_path(building_coroutine)
    if building_coroutine ~= nil then
        return
    end

    if tower_menu_open_delay > 0 then
        tower_menu_open_delay -= 1
        return
    end

    if tower_menu_shake > 0 then
        tower_menu_shake -= 1
    end

    if btnp(3) then -- Down
        tower_menu_index -= 1
        if tower_menu_index < 1 then
            tower_menu_index = #tower_types
        end
    elseif btnp(2) then -- Up
        tower_menu_index += 1
        if tower_menu_index > #tower_types then
            tower_menu_index = 1
        end
    elseif btnp(5) then -- Button X to build
        local tower_type = tower_types[tower_menu_index]
        if diamonds >= tower_type.cost then
            build_tower(cursor.x, cursor.y, tower_type)
            game_state = 'normal'
        else
            -- Not enough diamonds
            tower_menu_shake = 5
        end
    elseif btnp(4) then -- Button O to cancel
        game_state = 'normal'
    end
end

-- Update sell menu interactions
function update_sell_menu()
    if tower_menu_open_delay > 0 then
        tower_menu_open_delay -= 1
        return
    end

    if btnp(5) then -- Button X to confirm sell
        sell_tower(cursor.x, cursor.y)
        game_state = 'normal'
    elseif btnp(4) then -- Button O to cancel
        game_state = 'normal'
    end
end

function build_tower(x, y, tower_type)
    sfx(0, 0, 0, 6)

    towers_built += 1

    -- Place the tower
    tower_set(x, y, {
        x = x,
        y = y,
        type = tower_type,
        cooldown = 0,
        target_unit = nil
    })
    diamonds -= tower_type.cost
    check_invalid_nodes = true
end

function sell_tower(x, y)
    local tower = get_tower_at(x, y)
    if tower then
        local refund = ceil(tower.type.cost * 0.75)
        diamonds += refund
        towers_sold += 1
        tower_set(x, y, nil)
    end
end

function can_build_tower_at(x, y)
    if grid[x][y].can_build and grid[x][y].unit_id == nil and get_tower_at(x, y) == nil then
        tower_set(x, y, {
            x = x,
            y = y,
            type = tower_types[1],
            cooldown = 0
        })
        local spawn_x = 8
        local spawn_y = 1
        building_coroutine = find_path_coroutine(EXIT_X + 2, EXIT_Y, spawn_x, spawn_y, 15)
        found_build_path = false
    else
        game_state = 'normal'
        cursor_cannot_build_timer = 30
    end
end

function process_tower_build_path(path_co)
    if not found_build_path then
        if building_coroutine ~= nil then
            local path = nil
            building_coroutine, path = process_path_coroutine(building_coroutine)

            if path ~= nil then
                tower_set(cursor.x, cursor.y, nil)
                found_build_path = true
            end
        else
            cursor_cannot_build_timer = 30
            game_state = 'normal'
            tower_set(cursor.x, cursor.y, nil)
        end
    end
end

function draw_towers()
    for key, tower in pairs(towers) do
        local x = (tower.x - 1) * CELL_SIZE
        local y = (tower.y - 1) * CELL_SIZE
        tower.type.draw(tower, x, y)
    end
end

function draw_tower_menu()
    if building_coroutine ~= nil then
        local x = (cursor.x - 1) * CELL_SIZE
        local y = (cursor.y - 1) * CELL_SIZE
        rectfill(x, y, x + CELL_SIZE - 2, y + CELL_SIZE - 2, 1)
        circ(x + CELL_SIZE / 2 - 1, y + CELL_SIZE / 2 - 1, cursor_size % 5, 12)
        return
    end

    local cursor_y = -1
    if cursor.y <= 8 then
        cursor_y = 6
    end
    local x = mid(0, (cursor.x - 2) * CELL_SIZE - 18 + tower_menu_shake % 3, GRID_WIDTH * CELL_SIZE - POPUP_MENU_WIDTH)
    local y = mid(25, (cursor.y + cursor_y) * CELL_SIZE - POPUP_MENU_HEIGHT - 10 + tower_menu_shake % 2, GRID_HEIGHT * CELL_SIZE - POPUP_MENU_HEIGHT)

    -- Draw menu background
    rectfill(x, y, x + POPUP_MENU_WIDTH, y + POPUP_MENU_HEIGHT, 0)

    -- Draw selected tower
    local tower_type = tower_types[tower_menu_index]
    tower_type.draw({cooldown = 0, type = tower_type}, x + 10, y + POPUP_MENU_HEIGHT / 2 - 4)

    -- Draw cost
    local cost = tower_type.cost
    for i = 1, cost do
        if i > diamonds then
            pal(12, 8)
        end
        spr(7, x + 21 + ((i - 1) % 4) * 8, y + flr((i - 1) / 4) * 8 + 2)
    end
    pal()

    -- Draw tower stats
    -- Attack type
    local stat_start_y = y + 1

    if tower_type.attack_type == 'laser' then
        line(x + 2, stat_start_y + 1, x + 6, stat_start_y + 5, 7)
    else
        circ(x + 4, stat_start_y + 2, tower_type.splash, 7)
    end

    -- Power
    local power_width = 6
    for i = 1, ceil(tower_type.attack_power / MAX_TOWER_POWER * power_width)  do
        local line_bottom = flr(stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 1.5)
        local line_x = x + 8 - i
        line(line_x, line_bottom - ceil(i * 0.6), line_x, line_bottom, 10 - flr((i-1) / power_width * 3))
    end

    -- Range
    local range_number = flr((tower_type.attack_range - MIN_TOWER_RANGE - 2) / MAX_TOWER_RANGE * 4)
    local range_image_x = 84 - range_number * 4
    sspr(range_image_x, 16, 4, 6, x + 3, stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 2 - 1)

    -- Attack Speed
    local practical_attack_speed = tower_type.attack_speed
    if tower_type.attack_type == 'laser' then
        practical_attack_speed = practical_attack_speed / 3
    end

    local attack_percent = percent_range(
        (MAX_TOWER_ATTACK_SPEED - practical_attack_speed + 15),
        MIN_TOWER_ATTACK_SPEED, MAX_TOWER_ATTACK_SPEED
    )
    local images = ceil(attack_percent * 3)
    pal(7, 8 + flr(attack_percent * 4))
    for i = 1, images do 
        sspr(120, 0, 2, 4, x + i * 3, stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 3)
    end
    pal()

    -- Arrows
    if btn(2) then
        pal(12, 10)
    end
    spr(10, x + POPUP_MENU_WIDTH/2 - 6, y - 9)
    spr(10, x + POPUP_MENU_WIDTH/2 + 2, y - 9, 1, 1, true, false)
    pal()
    if btn(3) then
        pal(12, 10)
    end
    spr(10, x + POPUP_MENU_WIDTH/2 - 6, y + POPUP_MENU_HEIGHT + 2, 1, 1, false, true)
    spr(10, x + POPUP_MENU_WIDTH/2 + 2, y + POPUP_MENU_HEIGHT + 2, 1, 1, true, true)
    pal()
end

function draw_sell_menu()
    local x = mid(0, (cursor.x - 1) * CELL_SIZE - 20, GRID_WIDTH * CELL_SIZE - POPUP_MENU_WIDTH)
    local y = mid(0, (cursor.y - 1) * CELL_SIZE - 10, GRID_HEIGHT * CELL_SIZE - POPUP_MENU_HEIGHT)

    rectfill(x, y, x + POPUP_MENU_WIDTH, y + POPUP_MENU_HEIGHT, 0)
    local tower = get_tower_at(cursor.x, cursor.y)
    tower.type.draw({cooldown = 0, type = tower.type}, x + 2, y + 14)
    spr(2, x + 10, y + 14)
    print("sell", x + 2, y + 4, 10)
    line(x + 20, y + 2, x + 20, y + 24, 10)

    local refund = ceil(tower.type.cost * 0.75)
    for i = 1, refund do
        spr(7, x + 22 + ((i - 1) % 4) * 8, y + flr((i - 1) / 4) * 8 + 2)
    end
end