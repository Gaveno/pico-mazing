-- Implementing A* Pathfinding

function find_path(start_x, start_y, goal_x, goal_y)
    local open_list = {}
    local closed_list = {}
    local came_from = {}

    local start_node = {x = start_x, y = start_y, g = 0, h = heuristic(start_x, start_y, goal_x, goal_y), f = 0}
    start_node.f = start_node.g + start_node.h
    add(open_list, start_node)

    while #open_list > 0 do
        -- Find node in open_list with lowest f
        local current_index = 1
        local current_node = open_list[1]
        for i, node in ipairs(open_list) do
            if node.f < current_node.f then
                current_node = node
                current_index = i
            end
        end

        del(open_list, current_node)
        add(closed_list, current_node)

        if current_node.x == goal_x and current_node.y == goal_y then
            -- Reconstruct path
            local path = {}
            local current = current_node
            while current do
                add(path, {x = current.x, y = current.y}, 1)
                current = came_from[current.x .. ',' .. current.y]
            end
            return path
        end

        -- Get neighbors
        local neighbors = get_neighbors(current_node.x, current_node.y)
        for _, neighbor in ipairs(neighbors) do
            if not in_list(closed_list, neighbor.x, neighbor.y) then
                local tentative_g = current_node.g + 1 -- assuming cost between nodes is 1
                local neighbor_in_open = in_open_list(open_list, neighbor.x, neighbor.y)
                if not neighbor_in_open or tentative_g < neighbor_in_open.g then
                    came_from[neighbor.x .. ',' .. neighbor.y] = current_node
                    neighbor.g = tentative_g
                    neighbor.h = heuristic(neighbor.x, neighbor.y, goal_x, goal_y)
                    neighbor.f = neighbor.g + neighbor.h
                    if not neighbor_in_open then
                        add(open_list, neighbor)
                    end
                end
            end
        end
    end

    -- No path found
    return nil
end

function heuristic(x1, y1, x2, y2)
    -- Use Manhattan distance
    return abs(x1 - x2) + abs(y1 - y2)
end

function get_neighbors(x, y)
    local neighbors = {}
    local directions = {
        {dx = 0, dy = -1}, -- up
        {dx = -1, dy = 0}, -- left
        {dx = 1, dy = 0},  -- right
        {dx = 0, dy = 1},  -- down
    }

    for _, dir in ipairs(directions) do
        local nx, ny = x + dir.dx, y + dir.dy
        if nx >= 1 and nx <= GRID_WIDTH and ny >= 1 and ny <= GRID_HEIGHT then
            local tower = get_tower_at(nx, ny) --grid[nx][ny]
            if tower == nil then
                add(neighbors, {x = nx, y = ny})
            end
        end
    end

    return neighbors
end

function in_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return true
        end
    end
    return false
end

function in_open_list(list, x, y)
    for _, node in ipairs(list) do
        if node.x == x and node.y == y then
            return node
        end
    end
    return nil
end

-- Draw paths for debugging
function draw_path(path_index, path)
    if path ~= nil then
        for i = path_index, #path do
            local node = path[i]
            local x = (node.x - 1) * CELL_SIZE + CELL_SIZE / 2
            local y = (node.y - 1) * CELL_SIZE + CELL_SIZE / 2
            circfill(x, y, 5, 12)
            -- printh("node: "..i.." x: "..x.." y: "..y)
            -- pset(x, y, 12) -- Light blue
        end
    end
end

function draw_unit_paths()
    for unit in all(units) do
        draw_path(unit.path_index, unit.path)
    end
end
