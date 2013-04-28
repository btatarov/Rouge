require("rouge")

Config = class()

local _instance

function Config.getInstance()
	if not _instance then
		_instance = Config:init()
	end

	return _instance
end

function Config:new()
end

function Config:init()
	self._config = nil
	return self
end

function Config:setConfigFilePath(configFilePath)
	if not configFilePath then
		print("ERROR: Empty config file path!")
	else
		self._configFilePath = configFilePath
		if file_exists(configFilePath) then
			local configModule = configFilePath:sub(4, configFilePath:len() - 4)
			self._config = require(configModule)
		else
			print("ERROR: Config file does not exist!")
		end
	end
end

function Config:getConfigFilePath()
	return self._configFilePath
end

function Config:get(param)
	if not self._config then
		print("ERROR: Config instance not initialised!")
	else
		return self._config[param]
	end
end