local require = require
local json = require "json"

math.randomseed(os.time())

-- read csv lines
function ParseCSVLine(line,sep)
    local res = {}
    local pos = 1
    sep = sep or ','
    while true do
        local c = string.sub(line,pos,pos)
        if (c == "") then break end
        if (c == '"') then
            -- quoted value (ignore separator within)
            local txt = ""
            repeat
                local startp,endp = string.find(line,'^%b""',pos)
                txt = txt..string.sub(line,startp+1,endp-1)
                pos = endp + 1
                c = string.sub(line,pos,pos)
                if (c == '"') then txt = txt..'"' end
                -- check first char AFTER quoted string, if it is another
                -- quoted string without separator, then append it
                -- this is the way to "escape" the quote char in a quote. example:
                --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
            until (c ~= '"')
            table.insert(res,txt)
            assert(c == sep or c == "")
            pos = pos + 1
        else
            -- no quotes used, just look for the first separator
            local startp,endp = string.find(line,sep,pos)
            if (startp) then
                table.insert(res,string.sub(line,pos,startp-1))
                pos = endp + 1
            else
                -- no separator found -> use rest of string and terminate
                table.insert(res,string.sub(line,pos))
                break
            end
        end
    end
    return res
end

loadFile = function()
    -- 1. Get file path
    local filename = "zip_code_database.csv"

    -- 3. Parse the data:
    local data = {}
    local count = 0
    local sep = ","

    for line in io.lines(filename) do
        local values = ParseCSVLine(line,sep)
        data[count + 1] = { zip=values[1], type=values[2], city=values[4], state=values[7], county=values[8], timezone=values[9] }
        count = count + 1
    end

    return data
end

generator = function()
    local data = loadFile()
    return coroutine.create(function()
        for k,v in pairs(data) do
            coroutine.yield(json.stringify(v))
        end
    end)
end

return generator()