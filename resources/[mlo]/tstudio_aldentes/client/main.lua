Locale = Locales[Config.Locale] or Locales["en"]

function table.sortKeys(tbl)
  local sortedTable = {}

  local keys = {}
  for key in pairs(tbl) do
      table.insert(keys, key)
  end
  table.sort(keys, function(a, b) return a > b end)

  for _, key in ipairs(keys) do
      sortedTable[key] = tbl[key]
  end

  return sortedTable
end

CreateThread(function ()
  for _, elevator in pairs(Config.Elevators) do
    Elevator.new(elevator)
  end
end)