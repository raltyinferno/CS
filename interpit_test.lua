#!/usr/bin/env lua
-- interpit_test.lua
-- Glenn G. Chappell
-- 7 Apr 2016
--
-- For CS 331 Spring 2016
-- Test Program for Module interpit
-- Used in Assignment 6, Exercise A

interpit = require "interpit"  -- Import parseit module


-- *********************************************
-- * YOU MAY WISH TO CHANGE THE FOLLOWING LINE *
-- *********************************************

exit_on_failure = true

-- If exit_on_failure is true, then:
-- - On first failing test, we print the input, expected output, and
--   actual output; then the test program terminates.
-- If exit_on_failure is false, then:
-- - All tests are performed, with a summary of results printed at the
--   end.


-- *********************************************************************
-- Testing Package
-- *********************************************************************


tester = {}
tester.countTests = 0
tester.countPasses = 0

function tester.test(self, success, testName)
    self.countTests = self.countTests+1
    io.write("    Test: " .. testName .. " - ")
    if success then
        self.countPasses = self.countPasses+1
        io.write("passed")
    else
        io.write("********** FAILED **********")
    end
    io.write("\n")
end

function tester.allPassed(self)
    return self.countPasses == self.countTests
end


-- *********************************************************************
-- Definitions for This Test Program
-- *********************************************************************


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


function printNoteAndExit()
    io.write("\n")
    io.write("******************************************************\n")
    io.write("*                                                    *\n")
    io.write("*  NOTE: This program is set to terminate after the  *\n")
    io.write("*        first failing test. If you would prefer to  *\n")
    io.write("*        execute all tests, whether they pass or     *\n")
    io.write("*        not, then set variable exit_on_failure to   *\n")
    io.write("*        false. (See the beginning of the source     *\n")
    io.write("*        code.)                                      *\n")
    io.write("*                                                    *\n")
    io.write("******************************************************\n")
    io.write("\n")
    os.exit(1)
end


-- deepcopy
-- Returns deep copy of given value.
-- From http://lua-users.org/wiki/CopyTable 
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


-- strArrayEq
-- Check equality of two arrays of strings. Return true/false.
function strArrayEq(sa1, sa2)
    if #sa1 ~= #sa2 then
        return false
    end

    for i = 1, #sa1 do
        if sa1[i] ~= sa2[i] then
            return false
        end
    end

    return true
end


-- numKeys
-- Given a table, return the number of keys in it.
function numKeys(tab)
    local keycount = 0
    for k, v in pairs(tab) do
        keycount = keycount + 1
    end
    return keycount
end


-- isState
-- Check whether given table is properly formatted Zebu state. Return
-- true/false.
function isState(tab)
    -- Is table?
    if type(tab) ~= "table" then
        return false
    end

    -- Has exactly 2 keys?
    if numKeys(tab) ~= 2 then
        return false
    end

    -- Has s, a keys?
    if tab.s == nil or tab.a == nil then
        return false
    end

    -- s, a keys are tables?
    if type(tab.s) ~= "table" or type(tab.a) ~= "table" then
        return false
    end

    -- All items in s are string:number
    for k, v in pairs(tab.s) do
        if type(k) ~= "string" or type(v) ~= "number" then
            return false
        end
    end

    -- All items in a are string:table
    -- All items in values in a are string:number
    for k, v in pairs(tab.a) do
        if type(k) ~= "string" or type(v) ~= "table" then
            return false
        end
        for kk, vv in pairs(v) do
            if type(kk) ~= "number" or type(vv) ~= "number" then
                return false
            end
        end
    end

    return true
end


-- stateEq
-- Given two properly formatted Zebu state tables, checks if they are
-- the same. Returns true/false.
function stateEq(st1, st2)
    if numKeys(st1.s) ~= numKeys(st2.s) then
        return false
    end
    for k, v in pairs(st1.s) do
        if st2.s[k] == nil then
            return false
        end
        if st2.s[k] ~= st1.s[k] then
            return false
        end
    end

    if numKeys(st1.a) ~= numKeys(st2.a) then
        return false
    end
    for k, v in pairs(st1.a) do
        if st2.a[k] == nil then
            return false
        end
        if numKeys(st2.a[k]) ~= numKeys(st2.a[k]) then
            return false
        end
        for kk, vv in pairs(st1.a[k]) do
            if st2.a[k][kk] == nil then
                return false
            end
            if st2.a[k][kk] ~= st1.a[k][kk] then
                return false
            end
        end
    end

    return true
end


-- checkInterp
-- Given tester object, AST, array of input strings, input state, array
-- of expected output strings, expected output state, and string giving
-- the name of the test. Calls interpit.interp and checks output strings
-- & state. Prints result. If test fails and exit_on_failure is true,
-- then print detailed results and exit program.
function checkInterp(t, ast,
                     input, statein,
                     expoutput, expstateout,
                     testName)
    -- Error flags
    local err_incallparam = false
    local err_outcallnil = false
    local err_outcallnonstr = false

    local incount = 0
    local function incall(param)
        if param ~= nil then
            err_incallparam = true
        end
        incount = incount + 1
        if incount <= #input then
            return input[incount]
        else
            return ""
        end
    end

    local output = {}
    local function outcall(str)
        if type(str) == "string" then
            table.insert(output, str)
        elseif str == nil then
            err_outcallnil = true
            table.insert(output, "")
        else
            err_outcallnonstr = true
            table.insert(output, "")
        end
    end

    local stateout = interpit.interp(ast, statein, incall, outcall)

    local pass = true
    local msg = ""

    if incount > #input then
        pass = false
        msg = msg .. "Too many calls to incall\n"
    elseif incount < #input then
        pass = false
        msg = msg .. "Too few calls to incall\n"
    end

    if err_incallparam then
        pass = false
        msg = msg .. "incall called with parameter\n"
    end

    if #output > #expoutput then
        pass = false
        msg = msg .. "Too many calls to outcall\n"
    elseif #output < #expoutput then
        pass = false
        msg = msg .. "Too few calls to outcall\n"
    end

    if err_outcallnil then
        pass = false
        msg = msg .. "outcall called with nil or missing parameter\n"
    end
    if err_outcallnonstr then
        pass = false
        msg = msg .. "outcall called with non-string parameter\n"
    end

    if not strArrayEq(output, expoutput) then
        pass = false
        msg = msg .. "Output incorrect\n"
    end

    if isState(stateout) then
        if not stateEq(stateout, expstateout) then
            pass = false
            msg = msg .. "Returned state is incorrect\n"
        end
    else
        pass = false
        msg = msg .. "Returned state does not represent a Zebu state\n"
    end

    t:test(pass, testName)
    if pass or not exit_on_failure then
        return
    end

    io.write("\n")
    io.write(msg)
    io.write("\n")
    printNoteAndExit()
end


-- *********************************************************************
-- Test Suite Functions
-- *********************************************************************


function test_simple(t)
    io.write("Test Suite: simple programs\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- Empty program
    ast = {STMT_LIST}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Empty program")

    -- Nl
    ast = {STMT_LIST, {NL_STMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "nl")

    -- Two nl-statements
    ast = {STMT_LIST, {NL_STMT}, {NL_STMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"\n", "\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Two nl-statements")

    -- Print: empty string
    ast = {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "''"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {""}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: empty string")

    -- Print: string, single-quoted
    ast = {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'abc'"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string, single-quoted")

    -- Print: string, double-quoted
    ast = {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, '"def"'}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"def"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string, double-quoted")

    -- Print: string + nl
    ast = {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'abc'"}}, {NL_STMT}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"abc", "\n"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: string + nl")

    -- Simple set
    ast = {STMT_LIST, {SET_STMT, {ID_VAL, "a"},
      {NUMLIT_VAL, "42"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={a=42}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple set")

    -- Simple if #1
    ast = {STMT_LIST, {IF_STMT, {NUMLIT_VAL, "0"}, {STMT_LIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple if #1")

    -- Simple if #2
    ast = {STMT_LIST, {IF_STMT, {NUMLIT_VAL, "4"}, {STMT_LIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple if #2")

    -- Simple while
    ast = {STMT_LIST, {WHILE_STMT, {NUMLIT_VAL, "0"}, {STMT_LIST}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple while")

   -- Simple input
    ast = {STMT_LIST, {INPUT_STMT, {ID_VAL, "b"}}}
    input = {"37"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={b=37}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Simple input")

    -- Print: number
    ast = {STMT_LIST, {PRINT_STMT, {NUMLIT_VAL, "28"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"28"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: number")

    -- Print: undefined variable
    ast = {STMT_LIST, {PRINT_STMT, {ID_VAL, "d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print: undefined variable")

    -- Set + print: variable
    ast = {STMT_LIST, {SET_STMT, {ID_VAL, "c"}, {NUMLIT_VAL, "57"}},
      {PRINT_STMT, {ID_VAL, "c"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"57"}
    expstateout = {s={c=57}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set + print: variable")

    -- Set + print: other variable
    ast = {STMT_LIST, {SET_STMT, {ID_VAL, "c"}, {NUMLIT_VAL, "57"}},
      {PRINT_STMT, {ID_VAL, "d"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {s={c=57}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set + print: variable")

    -- Input + print: variable
    ast = {STMT_LIST, {INPUT_STMT, {ID_VAL, "c"}},
      {PRINT_STMT, {ID_VAL, "c"}}}
    input = {"12"}
    statein = deepcopy(emptystate)
    expoutput = {"12"}
    expstateout = {s={c=12}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Input + print: variable")

    -- Input + print: other variable
    ast = {STMT_LIST, {INPUT_STMT, {ID_VAL, "c"}},
      {PRINT_STMT, {ID_VAL, "d"}}}
    input = {"24"}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = {s={c=24}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Input + print: other variable")

    -- Set array
    ast = {STMT_LIST, {SET_STMT,
      {ARRAY_REF, {ID_VAL, "a"}, {NUMLIT_VAL, "2"}},
      {NUMLIT_VAL, "7"}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={}, a={a={[2]=7}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Set array")
end


function test_state(t)
    io.write("Test Suite: modified initial state\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- Empty program
    ast = {STMT_LIST}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - empty program")

    -- Set simple var #1
    ast = {STMT_LIST, {SET_STMT, {ID_VAL, "a"}, {NUMLIT_VAL, "3"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = {s={a=3,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set simple var #1")

    -- Set simple var #2
    ast = {STMT_LIST, {SET_STMT, {ID_VAL, "c"}, {NUMLIT_VAL, "3"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = {s={a=1,b=2,c=3},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set simple var #2")

    -- Set array #1
    ast = {STMT_LIST, {SET_STMT,
      {ARRAY_REF, {ID_VAL, "b"}, {NUMLIT_VAL, "2"}},
      {NUMLIT_VAL, "9"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=9,[4]=3}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #1")

    -- Set array #2
    ast = {STMT_LIST, {SET_STMT,
      {ARRAY_REF, {ID_VAL, "b"}, {NUMLIT_VAL, "-5"}},
      {NUMLIT_VAL, "9"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3,[-5]=9}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #2")

    -- Set array #3
    ast = {STMT_LIST, {SET_STMT,
      {ARRAY_REF, {ID_VAL, "c"}, {NUMLIT_VAL, "0"}},
      {NUMLIT_VAL, "9"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {}
    expstateout = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3},c={[0]=9}}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - set array #3")

    -- Print simple var #1
    ast = {STMT_LIST, {PRINT_STMT, {ID_VAL, "a"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print simple var #1")

    -- Print simple var #2
    ast = {STMT_LIST, {PRINT_STMT, {ID_VAL, "c"}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print simple var #2")

    -- Print array #1
    ast = {STMT_LIST, {PRINT_STMT, {ARRAY_REF, {ID_VAL, "a"},
      {NUMLIT_VAL, "4"}}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #1")

    -- Print array #2
    ast = {STMT_LIST, {PRINT_STMT, {ARRAY_REF, {ID_VAL, "a"},
      {NUMLIT_VAL, "8"}}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #2")

    -- Print array #3
    ast = {STMT_LIST, {PRINT_STMT, {ARRAY_REF, {ID_VAL, "c"},
      {NUMLIT_VAL, "8"}}}}
    input = {}
    statein = {s={a=1,b=2},
      a={a={[2]=3,[4]=7},b={[2]=7,[4]=3}}}
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print array #3")

    -- Print-set-print-input-print
    ast = {STMT_LIST,
      {PRINT_STMT, {ID_VAL, "abc"}},
      {SET_STMT, {ID_VAL, "abc"}, {NUMLIT_VAL, "55"}},
      {PRINT_STMT, {ID_VAL, "abc"}},
      {INPUT_STMT, {ID_VAL, "abc"}},
      {PRINT_STMT, {ID_VAL, "abc"}}}
    input = {"66"}
    statein = {s={abc=44}, a={}}
    expoutput = {"44", "55", "66"}
    expstateout = {s={abc=66}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Modified initial state - Print-set-print-input-print")
end


function test_expr(t)
    io.write("Test Suite: expressions\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- Print unary +
    ast = {STMT_LIST, {PRINT_STMT,
      {{UN_OP, "+"}, {NUMLIT_VAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"5"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print unary +")

    -- Print unary -
    ast = {STMT_LIST, {PRINT_STMT,
      {{UN_OP, "-"}, {NUMLIT_VAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-5"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print unary -")

    -- Print binary +
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "+"}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"7"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print binary +")

    -- Print binary -
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "-"}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"3"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print binary -")

    -- Print *
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "*"}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"10"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print *")

    -- Print /
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "/"}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"2"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print /")

    -- Print %
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "%"}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print %")

    -- Print == #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "=="}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print == #1")

    -- Print == #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "=="}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print == #2")

    -- Print != #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "!="}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print != #1")

    -- Print != #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "!="}, {NUMLIT_VAL, "5"}, {NUMLIT_VAL, "5"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print != #2")

    -- Print < #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<"}, {NUMLIT_VAL, "1"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #1")

    -- Print < #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<"}, {NUMLIT_VAL, "2"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #2")

    -- Print < #3
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<"}, {NUMLIT_VAL, "3"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print < #3")

    -- Print <= #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<="}, {NUMLIT_VAL, "1"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #1")

    -- Print <= #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<="}, {NUMLIT_VAL, "2"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #2")

    -- Print <= #3
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, "<="}, {NUMLIT_VAL, "3"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print <= #3")

    -- Print > #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">"}, {NUMLIT_VAL, "1"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #1")

    -- Print > #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">"}, {NUMLIT_VAL, "2"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #2")

    -- Print > #3
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">"}, {NUMLIT_VAL, "3"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print > #3")

    -- Print >= #1
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">="}, {NUMLIT_VAL, "1"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #1")

    -- Print >= #2
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">="}, {NUMLIT_VAL, "2"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #2")

    -- Print >= #3
    ast = {STMT_LIST, {PRINT_STMT,
      {{BIN_OP, ">="}, {NUMLIT_VAL, "3"}, {NUMLIT_VAL, "2"}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"1"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Print >= #3")

    -- Longer expression
    ast =
      {STMT_LIST,
        {PRINT_STMT,
          {{UN_OP, "-"},
            {{BIN_OP, "-"},
              {{BIN_OP, "=="}, {ID_VAL, "x"}, {NUMLIT_VAL, "3"}},
              {{BIN_OP, "*"},
                {NUMLIT_VAL, "9"},
                {{UN_OP, "+"}, {ID_VAL, "y"}}
              }
            }
          }
        }
      }
    input = {}
    statein = {s={x=3, y=5}, a={}}
    expoutput = {"44"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Longer expression")
end


function test_intconv(t)
    io.write("Test Suite: integer conversion\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- Numeric literal #1
    ast =
      {STMT_LIST,
        {SET_STMT, {ID_VAL, "n"}, {NUMLIT_VAL, "5.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={n=5}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #1")

    -- Numeric literal #2
    ast =
      {STMT_LIST,
        {SET_STMT, {ID_VAL, "n"}, {NUMLIT_VAL, "-7.4"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={n=-7}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #2")

    -- Numeric literal #3
    ast =
      {STMT_LIST,
        {SET_STMT, {ID_VAL, "n"}, {NUMLIT_VAL, "5.74e1"}}
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={n=57}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - numeric literal #3")

    -- Input
    ast =
      {STMT_LIST,
        {INPUT_STMT, {ID_VAL, "n"}}
      }
    input = {"2.9"}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = {s={n=2}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - input")

    -- Division + multiplication #1
    ast =
      {STMT_LIST,
        {PRINT_STMT,
          {{BIN_OP, "*"},
            {{BIN_OP, "/"}, {NUMLIT_VAL, "10"}, {NUMLIT_VAL, "3"}},
            {NUMLIT_VAL, "3"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"9"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - division + multiplication #1")

    -- Division + multiplication #2
    ast =
      {STMT_LIST,
        {PRINT_STMT,
          {{BIN_OP, "*"},
            {{BIN_OP, "/"}, {NUMLIT_VAL, "-3"}, {NUMLIT_VAL, "2"}},
            {NUMLIT_VAL, "2"}
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"-2"}
    expstateout = deepcopy(statein)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Integer conversion - division + multiplication #2")
end


function test_if(t)
    io.write("Test Suite: if-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- If #1
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "4"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If #1")

    -- If #2
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If #1")

    -- If-else #1
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "5"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-else #1")

    -- If-else #2
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-else #2")

    -- If-elseif #1
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "6"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "7"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #1")

    -- If-elseif #2
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "7"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #2")

    -- If-elseif #3
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif #3")

    -- If-elseif-else #1
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "6"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "7"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #1")

    -- If-elseif-else #2
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "7"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #2")

    -- If-elseif-else #3
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif-else #3")

    -- If-elseif*-else #1
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "8"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
      {NUMLIT_VAL, "9"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'e'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #1")

    -- If-elseif*-else #2
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
      {NUMLIT_VAL, "9"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'e'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #2")

    -- If-elseif*-else #3
    ast = {STMT_LIST, {IF_STMT,
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}},
      {NUMLIT_VAL, "0"},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'e'"}}},
      {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'f'"}}}}}
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"f"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "If-elseif*-else #3")

    -- Nested if-else #1
    ast =
      {STMT_LIST,
        {IF_STMT,
          {NUMLIT_VAL, "1"},
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "1"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}
            }
          },
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "1"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"a"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #1")

    -- Nested if-else #2
    ast =
      {STMT_LIST,
        {IF_STMT,
          {NUMLIT_VAL, "1"},
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "0"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}
            }
          },
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "0"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"b"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #2")

    -- Nested if-else #3
    ast =
      {STMT_LIST,
        {IF_STMT,
          {NUMLIT_VAL, "0"},
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "1"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}
            }
          },
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "1"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"c"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #3")

    -- Nested if-else #4
    ast =
      {STMT_LIST,
        {IF_STMT,
          {NUMLIT_VAL, "0"},
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "0"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'a'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'b'"}}}
            }
          },
          {STMT_LIST,
            {IF_STMT,
              {NUMLIT_VAL, "0"},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'c'"}}},
              {STMT_LIST, {PRINT_STMT, {STRLIT_VAL, "'d'"}}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"d"}
    expstateout = deepcopy(emptystate)
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "Nested if-else #4")
end


function test_while(t)
    io.write("Test Suite: while-statements\n")

    local ast, statein, expoutput, expstateout
    local emptystate = {s={}, a={}}

    -- While loop - counted
    ast =
      {STMT_LIST,
        {SET_STMT, {ID_VAL, "i"}, {NUMLIT_VAL, "0"}},
        {WHILE_STMT,
          {{BIN_OP, "<"}, {ID_VAL, "i"}, {NUMLIT_VAL, "7"}},
          {STMT_LIST,
            {PRINT_STMT,
              {{BIN_OP, "*"}, {ID_VAL, "i"}, {ID_VAL, "i"}}
            },
            {SET_STMT,
              {ID_VAL, "i"},
              {{BIN_OP, "+"}, {ID_VAL, "i"}, {NUMLIT_VAL, "1"}}
            }
          }
        }
      }
    input = {}
    statein = deepcopy(emptystate)
    expoutput = {"0", "1", "4", "9", "16", "25", "36"}
    expstateout = {s={i=7},a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "While loop - counted")

    -- While loop - input with sentinel
    ast =
      {STMT_LIST,
        {SET_STMT, {ID_VAL, "notdone"}, {NUMLIT_VAL, "1"}},
        {WHILE_STMT,
          {ID_VAL, "notdone"},
          {STMT_LIST,
            {INPUT_STMT, {ID_VAL, "n"}},
            {IF_STMT,
              {{BIN_OP, "=="}, {ID_VAL, "n"}, {NUMLIT_VAL, "99"}},
              {STMT_LIST,
                {SET_STMT, {ID_VAL, "notdone"}, {NUMLIT_VAL, "0"}}
              },
              {STMT_LIST,
                {PRINT_STMT, {ID_VAL, "n"}},
                {NL_STMT}
              }
            }
          }
        },
        {PRINT_STMT, {STRLIT_VAL, "'Bye!'"}},
        {NL_STMT}
      }
    input = {"1", "8", "-17", "13.5", "99"}
    statein = deepcopy(emptystate)
    expoutput = {"1", "\n", "8", "\n", "-17", "\n", "13", "\n", "Bye!", "\n"}
    expstateout = {s={notdone=0, n=99}, a={}}
    checkInterp(t, ast, input, statein, expoutput, expstateout,
      "While loop - input with sentinel")
end


function test_interpit(t)
    io.write("TEST SUITES FOR MODULE parseit\n")
    test_simple(t)
    test_state(t)
    test_expr(t)
    test_intconv(t)
    test_if(t)
    test_while(t)
end


-- *********************************************************************
-- Main Program
-- *********************************************************************


test_interpit(tester)
io.write("\n")
if tester:allPassed() then
    io.write("All tests successful\n")
else
    io.write("Tests ********** UNSUCCESSFUL **********\n")
    io.write("\n")
    io.write("******************************************************\n")
    io.write("*                                                    *\n")
    io.write("*  NOTE: This program is set to execute all tests.   *\n")
    io.write("*        If you would prefer to stop after the       *\n")
    io.write("*        first failing test and see detailed         *\n")
    io.write("*        results, then set variable exit_on_failure  *\n")
    io.write("*        to true. (See the beginning of the source   *\n")
    io.write("*        code.)                                      *\n")
    io.write("*                                                    *\n")
    io.write("******************************************************\n")
end
io.write("\n")

