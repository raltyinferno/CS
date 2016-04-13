--Kai Davids Schell
--4/10/16
--CS331 Assignment 6
--interpit.lua
--Interpreter module for the Zebu language


local interpit = {}

-- Symbolic Constants for AST

local STMT_LIST  = 1
local SET_STMT   = 2
local PRINT_STMT = 3
local NL_STMT    = 4
local INPUT_STMT = 5
local IF_STMT    = 6
local WHILE_STMT = 7
local BIN_OP     = 8
local UN_OP      = 9
local NUMLIT_VAL = 10
local STRLIT_VAL = 11
local ID_VAL     = 12
local ARRAY_REF  = 13


-- ***** Utility Functions *****


-- toInt
-- Given a number, return the number rounded toward zero.
function toInt(n)
    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
function strToNum(s)
    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return 0+s end)

    -- Return integer value, or 0 on error.
    if success then
        return toInt(value)
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
function numToStr(n)
    return ""..n
end



-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding values of Zebu integer variables
--             Value of simple variable xyz is in state.s["xyz"]
--             Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             outcall(str) outputs str with no added newline
--             To print a newline, do outcall("\n")
-- Return Value:
--   state updated with changed variable values
function interpit.interp(ast, state, incall, outcall)

    local function get_variable(tab,index,key)
		if tab == "s" then
			if state[tab][index] == nil then
				return 0
			else
				return strToNum(state[tab][index])
			end
		else
			if state[tab][index] == nil then
				return 0
			elseif state[tab][index][key] == nil then
				return 0
			else
				return strToNum(state[tab][index][key])
			end
		end
    end
    
    local function set_variable(key,value)
			state.s[key]=strToNum(value)
    end
	
    local function eval_expr(ast)
		
		if ast[1] == NUMLIT_VAL then
			return strToNum(ast[2])
		elseif ast[1] == ID_VAL then
			return get_variable("s",ast[2],0)
		elseif ast[1] == ARRAY_REF then
			return get_variable("a",ast[2][2], eval_expr(ast[3]))
		elseif ast[1][1] == UN_OP then
			if ast[1][2] == "-" then
				return -(eval_expr(ast[2]))
			else
				return eval_expr(ast[2])
			end
		elseif ast[1][1] == BIN_OP then
			if ast[1][2] == "==" then
				if eval_expr(ast[2]) == eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == "!=" then
				if eval_expr(ast[2]) ~= eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == "<=" then
				if eval_expr(ast[2]) <= eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == ">=" then
				if eval_expr(ast[2]) >= eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == "<" then
				if eval_expr(ast[2]) < eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == ">" then
				if eval_expr(ast[2]) > eval_expr(ast[3]) then
					return 1
				else 
					return 0
				end
			elseif ast[1][2] == "+" then
				return eval_expr(ast[2])+eval_expr(ast[3])
			elseif ast[1][2] == "-" then
				return eval_expr(ast[2])-eval_expr(ast[3])
			elseif ast[1][2] == "*" then
				return eval_expr(ast[2])*eval_expr(ast[3])
			elseif ast[1][2] == "/" then
				return toInt(eval_expr(ast[2])/eval_expr(ast[3]))
			elseif ast[1][2] == "%" then
				return eval_expr(ast[2])%eval_expr(ast[3])
			end
		end
    end 
	
    
    local function interp_stmt(ast)
        if (ast[1] == SET_STMT) then
            if(ast[2][1] == ID_VAL) then
                set_variable(ast[2][2],ast[3][2])
            elseif(ast[2][1] == ARRAY_REF) then
                state.a[ast[2][2][2]] = { [strToNum(ast[2][3][2])] = strToNum(ast[3][2])    }
            end
        elseif (ast[1] == PRINT_STMT) then
            if (ast[2][1] == STRLIT_VAL) then
                outcall(ast[2][2]:sub(2,ast[2][2]:len()-1))
			else
				outcall(numToStr(eval_expr(ast[2])))
            end
        elseif (ast[1] == NL_STMT) then
            outcall("\n")
        elseif (ast[1] == IF_STMT) then
            if eval_expr(ast[2]) ~= 0 then
				for k = 2, #ast[3] do
					interp_stmt(ast[3][k])
				end
			else
				for k = 4, #ast, 2 do
					if ast[k] ~= nil then
						if ast[k][1] == STMT_LIST then
							for j = 2, #ast[k] do
								interp_stmt(ast[k][j])
							end
						elseif eval_expr(ast[k]) ~= 0 then
							for j = 2, #ast[k+1] do
								interp_stmt(ast[k+1][j])
							end
							return
						end
					end
				end
			end
        elseif (ast[1] == WHILE_STMT) then
            while eval_expr(ast[2]) ~= 0 do
				assert(ast[3][1] == STMT_LIST)
				for k = 2, #ast[3] do
					interp_stmt(ast[3][k])
				end
			end
        elseif (ast[1] == INPUT_STMT) then
			if ast[2][1] == ID_VAL then
				set_variable(ast[2][2],incall())
			elseif ast[2][1] == ARRAY_REF then
				state.a[ast[2][2][2]][eval_expr(ast[2][3])] = strToNum(incall())
			end
        end
    end



    local function interp_stmt_list(ast)
        assert(ast[1] == STMT_LIST)
        for k = 2, #ast do
            interp_stmt(ast[k])
        end
    end


    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

