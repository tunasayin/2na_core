TwoNa_Functions = {}

TwoNa_Functions.Trim = function(str)
   return (str:gsub("^%s*(.-)%s*$", "%1"))
end