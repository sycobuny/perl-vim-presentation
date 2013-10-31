" initialize some things
let s:file = expand('<sfile>:h:p')
perl <<
    use File::Basename qw(basename);
    our $base = VIM::Eval('s:file');

    # " Tps : TARGET perl subs
    # " wrap vim functions in perl one-liners
    sub feedchar($) { VIM::DoCommand("call SendChar('$_[0]')") }
    sub writestr($) { VIM::DoCommand("call TypeString('$_[0]')") }
    sub vimsleep($) { VIM::DoCommand("sleep $_[0]") }

    # " execute a series of commands from typefast() as quickly as possible
    sub rightnow($) { local $typing = '1m'; writestr shift }

    # " script wrappers for doing things other than basic typing
    sub pausesec($) { bless(\(shift), 'Pause') } # " pause for a bit
    sub typefast($) { bless(\(shift), 'Fast')  } # " type like a computer

    # " load up the slides portion of the script dynamically based on
    # " whatever's currently in slides/
    our @slides = ();
    foreach my $outer (sort glob("$base/slides/??-*")) {
        next unless (-e "$outer/base.md");

        push(@slides, [sub {
            `cp $outer/base.md $base/slides/current-slide.md`;
            rightnow("\e:e! \$SLIDES/current-slide.md\r1G");
        }]);

        foreach my $inner (sort glob("$outer/*.next.md")) {
            my $read = '$SLIDES/' . basename($outer) .'/'.  basename($inner);
            push(@slides, [sub { rightnow("G:read $read\r1G") }]);
        }
    }

    # " if we have any slides, then the first command should get us into them
    # " as quickly as possible. we hack our way into doing this by opening up
    # " a temporary file (so as to skip a flash of the welcome message) and
    # " then immediately progress into opening the first slide.
    if (@slides) {
        $slides[0] = [typefast("vi presentation.vim\r"), $slides[0][0]];
    }

    # " Tdv : TARGET default variables
    our $pause  = pausesec '500m'; # " our default pause; syntactic sugar
    our $typing = '100m';          # " our faked-out-typing speed

    # " Tsc : TARGET script specification
    # " the script - each arrayref is a series of commands to be sent to the
    # " tmux 'player' session. hitting the right arrow  advances the script.
    # " NB: \t is a tab char, \e is escape, \r is return
    our $script = [
        # " run through the slides, whatever they may be
        @slides,

        [typefast("\e:q!\rclear\r"), "vi .vim/snippets/perl.snippets\r",
         $pause, "jzO"],

        [typefast("\e:q!\rclear\r"), "mkdir -p \$MODLIB/My\r", $pause,
         "vi \$MODLIB/My/Class.pm\r"],

        # " demonstrate snipMate with closed-up folds
        ['anewpkg'],
        ["\t"],
        ['My::Class', $pause, "\t"],
        ["1.0\e"],

        # " show the other stuff that already got filled out
        ["\e14G\026el", $pause, "\e18Gv\$"],

        # " now, let's show them this file.
        ["\e:e! controller.vim\r"],
        ['3GV$'],            # " highlight the perl opening bracket
        ["\e/Tps\rV11j"],    # " highlight the perl subs
        ["\e/Tdv\rV2j"],     # " highlight our default variables
        ["\e/Tsc\rz\rVL"],   # " highlight the whole (visible) script
        ["\e@{[ __LINE__ + 3 ]}GzzV"], # " *waves* HI MOM
        ["\e2j/Tvf\rz\rVL"], # " highlight SendChar/TypeString functions

        # " demonstrate how to pass and receive arguments in perl
        ["\e?Tva\rjfSvf)"], # " highlight the argument passed in
        ["\e/Tpa\rjfVvf)"], # " highlight how we access it from perl

        # " highlight the various ways to call perl scripts
        ["\e?Thd\rjV\$", $pause, "\e9jV\$"], # " standard heredoc, w/dot
        ["\e/Thc\rjV\$", $pause, "\e5jV\$"], # " heredoc w/custom terminator
        ["\e/Tol\rjzzV\$"],                  # " oneliner

        # " show the legwork code
        ["\e/Tsr\rz\rV14j\$"], # " highlight the actual script runner
        ["\e/Tkb\rz\rVG\$"],   # " highlight the keybindings

        # " show the 'Questions?' slide
        [typefast("\e:e! \$SLIDES/questions.md\r")],

        # " exit the presentation.
        [typefast("\e:q!\rexit\r")],
    ];
    # " our current position in the script
    our $cue = 0;
.

" Tvf - TARGET vim functions
" sends a single character to the tmux 'player' session. should ideally only
" get one character as arg, but we make SURE that we only send one.
" Tva - TARGET vim arg
function! SendChar(char)
" Thd - TARGET heredoc with dot
perl <<
    # " Tpa - TARGET perl arg
    my $char = (split(//, VIM::Eval('a:char')))[0];

    # " special case: send '\;' for semicolons cause send-keys requires it
    if ($char eq ';') { $char = "\\;" }

    # " send the key along to tmux
    `tmux send-keys -t presentation:0.0 -l "$char"`;
.
endfunction

" 'type' out a string, based on our current typing speed, whatever that's at.
function! TypeString(str)
" Thc - TARGET heredoc with custom terminator
perl << HEREDOCS
    foreach my $char (split(//, VIM::Eval('a:str'))) {
        feedchar($char);
        vimsleep($typing);
    }
HEREDOCS
endfunction

" debug purposes: tell us what line in the script we're up to.
function! LinePlease()
    " Tol - TARGET oneline perl command
    perl VIM::DoCommand("echom 'The current cue is: $cue'")
endfunction

" debug purposes: set the cue number manually
function! UseTakeTwo(cue)
    perl $cue = VIM::Eval('a:cue') + 0
endfunction

" debug purposes: set the cue number (by asking for it).
function! Cut()
perl <<
    VIM::DoCommand('call inputsave()');
    VIM::DoCommand('let cue = input("CUT! Take it from scene: ")');
    VIM::DoCommand('call inputrestore()');
    VIM::DoCommand("call UseTakeTwo(@{[ VIM::Eval('cue') + 0 ]})");
.
endfunction

" in case the syntax highlighting isn't very clear on the projector
function! ToggleHighlighting()
    perl rightnow(';TS')
endfunction

" Tsr - TARGET script runner
" play the next line in the script, unless we're all done, then exit quietly.
function! RunTheShow()
perl <<
    if ($cue <= $#$script) {
        foreach my $line (@{ $script->[$cue] }) {
            if    (ref($line) =~ /Pause/) { vimsleep($$line) }
            elsif (ref($line) =~ /Fast/)  { rightnow($$line) }
            elsif (ref($line) =~ /CODE/)  { $line->()        }
            else                          { writestr($line)  }
        }
        $cue++;
    }
.
endfunction

" Tkb - TARGET key bindings
" map the previous functions to simple commands for ease-of-use during
" presentation.
nmap <Right> :call RunTheShow()<enter>
nmap <Leader>c :call LinePlease()<enter>
nmap <Leader>sc :call Cut()<enter>
nmap <Leader>so :call ToggleHighlighting()<enter>

" write this file, then load the script over again
nmap <Leader>w :w<enter>:source %<enter>
