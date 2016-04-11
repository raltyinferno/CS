-- Tristan Craddick
-- 30 Mar 2016
--
-- For CS 331 Spring 2016


-- ******************************************************************
-- * To run a Zebu program, use zebu.lua (which calls this module). *
-- ******************************************************************

----------- Assignment Notes:	-----------
--	-DRY: write a function to do something, then when you need to do that, call the function
--	-Assue AST is formatted correctly
--	-Write all functions local to interpit.interp
--		--pass around ASTs
--		--do not pass around state, incall, outcall
--	-l-values occur:
--		--paramter of input
--		--lhs of set
--	-expressions occur
--		--parameter of print
--		--rhs of set
--		--array index
--		--inside expressions
--

--seven functions
--	-Find_variable			--takes AST, returns name, index ("NONE" for simple variable)	
--							--name/index are both passed below to the variable functions
--	-get_variable			-takes name, index, returns value
--	-set_variable			-takes name, index, value, returns nothing
--	-bool_to_in				
--	-eval_expr				-takes an AST, returns a value (number)
--							--if ast[1] == NUMLIT_VAR then
--							--.... happens
--							--elseif ast[1] == ID_VAL
--								--or ast[1] == ARRAT_REF
--							--... happens
--							--elseif ast[1][1] == UN_OP then	---as the AST is correct, only remaining is table
--							--... happens
--							--elseif ast[1][1] == BIN_OP then
--									val1 == eval_expr(ast[2])
--									val2 == eval_expr(ast[2])
--									return toInt(val1 + val2)
--								-if ast[1][2] == "t" then
--								-... happens
--								-elseiif ast[1][2] == ...
--	-interp_stmt
--	-interp_stmt_list

--find_variable, eval_expr will call eachother


local interpit = {}  -- Our module


-- ***** Variables *****


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


-- ***** Primary Function for Client Code *****


-- interp
-- Interpreter, given AST returned by parseit.parse.
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
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.
	local function get_variable(tab,index)
		return state.tab[index]
	end
	
	local function set_variable(key,value)
		state.s[key]=strToNum(value)
	end
	
    local function interp_stmt(ast)
        if (ast[1] == SET_STMT) then
			set_variable(ast[2][2],ast[3][2])
        elseif (ast[1] == PRINT_STMT) then
            if (ast[2][1] == STRLIT_VAL) then
                outcall(ast[2][2]:sub(2,ast[2][2]:len()-1))
            elseif (ast[2][1] == NUMLIT_VAL) then
				outcall(ast[2][2])
			elseif (ast[2][1] == ID_VAL) then
				if (state.s[ast[2][2]] ~= nil) then
					outcall(numToStr(state.s[ast[2][2]]))
				else
					outcall("0")
				end
			else
				outcall("[DUNNO WHAT TO DO!!!]\n")
            end
        elseif (ast[1] == NL_STMT) then
            outcall("\n")
        elseif (ast[1] == IF_STMT) then
			--if(ast[2][2] == interp_stmt_list(ast[3])) then
		elseif (ast[1] == WHILE_STMT) then
			--
		elseif (ast[1] == INPUT_STMT) then
			state.s[ast[2][2]] = strToNum(incall())
		else
            outcall("[DUNNO WHAT TO DO!!!]\n")
        end
    end

    local function interp_stmt_list(ast)
        assert(ast[1] == STMT_LIST)
        for k = 2, #ast do
            interp_stmt(ast[k])
        end
    end
	--	-eval_expr				-takes an AST, returns a value (number)
--							--if ast[1] == NUMLIT_VAR then
--							--.... happens
--							--elseif ast[1] == ID_VAL
--								--or ast[1] == ARRAY_REF
--							--... happens
--							--elseif ast[1][1] == UN_OP then	---as the AST is correct, only remaining is table
--							--... happens
--							--elseif ast[1][1] == BIN_OP then
--									val1 == eval_expr(ast[2])
--									val2 == eval_expr(ast[2])
--									return toInt(val1 + val2)
--								-if ast[1][2] == "t" then
--								-... happens
--								-elseiif ast[1][2] == ...
	local function eval_expr(ast)
		if ast[1] == NUMLIT_VAL then
			return ast[2]
		
		
		
		end	
	end


    interp_stmt_list(ast)
	--io.write("42 ")
	--io.write(strToNum(ast[3]))
	--io.write(state.s["a"])
    return state
end


-- ***** Module Export *****


return interpit

