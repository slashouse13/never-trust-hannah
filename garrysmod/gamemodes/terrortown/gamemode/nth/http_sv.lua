
local HTTPReady = false -- IS HTTP READY? Probably not, since it's one of the last things to load, and there's no hook for it >:|
local HTTPQueue = {} -- this acts as a queue for DB requests which can't be made just yet

local function flagHttpReady()
    if not HTTPReady then
        HTTPReady = true
        timer.Destroy("NTH-HTTPReadyChecker")
        hook.Call("NTH-HTTPReady")
    end
end

hook.Add("InitPostEntity", "NTH-StartHTTPReadyChecker", function()
    timer.Create("NTH-HTTPReadyChecker", 1, 0, function()
        -- dummy request. if any callbacks fired, we can assume HTTP is loaded
        http.Fetch("", flagHttpReady, flagHttpReady)
    end)
end)



local function EmptyQueue()
    while HTTPReady and #HTTPQueue > 0 do
        local params = table.remove(HTTPQueue, 1)
        HTTP(params)
    end
end
hook.Add("NTH-HTTPReady", "NTH-HTTPReady-EmptyQueue", EmptyQueue)

NTH.HTTP = function(params)
    -- so what's different about this? why not use HTTP()?
    -- this function will queue HTTP requests until the server is ready to send them
    if not HTTPReady then
        return table.insert(HTTPQueue, params)
    end
    -- if HTTPReady, then HTTP must be ready, right?
    HTTP(params)
end

-- basically, all functionality of http library, but using NTH.HTTP() instead of HTTP()
NTH.http = {}

-- basically the same as http.Fetch, but using NTH.HTTP() instead of HTTP()
NTH.http.Fetch = function(url, onsuccess, onfailure)
	NTH.HTTP({
		url			= url,
		method		= "get",
        success		= function( code, body, headers )
			if ( !onsuccess ) then return end
			onsuccess( body, body:len(), headers, code )
		end,
		failed		= function( err )
			if ( !onfailure ) then return end
			onfailure( err )
		end
	})
end

-- basically the same as http.Post, but using NTH.HTTP() instead of HTTP()
NTH.http.Post = function(url, params, onsuccess, onfailure)
    NTH.HTTP({
		url			= url,
		method		= "post",
		parameters	= params,
        success		= function( code, body, headers )
            if ( !onsuccess ) then return end
            onsuccess( body, body:len(), headers, code )
		end,
		failed		= function( err )
			if ( !onfailure ) then return end
			onfailure( err )
		end
	})
end


-- Make a call to the NTH website
NTH.WEB = function(func, dataTable, cb)
    if not NTHC.Web.enabled then
        return cb("NTH.WEB is disabled")
    end
    NTH.HTTP({
        url			= NTHC.Web.endpoint .. func,
        method		= "post",
        parameters	= {data = util.TableToJSON(dataTable)},
        success		= function( code, body, headers )
            if code >= 400 then
                return cb and cb(code or true, body)
            end
        
            local json = util.JSONToTable(body)
            if json == nil then
                return cb and cb("Invalid JSON", body)
            end
            
            return cb and cb(nil, json)
        end,
        failed		= function( err )
            return cb and cb(err or true)
        end
    })
end
