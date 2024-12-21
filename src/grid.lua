-- Constants
GRID_WIDTH = 16
GRID_HEIGHT = 20
EXIT_X = 7
EXIT_Y = GRID_HEIGHT
CELL_SIZE = 8

-- Variables
grid = {}

-- Initialize Grid
function init_grid()
    for x = 1, GRID_WIDTH do
        grid[x] = {}
        for y = 1, GRID_HEIGHT do
            grid[x][y] = {
                can_build = true,
                unit_id = nil
            }
        end
    end

    -- Set non-buildable areas
    for x = 1, GRID_WIDTH do
        for y = 1, 2 do
            grid[x][y].can_build = false
        end
    end
    local mid_start = 7
    local mid_end = 10
    for x = mid_start, mid_end do
        for y = GRID_HEIGHT - 1, GRID_HEIGHT do
            grid[x][y].can_build = false
        end
    end
end

function grid_to_room(v)
    return (v - 1) * CELL_SIZE
end

function draw_grid()
    for x = 1, GRID_WIDTH do
        for y = 1, GRID_HEIGHT do
            local px = grid_to_room(x)
            local py = grid_to_room(y)
            local cell = grid[x][y]
            spr(3 + (x + y) % 3, px, py)
            if not cell.can_build then
                spr(19, px, py)
            end
        end
    end
end