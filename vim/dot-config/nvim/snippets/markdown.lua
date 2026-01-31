return {
  s(
    { trig="tomorrow", name="Tomorrow", desc="Tomorrow" },
    {
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 24*60*60) end, {}), t({"", "", ""})
    }
  ),

  s(
    { trig="yesterday", name="Yesterday", desc="Yesterday" },
    {
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() - 24*60*60) end, {}), t({"", "", ""})
    }
  ),

  s(
    { trig="next-week", name="Next Week", desc="Next Week" },
    {
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 7*24*60*60) end, {}), t({"", "", ""}),
      t({"- [ ] planning", "", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 6*24*60*60) end, {}), t({"", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 5*24*60*60) end, {}), t({"", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 4*24*60*60) end, {}), t({"", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 3*24*60*60) end, {}), t({"", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 2*24*60*60) end, {}), t({"", "", ""}),
      f(function(_, _) return os.date("## %Y-%m-%d - Week %U - %A", os.time() + 24*60*60) end, {}), t({"", "", ""}),
    }
  )

}
