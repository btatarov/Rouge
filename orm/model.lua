require "rouge"

local M = {}

local Model
local BaseField
local CharField

Model = class()
M.Model = Model

function Model:init(fields)
	self.fields = {}

	for name, value in pairs(fields) do
		self.fields[name] = value
		if not value.verbose then value.verbose = string.capitalize(name) end
	end

	getmetatable(self).__index = Model._fieldAccess
	getmetatable(self).__newindex = Model._fieldChange
end

function Model._fieldAccess(self, key)
	local value = nil
	if key ~= nil then
		if self.fields[key] then value = self.fields[key].value
		else value = self[key] end
	end

	return value
end

function Model._fieldChange(self, key, value)
	if key ~= nil then
		if self.fields[key] then self.fields[key].value = value
		else self[key] = value end
	end
end

function Model:save()
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