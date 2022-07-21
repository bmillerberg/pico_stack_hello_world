ruleset edu.byu.bmillerb.helloworld {
  meta {
    name "hellos"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares hello
  }
  global {
    event_domain = "edu_byu_bmillerb_helloworld"
    hello = function(_headers){
      url = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}/name_given>>
      html:header("manage hellos","",null,null,_headers)
      + <<
<h1>Manage hellos</h1>
<p>
Hello, #{ent:name.defaultsTo("world")}!
</p>
<h2>Technical details</h2>
<pre>#{url}</pre>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["hellos"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise edu_byu_bmillerb_helloworld event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when edu_byu_bmillerb_helloworld factory_reset
    foreach wrangler:channels(["hellos"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}
