-- Define tower types
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
        attack_type = 'laser',
        attack_power = 1,
        attack_range = 2 * CELL_SIZE,
        attack_speed = 35,
        splash = 0,
        projectile_speed = 0,
        proj_launch_x = 3,
        proj_launch_y = 3,
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
        attack_type = 'pixel',
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
        attack_type = 'bomb',
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
        name = 'QuadPixel',
        cost = 6,
        attack_type = 'pixel',
        attack_power = 2,
        attack_range = 4 * CELL_SIZE,
        attack_speed = 30,
        splash = 1,
        projectile_speed = 2,
        proj_launch_x = 7,
        proj_launch_y = 7,
        draw = function(tower, x, y)
            local image = 32
            if tower.cooldown > 8 then
                image = 33
            end
            spr(image, x, y)
        end,
        custom_attack = function(tower)
            -- 4 total projectiles
            tower.proj_launch_x = 7
            tower.proj_launch_y = 7
            create_projectile(tower, tower.target_unit)
            tower.proj_launch_x = 0
            create_projectile(tower, tower.target_unit)
            tower.proj_launch_y = 0
            create_projectile(tower, tower.target_unit)
            tower.proj_launch_x = 7
            create_projectile(tower, tower.target_unit)
        end
    },
    {
        name = 'Stacked Triangle',
        cost = 8,
        attack_type = 'laser',
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
        attack_type = 'bomb',
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