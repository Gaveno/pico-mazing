-- Constants
WAVE_PREP_TIME = 15 * 30 -- 15 seconds (PICO-8 runs at 30 FPS)

-- Variables
wave_number = 1
wave_timer = WAVE_PREP_TIME
wave_units_to_spawn = 0
wave_spawning_unit_type = nil
wave_is_elite = false
wave_running = false
chicken_spawn_delay = 0

-- Wave variables
boss_waves = {10, 30}
elite_waves = {7, 13, 19, 23, 27}

-- Update wave timing and spawning units
function update_waves()
    -- Check if wave is still spawning
    if wave_units_to_spawn > 0 then
        if wave_spawning_unit_type.name == 'Chicken' and chicken_spawn_delay > 0 then
            chicken_spawn_delay -= 1
        else
            if wave_spawning_unit_type.name == 'Chicken' and not wave_running then
                return -- Don't prespawn chickens
            end

            chicken_spawn_delay = unit_types_list['Chicken'].spawn_rate
            printh("Attempting to spawn: "..wave_spawning_unit_type.name)
            local spawned_unit = spawn_unit(wave_spawning_unit_type)
            if spawned_unit then
                printh("Successfully spawned "..wave_spawning_unit_type.name)
                wave_units_to_spawn -= 1
            end
        end
    end

    -- Check if game has been won
    if wave_number > 30 and #units == 0 and game_state == 'normal' then
        game_state = 'victory'
    end

    -- Countdown timer if the wave is no longer running
    if not wave_running and wave_timer > 0 then
        wave_timer -= 1
    end

    if wave_timer <= 0 and wave_number <= 30 then
        start_wave()
        wave_number += 1
        if wave_number <= 30 then
            wave_timer = WAVE_PREP_TIME -- 20 seconds after all units destroyed
        end
    end
end

-- Prepare the wave by prespawning units
function prep_wave()
    wave_units_to_spawn = get_wave_unit_total(wave_number)
    wave_is_elite = (contains(elite_waves, wave_number))
    wave_spawning_unit_type = next_unit_type

    -- Bosses have their own fixed number of spawns
    if wave_spawning_unit_type.type == 'boss' then
        wave_units_to_spawn = wave_spawning_unit_type.spawn_number
    end
end

-- Start a new wave of units
function start_wave()
    next_unit_type = get_next_unit_type()
    wave_running = true
end

function get_wave_unit_total(wave)
    return 2 + ceil(wave / 3)
end

-- Determine the next unit type based on probabilities
function get_next_unit_type()
    local next_wave = wave_number + 1

    -- Define basic unit probabilities
    local unit_probs = {
        {type = unit_types_list['Walker'], prob = 0.30},
        {type = unit_types_list['Knight'], prob = 0.25},
        {type = unit_types_list['Lizard'], prob = 0.25},
        {type = unit_types_list['Bat'], prob = 0.20}
    }

    -- Override with boss probabilities for wave 10 and 30
    if contains(boss_waves, next_wave) then
        unit_probs = {
            {type = unit_types_list['Carrier'], prob = 0.5},
            {type = unit_types_list['BigBoy'], prob = 0.5},
        }
    elseif contains(elite_waves, next_wave) then
        unit_probs = {
            {type = unit_types_list['Chicken'], prob = 0.34},
            {type = unit_types_list['Lizard'], prob = 0.33},
            {type = unit_types_list['Knight'], prob = 0.33},
        }
    end

    -- Set chicken deploy
    if unit_probs[1].type.name == 'Chicken' then
        chicken_deploy_y = 8
        chcken_deploy_y = chicken_deploy_y + ceil(rnd(GRID_HEIGHT - 3 - chicken_deploy_y))
    end

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