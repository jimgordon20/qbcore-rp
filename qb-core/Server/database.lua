local secret = Server.GetCustomSettings()
DB_IP = secret.DB_IP or '127.0.0.1'
DB_PORT = secret.DB_PORT or '5432'
DB_USER = secret.DB_USER or 'postgres'
DB_PASSWORD = secret.DB_PASSWORD or '12345'
DB_NAME = secret.DB_NAME or 'postgres'

PSQL = Database(
    DatabaseEngine.PostgreSQL,
    ' hostaddr='
    .. DB_IP
    .. ' port='
    .. DB_PORT
    .. ' user='
    .. DB_USER
    .. ' password='
    .. DB_PASSWORD
    .. ' dbname='
    .. DB_NAME
)

if PSQL then
    Console.Log('Connected to database')
else
    Console.Log('Failed to connect to database')
end

-- Package.Subscribe('Unload', function()
--     if PSQL then
--         Console.Log('Closing database connection')
--         PSQL:Close()
--     end
-- end)

MySQL = {
    query = {},
    insert = {},
    scalar = {},
    single = {},
    update = {},
    prepare = {},
    transaction = {},
}

local function convertPlaceholders(query, params)
    local paramIndex = 0
    local newParams = {}

    query = query:gsub('ON DUPLICATE KEY UPDATE', function()
        return 'ON CONFLICT (citizenid) DO UPDATE SET'
    end)

    if query:find(':') then
        query = query:gsub(':(%w+)', function(name)
            paramIndex = paramIndex + 1
            local value = params[name]
            newParams[paramIndex] = value
            return '$' .. paramIndex
        end)
    else
        query = query:gsub('%?', function()
            paramIndex = paramIndex + 1
            local value = params[paramIndex]
            newParams[paramIndex] = value
            return '$' .. paramIndex
        end)
    end

    return query, newParams
end

local function executeQuery(query, params, asyncCallback)
    local newQuery, newParams = convertPlaceholders(query, params)
    local isSelectQuery = string.match(string.lower(query), '^select')

    if asyncCallback then
        if isSelectQuery then
            PSQL:SelectAsync(newQuery, function(rows, error)
                if error then
                    Console.Log('Async Select Query Error: ' .. error)
                    asyncCallback(nil, error)
                else
                    asyncCallback(rows)
                end
            end, table.unpack(newParams))
        else
            PSQL:ExecuteAsync(newQuery, function(rows_affected, error)
                if error then
                    Console.Log('Async Execute Query Error: ' .. error)
                    asyncCallback(nil, error)
                else
                    asyncCallback(rows_affected)
                end
            end, table.unpack(newParams))
        end
    else
        if isSelectQuery then
            local rows, error = PSQL:Select(newQuery, table.unpack(newParams))
            if error then
                Console.Log('Sync Select Query Error: ' .. error)
                return nil, error
            else
                return rows
            end
        else
            local rows_affected, error = PSQL:Execute(newQuery, table.unpack(newParams))
            if error then
                Console.Log('Sync Execute Query Error: ' .. error)
                return nil, error
            else
                return rows_affected
            end
        end
    end
end

setmetatable(MySQL.query, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.query.await(query, params)
    return executeQuery(query, params)
end

setmetatable(MySQL.insert, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.insert.await(query, params)
    return executeQuery(query, params)
end

setmetatable(MySQL.scalar, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.scalar.await(query, params)
    local result, error = executeQuery(query, params)
    if result and #result > 0 then
        for _, value in pairs(result[1]) do
            return value
        end
    end
    return nil, error
end

setmetatable(MySQL.single, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.single.await(query, params)
    local result, error = executeQuery(query, params)
    if result and #result > 0 then
        return result[1], error
    end
    return nil, error
end

setmetatable(MySQL.update, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.update.await(query, params)
    local result, error = executeQuery(query, params)
    if error then
        return nil, error
    end
    return result.row_count
end

setmetatable(MySQL.prepare, {
    __call = function(_, query, params, callback)
        executeQuery(query, params, callback)
    end,
})

function MySQL.prepare.await(query, params)
    return executeQuery(query, params)
end

setmetatable(MySQL.transaction, {
    __call = function(_, queries, sharedValues, callback)
        local function executeTransaction(queries, sharedValues, callback)
            PSQL:ExecuteAsync('BEGIN', function(success, error)
                if not success then
                    Console.Log('Failed to begin transaction: ' .. error)
                    callback(false)
                    return
                end
                local totalQueries = #queries
                local completedQueries = 0
                local rollback = false
                local function executeNextQuery(index)
                    if rollback then
                        return
                    end
                    if index > totalQueries then
                        PSQL:ExecuteAsync('COMMIT', function(success, error)
                            if not success then
                                Console.Log('Failed to commit transaction: ' .. error)
                                callback(false)
                            else
                                callback(true)
                            end
                        end)
                        return
                    end
                    local q = queries[index]
                    local query, params
                    if type(q) == 'table' and q.query then
                        query = q.query
                        params = q.values
                    else
                        query = q
                        params = sharedValues
                    end
                    PSQL:ExecuteAsync(query, function(success, error)
                        if not success then
                            PSQL:ExecuteAsync('ROLLBACK', function()
                                Console.Log('Transaction failed: ' .. error)
                                callback(false)
                            end)
                            rollback = true
                            return
                        end
                        completedQueries = completedQueries + 1
                        executeNextQuery(index + 1)
                    end, table.unpack(params))
                end
                executeNextQuery(1)
            end)
        end
        executeTransaction(queries, sharedValues, callback)
    end,
})

function MySQL.transaction.await(queries, sharedValues)
    local success, error = PSQL:Execute('BEGIN')
    if not success then
        Console.Log('Failed to begin transaction: ' .. error)
        return false
    end
    for _, q in ipairs(queries) do
        local query, params
        if type(q) == 'table' and q.query then
            query = q.query
            params = q.values
        else
            query = q
            params = sharedValues
        end

        success, error = PSQL:Execute(query, table.unpack(params))
        if not success then
            PSQL:Execute('ROLLBACK')
            Console.Log('Transaction failed: ' .. error)
            return false
        end
    end
    success, error = PSQL:Execute('COMMIT')
    if not success then
        Console.Log('Failed to commit transaction: ' .. error)
        return false
    end
    return true
end

-- Package.Export('MySQL', MySQL)
-- Package.Export('PSQL', PSQL)

local rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS apartments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT NULL,
    type VARCHAR(255) DEFAULT NULL,
    label VARCHAR(255) DEFAULT NULL,
    citizenid VARCHAR(11) DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_apartments_citizenid ON apartments (citizenid)')
    PSQL:Execute('CREATE INDEX idx_apartments_name ON apartments (name)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS bank_accounts (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    account_name VARCHAR(50) UNIQUE,
    account_balance INT NOT NULL DEFAULT 0,
    account_type VARCHAR(10) CHECK (account_type IN ('shared', 'job', 'gang')),
    users TEXT DEFAULT '[]'
    );
]])

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS bank_statements (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    account_name VARCHAR(50) DEFAULT 'checking',
    amount INT DEFAULT NULL,
    reason VARCHAR(50) DEFAULT NULL,
    statement_type VARCHAR(10) CHECK (statement_type IN ('deposit', 'withdraw')),
    date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_bank_statements_citizenid ON bank_statements (citizenid)')

    PSQL:Execute([[
        CREATE OR REPLACE FUNCTION update_date_column()
        RETURNS TRIGGER AS $$
        BEGIN
        NEW.date = NOW();
        RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
    ]])

    PSQL:Execute([[
        CREATE TRIGGER bank_statements_update_date_trigger
        BEFORE UPDATE ON bank_statements
        FOR EACH ROW
        EXECUTE FUNCTION update_date_column();
    ]])
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS bans (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) DEFAULT NULL,
    license VARCHAR(50) DEFAULT NULL,
    discord VARCHAR(50) DEFAULT NULL,
    ip VARCHAR(50) DEFAULT NULL,
    reason TEXT DEFAULT NULL,
    expire INT DEFAULT NULL,
    bannedby VARCHAR(255) NOT NULL DEFAULT 'LeBanhammer'
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_bans_license ON bans (license)')
    PSQL:Execute('CREATE INDEX idx_bans_discord ON bans (discord)')
    PSQL:Execute('CREATE INDEX idx_bans_ip ON bans (ip)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS crypto (
    crypto VARCHAR(50) PRIMARY KEY DEFAULT 'qbit',
    worth INT NOT NULL DEFAULT 0,
    history TEXT DEFAULT NULL
    );
]])

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS crypto_transactions (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    title VARCHAR(50) DEFAULT NULL,
    message VARCHAR(50) DEFAULT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_crypto_transactions_citizenid ON crypto_transactions (citizenid)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS dealers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL DEFAULT '0',
    coords TEXT DEFAULT NULL,
    time TEXT DEFAULT NULL,
    createdby VARCHAR(50) NOT NULL DEFAULT '0'
    );
]])

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS houselocations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) DEFAULT NULL,
    label VARCHAR(255) DEFAULT NULL,
    coords TEXT DEFAULT NULL,
    owned BOOLEAN DEFAULT NULL,
    price INT DEFAULT NULL,
    tier SMALLINT DEFAULT NULL,
    garage TEXT DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_houselocations_name ON houselocations (name)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS inventories (
    id SERIAL,
    identifier VARCHAR(50) NOT NULL PRIMARY KEY,
    items TEXT DEFAULT '[]'
    );
]])

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_houses (
    id SERIAL PRIMARY KEY,
    house VARCHAR(50) NOT NULL,
    identifier VARCHAR(50) DEFAULT NULL,
    citizenid VARCHAR(11) DEFAULT NULL,
    keyholders TEXT DEFAULT NULL,
    decorations TEXT DEFAULT NULL,
    stash TEXT DEFAULT NULL,
    outfit TEXT DEFAULT NULL,
    logout TEXT DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_player_houses_house ON player_houses (house)')
    PSQL:Execute('CREATE INDEX idx_player_houses_citizenid ON player_houses (citizenid)')
    PSQL:Execute('CREATE INDEX idx_player_houses_identifier ON player_houses (identifier)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS house_plants (
    id SERIAL PRIMARY KEY,
    building VARCHAR(50) DEFAULT NULL,
    stage INT DEFAULT 1,
    sort VARCHAR(50) DEFAULT NULL,
    gender VARCHAR(50) DEFAULT NULL,
    food INT DEFAULT 100,
    health INT DEFAULT 100,
    progress INT DEFAULT 0,
    coords TEXT DEFAULT NULL,
    plantid VARCHAR(50) DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_house_plants_building ON house_plants (building)')
    PSQL:Execute('CREATE INDEX idx_house_plants_plantid ON house_plants (plantid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS lapraces (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) DEFAULT NULL,
    checkpoints TEXT DEFAULT NULL,
    records TEXT DEFAULT NULL,
    creator VARCHAR(50) DEFAULT NULL,
    distance INT DEFAULT NULL,
    raceid VARCHAR(50) DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_lapraces_raceid ON lapraces (raceid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS occasion_vehicles (
    id SERIAL PRIMARY KEY,
    seller VARCHAR(50) DEFAULT NULL,
    price INT DEFAULT NULL,
    description TEXT DEFAULT NULL,
    plate VARCHAR(50) DEFAULT NULL,
    model VARCHAR(50) DEFAULT NULL,
    mods TEXT DEFAULT NULL,
    occasionid VARCHAR(50) DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_occasion_vehicles_occasionid ON occasion_vehicles (occasionid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS phone_invoices (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    amount INT NOT NULL DEFAULT 0,
    society TEXT DEFAULT NULL,
    sender VARCHAR(50) DEFAULT NULL,
    sendercitizenid VARCHAR(50) DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_phone_invoices_citizenid ON phone_invoices (citizenid)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS phone_gallery (
    citizenid VARCHAR(11) NOT NULL,
    image VARCHAR(255) NOT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
]])

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_mails (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    sender VARCHAR(50) DEFAULT NULL,
    subject VARCHAR(50) DEFAULT NULL,
    message TEXT DEFAULT NULL,
    read SMALLINT DEFAULT 0,
    mailid INT DEFAULT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    button TEXT DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_player_mails_citizenid ON player_mails (citizenid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS phone_messages (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    number VARCHAR(50) DEFAULT NULL,
    messages TEXT DEFAULT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_phone_messages_citizenid ON phone_messages (citizenid)')
    PSQL:Execute('CREATE INDEX idx_phone_messages_number ON phone_messages (number)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS phone_tweets (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    firstName VARCHAR(25) DEFAULT NULL,
    lastName VARCHAR(25) DEFAULT NULL,
    message TEXT DEFAULT NULL,
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    url TEXT DEFAULT NULL,
    picture VARCHAR(512) DEFAULT './img/default.png',
    tweetId VARCHAR(25) NOT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_phone_tweets_citizenid ON phone_tweets (citizenid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_contacts (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    name VARCHAR(50) DEFAULT NULL,
    number VARCHAR(50) DEFAULT NULL,
    iban VARCHAR(50) NOT NULL DEFAULT '0'
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_player_contacts_citizenid ON player_contacts (citizenid)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS players (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) NOT NULL UNIQUE,
    cid INT DEFAULT NULL,
    license VARCHAR(100) NOT NULL,
    name VARCHAR(50) NOT NULL,
    money TEXT NOT NULL,
    charinfo TEXT DEFAULT NULL,
    job TEXT NOT NULL,
    gang TEXT DEFAULT NULL,
    position TEXT NOT NULL,
    metadata TEXT NOT NULL,
    inventory TEXT DEFAULT NULL,
    last_updated TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_players_last_updated ON players (last_updated)')
    PSQL:Execute('CREATE INDEX idx_players_license ON players (license)')


    PSQL:Execute([[
        CREATE OR REPLACE FUNCTION update_last_updated_column()
        RETURNS TRIGGER AS $$
        BEGIN
        NEW.last_updated = NOW();
        RETURN NEW;
        END;
        $$ LANGUAGE plpgsql;
    ]])

    PSQL:Execute([[
        CREATE TRIGGER players_update_last_updated_trigger
        BEFORE UPDATE ON players
        FOR EACH ROW
        EXECUTE FUNCTION update_last_updated_column();
    ]])
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS playerskins (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) NOT NULL,
    model VARCHAR(255) NOT NULL,
    skin TEXT NOT NULL,
    active SMALLINT NOT NULL DEFAULT 1
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_playerskins_citizenid ON playerskins (citizenid)')
    PSQL:Execute('CREATE INDEX idx_playerskins_active ON playerskins (active)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_outfits (
    id SERIAL PRIMARY KEY,
    citizenid VARCHAR(11) DEFAULT NULL,
    outfitname VARCHAR(50) NOT NULL,
    model VARCHAR(50) DEFAULT NULL,
    skin TEXT DEFAULT NULL,
    outfitId VARCHAR(50) NOT NULL
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_player_outfits_citizenid ON player_outfits (citizenid)')
    PSQL:Execute('CREATE INDEX idx_player_outfits_outfitId ON player_outfits (outfitId)')
end

rows, error = PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_vehicles (
    id SERIAL PRIMARY KEY,
    license VARCHAR(50) DEFAULT NULL,
    citizenid VARCHAR(11) DEFAULT NULL,
    vehicle VARCHAR(50) DEFAULT NULL,
    hash VARCHAR(50) DEFAULT NULL,
    mods TEXT DEFAULT NULL,
    plate VARCHAR(8) NOT NULL,
    fakeplate VARCHAR(8) DEFAULT NULL,
    garage VARCHAR(50) DEFAULT NULL,
    fuel INT DEFAULT 100,
    engine FLOAT DEFAULT 1000,
    body FLOAT DEFAULT 1000,
    state INT DEFAULT 1,
    depotprice INT NOT NULL DEFAULT 0,
    drivingdistance INT DEFAULT NULL,
    status TEXT DEFAULT NULL,
    balance INT NOT NULL DEFAULT 0,
    paymentamount INT NOT NULL DEFAULT 0,
    paymentsleft INT NOT NULL DEFAULT 0,
    financetime INT NOT NULL DEFAULT 0
    );
]])

if not error and rows > 0 then
    PSQL:Execute('CREATE INDEX idx_player_vehicles_plate ON player_vehicles (plate)')
    PSQL:Execute('CREATE INDEX idx_player_vehicles_citizenid ON player_vehicles (citizenid)')
    PSQL:Execute('CREATE INDEX idx_player_vehicles_license ON player_vehicles (license)')
end

PSQL:Execute([[
    CREATE TABLE IF NOT EXISTS player_warns (
    id SERIAL PRIMARY KEY,
    senderIdentifier VARCHAR(50) DEFAULT NULL,
    targetIdentifier VARCHAR(50) DEFAULT NULL,
    reason TEXT DEFAULT NULL,
    warnId VARCHAR(50) DEFAULT NULL
    );
]])
