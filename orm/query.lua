require "rouge"

-- TODO: SELECT DISTINCT, GROUP BY + HAVING
Query = class()

function Query:new(connection)
	self.conn = connection
	
	return self
end

function Query:set_table(table)
	table = string.trim(self.conn:escape(table))
	if table:sub(-1) ~= "'" then table = ('"%s"'):format(table) end
	self.table = table

	return self
end

function Query:set_type(type)
	self.type = string.lower(string.trim(self.conn:escape(type)))

	return self
end

function Query:set_fields(fields)
	for field in pairs(fields) do
		local field_parts = string.split(fields[field],'.')

		for field_part in pairs(field_parts) do
			field_parts[field_part] = string.trim(self.conn:escape(field_parts[field_part]))
			if field_parts[field_part]:sub(-1) ~= '"' then
				field_parts[field_part] = ('"%s"'):format(field_parts[field_part])
			end
		end

		if #field_parts < 2 then fields[field] = ('%s.%s'):format(self.table, field_parts[1]) end
	end
	self.fields = fields

	return self
end

-- TODO: fix splitting by . (concat them)
function Query:add_where(conditions)
	if not self.where then self.where = {} end

	for condition, _ in ipairs(conditions) do
		local condition_name
		local condition_value = conditions[condition]['value']
		local condition_field = conditions[condition]['field']
		local condition_parts = string.split(condition_field,'.')

		for condition_part, _ in ipairs(condition_parts) do
			condition_parts[condition_part] = string.trim(self.conn:escape(condition_parts[condition_part]))
			condition_name = condition_parts[condition_part]
			if condition_name:sub(-1) ~= '"' then condition_name = ('"%s"'):format(condition_name) end
		end

		condition_value = self.conn:escape(condition_value)
		if #condition_parts < 2 then condition_name = ('%s.%s'):format(self.table, condition_name) end
		table.insert(self.where, {name = condition_name, operator = conditions[condition].operator, value = condition_value})
	end

	return self
end

-- TODO: fix splitting by . (concat them), insert table name
function Query:set_order_by(order_list)
	self.order_by = {}

	for order, _ in ipairs(order_list) do
		order_list[order] = self.conn:escape(order_list[order])
		local order_name
		local order_parts = string.split(order_list[order],'.')

		for order_part, _ in ipairs(order_parts) do
			order_parts[order_part] = string.trim(self.conn:escape(order_parts[order_part]))
			order_name = order_parts[order_part]
			if order_name:sub(-1) ~= '"' then order_name = ('"%s"'):format(order_name) end
		end
		table.insert(self.order_by, order_name)
	end

	return self
end

function Query:set_limit(first, last)
	self.limit = {}

	table.insert(self.limit, string.trim(self.conn:escape(first)))
	if last ~= nil then last = string.trim(self.conn:escape(last)); table.insert(self.limit, last) end

	return self
end

-- TODO: cases for update and insert
function Query:execute()
	assert(self.table, "No table selected!")
	assert(self.type, "Type of query not set!")
	if not self.fields then self.fields = {'*'} end

	local query = {}
	if self.type == 'select' then
		table.insert(query, 'SELECT')
		table.insert(query, table.concat(self.fields, ', '))
		table.insert(query, 'FROM')
		table.insert(query, self.table)
	elseif self.type == 'delete' then
		table.insert(query, 'DELETE FROM')
		table.insert(query, self.table)
	end

	if self.where then
		local where_list = {}
		table.insert(query, 'WHERE')
		for where, _ in ipairs(self.where) do
			table.insert(where_list, ('%s %s %s'):format(self.where[where].name, self.where[where].operator, self.where[where].value))
		end

		table.insert(query, table.concat(where_list, ' AND '))
	end

	if self.order_by then
		table.insert(query, 'ORDER BY')
		table.insert(query, table.concat(self.order_by, ', '))
	end

	if self.limit then
		table.insert(query, 'LIMIT')
		table.insert(query, table.concat(self.limit, ', '))
	end

	query = table.concat(query, ' ')

	print(query)
end
