require("rouge")
require("router")

Dispatcher = class()

local _instance

function Dispatcher.getInstance()
	if not _instance then
		_instance = Dispatcher:init()
	end

	return _instance
end

function Dispatcher:new()
end

function Dispatcher:init()
	return self
end

function Dispatcher:run(wsapi_env)
	local router = Router.getInstance()
	return router:parse(wsapi_env)
end