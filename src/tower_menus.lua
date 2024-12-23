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
        -- local refund = ceil(tower.type.cost * 0.75)
        diamonds += get_sell_price(tower)
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
    for _, tower in pairs(towers) do
        local x = grid_to_room(tower.x)
        local y = grid_to_room(tower.y)
        tower.type.draw(tower, x, y)
    end
end

function draw_tower_menu()
    if building_coroutine then
        local x, y = grid_to_room(cursor.x), grid_to_room(cursor.y)
        rectfill(x, y, x + CELL_SIZE - 2, y + CELL_SIZE - 2, 1)
        circ(x + CELL_SIZE / 2 - 1, y + CELL_SIZE / 2 - 1, cursor_size % 5, 12)
        return
    end

    local cursor_y = cursor.y <= 8 and 6 or -1
    local x = mid(0, (cursor.x - 2) * CELL_SIZE - 18 + tower_menu_shake % 3, GRID_WIDTH * CELL_SIZE - POPUP_MENU_WIDTH)
    local y = mid(25, (cursor.y + cursor_y) * CELL_SIZE - POPUP_MENU_HEIGHT - 10 + tower_menu_shake % 2, GRID_HEIGHT * CELL_SIZE - POPUP_MENU_HEIGHT)

    -- Draw menu background
    rectfill(x, y, x + POPUP_MENU_WIDTH, y + POPUP_MENU_HEIGHT, 0)

    -- Draw selected tower
    local tower_type = tower_types[tower_menu_index]
    tower_type.draw({cooldown = 0, type = tower_type}, x + 10, y + POPUP_MENU_HEIGHT / 2 - 4)

    -- Draw cost
    local cost, stat_start_y = tower_type.cost, y + 1
    for i = 1, cost do
        if i > diamonds then pal(12, 8) end
        spr(7, x + 21 + ((i - 1) % 4) * 8, y + flr((i - 1) / 4) * 8 + 2)
    end
    pal()

    -- Draw tower stats
    -- Attack type
    if tower_type.attack_type == 'laser' then
        line(x + 2, stat_start_y + 1, x + 6, stat_start_y + 5, 7)
    else
        circ(x + 4, stat_start_y + 2, tower_type.splash, 7)
    end

    -- Power
    local power_width = 6
    for i = 1, ceil(tower_type.attack_power / MAX_TOWER_POWER * power_width) do
        local line_x = x + 8 - i
        local line_bottom = flr(stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 1.5)
        line(line_x, line_bottom - ceil(i * 0.6), line_x, line_bottom, 10 - flr((i - 1) / power_width * 3))
    end

    -- Range
    local range_number = flr((tower_type.attack_range - MIN_TOWER_RANGE - 2) / MAX_TOWER_RANGE * 4)
    sspr(84 - range_number * 4, 16, 4, 6, x + 3, stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 2 - 1)

    -- Attack Speed
    local speed_factor = tower_type.attack_type == 'laser' and 3 or 1
    local practical_speed = tower_type.attack_speed / speed_factor
    local attack_percent = percent_range(MAX_TOWER_ATTACK_SPEED - practical_speed + 15, MIN_TOWER_ATTACK_SPEED, MAX_TOWER_ATTACK_SPEED)
    local images = ceil(attack_percent * 3)
    pal(7, 8 + flr(attack_percent * 4))
    for i = 1, images do
        sspr(120, 0, 2, 4, x + i * 3, stat_start_y + POPUP_MENU_TOWER_STAT_SEP * 3)
    end
    pal()

    -- Arrows
    if btn(2) then pal(12, 10) end
    spr(10, x + POPUP_MENU_WIDTH/2 - 6, y - 9)
    spr(10, x + POPUP_MENU_WIDTH/2 + 2, y - 9, 1, 1, true, false)
    pal()
    if btn(3) then pal(12, 10) end
    spr(10, x + POPUP_MENU_WIDTH/2 - 6, y + POPUP_MENU_HEIGHT + 2, 1, 1, false, true)
    spr(10, x + POPUP_MENU_WIDTH/2 + 2, y + POPUP_MENU_HEIGHT + 2, 1, 1, true, true)
    pal()

    draw_confirm_cancel_menu()
end

function draw_sell_menu()
    -- Calculate menu position to stay within the screen
    local x = mid(0, grid_to_room(cursor.x) - 20, GRID_WIDTH * CELL_SIZE - POPUP_MENU_WIDTH)

    -- Place the menu above the cursor if possible; otherwise, adjust to stay on-screen
    local y = grid_to_room(cursor.y) - POPUP_MENU_HEIGHT - 10
    if y < 0 then
        y = grid_to_room(cursor.y) + 10 -- Move below cursor if not enough space above
    end

    rectfill(x, y, x + POPUP_MENU_WIDTH, y + POPUP_MENU_HEIGHT, 0)
    local tower = get_tower_at(cursor.x, cursor.y)
    tower.type.draw({cooldown = 0, type = tower.type}, x + 2, y + 14)
    spr(2, x + 10, y + 14)
    print("sell", x + 2, y + 4, 10)
    line(x + 20, y + 2, x + 20, y + 24, 10)

    for i = 1, get_sell_price(tower) do
        spr(7, x + 22 + ((i - 1) % 4) * 8, y + flr((i - 1) / 4) * 8 + 2)
    end

    draw_confirm_cancel_menu()
end


function draw_confirm_cancel_menu()
    camera(0, 0)

    -- Draw cancel on the bottom-left
    print("o: cancel", 2, 122, 8)

    -- Draw confirm on the bottom-right
    print("x: confirm", 128 - 42, 122, 11) -- 42 = #("x: confirm") * 4 + 2
end

function draw_contextual_menu()    
    local is_sell = get_tower_at(cursor.x, cursor.y)
    local action_str = is_sell and "x: sell" or "x: build"
    local color = is_sell and 8 or 11 -- Red for "sell" (color 8), green for "build" (color 11)
    local text_width = #action_str * 4 -- Total width of the full string

    camera(0, 0)
    print(action_str, 128 - text_width - 2, 122, color) -- Adjust padding as needed
    if (not wave_running) print("o: faster", 2, 122, 9)
end

function get_sell_price(tower)
    return flr(tower.type.cost * 0.75)
end