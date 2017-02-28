---
layout: page 
title: Guacamole Style Guidelines
permalink: /guac-style/
---

These guidelines are intended to serve as a reference and means of
standardizing the code style of the Guacamole codebase. Not all developers or
contributors will agree with these guidelines, but this is beside the point.
Above all, these guidelines ensure Guacamole code is readable and maintainable.
The key to achieving this is consistency. [The Google style
guidelines](http://google-styleguide.googlecode.com/svn/trunk/javascriptguide.xml)
perhaps describe this need best:

> 
> BE CONSISTENT.
> 
> If you're editing code, take a few minutes to look at the code around you and
> determine its style. If they use spaces around all their arithmetic
> operators, you should too. If their comments have little boxes of hash marks
> around them, make your comments have little boxes of hash marks around them
> too.
> 
> The point of having style guidelines is to have a common vocabulary of coding
> so people can concentrate on what you're saying rather than on how you're
> saying it. We present global style rules here so people know the vocabulary,
> but local style is also important. If code you add to a file looks
> drastically different from the existing code around it, it throws readers out
> of their rhythm when they go to read it. Avoid this.
> 
 
If you are a developer on the Guacamole project, or intend to contribute code
to the Guacamole project, you absolutely must follow these guidelines; to do
otherwise would be detrimental to the project and the collaborative effort it
represents.

We won't attempt to argue against other styles here - to do so is pointless, as
all styles have merit. This is simply the style we prefer, for our own reasons.

Rule of Thumb
-------------

**When in doubt, follow the style around you.** If you see that the code uses a
4-space indent and no tabs, then obviously you should not use tabs. If you see
the code uses `variables_named_like_this`, then your code should not suddenly
start `namingThingsLikeThis`.

That said, these style guidelines are intended to be adopted going forward. We
develop according to these guidelines, but definitely may not have done so in
the ancient past.

General Style
-------------

1. **Use 4-space indents and no tabs.**
2. Comment everything semantically and liberally, use blank lines to separate
   logical blocks. Yes, HTML should be commented, too.
3. Wrap lines to 80 columns when doing so does not decrease readability.

Comments and Documentation
--------------------------

1. All functions, all parameters, all return values, all structures, and all
   members must be documented with JavaDoc/Doxygen, wrapping lines as necessary
   to fit the 80 column maximum:

        /**
         * High-level function description. Implementation details if
         * appropriate (it's usually not).
         *
         * @param var1
         *     Description of what var1 is.
         *
         * @param var2
         *     Description of what var2 is, though this description is
         *     particularly long to demonstrate how lines should be wrapped and
         *     indented.
         *
         * @return
         *     Description of return value.
         */
         int fun(int var1, int var2);
2. Do not use the `@author` tag (or similar). The authors of various parts of
   the codebase should be tracked by git, not by the code itself.
3. There must be no undocumented behavior of functions.
4. If changes you are making will make parts of the existing manual incorrect,
   you are not expected to update the manual yourself, but **please let us know
   so we correct it**.
5. For C code, local functions should be static and documented locally.
   Functions, types, etc. which are not local should be declared in an
   appropriate header file, and documented within the header file.

Braces
------

1. Avoid braces when unnecessary (single statement `if`'s, for example) unless
   it significantly increases readability. There is no hard rule here - use
   your own best judgment.
2. Do not cuddle the `else`, etc.

        /* Do this */
        if (thing) {
        }
        else {
        }

        /* Not this */
        if (thing) {
        } else {
        }

   The only exception here is `do`/`while`:

        do {
        } while (thing);

Naming
------

1. Variables, functions, and datatypes in C should use the standard C
   convention of `words_separated_by_underscores`. Functions must have an
   appropriate namespace.
2. Variables and functions in Java and JavaScript should use
   `headlessCamelCase`. Classes in Java and JavaScript should use `CamelCase`.
3. Constants and enums (or variables which are intended to be constant) in all
   languages should use `UPPERCASE_WORDS_SEPARATED_BY_UNDERSCORES`.
4. Prefer `'single quotes'` over `"double quotes"` for strings in JavaScript.

Error Handling
--------------

1. Exceptions within Java and return types of function calls in C which can
   fail may not be ignored, unless the failure (A) has no effect on the running
   of the program and (B) would not be useful even if logged at the debug
   level.
2. If an exception should be logged, log it at an appropriate log level.
   Additionally, log the exception itself at the debug level such that a stack
   trace is included when debug-level logging is enabled. **Do not pollute
   non-debug log levels with stack traces!**

