Perl and VIM
============

This is a presentation made using both Perl and VIM to talk about Perl and
VIM. It is an introduction to the varied and various ways you can change it
around to make it more useful and enable rapid deployment of applications.

It was first presented at Baltimore.pm's Meetup on October 30, 2013 at
CargoTEL in Baltimore City.

Requirements
============

Of Course
---------

  * [VIM][]
  * [Perl][]

Not As Obvious
--------------

  * [tmux][]
  * [git][]

We'll Handle The Rest
---------------------

  * [Vundle][]
  * [Syntastic][]
  * [vim-markdown][]
  * [SyntaxRange][]
  * [snipMate][]

Setting Up
==========

You're on your own (for now) to make sure the binaries for [VIM][], [Perl][],
[tmux][], and [git][] are installed. However, once they are, you can just do
this:

```bash
git clone https://github.com/sycobuny/perl-vim-presentation
cd perl-vim-presentation
./setup.bash
```

And you should be good to go! It will pull down the [Vundle][] repository for
you, and then use it to install the various other required plugins.

Running This Presentation
=========================

Terminals
---------

You'll need two terminal sessions open. How this happens is dependent on your
terminal, so I'll trust you know how to do it. If you don't, running this
presentation may be jumping the gun for you.

Player and Controller
---------------------

The first session will be your "player" session. It will be piloted by the
second session, the "controller". The "player" session requires a tmux session
named "presentation", with one window and one pane, and several environment
variables set up (such as manipulating `$HOME` to point to the project root
rather than your home directory). This is all actually moderately complicated
and definitely annoying, so there's a script located in the project root to do
it for you!

```bash
./present.bash
```

This will launch your "player" tmux session, set up the variables, and clean
up after itself.

Starting up the "controller" session is easier, you simply need to launch VIM
and make sure to process the `controller.vim` file in the project root. This
can be done in one command, as follows:

```bash
vim -S controller.vim controller.vim
```

**NB**: Strictly speaking, it is not necessary to edit the `controller.vim`
file while you're running the script from it, you could do it from any file or
window, but I often find it easier to follow along with the script, as there
are comments explaining each cue after the slides.

Moving Around
-------------

Navigating the project is a little bit tricky: you press the right arrow to
move forward.

Actually, that wasn't so bad. Oh, you might want to jump around and edit
different sections. Unfortunately, this currently requires a bit of knowledge
about where in the script you are and where in the script you want to go. You
can fairly easily tell where you *are* by typing `<Leader>c`4 in your
controller session. But, telling where you're going is trickier. For now,
you'll probably just have to count backwards from your current cue. (See? I
told you it would be easier if you had the file loaded in a buffer!)

Moving to a cue is accomplished by typing the `<Leader>sc` command in the
controller, and it will give you a prompt to enter a cue number. This will
jump to that point in the script, and the next time you press the right arrow,
the script will run that command and continue on from that point as normal.

You should note that moving around in the script this way is fragile. Because
each command in the script alters the state of the VIM session in the player,
moving forwards and backwards is not (currently) guaranteed to be idempotent.
Several commands in the script expect to be in a specific mode, with a
specific cursor position, and starting elsewhere may produce undesirable
results. You should very much practice before you try to give this
presentation, so you can get a feel for which targets you can jump to and from
where (and also familiarize yourself with cue numbers). Similar caveats apply
if you'd like to jump into the player and start manipulating the session by
hand (which is absolutely possible).

See the *TODO* section for more information about this process.

Syntax Highlighting
-------------------

I feel personally that highlighting is desirable in almost all cases. This may
not be the case with you. So, there's a special controller command,
`<Leader>so`, which disables the syntax highlighting. This could either be
because you just hate syntax highlighting, or, more likely that the syntax
highlighting results in illegible content on a given display.

You shouldn't need to do anything special to prepare the player to receive
this command. It accepts the characters in the modes that the script causes
VIM to enter. Any time you call this, it should return to the state it was in
before (more or less, anyway: the cursor position may be on opposite sides of
a restored visual selection, for instance).

Also, you will need to run the command for any given instance of VIM that
starts in the player. Currently this means only the slides and the demo. As
all the files edited for these two groups occur in just the two sessions, you
should only have to set this twice.

Note that, if you run the command twice in the same session, it will re-enable
highlighting. This is by design: it is a toggle, not a self-destruct button.

TODO
====

Style
-----

  * Make it possible to create idempotent scripts
  * Add "tags" feature to points in the script to allow for easier motion
    control.
  * Smarten up the slide reader so that slides don't have to be broken apart
    so hideously (see slides/05-about-vimrc/ for an example).
  * Make it possible to "animate" the addition of new material on slides
  * Make the syntax highlighting preference stick to all sessions

Substance
---------

  * Write slide 9. I, er, forgot to do so, and that was a bit problematic
    during the presentation.
  * Cover the other plugins required by `.vimrc`. This includes [Syntastic][]
    and [SyntaxRange][].
  * Write a notes file to be (optionally) distributed with this presentation
    as supplemental materials.

Author
======

Stephen Belcher

  * [GitHub][] ([Resume][])
  * [Twitter][]

Copyright and License
=====================

tl;dr: Pretty much the [MIT License][].

-----

Copyright (c) 2013 Stephen Belcher

Permission is hereby granted, free of charge, to any person obtaining a copy
of the software, documentation, and other content in this software repository
(the "Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

----

[VIM]:  http://www.vim.org/
[Perl]: http://www.perl.org/
[tmux]: http://tmux.sourceforge.net/
[git]:  http://git-scm.com/

[Vundle]:       https://github.com/gmarik/vundle
[Syntastic]:    https://github.com/scrooloose/syntastic
[vim-markdown]: https://github.com/tpope/vim-markdown
[SyntaxRange]:  http://www.vim.org/scripts/script.php?script_id=4168
[snipMate]:     https://github.com/msanders/snipmate.vim

[GitHub]:  https://github.com/sycobuny
[Resume]:  https://github.com/sycobuny/resume
[Twitter]: https://twitter.com/sycobuny

[MIT License]: http://opensource.org/licenses/MIT
