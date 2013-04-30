require "rouge"

local VIEW_ACTIONS = {
    ['{%'] = function(code)
        return code
    end,

    ['{{'] = function(code)
        return ('_result[#_result+1] =  string.html_escape(tostring(%s))'):format(code)
    end,

    ['{='] = function(code)
        return ('_result[#_result+1] = %s'):format(code)
    end,

    ['{<'] = function(code)
        return ('_result[#_result+1] =  render_view(%s, params, namespace)'):format(code)
    end,
}

function render_view(tmpl, params, namespace)
	if not namespace then namespace = '' else namespace = namespace .. '/' end
	params.params = params
	params.namespace = namespace

	tmpl = '../app/' .. namespace .. 'views/' .. tmpl

	local f = io.open(tmpl, "r")
	assert(f, ("Template %s not found!"):format(tmpl))
    tmpl = f:read("*all")
    f:close()

    tmpl = tmpl .. '{}'
    local code = {'local _result, _children = {}, {}\n'}

    for text, block in string.gmatch(tmpl, "([^{]-)(%b{})") do
        local act = VIEW_ACTIONS[block:sub(1,2)]
        local output = text

        if act then
            code[#code+1] =  '_result[#_result+1] = [=[' .. text .. ']=]'
            code[#code+1] = act(block:sub(3,-3))
        elseif #block > 2 then
            code[#code+1] = '_result[#_result+1] = [=[' .. text .. block .. ']=]'
        else
            code[#code+1] =  '_result[#_result+1] = [=[' .. text .. ']=]'
        end
    end

    code[#code+1] = 'return table.concat(_result)'

    code = table.concat(code, '\n')

    local func, err = loadstring(code)

    if err then
        assert(func, err)
    end

    result = function(context)
        assert(context, "You must always pass in a table for context.")
        setmetatable(context, {__index=_G})
        setfenv(func, context)
        return func()
    end
    return result(params)
end


function get_view(tmpl, params, namespace)
	local headers = { ["Content-type"] = "text/html" }
	if not params then params = {} end
	return 200, headers, render_view(tmpl, params, namespace)
end