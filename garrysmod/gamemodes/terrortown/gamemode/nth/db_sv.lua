require("mysqloo")

local my
local db = {}
local busy = false

if not my and NTHC.DB.enabled then
    my = mysqloo.connect(NTHC.DB.ip, NTHC.DB.username, NTHC.DB.password, NTHC.DB.database)
    
    db = {
        mysqloo=my,
        queuedQueries={},
        connected=false
    }
    
    busy = false

    function queuePop()
        if not busy and db.connected and #db.queuedQueries > 0 then
            busy = true
            local qq = table.remove(db.queuedQueries, 1)
            local q = my:query(qq.sql)
            q.onSuccess = function(q, data)
                if qq.cb then qq.cb(nil, data) end
                busy = false
                return queuePop()
            end
            q.onError = function(q, err)
                if qq.cb then qq.cb(err) end
                busy = false
                return queuePop()
            end
            q:start()
        end
    end

    function my:onConnected()
        db.connected = true
        queuePop()
    end

    function my:onConnectionFailed( err )
        db.connected = false
        
        print( "Connection to database failed!" )
        print( "Error:", err )
        
        timer.Simple(4, function()
            print("Reconnecting...")
            my:connect()
        end)

    end

    my:connect()
end
    
local queryQueue = function(sql, cb)
    table.insert(db.queuedQueries, {sql=sql,cb=cb})
    queuePop()
end

db.queryAll = function(sql, params, cb)
    if not NTHC.DB.enabled then return cb("NTH.DB is not enabled") end
    
    if type(params) ~= "table" then
        params = {params}
    end
    
    local args = table.Copy(params)
    local lastpos = 1
    while true do
        local pos = sql:find("?", 1, true)
        if #args == 0 or pos == nil then break end
        
        sql = string.sub(sql, 1, pos-1) .. '"' .. my:escape(tostring(table.remove(args, 1))) .. '"' .. string.sub(sql, pos + 1)
    end
    
    queryQueue(sql, cb)
end

db.query = function(sql, params, cb)
    db.queryAll(sql, params, function(err, rows)
        if err then return cb and cb(err) end
        return cb and cb(nil, rows[1])
    end)
end

NTH.DB = db
