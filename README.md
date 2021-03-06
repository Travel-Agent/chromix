# Chromix

Chromix is a command-line and scripting utility for controlling Google chrome.  It can be
used, amongst other things, to create, switch, focus, reload and remove tabs.

Here's a use case.  Say you're editing an
[asciidoc](http://www.methods.co.nz/asciidoc/userguide.html) or a
[markdown](http://daringfireball.net/projects/markdown/) document.  The work
flow is: edit, compile, and reload the chrome tab to see your changes.

Chromix can automate this, particularly the last step.  Change the build step to:
```
markdown somefile.md > somefile.html && chromix load file://$PWD/somefile.html
```
Now, chrome reloads your work every time it changes.  And with suitable key
bindings in your text editor, the build-view process can involve just a couple
of key strokes.

Jump straight to
[here](https://github.com/smblott-github/chromix#chromix-commands) for a list
of available commands.

## Installation

Chromix involves three components:

  - A Chrome extension known as [Chromi](https://github.com/smblott-github/chromi).  
    Chromi is packaged separately.  It is available either at the [Chrome Web
    Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo)
    or from [GitHub](https://github.com/smblott-github/chromi).
  - A server: `chromix-server`.
  - A client: `chromix`.  
    This is Chromix's command-line and scripting utility.

This project provides the Chromix server and client.

To install:

```
sudo npm install -g chromix
```

### Extension Installation

Install [Chromi](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

### Server Installation

The server executable is installed by the NPM module.
The server can be run with an invocation such as:

```
chromix-server
```

The extension broadcasts a heartbeat every five seconds.  If everything is
working correctly, then these heartbeats (and all other messages) appear on the
server's standard output.

By default, the server binds to localhost.  To expose the server to
devices outside of your local machine, set the bind address:

```
node script/server.js --host=0.0.0.0
```

The server might beneficially be run under the control of a supervisor daemon
such as [daemontools](http://cr.yp.to/daemontools.html) or
[supervisord](http://supervisord.org/).

### Client Installation

The client executable is also installed by the NPM module.
A chromix invocation looks something like:

```
chromix CHROMIX-COMMAND [ARGUMENTS...]
```

## Chromix Commands

There are two types of Chromix commands: 
[general commands](https://github.com/smblott-github/chromix#general-commands) and
[tab commands](https://github.com/smblott-github/chromix#tab-commands).  The
latter group operate on tabs.

### General Commands

#### Ping

```
chromix ping
```
This produces no output, but yields an exit code of `0` if Chromix was able to
ping Chromi/Chrome, and non-zero otherwise.  It can be useful in scripts for checking
whether Chromi/Chrome is running.

This is the default command if no arguments are provided to chromix, so the
`ping`, above, can be omitted.

#### Load

```
chromix load https://github.com/
```
This first searches for a tab for which `https://github.com/` is contained in
the tab's URL.  If such a tab is found, it is focussed.  Otherwise, a new tab
is created for the URL.

Additionally, if the URL is of the form 'file://.*', then the tab is
reloaded.

If Chrome is running but has no window, then a new window will be created.
However, if chrome is not running, then Chromix will *not* start it.

#### With

```
chromix with other close
```
This closes all tabs except the currently focused one.

Another example:
```
chromix with chrome close
```
This closes all tabs which *aren't* `http://`, `file://` or `ftp://`.

The first argument to `with` specifies the tabs to which the rest of the command applies.
`other`, above,  means "all non-focused tabs").  The rest of the command must
be a [tab command](https://github.com/smblott-github/chromix#tab-commands).

Tabs can be specified in a number of ways: `all`, `current`,
`other`, `http` (including HTTPS), `file`, `ftp`, `normal` (meaning `http`,
`file` or `ftp`), `pinned`, or `chrome` (meaning not `normal`).

Any other argument to `with` is handled as follows.  If it is an integer
(specifically, if a prefix is parseable with `parseInt`) then it matches the
corresponding tab identifier. Otherwise, it is taken to be a pattern which is
used to match tab URLs.  Patterns may contain JavaScript RegExp operators.

Here are a couple of examples:
```
chromix with "file:///.*/slidy/.*.html" reload
chromix with "file://$HOME" reload
```
The first reloads all tabs containing HTML *files* under directories named
`slidy`.  The second reloads all tabs containing files under the user's home
directory.

#### Without

```
chromix without https://www.facebook.com/ close
```
This closes all windows *except* those within the Facebook domain.

`without` is the same as `with`, except that the test is inverted.  So
`without normal` is the same as `with chrome`, and `without current` is the
same as `with other`.

Here's another example:
```
chromix without "file://$HOME" close
```
This closes all tabs *except* those containing files under the user's home
directory.

And another example:
```
chromix without pinned close
```
This closes all unpinned tabs.

#### Window

```
chromix window
```
This ensures that there is at least one normal Chrome window.  It does not
start Chrome if Chrome is not running.

#### New Tab

```
chromix newTab
```
Create a new, empty tab, creating a new window, if necessary.

#### Raw

```
chromix raw chrome.tabs.update '{"pinned":true}'
```
Pass raw function and arguments to Chrome.

The first argument is the name of a Chrome function.  Subsequent arguments are
JSON encoded arguments to the function. (The outer quotes `'`, here, are just
protecting the JSON from shell expansion.)

#### Bookmarks

```
chromix bookmarks
```
This outputs (to `stdout`) a list of all Chrome bookmarks, one per line.

#### Booky

```
chromix booky
```
This outputs (to `stdout`) a list of (some of) Chrome bookmarks, but in a different format.

### Tab Commands

Tab commands operate on one or more tabs.  They are usually used with `with` or
`without`, above.

#### Focus

```
chromix with http://www.bbc.co.uk/news/ focus
```
Focus the indicated tab.

#### Reload

```
chromix with http://www.bbc.co.uk/news/ reload
```
Reload the indicated tab.

#### Duplicate

```
chromix with current duplicate
```
Duplicate a tab.  Chromix can duplicate many tabs at once, but duplicating the
current tab is probably the most useful case.

#### ReloadWithoutCache

```
chromix with http://www.bbc.co.uk/news/ reloadWithoutCache
```
Reload the indicated tab, but bypass the cache.

#### Close

```
chromix with http://www.bbc.co.uk/news/ close
```
Close the indicated tab.

#### Goto

```
chromix with current goto http://www.bbc.co.uk/news/
```
Visit `http://www.bbc.co.uk/news/` in the current tab.

(The naming here is a little confusing.  Use `load` if you want to focus or switch
to an existing tab.)

#### List

```
chromix with chrome list
```
List all open Chrome tabs to standard output, one per line.  The output format
is: the tab identifier, the URL and the title.

#### Pin

```
chromix with current pin
```
Pin tab.

#### Unpin

```
chromix with current unpin
```
Unpin tab.

#### Url

```
chromix url
```
Output the URL of the current tab.


```
chromix url | xsel
```
Copy the current URL to the X selection.

## Notes

### Implicit `with` in Tab Commands

If a tab command is used without a preceding `with` clause, then the current tab is assumed.

So, the following:
```
chromix goto http://www.bbc.co.uk/news/
```
is shorthand for:
```
chromix with current goto http://www.bbc.co.uk/news/
```

### Implicit `ping`

If *no* command is provided, then `ping` is assumed.  So:
```
chromix
```
is shorthand for:
```
chromix ping
```

## Closing Comments

Please post an "Issue" if you have ideas for improving Chromix.

