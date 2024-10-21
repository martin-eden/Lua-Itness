-- Serialization event handler

-- Last mod.: 2024-10-21

--[[
  Adds delimiters for separation and indentation
  between items. Called before and after writing
  non-delimiting element.

  Input

    self
    When: str (= Before, After)
    EventName: str (= StartList, EndList, Write),
    NodeType: str (= String, Container),
    NodeRole: str (= Object, Key, Value)

  Output

    Emits strings to <self.Output>
]]

local EventHandler =
  function(
    self,
    When,
    EventName,
    NodeType,
    NodeRole
  )
    -- Delimiters shortcuts
    local Space = self.Syntax.Delimiters.Space
    local Newline = self.Syntax.Delimiters.Newline

    --( List contents have additional indent
    if
      (When == 'After') and
      (EventName == 'StartList')
    then
      self.Indent:Increase()
    end

    if
      (When == 'Before') and
      (EventName == 'EndList')
    then
      self.Indent:Decrease()
    end
    --)

    --( Key is on indented newline
    if
      (When == 'Before') and
      (
        (EventName == 'StartList') or
        (EventName == 'Write')
      ) and
      (NodeRole == 'Key')
    then
      self:EmitNewlineIndent()
    end
    --)

    -- Space between key and value
    if
      (When == 'After') and
      (
        (EventName == 'EndList') or
        (EventName == 'Write')
      ) and
      (NodeRole == 'Key')
    then
      self:Emit(Space)
    end

    -- Container objects are multilined
    if
      (When == 'Before') and
      (
        (EventName == 'StartList') or
        (EventName == 'EndList')
      ) and
      (NodeType == 'Container') and
      (NodeRole == 'Object')
    then
      self:EmitNewlineIndent()
    end

    -- List key closing parenthesis on newline
    if
      (When == 'Before') and
      (EventName == 'EndList') and
      (NodeType == 'Container') and
      (NodeRole == 'Key')
    then
      self:EmitNewlineIndent()
    end

    --[[
      Value's closing parenthesis is on indented newline
      when value is serialized in several lines.

      I can not track exactly this condition but if previous
      node role was "object" and now it is "value" it means
      we are writing next ")" in wrapped list.
    ]]
    if
      (When == 'Before') and
      (EventName == 'EndList') and
      (NodeType == 'Container') and
      (NodeRole == 'Value') and
      (
        (self.PrevState.EventName == 'EndList') and
        (self.PrevState.NodeRole == 'Object')
      )
    then
      self:EmitNewlineIndent()
    end

    -- Maintenance: we are not on newline at "after" event
    if (When == 'After') then
      self.IsOnEmptyLine = false
    end

    -- Maintenance: store current arguments for the next call
    do
      -- No table constructor syntax as we don't want new table alloc.
      self.PrevState.When = When
      self.PrevState.EventName = EventName
      self.PrevState.NodeType = NodeType
      self.PrevState.NodeRole = NodeRole
    end
  end

-- Exports:
return EventHandler

--[[
  2024-09 4
  2024-10-21
]]
