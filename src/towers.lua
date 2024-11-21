-- CONSTANTS
POPUP_MENU_WIDTH = 56
POPUP_MENU_HEIGHT = 26
POPUP_MENU_TOWER_STATS = 4
POPUP_MENU_TOWER_STAT_SEP = 7
MAX_TOWER_RANGE = 5 * CELL_SIZE
MIN_TOWER_RANGE = 1 * CELL_SIZE
MAX_TOWER_POWER = 8
MIN_TOWER_ATTACK_SPEED = 20 / 3
MAX_TOWER_ATTACK_SPEED = 80
SCALE_TOWER_ATTACK_SPEED = (MAX_TOWER_ATTACK_SPEED - MIN_TOWER_ATTACK_SPEED)


-- Variables
tower_menu_index = 1
towers = {}
tower_menu_shake = 0
tower_menu_open_delay = 0

-- towers[x .. ',' .. y] = {
--     x = x,
--     y = y,
--     type = tower_types[1],
--     cooldown = 0     <- attack speed
-- }

tower_types = {
    {
        name = 'Triangle',
        cost = 1,
        attack_type = 2, -- 'pixel_shot',
        attack_power = 1,
        attack_range = 2 * CELL_SIZE,
        attack_speed = 30,
        splash = 0,
        projectile_speed = 0,
        proj_launch_x = 3,
        proj_launch_y = 2,
        draw = function(tower, x, y)
            -- Draw Lightning Tower
            local image = 0
            if tower.cooldown > 20 then
                image = 1 + (tower.cooldown / 2) % 2
            end
            spr(34 + image, x, y)
        end
    },
    {
        name = 'Circle',
        cost = 3,
        attack_type = 0, --'pixel_shot',
        attack_power = 5,
        attack_range = 3 * CELL_SIZE,
        attack_speed = 30,
        splash = 0,
        projectile_speed = 2,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            local image = 0
            if tower.cooldown > 20 then
                image = 1
            end
            spr(50 + image, x, y)
        end
    },
    {
        name = 'Square',
        cost = 4,
        attack_type = 1, --'bomb',
        attack_power = 5,
        attack_range = 4 * CELL_SIZE,
        attack_speed = 50,
        splash = 1,
        projectile_speed = 1,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            local image = 0
            if tower.cooldown > 30 then
                image = 1
            end
            spr(image, x, y)
        end
    },
    {
        name = 'Stacked Circle',
        cost = 6,
        attack_type = 1, --'bomb',
        attack_power = 4,
        attack_range = 4 * CELL_SIZE,
        attack_speed = 15,
        splash = 1,
        projectile_speed = 2,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            -- Draw yellow circle with white inner circle
            circfill(x + CELL_SIZE / 2, y + CELL_SIZE / 2, 3, 10) -- Outer circle (Yellow)
            circfill(x + CELL_SIZE / 2, y + CELL_SIZE / 2, 1, 7)  -- Inner circle (White)
        end
    },
    {
        name = 'Stacked Triangle',
        cost = 8,
        attack_type = 2, --'laser',
        attack_power = 2,
        attack_range = 5 * CELL_SIZE,
        attack_speed = 20,
        splash = 0,
        projectile_speed = 0,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            local image = 0
            if tower.cooldown > 10 then
                image = (tower.cooldown / 2) % 2
            end
            spr(48 + image, x, y)
        end
    },
    {
        name = 'Stacked Square',
        cost = 12,
        attack_type = 1, --'bomb',
        attack_power = 8,
        attack_range = 6 * CELL_SIZE,
        attack_speed = 80,
        splash = 2,
        projectile_speed = 3,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            local image = tower.cooldown / (tower.type.attack_speed - 5) * 6
            spr(52 + image, x, y)
        end
    }
}

-- Tower Update Functions
function update_towers()
    -- Don't aquire targets until units have finished spawning
    -- Unless it's a chicken
    if wave_units_to_spawn > 0 and wave_spawning_unit_type.name ~= 'Chicken' then
        return
    end

    for _, tower in pairs(towers) do
        if tower.cooldown > 0 then
            tower.cooldown -= 1
        end

        if tower.cooldown <= 0 then
            if tower.target_unit == nil or tower.target_unit.health <= 0 then
                tower.target_unit = find_nearest_unit_in_range(tower)
            elseif tower_distance_to_unit(tower, tower.target_unit) > tower.type.attack_range then
                tower.target_unit = find_nearest_unit_in_range(tower)
            end

            if tower.target_unit ~= nil then
                -- printh("tower: "..tower.type.name.." attacking: "..target_unit.type.name)
                -- printh("("..(tower.x * CELL_SIZE)..","..(tower.y * CELL_SIZE)..") -> ("..target_unit.px..","..target_unit.py..")")
                tower.cooldown = tower.type.attack_speed
                create_projectile(tower, tower.target_unit)
            end
        end
    end
end

function find_nearest_unit_in_range(tower)
    local nearest_unit = nil
    local nearest_distance = tower.type.attack_range + 1
    for unit in all(units) do
        local distance = tower_distance_to_unit(tower, unit)
        if distance < nearest_distance then
            nearest_unit = unit
            nearest_distance = distance
        end 
    end
    return nearest_unit
end

function tower_distance_to_unit(tower, unit)
    local dx = abs(unit.px - (tower.x - 1) * CELL_SIZE)
    local dy = abs(unit.py - (tower.y - 1) * CELL_SIZE)
    if dx <= tower.type.attack_range and dy <= tower.type.attack_range then
        return sqrt(dx * dx + dy * dy)
    end
    return tower.type.attack_range + 1
end

-- Update tower menu interactions
function update_tower_menu()
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

function get_tower_at(x, y)
    return towers[x..","..y]
end

-- Function to build a tower at a specific location
function build_tower(x, y, tower_type)
    -- Update grid and unit paths
    -- grid[x][y] = false
    update_unit_paths()

    -- Place the tower
    towers[x .. ',' .. y] = {
        x = x,
        y = y,
        type = tower_type,
        cooldown = 0,
        target_unit = nil
    }
    diamonds -= tower_type.cost
end

-- Function to sell a tower at a specific location
function sell_tower(x, y)
    local tower = get_tower_at(x, y)
    if tower then
        -- Refund diamonds
        local refund = flr(tower.type.cost * 0.75)
        diamonds += refund

        -- Remove tower
        -- grid[x][y] = true
        towers[x .. ',' .. y] = nil

        update_unit_paths()
    end
end

-- Check if a tower can be built at the specified location
function can_build_tower_at(x, y)
    if grid[x][y].can_build and grid[x][y].unid_id == nil and get_tower_at(x, y) == nil then
        -- Check if path from spawn to exit exists after building the tower
        -- printh("Checking if there's a valid path with this tower being built")
        towers[x .. ',' .. y] = {
            x = x,
            y = y,
            type = tower_types[1],
            cooldown = 0
        }
        local spawn_x = flr(GRID_WIDTH / 2)
        local spawn_y = 1
        local path = find_path(spawn_x, spawn_y, EXIT_X, EXIT_Y)
        -- printh("Path length: "..#path)
        towers[x .. ',' .. y] = nil
        if path then
            return true
        end
    end
    printh("Could not build tower at ("..x..","..y..")")
    return false
end

-- Tower Draw Functions
function draw_towers()
    for key, tower in pairs(towers) do
        local x = (tower.x - 1) * CELL_SIZE
        local y = (tower.y - 1) * CELL_SIZE
        tower.type.draw(tower, x, y)
    end
end

function draw_tower_menu()
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

    if tower_type.attack_type == 2 then
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
    if tower_type.attack_type == 2 then
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

    -- Buttons
    -- spr(16, x + 2, y + POPUP_MENU_HEIGHT - 1)
    -- spr(17, x + POPUP_MENU_WIDTH - 10, y + POPUP_MENU_HEIGHT - 1)

end

function draw_sell_menu()
    local x = mid(0, (cursor.x - 1) * CELL_SIZE - 20, GRID_WIDTH * CELL_SIZE - POPUP_MENU_WIDTH)
    local y = mid(0, (cursor.y - 1) * CELL_SIZE - 10, GRID_HEIGHT * CELL_SIZE - POPUP_MENU_HEIGHT)

    -- Draw menu background
    rectfill(x, y, x + POPUP_MENU_WIDTH, y + POPUP_MENU_HEIGHT, 0)

    -- Draw tower being sold
    local tower = get_tower_at(cursor.x, cursor.y)
    tower.type.draw({cooldown = 0, type = tower.type}, x + 2, y + 2)

    -- Draw sell price
    local refund = flr(tower.type.cost * 0.75)
    for i = 1, refund do
        spr(7, x + 12 + (i - 1) * 8, y + 2)
    end

    -- Buttons
    -- spr(16, x + 2, y + POPUP_MENU_HEIGHT - 1)
    -- spr(17, x + POPUP_MENU_WIDTH - 10, y + POPUP_MENU_HEIGHT - 1)
end