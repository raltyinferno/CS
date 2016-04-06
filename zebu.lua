#!/usr/bin/env lua
-- zebu.lua
-- Glenn G. Chappell
-- 30 Mar 2016
-- Revised 3 Apr 2016
--
-- For CS 331 Spring 2016
-- Interpreter for Zebu Programming Language
-- Requires lexit.lua, parseit.lua, interpit.lua


parseit = require "parseit"
interpit = require "interpit"


-- ***** Variables *****


local zebustate = { s={}, a={} }  -- Zebu state: variable values


-- ***** Utility Functions *****


-- inputLine
-- Input a line of text from standard input and return it in string
-- form, with no trailing newline.
function inputLine()
    return io.read("*l")
end


-- outputString
-- Output the given string to standard output, with no added newline.
function outputString(s)
    io.write(s)
end


-- ***** Functions for Zebu Interpreter *****


-- runZebu
-- Given a string, attempt to treat it as source code for a Zebu
-- program, and execute it. I/O uses standard input & output.
-- Parameters:
--   program  - Zebu source code
--   state    - Values of Zebu variables as in interpit.interp.
-- Returns two values:
--   success  - true if program parsed successfully, false otherwise.
--   newstate - If success is true, then new value of state, updated
--              with revised values of variables. If success is false,
--              then same as passed value of state.
function runZebu(program, state)
    local success, ast = parseit.parse(program)
    local newstate
    if success then
        newstate = interpit.interp(ast, state, inputLine, outputString)
    else
        outputString("*** ERROR: Syntax error in Zebu source\n")
        newstate = state
    end
    return success, newstate
end


-- isZebuSourceFilename
-- Given string, return true if it looks like the name of a Zebu source
-- file: no whitespace, ends with ".zebu", and has something before the
-- ".". Otherwise, return false.
function isZebuSourceFilename(s)
    if s:len() < 5 then
        return false
    end
    for i = 1, s:len() do
        local c = s:sub(i,i)
        if c == " " or c == "\t" or c == "\n" or c == "\r"
          or c == "\f" then
            return false
        end
    end
    return s:sub(s:len()-4,s:len()) == ".zebu"
end


-- runFile
-- Given filename, attempt to read source for a Zebu program from it,
-- and execute the program.
function runFile(fname)
    function readable(fname)
        local f = io.open(fname, "r")
        if f ~= nil then
            f:close()
            return true
        else
            return false
        end
    end

    local success

    if not readable(fname) then
        io.write("*** ERROR: Zebu source file not readable\n")
        return
    end
    local source = ""
    for line in io.lines(fname) do
        source = source .. line .. "\n"
    end
    success, zebustate = runZebu(source, zebustate)
end


-- repl
-- Zebu REPL. Prompt & get a line. If it is blank, then exit. If it
-- looks like the filename of a Zebu source file, then get Zebu source
-- from it, execute, and exit. Otherwise, treat line as Zebu program,
-- execute it, and REPEAT.
function repl()
    local success

    io.write("Type Zebu source filename (---.zebu) or Zebu program\n")
    io.write("Blank line to exit\n")
    while true do
        io.write("> ")
        local line = io.read("*l")  -- Read a line
        if line == "" then
            break
        elseif (isZebuSourceFilename(line)) then
            runFile(line)
            break
        else
            success, zebustate = runZebu(line, zebustate)
        end
        io.write("\n")
    end
end


-- ***** Main Program *****


-- Command-line argument? If so treat as Zebu source filename, read
-- source, and execute.
if arg[1] ~= nil then
    runFile(arg[1])
-- Otherwise, fire up the Zebu REPL.
else
    repl()
end

