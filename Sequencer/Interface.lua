-- Interface for converting between key-values and sequences

return
  {
    -- Lua table to list tree
    TableToSeq = request('TableToSeq'),
    -- List tree to Lua table
    SeqToTable = request('SeqToTable'),
  }
