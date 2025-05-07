-- Definizione di esempio
function drawLine(x1, y1, x2, y2, color)
    print("Esecuzione drawLine:", x1, y1, x2, y2, color)
end

-- Funzione per parsing ed esecuzione
local function parseAndExecute(commandStr)
    -- Split su virgole
    local parts = {}
    for part in string.gmatch(commandStr, "([^,]+)") do
        table.insert(parts, part)
    end

    -- Nome del metodo
    local methodName = parts[1]

    -- Elabora i parametri usando load per valutare i tipi dinamicamente
    local args = {}
    for i = 2, #parts do
        local code = "return " .. parts[i]
        local fn, err = load(code, "arg", "t", {
            colors = colors,  -- solo gli ambienti autorizzati
            true = true,
            false = false,
            nil = nil
        })
        if fn then
            local success, result = pcall(fn)
            if success then
                table.insert(args, result)
            else
                print("Errore nell'esecuzione dell'argomento:", result)
                table.insert(args, parts[i]) -- fallback
            end
        else
            print("Errore nel parsing dell'argomento:", err)
            table.insert(args, parts[i]) -- fallback
        end
    end

    -- Esecuzione dinamica della funzione
    local func = _G[methodName]
    if type(func) == "function" then
        func(table.unpack(args))
    else
        print("Funzione '" .. methodName .. "' non trovata.")
    end
end

-- ESEMPIO: questo funziona anche con colors.red, numeri, booleani, ecc.
parseAndExecute("drawLine,0,0,10,0,colors.red")
