require("rouge")
require("config")
require("router")
require("dispatcher")

App = class()

local _instance

function App.getInstance()
	if not _instance then
		_instance = App:init()
	end

	return _instance
end

function App:new()
end

function App:init()
	self._config = Config.getInstance()
	self._routes = Router.getInstance()

	return self
end

function App:setConfigFilePath(configFilePath)
	self._config:setConfigFilePath(configFilePath)
end

function App:getConfigFilePath()
	return self._config:getConfigFilePath()
end

function App:getConfig()
	return self._config
end

function App:setRoutesFilePath(routesFilePath)
	self._routes:setRoutesFilePath(routesFilePath)
end

function App:getRoutesFilePath()
	return self._routes:getRoutesFilePath()
end

function App:getRoutes()
	return self._routes
end

function App:run(wsapi_env)
	if self:getConfigFilePath() == nil then
		self:setConfigFilePath('../app/settings.lua')
	end

	if self:getRoutesFilePath() == nil then
		self:setRoutesFilePath('../app/urls.lua')
	end

	self._dispatcher = Dispatcher.getInstance()
	return self._dispatcher:run(wsapi_env)
end