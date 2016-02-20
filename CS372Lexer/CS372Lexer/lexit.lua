--Kai Davids Schell
--CS372
--2/16/16
--Lexer

local lexit = {}

lexit.catnames = {"Keyword", "Identifier", "NumericLiteral", "StringLiteral", "Operator", "Punctuation", "Malformed"}
local pref_OP = false --flag for lexer to prefer an operator

local function is_letter(char)
    if char:len() ~= 1 then
        return false
    elseif char >= "A" and char <= "Z" then
        return true
    elseif char >= "a" and char <= "z" then
        return true
    else
        return false
    end
end

local function is_digit(char)
    if char:len() ~=1 then
        return false
    elseif char >= "0" and char <="9" then
        return true
    else
        return false
    end
end

local function is_whitespace(char)
    if char:len() ~= 1 then
        return false
    elseif char == " " or char == "\t" or char == "\n" or char == "\r" or char == "\f" or char == "\v" then
       return true
    else
        return false
    end
end

local function is_malformed(char)
    if char:len() ~= 1 then
        return false
    elseif is_whitespace(char) then
        return false
    else
        return true
	end
end

function lexit.preferOp()
    pref_OP = true
end

function lexit.lex(program)
    local pos -- current position in program file
    local state --current state
    local char --current character
    local lex --total current lex string
    local cat --current category
    local handler --table for handler functions

    local str_type="" --for set in handle_STRING, looks for second str_type to end string



    local KEY = 1
    local ID = 2
    local NUMLIT = 3
    local STRLIT = 4
    local OP = 5
    local PUNCT = 6
    local MAL = 7


    --States
    local DONE = 0
    local START = 1
    local LETTER = 2 -- a-z
    local DIGIT = 3 -- 0-9
    local PLUS = 4 -- +
    local MINUS = 5-- -
    local TIMES = 6-- *
    local DIV = 7-- /
    local EQUAL = 8-- =
    local MOD = 9-- %
    local NOT = 10-- !
    local GREATorLESS = 11-- > or <
    local EXP = 12-- e or E
    local EXPDIGIT = 13 --e0-9
	local STRING = 14 -- "abc" or 'abc'


    local function current_char()
        return program:sub(pos,pos)
    end

    local function next_char()
        return program:sub(pos+1,pos+1)
    end

    local function next_next_char()
        return program:sub(pos+2,pos+2)
    end

    local function to_next()
        pos = pos + 1
    end

    local function add_char()
        lex = lex .. current_char()
        to_next()
    end

    local function skip_whitespace() --also handles comments
        while is_whitespace(current_char()) do
            to_next()
        end
		while true do
		
			if current_char() ~= "#" then
				break
			end
					
			while current_char() ~= "\n" do
				to_next()
				if current_char() == "" then
					return
				end
			end
			to_next()
		end
    end

    local function handle_START()
        if is_digit(char) then
            add_char()
            state = DIGIT
        elseif is_letter(char) then
            add_char()
            state = LETTER
        elseif char == "+" then
            if pref_OP then
                state = DONE
                cat = OP
            else
                add_char()
                state = PLUS
            end
        elseif char == "-" then
            if pref_OP then
                state = DONE
                cat = OP
            else
                add_char()
                state = MINUS
            end
        elseif char == "*" then
            add_char()
            state = DONE
            cat = OP
        elseif char == "/" then
            add_char()
            state = DONE
			cat = OP
        elseif char == "=" then
            add_char()
            state = EQUAL
        elseif char == "%" then
            add_char()
            state = DONE
            cat = OP
        elseif char == "!" then
            add_char()
            if current_char() == "=" then
                add_char()
                cat = OP
            else
                cat = PUNCT
            end
            state = DONE
        elseif char == ">" or char == "<" then
            add_char()
            state = GREATorLESS
        elseif char == "[" then
            add_char()
            state = DONE
            cat = OP
        elseif char == "]" then
            add_char()
            state = DONE
            cat = OP
        elseif char == "'" or char == '"' then
            add_char()
            state = STRING
            if char == "'" then
                str_type = "'"
            else
                str_type = '"'
            end
        elseif string.byte(char) < 32 or string.byte(char) > 126 then
            add_char()
            state = DONE
            cat = MAL
        else
            add_char()
            state = DONE
            cat = PUNCT
        end
    end

    local function handle_LETTER()
        if is_letter(char) or is_digit(char) or char == "_" then
            add_char()
        else
            state = DONE
            cat = ID
            if lex == "set" or lex == "print" or lex == "nl" or lex == "input"
            or lex == "if" or lex == "else" or lex == "elseif" or lex == "while"
            or lex == "end" then
                cat = KEY
            end
        end
    end

    local function handle_DIGIT()
        if is_digit(char) then
            add_char()
        elseif char == "E" or char == "e" then
			if next_char() == "+" or next_char() == "-" then
                if is_digit(next_next_char()) then
				    add_char()
				    state = EXP
                else
                    state = DONE
                    cat = NUMLIT
                end
            elseif is_digit(next_char()) then
                add_char()
				state = EXP
			else
				state = DONE 
				cat = NUMLIT
			end
        else
            state = DONE
            cat = NUMLIT
        end
    end

    local function handle_EXP()
        if is_digit(char) or char == "+" or char == "-" then
            add_char()
            state = EXPDIGIT
        else
            state = DONE
            cat = MAL
        end
    end

    local function handle_EXPDIGIT()
        if is_digit(char) then
            add_char()
        else
            state = DONE
            cat = NUMLIT
        end
    end

    local function handle_PLUS()
        if is_digit(char) then
            add_char()
            state = DIGIT
        else
            state = DONE
            cat = OP
        end
    end

    local function handle_MINUS()
        if is_digit(char) then
            add_char()
            state = DIGIT
        else
            state = DONE
            cat = OP
        end
    end

    local function handle_EQUAL()
        if current_char() == "=" then
            add_char()
        end
            state = DONE
            cat = OP
    end

    local function handle_GREATorLESS()
        if current_char() == "=" then
            add_char()
        end
            state = DONE
            cat = OP
    end

    local function handle_STRING()
            add_char()
            if current_char() == str_type then
                state = DONE
                cat = STRLIT
				add_char()
            elseif char == "" then
                state = DONE
                cat = MAL
            end
    end

    handlers = {
    [START] = handle_START,
    [LETTER] = handle_LETTER,
    [DIGIT] = handle_DIGIT,
    [EXP] = handle_EXP,
    [EXPDIGIT] = handle_EXPDIGIT,
    [PLUS] = handle_PLUS,
    [MINUS] = handle_MINUS,
    [EQUAL] = handle_EQUAL,
    [GREATorLESS] = handle_GREATorLESS,
    [STRING] = handle_STRING
    }

    local function get_lexeme(dummy1, dummy2)
        if pos > program:len() then
			pref_OP = false
            return nil,nil
        end
        lex = ""
        state = START
        while state ~= DONE do
            char = current_char()
            handlers[state]()
        end
        skip_whitespace()
		pref_OP = false
        return lex, cat
    end

    pos = 1
	char = ""
    skip_whitespace()
    return get_lexeme, nil, nil

end

return lexit
