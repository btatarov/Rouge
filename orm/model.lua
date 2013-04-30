require "rouge"

local M = {}

local BaseModel
local Model
local BaseField
local CharField

function Model_fieldAccess(self, key)
	local object = getmetatable(self).__object
	local value = nil

	if key ~= nil then
		if object.fields and object.fields[key] then value = object.fields[key].value
		else value = object[key] end
	end

	return value
end

function Model_fieldChange(self, key, value)
	local object = getmetatable(self).__object

	if key ~= nil then
		if object.fields and object.fields[key] then object.fields[key].value = value
		else object[key] = value end
	end
end


BaseModel = {}

function BaseModel.new()
	local proxy = setmetatable({}, { __newindex = Model_fieldChange, __index = Model_fieldAccess, __object = {} })
    return proxy
end


Model = class()
Model.__factory = BaseModel
M.Model = Model

function Model:init(fields)
	self.fields = {}

	for name, value in pairs(fields) do
		self.fields[name] = value
		if not value.verbose then value.verbose = string.capitalize(name) end
	end
end

function Model:save()
	for key, value in pairs(self.fields) do
		print(key, value.value)
	end
end


BaseField = class()

function BaseField:init(params)
	if not params then params = {} end
	if params.null ~= nil then self.null = params.null else self.null = false end
	if params.default ~= nil then self.default = params.default end
	if params.editable ~= nil then self.editable = params.editable else self.editable = true end
	if params.unique ~= nil then self.unique = params.unique else self.unique = false end
	if params.verbose ~= nil then self.verbose = params.verbose end
end

CharField = class(BaseField)
M.CharField = CharField

function CharField:init(params)
	BaseField.init(self)
	if params.max_length ~= nil then self.max_length = params.max_length else self.max_length = 128 end
end

return M