
# #####################################################################
# Setup and constants.

WebSocket = require "ws"
conf      = require "optimist" 
conf      = conf.usage "Usage: $0 [--port=PORT] [--server=SERVER]" 
conf      = conf.default "port", 7441 
conf      = conf.default "server", "localhost" 
conf      = conf.default "timeout", "500" 
conf      = conf.argv

chromi    = "chromi"
chromiCap = "Chromi"

# #####################################################################
# Utilities.

json = (x) -> JSON.stringify x

echo = (msg, where = process.stdout) ->
  switch typeof msg
    when "string"
      # Do nothing.
      true
    when "list"
      msg = msg.join " "
    when "object"
      msg = json msg
    else
      msg = json msg
  where.write "#{msg}\n"

echoErr = (msg, die = false) ->
  echo msg, process.stderr
  process.exit 1 if die

# #####################################################################
# Tab selectors.

class Selector
  selector: {}

  fetch: (pattern) ->
    return @selector[pattern] if @selector[pattern]
    regexp = new RegExp pattern
    @selector[pattern] =
      (win,tab) ->
        win.type == "normal" and regexp.test tab.url

  constructor: ->
    @selector.all      = (win,tab) -> win.type == "normal" and true
    @selector.active   = (win,tab) -> win.type == "normal" and tab.active
    @selector.current  = (win,tab) -> win.type == "normal" and tab.active
    @selector.other    = (win,tab) -> win.type == "normal" and not tab.active
    @selector.inactive = (win,tab) -> win.type == "normal" and not tab.active
    @selector.normal   = @fetch "https?://"
    @selector.http     = @fetch "https?://"
    @selector.file     = @fetch "file://"

selector = new Selector()

# #####################################################################
# Web socket utilities.

# TODO: Use IP address/port for ID?
createId = -> Math.floor Math.random() * 2000000000

# TODO: Move web socket outside of `wsDo` so that it can be reused.
#
wsDo = (func, args, callback) ->
  id = createId()
  ws = new WebSocket("ws://#{conf.server}:#{conf.port}/")
  setTimeout ( -> process.exit 1 ), conf.timeout
  msg = [ func, JSON.stringify args ].map(encodeURIComponent).join " "
  ws.on "open", -> ws.send "#{chromi} #{id} #{msg}"
  ws.on "error", (error) -> echoErr JSON.stringify(error), true
  ws.on "message",
    (msg) ->
      msg = msg.split(/\s+/).map(decodeURIComponent)
      [ signal, msgId, type, response ] = msg
      return unless signal == chromiCap and msgId == id.toString()
      switch type
        when "info"
          # echoErr msg
          true
        when "done"
          callback.apply null, JSON.parse response if callback
        when "error"
          echoErr msg, true
          process.exit 1
        else
          echoErr msg

tabDo = (predicate, process, done=null) ->
  wsDo "chrome.windows.getAll", [{ populate:true }],
    (wins) ->
      count = 0
      transit = 0
      for win in wins
        for tab in ( win.tabs.filter (t) -> predicate win, t )
          count += 1
          transit += 1
          process tab, ->
            transit -= 1
            done count if transit == 0
      done count if done and count == 0

# #####################################################################
# Operations:
#   - `support` operations are not available directly.
#   - `operations` are.

support =

  # Close tab.
  close:
    ( tab, callback=null) ->
      wsDo "chrome.tabs.remove", [ tab.id ],
        (response) ->
          echo "done remove: #{tab.id} #{tab.url}"
          callback() if callback
        
  # Focus tab.
  focus:
    ( tab, callback=null) ->
      wsDo "chrome.tabs.update", [ tab.id, { selected: true } ],
        (response) ->
          echo "done focus: #{tab.id} #{tab.url}"
          callback() if callback
        
operations =

  # Locate first tab matching `url` and focus it.  If there is no
  # match, then create a new tab and load `url`.
  # When done, call `callback` (if provided).
  load:
    (msg, callback=null) ->
      return echoErr "invalid load: #{msg}" unless msg and msg.length == 1
      url = msg[0]
      tabDo selector.fetch(url),
        (tab, callback) ->
          support.focus tab, callback
        (count) ->
          if count == 0
            wsDo "chrome.tabs.create", [{ url: url }],
              (response) ->
                echo "done create: #{url}"
                callback() if callback
          else
            callback() if callback

# #####################################################################
# Execute command line arguments.

msg = conf._

if msg and msg.length == 0
  # TODO: Ping.
  true

else if msg and msg[0] and operations[msg[0]]
  operations[msg[0]] msg.splice(1), -> process.exit 0

else
  echoErr "invalid command: #{msg}"
  process.exit 1

# #####################################################################
# Test.

# tabDo selector.fetch("all"),
#   (tab) ->
#     echo tab.url
#   (count) ->
#     echo count
#     process.exit 0
