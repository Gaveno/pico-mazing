function percent_range(x, x1, x2)
    return (x - x1) / (x2 - x1)
end

function lookup(map, key, default)
    if map[key] then
        return map[key]
    end

    return default
end

function contains(table, value)
    for i = 1,#table do
      if (table[i] == value) then
        return true
      end
    end
    return false
end