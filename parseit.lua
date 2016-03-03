--Kai Davids Schell
--CS331 HW 4
--parsit.lua
--exports parsit module: recursive decent parser


local parseit = {}

lexer = require "lexit"

local iter          -- Iterator returned by lexer.lex
local state         -- State for above iterator (maybe not used)

local lexstr = ""
local lexcat = 0

local KEY = 1
local ID = 2
local NUMLIT = 3
local STRLIT = 4
local OP = 5
local PUNCT = 6
local MAL = 7

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

local function advance()
    -- Advance the iterator
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)

    
    
    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then  
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
    if lexstr == "]" or lexstr == ")" or lexcat == NUMLIT or lexcat == ID then
            lexer.preferOp()        
        end
end


-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexer.lex(prog)
    advance()
end


-- atEnd
-- Return true is pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end


-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end


-- matchCat
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end


local parse_expr
local parse_term
local parse_factor


function parseit.parse(prog)
    -- Initialization
    init(prog)

    -- Get results from parsing
    local success, ast = parse_program()  -- Parse start symbol

    if success then
        return true, ast
    else
        return false, nil
    end
end



-- parse_program
-- Parsing function for nonterminal "program".
-- Function init must be called before this function is called.
function parse_program()
    local good, ast

    good, ast = parse_stmt_list()
    if not good then
        return false, nil
    end

    if not atEnd() then
        return false, nil
    end

    return true, ast
end
--------------------------------------------------------------

-- parse_expr   ==    parse_stmt_list?
-- Parsing function for nonterminal "expr".
-- Function init must be called before this function is called.
function parse_expr()
    local good, ast, saveop, newast

    good, ast = parse_aexpr()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("==") 
		and not matchString("!=") and not matchString("<") and not matchString(">") 
		and not matchString("<=") and not matchString(">=") then
            return true, ast
        end

        good, newast = parse_aexpr()
        if not good then
            return false, nil
        end

        ast = { { BIN_OP, saveop }, ast, newast }
    end
end

-- parse_aexpr 
-- Parsing function for nonterminal "expr".
-- Function init must be called before this function is called.
function parse_aexpr()
    local good, ast, saveop, newast

    good, ast = parse_term()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("+") and not matchString("-") then
            return true, ast
        end

        good, newast = parse_term()
        if not good then
            return false, nil
        end

        ast = { { BIN_OP, saveop }, ast, newast }
    end
end



-- parse_stmt_list
-- Parsing function for nonterminal "stmt_list".
-- Function init must be called before this function is called.
function parse_stmt_list()
    local good, ast, newast
    ast = {STMT_LIST}

    while true do
        if lexstr ~= "set"
          and lexstr ~= "print"
          and lexstr ~= "nl"
          and lexstr ~= "input"
          and lexstr ~= "if"
          and lexstr ~= "while" then
            return true, ast
        end

        good, newast = parse_statement()
        if not good then
            return false, nil
        end
        table.insert(ast, newast)
    end
end

-----------------------
-- parse_statement
-- Parsing function for nonterminal "statement"
-- Function init must be called before this function is called.
function parse_statement()
    local good, ast1={}, ast2, savelex

    if matchString("set") then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end     
        
        if not matchString("=") then
            return false, nil
        end     


        good, ast2 = parse_expr()
        if not good then
            return false, nil
        end
        return true, {SET_STMT, ast1, ast2}
        
    elseif matchString("print") then
        savelex = lexstr
        if matchCat(STRLIT) then
            return true, {PRINT_STMT, {STRLIT_VAL, savelex}}
        end

        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end
        return true, {PRINT_STMT, ast1}

    elseif matchString("nl") then
        return true, {NL_STMT}
        
    elseif matchString("input") then
        good, ast1 = parse_lvalue()
        if not good then
            return false, nil
        end
        return true, {SET_STMT, ast1}
        
    elseif matchString("if") then
		local ast3
        good,ast2 = parse_expr()
        if not good then
            return false, nil
        end
		ast1 = {IF_STMT, ast2}
        good, ast2 = parse_stmt_list()
        if not good then
            return false,nil
        end
		table.insert(ast1,ast2)
		while true do
			if matchString("elseif") then
				good, ast2 = parse_expr()
				if not good then
					return false, nil
				end
				good, ast3 = parse_stmt_list()
				if not good then
					return false, nil
				end
				table.insert(ast1,ast2)
				table.insert(ast1,ast3)
			else
				break
			end				
		end
		if matchString("else") then
			good, ast3 = parse_stmt_list()
			if not good then
				return false,nil
			end
			table.insert(ast1,ast3)
		elseif matchString("end") then
			return ast1
		else
			return false, nil
		end	
		
    elseif matchString("while") then
        
            
    end


end

-- parse_term
-- Parsing function for nonterminal "term".
-- Function init must be called before this function is called.
function parse_term()
    local good, ast, saveop, newast

    good, ast = parse_factor()
    if not good then
        return false, nil
    end

    while true do
        saveop = lexstr
        if not matchString("*") and not matchString("/") and not matchString("%") then
            return true, ast
        end

        good, newast = parse_factor()
        if not good then
            return false, nil
        end

        ast = { { BIN_OP, saveop }, ast, newast }
    end
end


-- parse_factor
-- Parsing function for nonterminal "factor".
-- Function init must be called before this function is called.
function parse_factor()
    local savelex, good, ast

    savelex = lexstr
    if matchCat(ID) then
	
		
        if matchString("[") then
            savenum = lexstr
			good, ast = parse_expr()
			
			if not good then
			return false
			end
			
			if not matchString("]") then
			return false, nil
            end
			
			return true, { ARRAY_REF, {ID_VAL, savelex}, ast  }			
        end
		
		
		
	
        return true, { ID_VAL, savelex }
    elseif matchCat(NUMLIT) then
        return true, { NUMLIT_VAL, savelex }
    elseif matchString("(") then
        good, ast = parse_expr()
        if not good then
            return false, nil
        end

        if not matchString(")") then
            return false, nil
        end

        return true, ast
		
		
	elseif matchCat(OP) then 
		lexid = lexstr
		
		
			good, ast = parse_factor()
			
			if not good or (savelex ~= "+" and savelex ~= "-") then
				return false, nil
			end
			
		 return true, { {UN_OP, savelex}, ast }
		
	
		
		
    else
        return false, nil
    end
end





function parse_lvalue()

    local savelex, good, ast

    savelex = lexstr
    if matchCat(ID) then
    
                
        if matchString("[") then
            savenum = lexstr
            if matchCat(NUMLIT) then 
                if matchString("]") then
                    return true, { ARRAY_REF, {ID_VAL, savelex}, {NUMLIT_VAL, savenum}  }
                end
                
                return false, nil
            end
        
        else
            return true, { ID_VAL, savelex }
        end
        
        
        
    elseif matchCat(NUMLIT) then
        
        if matchString("=") then
            return false, nil
        end
        
        
        plus = lexstr
        if matchString("+") then
            num2 = lexstr
            
            if matchCat(NUMLIT) then
            
            return true, {BIN_OP, plus}, {NUMLIT_VAL, num1}, {NUMLIT_VAL, num2}
            
            end
            return false, nil
        
        end
        
         return true, { NUMLIT_VAL, savelex }

        
    elseif matchString("(") then
        good, ast = parse_statement()
        if not good then
            return false, nil
        end

        if not matchString(")") then
            return false, nil
        end

        return true, ast

    else
        return false, nil
    end
end








-- Module Export

return parseit