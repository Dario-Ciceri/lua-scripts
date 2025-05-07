-- Definizione della funzione drawLine
function drawLine(x1, y1, x2, y2, color)
    print("Esecuzione drawLine:", x1, y1, x2, y2, color)
end

-- Funzione generica per eseguire un comando da stringa
local function parseAndExecute(commandStr)
    -- Split della stringa in base alle virgole
    local parts = {}
    for part in string.gmatch(commandStr, "([^,]+)") do
        table.insert(parts, part)
    end

    -- Nome del metodo (es. "drawLine")
    local methodName = parts[1]

    -- Ambiente sicuro per valutare i parametri
    local safeEnv = {
        colors = colors,     -- Consente colors.red, ecc.
        ["true"] = true,
        ["false"] = false,
        ["nil"] = nil,
        _G = _G  -- Aggiungi _G per accedere a tutte le funzioni globali
    }

    -- Costruzione della lista di parametri
    local args = {}
    for i = 2, #parts do
        local expr = "return " .. parts[i]
        local fn, err = load(expr, "arg", "t", safeEnv)
        if fn then
            local ok, result = pcall(fn)
            if ok then
                table.insert(args, result)
            else
                print("Errore durante l'esecuzione dell'argomento:", result)
                table.insert(args, parts[i]) -- fallback: stringa
            end
        else
            print("Errore durante il parsing dell'argomento:", err)
            table.insert(args, parts[i]) -- fallback: stringa
        end
    end

    -- Esecuzione della funzione, se esiste
    local func = _G[methodName]
    if type(func) == "function" then
        func(table.unpack(args))
    else
        print("Funzione '" .. methodName .. "' non trovata.")
    end
end

-- Test del sistema con una stringa comando
parseAndExecute("drawLine,0,0,10,0,colors.red")
