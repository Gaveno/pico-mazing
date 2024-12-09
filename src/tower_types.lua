-- Define tower types
-- towers[x .. ',' .. y] = {
--     x = x,
--     y = y,
--     type = tower_types[1],
--     cooldown = 0     <- attack speed
-- }

tower_types = {
    {
        name = 'Laser',
        cost = 1,
        attack_type = 'laser',
        attack_power = 0.4,
        attack_range = 16,
        attack_speed = 35,
        splash = 0,
        projectile_speed = 0,
        proj_launch_x = 3,
        proj_launch_y = 3,
        draw = function(tower, x, y)
            local image = 0
            if tower.cooldown > 20 then
                image = 1 + (tower.cooldown / 2) % 2
            end
            spr(34 + image, x, y)
        end
    },
    {
        name = 'Pixel',
        cost = 3,
        attack_type = 'pixel',
        attack_power = 3,
        attack_range = 24,
        attack_speed = 25,
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
        name = 'Bomb',
        cost = 4,
        attack_type = 'bomb',
        attack_power = 6,
        attack_range = 32,
        attack_speed = 50,
        splash = 1,
        projectile_speed = 2,
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
        attack_range = 32,
        attack_speed = 40,
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
        name = 'LaserL2',
        cost = 8,
        attack_type = 'laser',
        attack_power = 2,
        attack_range = 40,
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
        name = 'BombL2',
        cost = 12,
        attack_type = 'bomb',
        attack_power = 12,
        attack_range = 48,
        attack_speed = 65,
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