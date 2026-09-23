package.preload['RecodeIs'] =
  function(...)
    require('workshop.base')
    local input_file_name = arg[1]
    local output_file_name = arg[2]
    local InputFile = request('!.concepts.StreamIo.Input.File')
    local OutputFile = request('!.concepts.StreamIo.Output.File')
    local itness_parse = request('!.concepts.codec_itness.parse')
    local itness_compile = request('!.concepts.codec_itness.compile')
    local str_format = string.format
    local ItnessNode
    assert(input_file_name)
    assert(output_file_name)
    print(str_format('Reading data from "%s".', input_file_name))
    do
      InputFile:Open(input_file_name)
      ItnessNode = itness_parse(InputFile)
      InputFile:Close()
    end
    print(str_format('Writing results to "%s".', output_file_name))
    do
      OutputFile:Open(output_file_name)
      itness_compile(ItnessNode, OutputFile)
      OutputFile:Close()
    end
  end
package.preload['workshop.base'] =
  function(...)
    local str_match = string.match
    local str_find = string.find
    local str_sub = string.sub
    local tbl_pack = table.pack
    local tbl_unpack = table.unpack
    local require = require
    local empty = ''
    local stack_init
    local stack_get
    local stack_add
    local stack_remove
    do
      local Names
      local depth
      stack_init =
        function()
          Names = {}
          depth = 1
        end
      stack_get =
        function()
          return Names[depth]
        end
      stack_add =
        function(prefix, name)
          depth = depth + 1
          Names[depth] = { prefix = prefix, name = name }
        end
      stack_remove =
        function()
          depth = depth - 1
        end
    end
    local get_caller_prefix =
      function()
        local NameRec = stack_get()
        if not NameRec then
          return empty
        end
        return NameRec.prefix
      end
    local get_caller_name =
      function()
        local NameRec = stack_get()
        if not NameRec then
          return empty
        end
        return NameRec.prefix .. NameRec.name
      end
    local split_name
    do
      local prefix_name_capture = '^(.+%.)([^%.]+)$'
      split_name =
        function(qualified_name)
          local prefix, name =
            str_match(qualified_name, prefix_name_capture)
          if not prefix then
            prefix = empty
            if str_find(qualified_name, '%.') then
              name = empty
            else
              name = qualified_name
            end
          end
          return prefix, name
        end
    end
    local apply_rel_prefix
    do
      local uplevel_capture = '(.+%.)[^%.]-%.$'
      apply_rel_prefix =
        function(base_prefix, rel_prefix)
          while (str_sub(rel_prefix, 1, 2) == '^.') do
            if (base_prefix == empty) then
              error("Link is outside of caller's prefix.")
            end
            base_prefix =
              str_match(base_prefix, uplevel_capture) or empty
            rel_prefix = str_sub(rel_prefix, 3)
          end
          return base_prefix .. rel_prefix
        end
    end
    local set_base_prefix
    local get_base_prefix
    do
      local base_prefix
      set_base_prefix =
        function(arg_base_prefix)
          base_prefix = arg_base_prefix
        end
      get_base_prefix =
        function()
          return base_prefix
        end
    end
    local get_require_name =
      function(qualified_name)
        local caller_prefix
        local is_absolute_name = (str_sub(qualified_name, 1, 2) == '!.')
        if is_absolute_name then
          qualified_name = str_sub(qualified_name, 3)
          caller_prefix = get_base_prefix()
        else
          caller_prefix = get_caller_prefix()
        end
        local prefix, name = split_name(qualified_name)
        prefix = apply_rel_prefix(caller_prefix, prefix)
        return prefix .. name
      end
    local init_dependencies
    local get_dependencies
    local add_dependency
    do
      local Dependencies_Map
      init_dependencies =
        function()
          Dependencies_Map = {}
        end
      get_dependencies =
        function()
          return Dependencies_Map
        end
      add_dependency =
        function(src_name, dest_name)
          Dependencies_Map[src_name] = Dependencies_Map[src_name] or {}
          Dependencies_Map[src_name][dest_name] = true
        end
    end
    local request =
      function(qualified_name)
        local require_name = get_require_name(qualified_name)
        local src_name = get_caller_name()
        stack_add(split_name(require_name))
        local dest_name = get_caller_name()
        add_dependency(src_name, dest_name)
        local Results = tbl_pack(require(require_name))
        stack_remove()
        return tbl_unpack(Results)
      end
    do
      if (_G.request == nil) then
        local our_require_name = (...)
        set_base_prefix(split_name(our_require_name))
        init_dependencies()
        _G.request = request
        _G.get_require_name = get_require_name
        _G.get_base_prefix = get_base_prefix
        _G.get_dependencies = get_dependencies
        stack_init()
        stack_add(empty, our_require_name)
        request('!.system.install_is_functions')()
        request('!.system.install_assert_functions')()
        _G.new = request('!.table.new')
        stack_remove()
      end
    end
  end
package.preload['workshop.system.install_is_functions'] =
  function(...)
    local type_is =
      function(type_name)
        return
          function(val)
            return (type(val) == type_name)
          end
      end
    local number_is
    do
      local math_type = math.type
      number_is =
        function(type_name)
          return
            function(val)
              if not is_number(val) then
                return false
              end
              return (math_type(val) == type_name)
            end
        end
    end
    local TypeNames = request('!.concepts.lua.TypeNames')
    local NumberTypeNames = request('!.concepts.lua.NumberTypeNames')
    return
      function()
        for _, type_name in ipairs(TypeNames) do
          _G['is_' .. type_name] = type_is(type_name)
        end
        for _, number_type_name in ipairs(NumberTypeNames) do
          _G['is_' .. number_type_name] = number_is(number_type_name)
        end
      end
  end
package.preload['workshop.system.install_assert_functions'] =
  function(...)
    local spawn_assert_func
    do
      local str_format = string.format
      spawn_assert_func =
        function(type_name)
          local checker = _G['is_' .. type_name]
          assert(checker)
          return
            function(val)
              if not checker(val) then
                local err_msg =
                  str_format('assert_%s(%s)', type_name, tostring(val))
                error(err_msg)
              end
            end
        end
    end
    local TypeNames = request('!.concepts.lua.TypeNames')
    local NumberTypeNames = request('!.concepts.lua.NumberTypeNames')
    local install_assert_funcs =
      function()
        for _, type_name in ipairs(TypeNames) do
          _G['assert_' .. type_name] = spawn_assert_func(type_name)
        end
        for _, number_type_name in ipairs(NumberTypeNames) do
          _G['assert_' .. number_type_name] =
            spawn_assert_func(number_type_name)
        end
      end
    return install_assert_funcs
  end
package.preload['workshop.lua.regexp.magic_chars'] =
  function(...)
    return '^$()[]%.?*+-'
  end
package.preload['workshop.lua.regexp.magic_char_pattern'] =
  function(...)
    local magic_chars = request('magic_chars')
    local magic_char_patttern =
      '[' .. magic_chars:gsub('.', '%%%0') .. ']'
    return magic_char_patttern
  end
package.preload['workshop.lua.regexp.quote'] =
  function(...)
    local magic_char_pattern = request('magic_char_pattern')
    return
      function(s)
        return s:gsub(magic_char_pattern, '%%%0')
      end
  end
package.preload['workshop.number.is_natural'] =
  function(...)
    return
      function(Number)
        assert_number(Number)
        if not is_integer(Number) then
          return false
        end
        if (Number <= 0) then
          return false
        end
        return true
      end
  end
package.preload['workshop.table.clone'] =
  function(...)
    return
      function(Node)
        local clone
        do
          local Cloned = {}
          clone =
            function(Node)
              if (type(Node) ~= 'table') then
                return Node
              end
              if Cloned[Node] then
                return Cloned[Node]
              end
              local Result = {}
              Cloned[Node] = Result
              for key, value in pairs(Node) do
                Result[clone(key)] = clone(value)
              end
              setmetatable(Result, getmetatable(Node))
              return Result
            end
        end
        return clone(Node)
      end
  end
package.preload['workshop.table.new'] =
  function(...)
    local clone = request('clone')
    local patch = request('patch')
    return
      function(Base, Overrides)
        assert_table(Base)
        local Result = clone(Base)
        if is_table(Overrides) then
          patch(Result, Overrides)
        end
        return Result
      end
  end
package.preload['workshop.table.patch'] =
  function(...)
    local Rules = { { has_a = true, has_b = true, action = 'replace' } }
    local apply_table = request('apply_table')
    return
      function(Result, Additions)
        apply_table(Result, Additions, Rules)
      end
  end
package.preload['workshop.table.map_values'] =
  function(...)
    return
      function(List)
        assert_table(List)
        local Result = {}
        for _, value in pairs(List) do
          Result[value] = true
        end
        return Result
      end
  end
package.preload['workshop.table.create_instance'] =
  function(...)
    local clone = request('clone')
    local attach_methods = request('attach_methods')
    return
      function(Data, Methods)
        assert_table(Data)
        assert_table(Methods)
        local Result
        Result = clone(Data)
        attach_methods(Result, Methods)
        return Result
      end
  end
package.preload['workshop.table.get_values'] =
  function(...)
    local add_to_list = request('!.concepts.list.add_item')
    return
      function(List)
        assert_table(List)
        local Values = {}
        for _, value in pairs(List) do
          add_to_list(Values, value)
        end
        return Values
      end
  end
package.preload['workshop.table.apply_table'] =
  function(...)
    local keep_str = 'keep'
    local replace_str = 'replace'
    local remove_str = 'remove'
    local get_action =
      function(has_a, has_b, Rules)
        for _, Rule in ipairs(Rules) do
          if (Rule.has_a == has_a) and (Rule.has_b == has_b) then
            return Rule.action
          end
        end
        return keep_str
      end
    local apply_table
    apply_table =
      function(A, B, Rules)
        local Keys = {}
        do
          for a_key in pairs(A) do
            Keys[a_key] = true
          end
          for b_key in pairs(B) do
            Keys[b_key] = true
          end
        end
        for key in pairs(Keys) do
          local a_key = A[key]
          local b_key = B[key]
          if is_table(a_key) and is_table(b_key) then
            apply_table(a_key, b_key, Rules)
          else
            local has_a = not is_nil(a_key)
            local has_b = not is_nil(b_key)
            local action = get_action(has_a, has_b, Rules)
            if (action == keep_str) then
              ;
            elseif (action == replace_str) then
              A[key] = B[key]
            elseif (action == remove_str) then
              A[key] = nil
            end
          end
        end
      end
    local check_rule =
      function(Rule)
        local has_a = is_boolean(Rule.has_a)
        local has_b = is_boolean(Rule.has_b)
        local action = Rule.action
        local is_known_action =
          (action == keep_str) or
          (action == replace_str) or
          (action == remove_str)
        return has_a and has_b and is_known_action
      end
    return
      function(A, B, Rules)
        assert_table(A)
        assert_table(B)
        assert_table(Rules)
        assert(A ~= B)
        for index, Rule in ipairs(Rules) do
          if not check_rule(Rule) then
            error('Unsupported rule.')
          end
        end
        apply_table(A, B, Rules)
      end
  end
package.preload['workshop.table.attach_methods'] =
  function(...)
    return
      function(Object, Methods)
        assert_table(Object)
        assert_table(Methods)
        local Metatable =
          {
            __index = Methods,
            __newindex =
              function()
                error('Table is locked for additions/removals.')
              end,
          }
        setmetatable(Object, Metatable)
      end
  end
package.preload['workshop.file_system.file.open'] =
  function(...)
    local normalize_name = request('!.concepts.path_name.normalize')
    local default_mode = 'rb'
    local io_open = io.open
    return
      function(pathname, mode)
        assert_string(pathname)
        assert(is_nil(mode) or is_string(mode))
        pathname = normalize_name(pathname)
        mode = mode or default_mode
        local file, err_msg = io.open(pathname, mode)
        if not file then
          error(err_msg, 2)
        end
        return file
      end
  end
package.preload['workshop.file_system.file.open_for_writing'] =
  function(...)
    local open_file = request('open')
    return
      function(pathname)
        return open_file(pathname, 'w+b')
      end
  end
package.preload['workshop.file_system.file.close'] =
  function(...)
    local io_type = io.type
    return
      function(File)
        local file_type = io_type(File)
        if not is_string(file_type) then
          return
        end
        if (file_type == 'closed file') then
          return
        end
        File:close()
      end
  end
package.preload['workshop.file_system.file.open_for_reading'] =
  function(...)
    local open_file = request('open')
    return
      function(pathname)
        return open_file(pathname, 'rb')
      end
  end
package.preload['workshop.string.ends_with'] =
  function(...)
    local str_sub = string.sub
    return
      function(base_str, postfix_str)
        return (str_sub(base_str, -#postfix_str, -1) == postfix_str)
      end
  end
package.preload['workshop.string.split'] =
  function(...)
    local ends_with = request('!.string.ends_with')
    local quote_regexp = request('!.lua.regexp.quote')
    local str_find = string.find
    local add_to_list = request('!.concepts.list.add_item')
    return
      function(str, delimiter)
        assert_string(str)
        assert_string(delimiter)
        if (delimiter == '') then
          return { str }
        end
        if not ends_with(str, delimiter) then
          str = str .. delimiter
        end
        local Result = {}
        local item_capture = '(.-)' .. quote_regexp(delimiter) .. '()'
        local start_pos
        local end_pos
        local item_str
        start_pos = 1
        while true do
          start_pos, end_pos, item_str =
            str_find(str, item_capture, start_pos)
          if not start_pos then
            break
          end
          add_to_list(Result, item_str)
          start_pos = end_pos + 1
        end
        return Result
      end
  end
package.preload['workshop.concepts.Indent'] =
  function(...)
    local create_instance = request('!.table.create_instance')
    local RangePoint = request('!.concepts.RangePoint')
    local str_rep = string.rep
    local RangePoint = RangePoint.create()
    RangePoint:SetMinValue(0)
    RangePoint:SetMaxValue(60)
    RangePoint:SetValue(RangePoint:GetMinValue())
    local Core = { '  ', RangePoint }
    local Interface
    Interface =
      {
        GetIndentChunk =
          function(Me)
            return Me[1]
          end,
        SetIndentChunk =
          function(Me, str)
            assert_string(str)
            Me[1] = str
          end,
        GetRangePoint =
          function(Me)
            return Me[2]
          end,
        ToString =
          function(Me)
            local indent_level = Me:GetRangePoint():GetValue()
            if (indent_level == 0) then
              return ''
            end
            local indent_chunk = Me:GetIndentChunk()
            return str_rep(indent_chunk, indent_level)
          end,
        Inc =
          function(Me)
            Me:GetRangePoint():Inc()
          end,
        Dec =
          function(Me)
            Me:GetRangePoint():Dec()
          end,
        create =
          function(OptCore)
            return create_instance(OptCore or Core, Interface)
          end,
      }
    return Interface
  end
package.preload['workshop.concepts.RangePoint'] =
  function(...)
    local Interface
    local create
    do
      local DefaultCore = { 0, 0, 5 }
      local create_instance = request('!.table.create_instance')
      create =
        function(OptCore)
          return create_instance(OptCore or DefaultCore, Interface)
        end
    end
    local min = math.min
    local max = math.max
    Interface =
      {
        create = create,
        GetMinValue =
          function(Me)
            return Me[2]
          end,
        SetMinValue =
          function(Me, val)
            Me[2] = val
          end,
        GetMaxValue =
          function(Me)
            return Me[3]
          end,
        SetMaxValue =
          function(Me, val)
            Me[3] = val
          end,
        GetValue =
          function(Me)
            local min_value = Me:GetMinValue()
            local max_value = Me:GetMaxValue()
            return min(max(Me[1], min_value), max_value)
          end,
        SetValue =
          function(Me, arg_value)
            local min_value = Me:GetMinValue()
            local max_value = Me:GetMaxValue()
            Me[1] = min(max(arg_value, min_value), max_value)
          end,
        IncBy =
          function(Me, value)
            Me[1] = Me[1] + value
          end,
        DecBy =
          function(Me, value)
            Me[1] = Me[1] - value
          end,
        Inc =
          function(Me)
            Me:IncBy(1)
          end,
        Dec =
          function(Me)
            Me:DecBy(1)
          end,
      }
    return Interface
  end
package.preload['workshop.concepts.lua.NumberTypeNames'] =
  function(...)
    return { 'integer', 'float' }
  end
package.preload['workshop.concepts.lua.TypeNames'] =
  function(...)
    return
      {
        'nil',
        'boolean',
        'number',
        'string',
        'function',
        'thread',
        'userdata',
        'table',
      }
  end
package.preload['workshop.concepts.list.to_string'] =
  function(...)
    local tbl_concat = table.concat
    return
      function(List, separator_str)
        assert_table(List)
        separator_str = separator_str or ''
        assert_string(separator_str)
        return tbl_concat(List, separator_str)
      end
  end
package.preload['workshop.concepts.list.add_item'] =
  function(...)
    local tbl_insert = table.insert
    return
      function(OurList, item)
        tbl_insert(OurList, item)
      end
  end
package.preload['workshop.concepts.list.add_list'] =
  function(...)
    local tbl_move = table.move
    return
      function(OurList, AnotherList)
        assert(OurList ~= AnotherList)
        tbl_move(AnotherList, 1, #AnotherList, #OurList + 1, OurList)
      end
  end
package.preload['workshop.concepts.codec_itness.parse'] =
  function(...)
    local Syntax = request('common.Syntax')
    local read_token
    do
      local quote_open_char = Syntax.quote_open_char
      local quote_close_char = Syntax.quote_close_char
      local space_char = Syntax.delimiters_space_char
      local newline_char = Syntax.delimiters_newline_char
      read_token =
        function(Input)
          local token = ''
          local in_quotes = false
          while true do
            local char = Input:Read(1)
            if (char == '') then
              return token
            end
            if in_quotes then
              if (char == quote_close_char) then
                in_quotes = false
              else
                token = token .. char
              end
            else
              if (char == space_char) or (char == newline_char) then
                return token
              end
              if (char == quote_open_char) then
                in_quotes = true
              else
                token = token .. char
              end
            end
          end
        end
    end
    local parse
    do
      local group_open_char = Syntax.group_open_char
      local group_close_char = Syntax.group_close_char
      local add_to_list = request('!.concepts.list.add_item')
      parse =
        function(Input)
          while true do
            local token = read_token(Input)
            if (token == '') then
              return
            end
            if (token == group_open_char) then
              local Result = {}
              while true do
                local Node = parse(Input)
                if not Node then
                  break
                end
                add_to_list(Result, Node)
              end
              return Result
            elseif (token == group_close_char) then
              return
            else
              return token
            end
          end
        end
    end
    return parse
  end
package.preload['workshop.concepts.codec_itness.compile'] =
  function(...)
    local DataWriter = request('compile.DataWriter.Interface')
    local DelimitersWriter =
      request('compile.DelimitersWriter.Interface')
    local Syntax = request('common.Syntax')
    return
      function(Node, Output)
        local DataWriter = new(DataWriter)
        local DelimitersWriter = new(DelimitersWriter)
        local compile
        compile =
          function(Node)
            if is_string(Node) then
              DelimitersWriter:HandleEvent('write_string')
              DataWriter:WriteLeaf(Node)
            elseif is_table(Node) then
              DelimitersWriter:HandleEvent('start_list')
              DataWriter:StartList()
              for _, Node in ipairs(Node) do
                compile(Node)
              end
              DelimitersWriter:HandleEvent('end_list')
              DataWriter:EndList()
            end
          end
        DataWriter.Output = Output
        DataWriter.Syntax = Syntax
        DataWriter:Init()
        DelimitersWriter.Output = Output
        DelimitersWriter.space_char = Syntax.delimiters_space_char
        DelimitersWriter.newline_char = Syntax.delimiters_newline_char
        DelimitersWriter:Init()
        compile(Node)
        DelimitersWriter:HandleEvent('nothing')
      end
  end
package.preload['workshop.concepts.codec_itness.common.Syntax'] =
  function(...)
    local Syntax =
      {
        delimiters_space_char = ' ',
        delimiters_newline_char = '\n',
        quote_open_char = '[',
        quote_close_char = ']',
        group_open_char = '(',
        group_close_char = ')',
      }
    return Syntax
  end
package.preload[
  'workshop.concepts.codec_itness.compile.DataWriter.WriteLeaf'
] =
  function(...)
    local WriteLeaf =
      function(Me, str)
        local quote_open_char = Me.Syntax.quote_open_char
        local quote_close_char = Me.Syntax.quote_close_char
        local IsSyntaxChar_Map = Me.IsSyntaxChar_Map
        local syntax_chars_regexp = Me.syntax_chars_regexp
        local in_quotes = false
        local encode_char =
          function(char)
            local Result = char
            if
              not in_quotes and
              (IsSyntaxChar_Map[char] and (char ~= quote_close_char))
            then
              Result = quote_open_char .. char
              in_quotes = true
            end
            if in_quotes and (char == quote_close_char) then
              Result = quote_close_char .. char
              in_quotes = false
            end
            return Result
          end
        local encoded_str =
          string.gsub(str, syntax_chars_regexp, encode_char)
        if in_quotes then
          encoded_str = encoded_str .. quote_close_char
          in_quotes = false
        end
        if (str == '') then
          encoded_str = quote_open_char .. quote_close_char
        end
        Me.Output:Write(encoded_str)
      end
    return WriteLeaf
  end
package.preload[
  'workshop.concepts.codec_itness.compile.DataWriter.Interface'
] =
  function(...)
    local get_values = request('!.table.get_values')
    local map_values = request('!.table.map_values')
    local list_to_string = request('!.concepts.list.to_string')
    local lua_regexp_quote = request('!.lua.regexp.quote')
    local Interface =
      {
        Output = {},
        Syntax = {},
        Init =
          function(Me)
            local SyntaxList = get_values(Me.Syntax)
            Me.IsSyntaxChar_Map = map_values(SyntaxList)
            Me.syntax_chars_regexp =
              '[' .. lua_regexp_quote(list_to_string(SyntaxList)) .. ']'
          end,
        StartList =
          function(Me)
            Me.Output:Write(Me.Syntax.group_open_char)
          end,
        EndList =
          function(Me)
            Me.Output:Write(Me.Syntax.group_close_char)
          end,
        WriteLeaf = request('WriteLeaf'),
        IsSyntaxChar_Map = {},
        syntax_chars_regexp = '',
      }
    return Interface
  end
package.preload[
  'workshop.concepts.codec_itness.compile.DelimitersWriter.Interface'
] =
  function(...)
    local IndentClass = request('!.concepts.Indent')
    local Interface =
      {
        Output = {},
        space_char = '',
        newline_char = '',
        Init =
          function(Me)
            Me.Indent = IndentClass.create()
            local space_char = Me.space_char
            local spaces_per_indent = 2
            local indent_chunk =
              string.rep(space_char, spaces_per_indent)
            Me.Indent:SetIndentChunk(indent_chunk)
            Me.prev_event = 'nothing'
            Me.is_on_empty_line = true
          end,
        HandleEvent = request('HandleEvent'),
        Indent = Indent,
        prev_event = '',
        is_on_empty_line = false,
      }
    return Interface
  end
package.preload[
  'workshop.concepts.codec_itness.compile.DelimitersWriter.HandleEvent'
] =
  function(...)
    local Emit =
      function(Me, str)
        if (str == '') then
          return
        end
        Me.Output:Write(str)
        Me.is_on_empty_line = false
      end
    local EmitNewline =
      function(Me)
        if Me.is_on_empty_line then
          return
        end
        Emit(Me, Me.newline_char)
        Me.is_on_empty_line = true
      end
    local EmitIndent =
      function(Me)
        EmitNewline(Me)
        Emit(Me, Me.Indent:ToString())
      end
    local F_Empty =
      function(Me)
      end
    local F_Indent =
      function(Me)
        EmitIndent(Me)
      end
    local F_Space =
      function(Me)
        Emit(Me, Me.space_char)
      end
    local EventsToFunc =
      {
        ['nothing'] =
          {
            ['nothing'] = F_Empty,
            ['write_string'] = F_Empty,
            ['start_list'] = F_Empty,
            ['end_list'] = F_Empty,
          },
        ['write_string'] =
          {
            ['nothing'] = F_Empty,
            ['write_string'] = F_Space,
            ['start_list'] = F_Indent,
            ['end_list'] = F_Space,
          },
        ['start_list'] =
          {
            ['nothing'] = F_Empty,
            ['write_string'] = F_Space,
            ['start_list'] = F_Indent,
            ['end_list'] = F_Empty,
          },
        ['end_list'] =
          {
            ['nothing'] = F_Indent,
            ['write_string'] = F_Indent,
            ['start_list'] = F_Indent,
            ['end_list'] = F_Indent,
          },
      }
    local OnEvent =
      function(Me, cur_event)
        if (Me.prev_event ~= 'nothing') then
          Me.is_on_empty_line = false
        end
        if (cur_event == 'end_list') then
          Me.Indent:Dec()
        end
        local PaddingFunc = EventsToFunc[Me.prev_event][cur_event]
        PaddingFunc(Me)
        if (cur_event == 'start_list') then
          Me.Indent:Inc()
        end
        Me.prev_event = cur_event
      end
    return OnEvent
  end
package.preload['workshop.concepts.StreamIo.Input.File'] =
  function(...)
    local open_file_for_reading =
      request('!.file_system.file.open_for_reading')
    local close_file = request('!.file_system.file.close')
    local is_natural = request('!.number.is_natural')
    local Interface =
      {
        Open =
          function(Me, pathname)
            Me.File = open_file_for_reading(pathname)
          end,
        Close =
          function(Me)
            close_file(Me.File)
          end,
        Read =
          function(Me, num_bytes)
            assert(is_natural(num_bytes))
            local data_str = Me.File:read(num_bytes)
            if is_nil(data_str) then
              data_str = ''
            end
            return data_str
          end,
        File = nil,
      }
    setmetatable(
      Interface,
      {
        __gc =
          function(Me)
            Me:Close()
          end,
      }
    )
    return Interface
  end
package.preload['workshop.concepts.StreamIo.Output.File'] =
  function(...)
    local open_file_for_writing =
      request('!.file_system.file.open_for_writing')
    local close_file = request('!.file_system.file.close')
    local Interface =
      {
        Open =
          function(Me, pathname)
            Me.File = open_file_for_writing(pathname)
          end,
        Close =
          function(Me)
            close_file(Me.File)
          end,
        Write =
          function(Me, data_str)
            assert_string(data_str)
            Me.File:write(data_str)
          end,
        File = 0,
      }
    setmetatable(
      Interface,
      {
        __gc =
          function(Me)
            Me:Close()
          end,
      }
    )
    return Interface
  end
package.preload['workshop.concepts.path_name.pathname_to_str'] =
  function(...)
    local sep = request('Syntels').separator
    local clean_pathname
    do
      local clean_name
      do
        local ends_with = request('!.string.ends_with')
        local str_sub = string.sub
        clean_name =
          function(name)
            local sep_len = #sep
            while ends_with(name, sep) do
              name = str_sub(name, 1, -(sep_len + 1))
            end
            return name
          end
      end
      local add_to_list = request('!.concepts.list.add_item')
      clean_pathname =
        function(Pathname)
          local Result = {}
          for _, name in ipairs(Pathname) do
            add_to_list(Result, clean_name(name))
          end
          return Result
        end
    end
    local list_to_str = request('!.concepts.list.to_string')
    return
      function(Pathname)
        return list_to_str(clean_pathname(Pathname), sep)
      end
  end
package.preload['workshop.concepts.path_name.pathname_from_str'] =
  function(...)
    local split_string = request('!.string.split')
    local check_is_absolute = request('is_absolute')
    local check_is_directory = request('is_directory')
    local add_to_list = request('!.concepts.list.add_item')
    local add_list = request('!.concepts.list.add_list')
    local empty = ''
    local self_dir
    local sep
    do
      local Syntels = request('Syntels')
      self_dir = Syntels.self_dir
      sep = Syntels.separator
    end
    return
      function(path_name)
        assert_string(path_name)
        if (path_name == empty) then
          error('Empty pathname.')
        end
        local is_absolute
        local is_directory
        local Names = {}
        do
          local Segments = split_string(path_name .. sep, sep)
          is_absolute = check_is_absolute(Segments)
          is_directory = check_is_directory(Segments)
          for _, segment in ipairs(Segments) do
            if (segment ~= empty) and (segment ~= self_dir) then
              add_to_list(Names, segment)
            end
          end
        end
        if (#Names == 0) and not is_absolute then
          add_to_list(Names, self_dir)
        end
        do
          local Result = {}
          if is_absolute then
            add_to_list(Result, empty)
          end
          add_list(Result, Names)
          if is_directory then
            add_to_list(Result, empty)
          end
          return Result
        end
      end
  end
package.preload['workshop.concepts.path_name.normalize'] =
  function(...)
    local pathname_from_str = request('pathname_from_str')
    local pathname_to_str = request('pathname_to_str')
    return
      function(path_name)
        return pathname_to_str(pathname_from_str(path_name))
      end
  end
package.preload['workshop.concepts.path_name.is_absolute'] =
  function(...)
    return
      function(Pathname)
        return (Pathname[1] == '')
      end
  end
package.preload['workshop.concepts.path_name.is_directory'] =
  function(...)
    local self_dir
    local upper_dir
    do
      local Syntels = request('Syntels')
      self_dir = Syntels.self_dir
      upper_dir = Syntels.upper_dir
    end
    return
      function(Pathname)
        local last_node = Pathname[#Pathname]
        return
          (last_node == '') or
          (last_node == self_dir) or
          (last_node == upper_dir)
      end
  end
package.preload['workshop.concepts.path_name.Syntels'] =
  function(...)
    return { separator = '/', self_dir = '.', upper_dir = '..' }
  end
return require('RecodeIs')