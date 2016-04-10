-- interpit.lua (UNFINISHED)
-- Glenn G. Chappell
-- 30 Mar 2016
--
-- For CS 331 Spring 2016
-- Interpret AST from parseit.parse
-- For Assignment 6, Exercise A


-- ******************************************************************
-- * To run a Zebu program, use zebu.lua (which calls this module). *
-- ******************************************************************


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

    local function interp_stmt(ast)
        if (ast[1] == SET_STMT) then
            outcall("[DUNNO WHAT TO DO!!!]\n")
        elseif (ast[1] == PRINT_STMT) then
            if (ast[2][1] == STRLIT_VAL) then
                outcall(ast[2][2]:sub(2,ast[2][2]:len()-1))
            else
                outcall("[DUNNO WHAT TO DO!!!]\n")
            end
        elseif (ast[1] == NL_STMT) then
            outcall("\n")
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

    interp_stmt_list(ast)
    return state
end


-- ***** Module Export *****


return interpit

