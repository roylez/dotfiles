return {
  s(
    { trig="salary", name="Salary", desc="Salary" },
    {
      f(function(_, _) return os.date("%Y-%m-%d ") end, {}),
      i(1, "Canonical"),
      t({"", "    Assets:CBA"}),
      t({"", "    Income:Salary                 $ -"}), i(2, "0"),
      t({"", "    Liabilities:Reimbursable      $ "}), i(3, "0"),
      t({"", "    Assets:Smile                  $ "}), i(4, "0"),
      t({"", "    Distribution:Kimy             $ "}), f(function(args, _) return tostring(tonumber(args[1][1])/4) end, {4}),
      t({"", "    Distribution:Roy              $ "}), f(function(args, _) return tostring(tonumber(args[1][1])/4) end, {4}),
      t({"", "    Assets:Spend                  $ "}), i(5, "0"),
      t({"", "    Assets:Firefighter            $ "}),
      f(function(args, _)
        return tostring(tonumber(args[1][1])*8.5 - tonumber(args[2][1]))
      end, {4, 5})
    }
  )
}
