-- Variables
units = {}
unit_path_delay = 0

 -- Define the unit types list
unit_types_list = {}
unit_types_list['Circle'] = {
    name = 'Circle',
    health = function(wave_number) return 5 * wave_number / 2 end,
    speed = 5,
    draw = function(unit, x, y)
        -- Draw green circle
        -- circfill(x + CELL_SIZE / 2, y + CELL_SIZE / 2, 3, 11) -- Light green
        palt(1, true)
        local flip = false
        if flr(unit.lifetime / 4) % 2 == 0 then
            flip = true
        end

        spr(20, x, y, 1, 1, flip, false)
        palt()
    end
}
unit_types_list['Square'] = {
    name = 'Square',
    health = function(wave_number) return 7 * wave_number / 2 end,
    speed = 4,
    draw = function(unit, x, y)
        -- Draw dark blue square
        rectfill(x + 1, y + 1, x + CELL_SIZE - 2, y + CELL_SIZE - 2, 1) -- Dark blue
    end
}
unit_types_list['Triangle'] = {
    name = 'Triangle',
    health = function(wave_number) return 3 * wave_number / 2 end,
    speed = 6,
    draw = function(unit, x, y)
        -- Draw orange triangle
        spr(2, x, y) -- Unit Triangle
    end
}
unit_types_list['Star'] = {
    name = 'Star',
    health = function(wave_number) return 3 * wave_number / 2 end,
    speed = 4,
    draw = function(unit, x, y)
        -- Draw bat
        palt(15, true)

        -- Flip sprite
        local flip = false
        if flr(unit.lifetime / 8) % 2 == 0 then
            flip = true
        end

        palt(0, false)
        spr(24 + flr(unit.lifetime / 3) % 2, x, y, 1, 1, flip, false)

        palt()
    end
}
 
 -- Update paths for existing units
 function update_unit_paths()
    for unit in all(units) do
        unit.path = nil
        -- local unit_path = find_path(unit.x, unit.y, EXIT_X, EXIT_Y)
        -- if unit_path then
        --     unit.path = unit_path
        --     unit.path_index = 2
        -- else
        --     -- No path for this unit, remove it
        --     del(units, unit)
        -- end
    end
end

-- Unit Initialization
function spawn_unit(unit_type)
    local spawn_x = ceil(rnd(GRID_WIDTH))
    local spawn_y = ceil(rnd(2))

    -- local path = find_path(spawn_x, spawn_y, EXIT_X, EXIT_Y)
    -- if path then
    local unit = {
        x = spawn_x,
        y = spawn_y,
        px = (spawn_x - 1) * CELL_SIZE,
        py = (spawn_y - 1) * CELL_SIZE,
        path = nil, -- path,
        path_index = 2,
        type = unit_type,
        health = unit_type.health(wave_number),
        lifetime = 0
    }
    add(units, unit)
    -- else
    --     -- No path available, units cannot spawn
    --     printh("Error spawning unit: "..unit_type.name.." no valid path found from: ("..spawn_x..","..spawn_y..")")
    -- end
end

-- Update units (movement and removal)
function update_units()
    if unit_path_delay > 0 then
        unit_path_delay -= 1
    end
    
    -- local path_iteration_used = false
    for i = #units, 1, -1 do
        local unit = units[i]
        unit.lifetime += 1

        -- Find path if doesn't have one
        if unit.path == nil and unit_path_delay <= 0 and unit.type.name ~= 'Star' then
            local unit_path = find_path(unit.x, unit.y, EXIT_X, EXIT_Y)
            if unit_path then
                unit.path = unit_path
                unit.path_index = 2
                unit_path_delay = 3
                -- path_iteration_used = true
            end
        end

        if unit.health <= 0 then
            del(units, unit)
            diamonds += 1
        else
            if unit.type.name == 'Star' then
                move_star_unit(unit)
            else
                if unit.path ~= nil then
                    move_unit_along_path(unit)
                end
            end
            if unit.y >= GRID_HEIGHT - 1 and unit.x > GRID_WIDTH/2 - 2 and unit.x <= GRID_WIDTH/2 + 2 then
                del(units, unit)
                lives -= 1
                if lives <= 0 then
                    game_state = 'defeat'
                end
            end
        end
    end
end

-- Determine the next unit type based on probabilities
function get_next_unit_type()
    -- Define unit probabilities
    local unit_probs = {
        {type = unit_types_list['Circle'], prob = 0.3},
        {type = unit_types_list['Square'], prob = 0.3},
        {type = unit_types_list['Triangle'], prob = 0.3},
        {type = unit_types_list['Star'], prob = 0.1}
    }
    -- Randomly select unit type based on probabilities
    local r = rnd(1)
    local cumulative = 0
    for i = 1, #unit_probs do
        cumulative += unit_probs[i].prob
        if r <= cumulative then
            return unit_probs[i].type
        end
    end
    return unit_probs[1].type -- Default to first type
end

-- Function to move units along their paths
function move_unit_along_path(unit)
    if unit.path_index > #unit.path then
        return
    end

    local target_cell = unit.path[unit.path_index]
    local target_px = (target_cell.x - 1) * CELL_SIZE
    local target_py = (target_cell.y - 1) * CELL_SIZE

    local dx = target_px - unit.px
    local dy = target_py - unit.py
    local dist = sqrt(dx * dx + dy * dy)
    local speed = unit.type.speed / 15

    if dist < speed then
        unit.px = target_px
        unit.py = target_py
        unit.x = target_cell.x
        unit.y = target_cell.y
        unit.path_index += 1
    else
        unit.px += dx / dist * speed
        unit.py += dy / dist * speed
    end
end

-- Function to move star units
function move_star_unit(unit)
    unit.py += unit.type.speed / 15
    if unit.px < (GRID_WIDTH - 1) / 2 * CELL_SIZE then
        unit.px += unit.type.speed / 15
    end

    if unit.px > (GRID_WIDTH + 1) / 2 * CELL_SIZE then
        unit.px -= unit.type.speed / 15
    end

    if unit.py >= ((GRID_HEIGHT - 1) * CELL_SIZE) then
        del(units, unit)
        lives -= 1
        if lives <= 0 then
            game_state = 'defeat'
        end
    end
end

-- Unit Drawing
function draw_units()
    for unit in all(units) do
        local x = unit.px
        local y = unit.py
        unit.type.draw(unit, x, y)
    end
end