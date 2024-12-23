-- Constants
WAVE_PREP_TIME = 450

-- Variables
wave_number = 1
wave_timer = WAVE_PREP_TIME
wave_units_to_spawn = 0
wave_spawning_unit_type = nil
wave_is_elite = false
wave_running = false
elite_waves = {7, 13, 18, 23, 27, 34}

-- Update wave timing and spawning units
function update_waves()
    -- Check if wave is still spawning
    if wave_units_to_spawn > 0 then
        local spawned_unit = spawn_unit(wave_spawning_unit_type)
        if spawned_unit then
            wave_units_to_spawn -= 1
        end
    end

    -- Check if game has been won
    if wave_number > 35 and #units == 0 and game_state == 'normal' and exp_timer <= 0 then
        wave_number += 1
        game_state = 'victory'
    end

    if not wave_running and wave_timer > 0 then
        wave_timer -= 1
        if (btn(4)) wave_timer -= 5
    end

    if wave_timer <= 0 and wave_number <= 35 then
        next_unit_type = get_next_unit_type()
        wave_running = true
        sfx(-2, 3)
        wave_number += 1
        if wave_number <= 35 then
            wave_timer = WAVE_PREP_TIME
        end
    end
end

function prep_wave()
    wave_is_elite = contains(elite_waves, wave_number)
    wave_spawning_unit_type = next_unit_type
    wave_units_to_spawn = lookup(wave_spawning_unit_type, 'spawn_number', get_wave_unit_total(wave_number))
    wave_units_to_spawn += d_flr_m(wave_number, 25, game_difficulty)
end

function get_wave_unit_total(wave)
    return 2 + ceil(wave / 3)
end

function get_next_unit_type()
    local next_wave = wave_number + 1

    local unit_probs = {
        {type = unit_types_list['Walker'], prob = 0.30},
        {type = unit_types_list['Knight'], prob = 0.25},
        {type = unit_types_list['Lizard'], prob = 0.25},
        {type = unit_types_list['Bat'], prob = 0.20}
    }

    if next_wave == 10 or next_wave == 25 then
        return unit_types_list['Carrier']
    elseif next_wave == 15 or next_wave == 30 then
        return unit_types_list['BigBoy']
    elseif next_wave == 20 or next_wave == 35 then
        return unit_types_list['ST6']
    elseif next_wave == 7 or next_wave == 18 or next_wave == 34 then
        return unit_types_list['Chicken']
    elseif contains(elite_waves, next_wave) then
        unit_probs = {
            {type = unit_types_list['Lizard'], prob = 0.37},
            {type = unit_types_list['Knight'], prob = 0.37},
            {type = unit_types_list['Bat'], prob = 0.26}
        }
    end

    local r = rnd(1)
    local cumulative = 0
    for i = 1, #unit_probs do
        cumulative += unit_probs[i].prob
        if r <= cumulative then
            return unit_probs[i].type
        end
    end

    return unit_probs[1].type
end