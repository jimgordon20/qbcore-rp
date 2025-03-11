function QBCore.Functions.GetPlayer(source) -- return controller
    -- return QBCore.Players[source]
end

function QBCore.Functions.GetRandomElement(tbl)
    return tbl[math.random(1, #tbl)]
end

function QBCore.Functions.RandomStr(length)
    local result = {}
    for i = 1, length do
        local rand = math.random(1, 52)
        local char = rand <= 26 and string.char(rand + 64) or string.char(rand + 70)
        result[#result + 1] = char
    end
    return table.concat(result)
end

function QBCore.Functions.RandomInt(length)
    local result = {}
    for i = 1, length do
        result[#result + 1] = tostring(math.random(0, 9))
    end
    return table.concat(result)
end

function QBCore.Functions.CreateCitizenId()
    local CitizenId = tostring(QBCore.Functions.RandomStr(3) .. QBCore.Functions.RandomInt(5)):upper()
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE citizenid = ?) AS uniqueCheck', { CitizenId })
    -- if result == 0 then return CitizenId end
    -- return QBCore.Functions.CreateCitizenId()
    return CitizenId
end

function QBCore.Functions.CreateAccountNumber()
    local AccountNumber = 'US0' .. math.random(1, 9) .. 'QBCore' .. math.random(1111, 9999) .. math.random(1111, 9999) .. math.random(11, 99)
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.account")) = ?) AS uniqueCheck', { AccountNumber })
    -- if result == 0 then return AccountNumber end
    -- return QBCore.Functions.CreateAccountNumber()
    return AccountNumber
end

function QBCore.Functions.CreatePhoneNumber()
    local PhoneNumber = math.random(100, 999) .. math.random(1000000, 9999999)
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(charinfo, "$.phone")) = ?) AS uniqueCheck', { PhoneNumber })
    -- if result == 0 then return PhoneNumber end
    -- return QBCore.Functions.CreatePhoneNumber()
    return PhoneNumber
end

function QBCore.Functions.CreateFingerId()
    local FingerId = tostring(QBCore.Functions.RandomStr(2) .. QBCore.Functions.RandomInt(3) .. QBCore.Functions.RandomStr(1) .. QBCore.Functions.RandomInt(2) .. QBCore.Functions.RandomStr(3) .. QBCore.Functions.RandomInt(4))
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.fingerprint")) = ?) AS uniqueCheck', { FingerId })
    -- if result == 0 then return FingerId end
    -- return QBCore.Functions.CreateFingerId()
    return FingerId
end

function QBCore.Functions.CreateWalletId()
    local WalletId = 'QB-' .. math.random(11111111, 99999999)
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.walletid")) = ?) AS uniqueCheck', { WalletId })
    -- if result == 0 then return WalletId end
    -- return QBCore.Functions.CreateWalletId()
    return WalletId
end

function QBCore.Functions.CreateSerialNumber()
    local SerialNumber = math.random(11111111, 99999999)
    -- local result = MySQL.prepare.await('SELECT EXISTS(SELECT 1 FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(metadata, "$.phonedata.SerialNumber")) = ?) AS uniqueCheck', { SerialNumber })
    -- if result == 0 then return SerialNumber end
    -- return QBCore.Functions.CreateSerialNumber()
    return SerialNumber
end
