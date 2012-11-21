Chromix
=======

Chromix is a command-line and scripting utility for controlling Google chrome.  It can be
used, amongst other things, to create, switch, focus, reload and remove tabs.

Here's a use case.  Say you're editing an
[asciidoc](http://www.methods.co.nz/asciidoc/userguide.html) or a
[markdown](http://daringfireball.net/projects/markdown/) document.  The work
flow is: edit, compile, and reload the chrome tab to see your changes.

Chromix can automate this, particularly the last step.  Change the build step to:
```
markdown somefile.md > somefile.html && node chromix.js load file://$PWD/somefile.html
```
Now, chrome reloads your work every time it changes.  And with suitable key
bindings in your text editor, the build-view process can involve just a couple
of key strokes.

Jump straight to
[here](https://github.com/smblott-github/chromix#chromix-commands) for a list
of available commands.

Installation
------------

Chromix involves three components:

  - A Chrome extension known as [Chromi](https://github.com/smblott-github/chromi).  
    Chromi is packaged separately.  It is available either at the [Chrome Web
    Store](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo)
    or from [GitHub](https://github.com/smblott-github/chromi).
  - A server: `script/server.{coffee,js}`.
  - A client: `script/chromix.{coffee,js}`.  
    This is Chromix's command-line and scripting utility.

This project provides the Chromix server and client.

There's an explanation of how these three components interact (including an
example) on the [Chromi site](https://github.com/smblott-github/chromi#details).

### Dependencies

Dependencies include, but may not be limited to:

  - [Node.js](http://nodejs.org/)  
    (Install with your favourite package manager, perhaps something like `sudo apt-get install node`.)
  - [Coffeescript](http://coffeescript.org/)  
    (Install with something like `npm install coffee-script`.)
  - [Optimist](https://github.com/substack/node-optimist)  
    (Install with something like `npm install optimist`.)
  - The [ws](http://einaros.github.com/ws/) web socket implementation  
    (Install with something like `npm install ws`.)

### Build

Run `cake build` in the project's root folder.  This "compiles" the CoffeeScript
source to JavaScript.

`cake` is installed by `npm` as part of the `coffee-script` package.  Depending
on how the install is handled, you may have to search out where `npm` has
installed `cake`.

### Extension Installation

Install [Chromi](https://chrome.google.com/webstore/detail/chromi/eeaebnaemaijhbdpnmfbdboenoomadbo).

### Server Installation

The server can be run with an invocation such as:
```
node script/server.js
```
The extension broadcasts a heartbeat every five seconds.  If everything is
working correctly, then these heartbeats (and all other messages) appear on the
server's standard output.

The server might beneficially be run under the control of a supervisor daemon
such as [daemontools](http://cr.yp.to/daemontools.html) or
[supervisord](http://supervisord.org/).

### Client Installation

The JavaScript file (`script/chromix.js`) can be made executable and
installed in some suitable directory on your `PATH`.

A chromix invocation looks something like:
```
node chromix.js CHROMIX-COMMAND [ARGUMENTS...]
```

Chromix Commands
----------------

There are two types of Chromix commands: 
[general commands])https://github.com/smblott-github/chromix#general-commands) and
[tab commands](https://github.com/smblott-github/chromix#tab-commands).  The
latter operate on individual tabs, and are usually accessed via the
`[with](https://github.com/smblott-github/chromix#with)` general command.

### General Commands

#### Ping

```
node chromix.js ping
```
This produces no output, but yields an exit code of `0` if Chromix was able to
ping Chromi/Chrome, and non-zero otherwise.  It can be useful in scripts for checking
whether Chromi/Chrome is running.

This is the default command if no arguments are provided to chromix, so the
`ping`, above, can be omitted.

#### Load

```
node chromix.js load https://github.com/
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
node chromix.js with other close
```
This closes all tabs except the currently focused one.

Another example:
```
node chromix.js with chrome close
```
This closes all tabs which *aren't* `http://`, `file://` or `ftp://`.

The first argument to `with` specifies the tabs to which the rest of the command applies.
`other`, above,  means "all non-focused tabs").  The rest of the command must
be a [tab command](https://github.com/smblott-github/chromix#tab-commands).

Tabs can be specified in a number of ways: `all`, `current`,
`other`, `http` (including HTTPS), `file`, `ftp`, `normal` (meaning `http`,
`file` or `ftp`), or `chrome` (meaning not `normal`).  Any other argument to
`with` is taken to be a pattern which is used to match tabs.  Patterns may
contain JavaScript RegExp operators.

Here are a couple of examples:
```
node chromix.js with "file:///.*/slidy/.*.html" reload
node chromix.js with "file://$HOME" reload
```
The first reloads all tabs containing HTML *files* under directories named
`slidy`.  The second reloads all tabs containing files under the user's home
directory.

#### Without

```
node chromix.js without https://www.facebook.com/ close
```
This closes all windows *except* those within the Facebook domain.

`without` is the same as `with`, except that the test is inverted.  So
`without normal` is the same as `with chrome`, and `without current` is the
same as `with other`.

Here's another example
```
node chromix.js without "file://$HOME" close
```
This closes all tabs *except* those containing files under the user's home
directory.

#### Window

```
node chromix.js window
```
This ensures that there is at least one normal Chrome window.  It does not
start Chrome if Chrome is not running.

#### Bookmarks

```
node chromix.js bookmarks
```
This outputs (to `stdout`) a list of all Chrome bookmarks, one per line.

#### Booky

```
node chromix.js booky
```
This outputs (to `stdout`) a list of (some of) Chrome bookmarks, but in a different format.

### Tab Commands

Tab commands operate on one or more tabs.  They are usually used with `with` or
`without`, above.

#### Focus

```
node chromix.js with http://www.bbc.co.uk/news/ focus
```
Focus the indicated tab.

#### Reload

```
node chromix.js with http://www.bbc.co.uk/news/ reload
```
Reload the indicated tab.

#### ReloadWithoutCache

```
node chromix.js with http://www.bbc.co.uk/news/ reloadWithoutcache
```
Reload the indicated tab, but bypass the cache.

#### Close

```
node chromix.js with http://www.bbc.co.uk/news/ close
```
Close the indicated tab.

#### Goto

```
node chromix.js with current goto http://www.bbc.co.uk/news/
```
Visit `http://www.bbc.co.uk/news/` in the current tab.

(The naming here is a little confusing.  Use `load` if you want to focus or switch
to an existing tab.)

#### List

```
node chromix.js with chrome list
```
List all open Chrome tabs to standard output, one per line.  The output format
is: the tab identifier, the URL and the title.

Notes
-----

### Implicit `with` in Tab Commands

If a tab command is used without a preceding `with` clause, then the current tab is assumed.

So, the following:
```
node chromix.js goto http://www.bbc.co.uk/news/
```
is shorthand for:
```
node chromix.js with current goto http://www.bbc.co.uk/news/
```

### Implicit `ping`

If *no* command is provided, then `ping` is assumed.  So:
```
node chromix.js
```
is shorthand for:
```
node chromix.js ping
```

### Wrapper

The helper script `extra/chromix` may prove helpful.  To use it, set the
environment variable `CHROMIX` appropriately and install the helper script in
some suitable directory on your `PATH`.

Closing Comments
----------------

Chromix is a work in progress and may be subject to either gentle evolution or
abrupt change.

Please post an "Issue" if you have any ideas as to how Chromix might be
improved.

