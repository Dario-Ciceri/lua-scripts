function drawLine(x1, y1, x2, y2, color)
    print("Esecuzione drawLine:", x1, y1, x2, y2, color)
end

local function parseAndExecute(commandStr)
    local parts = {}
    for part in string.gmatch(commandStr, "([^,]+)") do
        table.insert(parts, part)
    end

    local methodName = parts[1]
    local args = {}

    -- Ambiente sicuro per valutare i parametri
    local safeEnv = {
        colors = colors,
        ["true"] = true,
        ["false"] = false,
        ["nil"] = nil,
    }

    for i = 2, #parts do
        local code = "return " .. parts[i]
        local fn, err = load(code, "arg", "t", safeEnv)
        if fn then
            local ok, result = pcall(fn)
            if ok then
                table.insert(args, result)
            else
                print("Errore nell'esecuzione arg:", result)
                table.insert(args, parts[i])
            end
        else
            print("Errore nel parsing:", err)
            table.insert(args, parts[i])
        end
    end

    local func = _G[methodName]
    if type(func) == "function" then
        func(table.unpack(args))
    else
        print("Funzione '" .. methodName .. "' non trovata.")
    end
end

-- Test
parseAndExecute("drawLine,0,0,10,0,colors.red")
