-- Parse input stream to strings tree

--[[
  Author: Martin Eden
  Last mod.: 2026-05-23
]]

-- Imports:
local add_to_list = request('!.concepts.list.add_item')

-- Add to list non-nil item (string or table)
local add_item =
  function(List, Item)
    if not is_nil(Item) then
      add_to_list(List, Item)
    end
  end

local parse_root =
  function(Input, Syntax)
    -- Syntels shortcuts:
    local group_open_char = Syntax.ListOpening
    local group_close_char = Syntax.ListClosing
    local quote_open_char = Syntax.QuoteOpening
    local quote_close_char = Syntax.QuoteClosing
    local space_char = Syntax.Delimiters.Space
    local newline_char = Syntax.Delimiters.Newline

    local parse
    parse =
      function()
        local Result = { }
        local term = nil
        local in_quotes = false

        while true do
          local char, is_ok = Input:Read(1)

          if not is_ok then break end

          local action = 'add_char'

          if not in_quotes then
            if ((char == space_char) or (char == newline_char)) then
              action = 'end_term'
            elseif (char == group_open_char) then
              action = 'start_group'
            elseif (char == group_close_char) then
              action = 'end_group'
            elseif (char == quote_open_char) then
              action = 'start_quote'
            end
          elseif in_quotes then
            if (char == quote_close_char) then
              action = 'end_quote'
            end
          end

          if (action == 'add_char') then
            term = term or ''
            term = term .. char
          elseif (action == 'end_term') then
            add_item(Result, term)
            term = nil
          elseif (action == 'start_quote') then
            term = term or ''
            in_quotes = true
          elseif (action == 'end_quote') then
            in_quotes = false
          elseif (action == 'start_group') then
            add_item(Result, term)
            term = nil
            add_item(Result, parse())
          elseif (action == 'end_group') then
            add_item(Result, term)

            return Result
          end
        end

        add_item(Result, term)

        return Result
      end

    return parse()
  end

-- Export:
return parse_root

--[[
  2024 # # # #
  2026-05-23
]]
