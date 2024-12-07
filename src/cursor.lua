-- Variables
cursor = {x = 0, y = 0}
cursor_color_timer = 0
cursor_color_index = 1
cursor_colors = {8, 9, 10, 11}
cursor_size = 0
cursor_cannot_build_timer = 0

function update_cursor()
    if game_state == 'normal' then
        if btnp(0) then
            cursor.x -= 1
            cursor_cannot_build_timer = 0
        end -- Left
        if btnp(1) then
            cursor.x += 1
            cursor_cannot_build_timer = 0
        end -- Right
        if btnp(2) then
            cursor.y -= 1
            cursor_cannot_build_timer = 0
        end -- Up
        if btnp(3) then
            cursor.y += 1
            cursor_cannot_build_timer = 0
        end -- Down

        
        if btnp(4) then
            local tower = get_tower_at(cursor.x, cursor.y)
            if tower then
                game_state = 'sell_menu'
                tower_menu_open_delay = 5
            end
        elseif btnp(5) then
            game_state = 'tower_menu'
            tower_menu_index = 1
            tower_menu_open_delay = 5
            can_build_tower_at(cursor.x, cursor.y)
        end
    end

    cursor.x = mid(1, cursor.x, GRID_WIDTH)
    cursor.y = mid(1, cursor.y, GRID_HEIGHT)
    camera(
        mid((cursor.x - 1)*CELL_SIZE - (SCREEN_WIDTH/2 - CELL_SIZE/2), 0, GRID_WIDTH*CELL_SIZE - SCREEN_WIDTH),
        mid((cursor.y - 1)*CELL_SIZE - (SCREEN_HEIGHT/2 - CELL_SIZE/2), -HUD_HEIGHT, GRID_HEIGHT*CELL_SIZE - SCREEN_HEIGHT)
    )

    if game_state ~= 'normal' then
        cursor_size = (cursor_size - 1) % 10
    else
        cursor_size = 0
    end

    if cursor_cannot_build_timer > 0 then
        cursor_cannot_build_timer -= 1
    end

    cursor_color_timer = (cursor_color_timer + 1) % 4
    if cursor_color_timer == 0 then
        cursor_color_index = (cursor_color_index % #cursor_colors) + 1
    end
end

function draw_cursor()
    local color = cursor_colors[cursor_color_index]
    local x = (cursor.x - 1) * CELL_SIZE
    local y = (cursor.y - 1) * CELL_SIZE
    rect(x - cursor_size/3, y - cursor_size/3, x + CELL_SIZE - 1 + cursor_size/3, y + CELL_SIZE - 1 + cursor_size/3, color)
    if cursor_cannot_build_timer/2 % 2 > 0 then
        rectfill(x, y, x + CELL_SIZE - 1, y + CELL_SIZE - 1, 8)
    end
end