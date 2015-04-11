perl <<
    use File::Basename        qw(dirname);
    use File::Spec::Functions qw(catfile rel2abs);
    use lib                   catfile(rel2abs(dirname(__FILE__)), 'lib');
    use Slides;

    Slides::load();
.

" sends a single character to the tmux 'player' session
function! SendChar(char)
perl <<
    # " get the arg from the vim args list; also, split it up and take only
    # " the first character to *ensure* we only ever send one
    my $char = (split(//, VIM::Eval('a:char')))[0];

    # " special case: send '\;' for semicolons cause send-keys requires it
    if ($char eq ';') { $char = "\\;" }

    # " same thing for double quotes, cause bash requires it
    if ($char eq '"') { $char = '\\"' }

    # " send the key along to tmux
    `tmux send-keys -t presentation:0.0 -l "$char"`;
.
endfunction

" 'type' out a string, based on our current typing speed, whatever that's at.
function! TypeString(str)
perl << HEREDOCS
    foreach my $char (split(//, VIM::Eval('a:str'))) {
        feedchar($char);
        vimsleep($typing);
    }
HEREDOCS
endfunction

function! Advance()
    perl Slides::advance()
endfunction

function! DisplaySlides()
    perl Slides::display_list();
endfunction

function! GoToSlide()
    call inputsave()
    let slide = input('Enter Slide Number: ')
    call inputrestore()

    perl Slides::go_to_slide(VIM::Eval('slide'))
endfunction

nmap n :call Advance()      <enter>
nmap l :call DisplaySlides()<enter>
nmap g :call GoToSlide()  <enter>
nmap k :perl Slide::Functions::feedchar('k')<Enter>
nmap j :perl Slide::Functions::feedchar('j')<Enter>
