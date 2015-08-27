
PANEL = {}
local GetOpenURLCallback = 0

local function toJSON(data)
    if type(data) == "table" then
        data = util.TableToJSON(data)
    elseif type(data) == "nil" then
        data = "null"
    else
        data = "\"" .. string.gsub(tostring(data), "\"","\\\""):gsub("\\", "\\\\") .. "\""
    end
    
    return data
end

--[[---------------------------------------------------------

-----------------------------------------------------------]]
function PANEL:Init()
	
    local ghtml = self
    
	self:SetScrollbars( true )
	self:SetAllowLua( true )

	self.JS = {}
	self.Callbacks = {}
    
    self.jsHooks = {}

	--
	-- Implement a console.log - because awesomium doesn't provide it for us anymore.
	--
	ghtml:AddFunction( "console", "log", function( param ) ghtml:ConsoleMessage( param ) end )
    
    ghtml:AddFunction( "GHTML_hook", "Call", function(json)
        local args = util.JSONToTable(json)
        local event = table.remove(args, 1)
        hook.Call(event, nil, unpack(args))
    end)
    
    ghtml:AddFunction( "GHTML_hook", "Add", function(event, uid)
        table.insert(ghtml.jsHooks, {event, uid})
        hook.Remove(event, uid)
        hook.Add(event, uid, function(...)
            ghtml:QueueJavascript('window._GHTML_hook.Call("' .. uid .. '", ' .. toJSON({...}) .. ')')
        end)
    end)
    
    
    ghtml:AddFunction( "GHTML_hook", "Remove", function(event, uid)
        hook.Remove(event, uid)
    end)
    
    ghtml:AddFunction( "GHTML", "GetURL", function(cbid, url)
        hook.Call(cbid, nil, url)
    end)

end

function PANEL:GetOpenURL(callback)
    GetOpenURLCallback = GetOpenURLCallback + 1
    local cbid = "GHTML-GetOpenURLCallback-" .. GetOpenURLCallback
    hook.Add(cbid, cbid, function(url)
        callback(url)
        hook.Remove(cbid, cbid)
    end)
    self:QueueJavascript('GHTML.GetURL(\'' .. cbid .. '\', window.location.href);')
end

function PANEL:RemoveJSHooks()
    for _,h in pairs(self.jsHooks) do
        hook.Remove(h[1], h[2])
    end
end

function PANEL:Paint() end

derma.DefineControl( "GHTML", "Better than DHTML", PANEL, "DHTML" )
