-- Макрос ожидает получить положительное число.
-- При наличии десятичной дроби, делает математическое округление.
-- При неверном типе данных добавит в таблицу - "Not number".
-- При отрицательном значении добавит в таблицу - "Отрицательное значение".
-- Ожидает заполнение исходных чисел в столбце А, в любом порядке.
-- После заполнения столбца А исходными данными, открыть меню "Макрокоманды".
-- И нажать на "Выполнить" рядом с навзанием макроса (numToString).
local tbl = document:getBlocks():getTable('Лист1')
local number = tbl:getCell('A2'):getFormattedValue()

-- Логика string -> number
function stringToNumber(sum)

    -- Templates
    local minusValue = "Отрицательное значение"
    local zero = "ноль"
    local ones = {"один", "два", "три", "четыре", "пять", "шесть", "семь", "восемь",
                  "девять", "десять", "одиннадцать", "двенадцать",
                  "тринадцать", "четырнадцать", "пятнадцать", "шестнадцать",
                  "семнадцать", "восемнадцать", "девятнадцать"}
    local tens = {"", "двадцать", "тридцать", "сорок", "пятьдесят",
                  "шестьдесят", "семьдесят", "восемьдесят", "девяносто"}
    local hundreds = {"сто", "двести", "триста", "четыреста", "пятьсот",
                      "шестьсот", "семьсот", "восемьсот", "девятьсот"}
    local unitsPlural = {{"", "", ""}, {"тысяча", "тысячи", "тысяч"},
                         {"миллион", "миллиона", "миллионов"},
                         {"миллиард", "миллиарда", "миллиардов"},
                         {"триллион", "триллиона", "триллионов"}}

    local resultString = ""
    local triplePos = 0

    local number = math.floor(tonumber(sum + 0.5)) -- оставляет целое число и математически округляет его(аналог math.round)

    -- Проверка на отрицательное число
    if (string.find(sum, ("-")) ~= nil) then
        return minusValue
    end

    function multiplies(n, titles)
        local cases = {3, 1, 2, 2, 2, 3}
        local index = 0

        if (n % 100 > 4 and n % 100 < 20) then
            index = 3
        else
            index = cases[math.min(n % 10, 5) + 1]
        end
        return titles[index]
    end

    -- Проверка на пробелы
    function deleteSpaces(s)
        return s:gsub("^%s*(.-)%s*$", "%1")
    end

    -- Основной цикл
    while (number > 0) do
        local tripleStr = ""
        local tripleUnit = ""
        local triple = number % 1000 -- Проверка на три нуля. 1000 => 0

        number = math.floor(number / 1000)
        triplePos = triplePos + 1

        if (triplePos > 5) then
            return ""
        end

        if (triple > 0) then
            local unitPlural = unitsPlural[triplePos]
            tripleUnit = multiplies(triple, unitPlural)
        end

        if (triple >= 100) then
            tripleStr = hundreds[math.floor(triple / 100)]
            triple = triple % 100
        end

        if (triple >= 20) then
            tripleStr = tripleStr .. " " .. tens[math.floor(triple / 10)]
            triple = triple % 10
        end

        if (triple >= 1) then
            tripleStr = tripleStr .. " " .. ones[triple]
        end

        if (triplePos == 2) then
            tripleStr = tripleStr:gsub("один$", "одна"):gsub("два$", "две")
        end

        resultString = tripleStr .. " " .. tripleUnit .. " " .. resultString
    end

    if (resultString == "") then
        resultString = zero
    end

    resultString = (deleteSpaces(resultString))
    return resultString
end

-- Проверка числа и подставление результата string
function execute()
    local rowCount = tbl:getRowsCount()

    for i = 1, (rowCount - 1) do
        local value = tbl:getCell(DocumentAPI.CellPosition(i, 0)):getFormattedValue()
        local format = tonumber(value)

        if (#value > 0 and type(format) ~= "number") then
            tbl:getCell(DocumentAPI.CellPosition(i, 1)):setText("Not number")
        else
            if #value > 0 and (type(format) == "number") then
                local result = stringToNumber(format)
                tbl:getCell(DocumentAPI.CellPosition(i, 1)):setText(result)
            end
        end

    end
end

execute()

