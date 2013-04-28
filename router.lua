require("rouge")

Router = class()

local _instance

function Router.getInstance()
	if not _instance then
		_instance = Router:init()
	end

	return _instance
end

function Router:new()
end

function Router:init()
	return self
end

function Router:parse(request)
	local uri = request.PATH_INFO
	local uri_parts = string.split(uri:sub(2), '/')
	local routes = self._routes
	local params = {}

	for route_key in pairs(routes) do
		local route = routes[route_key]
		local route_parts = string.split(route['pattern'], '/')
		local next = false
		params = {}

		if #route_parts == #uri_parts then
			for key in pairs(route_parts) do
				if route_parts[key]:sub(1,1) == ':' then
					params[route_parts[key]:sub(2)] = uri_parts[key]
				elseif route_parts[key] ~= uri_parts[key] then
					next = true
					break
				end
			end
		else
			next = true
		end
		if not next then
			self._namespace = route['namespace']
			self._controller = route['controller']
			self._action = route['action']
			self._params = params
			break
		end
	end

	local namespace
	if self._namespace == nil then namespace = '' else namespace = self._namespace .. '/' end

	require('app/' .. namespace .. 'controllers/' .. self._controller)
	local params = {request, unpack(self._params)}
	return assert(loadstring('return ' .. string.capitalize(self._controller) .. ':' .. self._action .. '(...)'))(unpack(params))
end

function Router:setRoutesFilePath(routesFilePath)
	if not routesFilePath then
		print("ERROR: Empty routes file path!")
	else
		self._routesFilePath = routesFilePath
		if file_exists(routesFilePath) then
			local routesModule = routesFilePath:sub(4, routesFilePath:len() - 4)
			self._routes = require(routesModule)
		else
			print("ERROR: Routes file does not exist!")
		end
	end
end

function Router:getRoutesFilePath()
	return self._routesFilePath
end

function Router:getRoutes()
	return self._routes
end