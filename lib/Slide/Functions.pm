{
    package Slide::Functions;
    $VERSION = 0.1;

    use warnings;
    use strict;

    use base qw(Exporter);
    our (@EXPORT) = qw(
        feedchar writestr vimsleep rightnow pausesec typefast
    );

    our ($pause);
    our ($typing) = '150m';

    # write a single character into the tmux session
    sub feedchar($) {
        my ($char) = @_;

        # special case for single-quotes
        if ($char eq "'") {
            VIM::DoCommand("call SendChar('''')");
        }
        else {
            VIM::DoCommand("call SendChar('$char')")
        }
    }

    # write a whole string into the tmux session; something else handles
    # whether to space it like a person or like a computer
    sub writestr($) {
        my ($string) = @_;

        # make sure to escape all single quotes in Vim's special way
        $string =~ s/'/''/g;

        VIM::DoCommand("call TypeString('$string')");
    }

    # wrap other vim functions in perl one-liners
    sub vimsleep($) { VIM::DoCommand("sleep $_[0]") }

    # execute a series of commands from typefast() as quickly as possible
    sub rightnow($) { local $typing = '1m'; writestr shift }

    # script wrappers for doing things other than basic typing
    sub pausesec($) { bless(\(shift), 'Pause') } # " pause for a bit
    sub typefast($) { bless(\(shift), 'Fast')  } # " type like a computer

    our $__SELF__ = __PACKAGE__
}
