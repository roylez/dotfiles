return {
  s(
    { trig="tomorrow", name="Tomorrow", desc="Tomorrow" },
    {
      f(function(_, _) return os.date("## %Y.%m.%d - Week %U - %A", os.time() + 24*60*60) end, {}),
      t({"", "", ""})
    }
  ),

  s(
    { trig="yesterday", name="Yesterday", desc="Yesterday" },
    {
      f(function(_, _) return os.date("## %Y.%m.%d - Week %U - %A", os.time() - 24*60*60) end, {}),
      t({"", "", ""})
    }
  ),
}
