guacamole-common-js
===================

The Guacamole project provides a JavaScript API for interfacing with other
components that conform to the design of Guacamole, such as projects using
libguac or guacamole-common. This API is called guacamole-common-js.

guacamole-common-js provides a JavaScript implementation of a Guacamole client,
as well as tunneling mechanisms for getting protocol data out of JavaScript and
into guacd or the server side of a web application.

For convenience, it also provides mouse and keyboard abstraction objects that
translate JavaScript mouse, touch, and keyboard events into consistent data
that Guacamole can more easily digest. The extendable on-screen keyboard that
was developed for the Guacamole web application is also included.

Guacamole client
----------------

The main benefit to using the JavaScript API is the full Guacamole client
implementation, which implements all Guacamole instructions, and makes use of
the tunnel implementations provided by both the JavaScript and Java APIs.

Using the Guacamole client is straightforward. The client, like all other
objects within the JavaScript API, is within the `Guacamole` namespace. It is
instantiated given an existing, unconnected tunnel:

```javascript
var client = new Guacamole.Client(tunnel);
```

Once you have the client, it won't immediately appear within the DOM. You need
to add its display element manually:

```javascript
document.body.appendChild(client.getDisplay().getElement());
```

At this point, the client will be visible, rendering all updates as soon as
they are received through the tunnel.

```javascript
client.connect();
```

It is possible to pass arbitrary data to the tunnel during connection which can
be used for authentication or for choosing a particular connection. When the
`connect()` function of the Guacamole client is called, it in turn calls the
`connect()` function of the tunnel originally given to the client, establishing
a connection.

:::{important}
When creating the `Guacamole.Client`, the tunnel used must not already be
connected. The `Guacamole.Client` will call the `connect()` function for you
when its own `connect()` function is invoked. If the tunnel is already
connected when it is given to the `Guacamole.Client`, connection may not work
at all.
:::

In general, all instructions available within the Guacamole protocol are
automatically handled by the Guacamole client, including instructions related
to audio and video. The only instructions which you must handle yourself are
"name" (used to name the connection), "clipboard" (used to update clipboard
data on the client side), and "error" (used when something goes wrong
server-side). Each of these instructions has a corresponding event handler; you
need only supply functions to handle these events. If any of these event
handlers are left unset, the corresponding instructions are simply ignored.

HTTP tunnel
-----------

Both the Java and JavaScript API implement corresponding ends of an HTTP
tunnel, based on `XMLHttpRequest`.

The tunnel is a true stream - there is no polling. An initial request is made
from the JavaScript side, and this request is handled on the Java side. While
this request is open, data is streamed along the connection, and instructions
within this stream are handled as soon as they are received by the client.

While data is being streamed along this existing connection, a second
connection attempt is made. Data continues to be streamed along the original
connection until the server receives and handles the second request, at which
point the original connection closes and the stream is transferred to the new
connection.

This process repeats, alternating between active streams, thus creating an
unbroken sequence of instructions, while also allowing JavaScript to free any
memory used by the previously active connection.

The tunnel is created by supplying the relative URL to the server-side tunnel
servlet:

```javascript
var tunnel = new Guacamole.Tunnel("tunnel");
```

Once created, the tunnel can be passed to a `Guacamole.Client` for use in a
Guacamole connection.

The tunnel actually takes care of the Guacamole protocol parsing on behalf of
the client, triggering "oninstruction" events for every instruction received,
splitting each element into elements of an array so that the client doesn't
have to.

Input abstraction
-----------------

Browsers can be rather finicky when it comes to keyboard and mouse input, not
to mention touch events. There is little agreement on which keyboard events get
fired when, and what detail about the event is made available to JavaScript.
Touch and mouse events can also cause confusion, as most browsers will generate
*both* events when the user touches the screen (for compatibility with
JavaScript code that only handles mouse events), making it more difficult for
applications to support both mouse and touch independently.

The Guacamole JavaScript API abstracts mouse, keyboard, and touch interaction,
providing several helper objects which act as an abstract interface between you
and the browser events.

(guacamole-mouse)=

### Mouse

Mouse event abstraction is provided by the `Guacamole.Mouse` object.  Given an
arbitrary DOM element, `Guacamole.Mouse` triggers onmousedown, onmousemove, and
onmouseup events which are consistent across browsers. This object only
responds to true mouse events. Mouse events which are actually the result of
touch events are ignored.

```javascript
var element = document.getElementById("some-arbitrary-id");
var mouse = new Guacamole.Mouse(element);

mouse.onmousedown =
mouse.onmousemove =
mouse.onmouseup   = function(state) {

    // Do something with the mouse state received ...

};
```

The handles of each event are given an instance of `Guacamole.Mouse.State`
which represents the current state of the mouse, containing the state of each
button (including the scroll wheel) as well as the X and Y coordinates of the
pointer in pixels.

(guacamole-touch)=

### Touch

Touch event abstraction is provided by either `Guacamole.Touchpad` (emulates a
touchpad to generate artificial mouse events) or `Guacamole.Touchscreen`
(emulates a touchscreen, again generating artificial mouse events). Guacamole
uses the touchpad emulation, as this provides the most flexibility and
mouse-like features, including scrollwheel and clicking with different buttons,
but your preferences may differ.

```javascript
var element = document.getElementById("some-arbitrary-id");
var touch = new Guacamole.Touchpad(element); // or Guacamole.Touchscreen

touch.onmousedown =
touch.onmousemove =
touch.onmouseup   = function(state) {

    // Do something with the mouse state received ...

};
```

Note that even though these objects are touch-specific, they still provide
mouse events. The state object given to the event handlers of each event is
still an instance of `Guacamole.Mouse.State`.

Ultimately, you could assign the same event handler to all the events of both
an instance of `Guacamole.Mouse` as well as `Guacamole.Touchscreen` or
`Guacamole.Touchpad`, and you would magically gain mouse and touch support.
This support, being driven by the needs of remote desktop, is naturally geared
around the mouse and providing a reasonable means of interacting with it. For
an actual mouse, events are translated simply and literally, while touch events
go through additional emulation and heuristics. From the perspective of the
user and the code, this is all transparent.

(guacamole-keyboard)=

### Keyboard

Keyboard events in Guacamole are abstracted with the `Guacamole.Keyboard`
object as only keyup and keydown events; there is no keypress like there is in
JavaScript. Further, all the craziness of keycodes vs. scancodes vs. key
identifiers normally present across browsers is abstracted away. All your event
handlers will see is an X11 keysym, which represent every key unambiguously.
Conveniently, X11 keysyms are also what the Guacamole protocol requires, so if
you want to use `Guacamole.Keyboard` to drive key events sent over the
Guacamole protocol, everything can be connected directly.

Just like the other input abstraction objects, `Guacamole.Keyboard` requires a
DOM element as an event target. Only key events directed at this element will
be handled.

```javascript
var keyboard = new Guacamole.Keyboard(document);

keyboard.onkeydown = function(keysym) {
    // Do something ...
};

keyboard.onkeyup = function(keysym) {
    // Do something ...
};
```

In this case, we are using `document` as the event target, thus receiving all
key events while the browser window (or tab) has focus.

On-screen keyboard
------------------

The Guacamole JavaScript API also provides an extendable on-screen keyboard,
`Guacamole.OnScreenKeyboard`, which requires the URL of an XML file describing
the keyboard layout. The on-screen keyboard object provides no hard-coded
layout information; the keyboard layout is described entirely within the XML
layout file.

### Keyboard layouts

The keyboard layout XML included in the Guacamole web application would be a
good place to start regarding how these layout files are written, but in
general, the keyboard is simply a set of rows or columns, denoted with `<row>`
and `<column>` tags respectively, where each can be nested within the other as
desired.

Each key is represented with a `<key>` tag, but this is not what the user sees,
nor what generates the key event. Each key contains any number of `<cap>` tags,
which represent the visible part of the key.  The cap describes which X11
keysym will be sent when the key is pressed.  Each cap can be associated with
any combination of arbitrary modifier flags which dictate when that cap is
active.

For example:

```xml
<keyboard lang="en_US" layout="example" size="5">
    <row>
        <key size="4">
            <cap modifier="shift" keysym="0xFFE1">Shift</cap>
        </key>
        <key>
            <cap>a</cap>
            <cap if="shift">A</cap>
        </key>
    </row>
</keyboard>
```

Here we have a very simple keyboard which defines only two keys: "shift" (a
modifier) and the letter "a". When "shift" is pressed, it sets the "shift"
modifier, affecting other keys in the keyboard. The "a" key has two caps: one
lowercase (the default) and one uppercase (which requires the shift modifier to
be active).

Notice that the shift key needed the keysym explicitly specified, while the "a"
key did not. This is because the on-screen keyboard will automatically derive
the correct keysym from the text of the key cap if the text contains only a
single character.

(displaying-osk)=

### Displaying the keyboard

Once you have a keyboard layout available, adding an on-screen keyboard to your
application is simple:

```javascript
// Add keyboard to body
var keyboard = new Guacamole.OnScreenKeyboard("path/to/layout.xml");
document.body.appendChild(keyboard.getElement());

// Set size of keyboard to 100 pixels
keyboard.resize(100);
```

Here, we have explicitly specified the width of the keyboard as 100 pixels.
Normally, you would determine this by inspecting the width of the containing
component, or by deciding on a reasonable width beforehand. Once the width is
given, the height of the keyboard is determined based on the arrangement of
each row.

### Styling the keyboard

While the `Guacamole.OnScreenKeyboard` object will handle most of the layout,
you will still need to style everything yourself with CSS to get the elements
to render properly and the keys to change state when clicked or activated. It
defines several CSS classes, which you will need to manually style to get
things looking as desired:

`guac-keyboard`
: This class is assigned to the root element containing the entire keyboard,
  returned by `getElement()`,

`guac-keyboard-row`
: Assigned to the `div` elements which contain each row.

`guac-keyboard-column`
: Assigned to the `div` elements which contain each column.

`guac-keyboard-gap`
: Assigned to any `div` elements created as a result of `<gap>` tags in the
  keyboard layout. `<gap>` tags are intended to behave as keys with no visible
  styling or caps.

`guac-keyboard-key-container`
: Assigned to the `div` element which contains a key, and provides that key
  with its required dimensions. It is this element that will be scaled relative
  to the size specified in the layout XML and the size given to the `resize()`
  function.

`guac-keyboard-key`
: Assigned to the `div` element which represents the actual key, not the cap.
  This element will not directly contain text, but it will contain all caps
  that this key can have. With clever CSS rules, you can take advantage of this
  and cause inactive caps to appear on the key in a corner (for example), or
  hide them entirely.

`guac-keyboard-cap`
: Assigned to the `div` element representing a key cap. Each cap is a child of
  its corresponding key, and it is up to the author of the CSS rules to hide or
  show or reposition each cap appropriately. Each cap will contain the display
  text defined within the `<cap>` element in the layout XML.

{samp}`guac-keyboard-requires-{MODIFIER}`
: Added to the cap element when that cap requires a specific modifier.

{samp}`guac-keyboard-uses-{MODIFIER}`
: Added to the key element when any cap contained within it requires a specific
  modifier.

{samp}`guac-keyboard-modifier-{MODIFIER}`
: Added to and removed from the root keyboard element when a modifier key is
  activated or deactivated respectively.

`guac-keyboard-pressed`
: Added to and removed from any key element as it is pressed and released
  respectively.

:::{important}
The CSS rules required for the on-screen keyboard to work as expected can be
quite complex. Looking over the CSS rules used by the on-screen keyboard in the
Guacamole web application would be a good place to start to see how the
appearance of each key can be driven through the simple class changes described
above.

Inspecting the elements of an active on-screen keyboard within the Guacamole
web application with the developer tools of your favorite browser is also a
good idea.
:::

(osk-event-handling)=

### Handling key events

Key events generated by the on-screen keyboard are identical to those of
`Guacamole.Keyboard` in that they consist only of a single X11 keysym.  Only
keyup and keydown events exist, as before; there is no keypress event.

```javascript
// Assuming we have an instance of Guacamole.OnScreenKeyboard already
// called "keyboard"

keyboard.onkeydown = function(keysym) {
    // Do something ...
};

keyboard.onkeyup = function(keysym) {
    // Do something ...
};
```

