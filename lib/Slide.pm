{
    package Slide;
    $VERSION = 0.1;

    use warnings;
    use strict;

    use File::Basename        qw(dirname);
    use File::Spec::Functions qw(catfile rel2abs);

    use YAML qw(LoadFile);

    use Slide::Keys;
    use Slide::Functions;

    # copied from Slides.pm cause Syntastic doesn't deal very well with the
    # recursive module loading, and I didn't feel like figuring out a "proper"
    # fix for that
    use constant SLIDEPATH => catfile(
        dirname(dirname(rel2abs(__FILE__))), 'slides'
    );

    use constant GOTO_TOP  => ESC . '1G';
    use constant CLEAR_BUF => GOTO_TOP . 'VGd';
    use constant SET_FT    => ESC . ':set ft=';
    use constant HEADERS   => {
        title       => '=',
        information => '-',
    };

    use constant DEFAULT_CONTENTS => {
        title => {
            lead   => 5,
            spacer => 1,
        },

        information => {
            lead   => 1,
            spacer => 1,
        },
    };

    use constant DEFAULT_INFO_ACTION => {
        type  => 'bullet',
        level => 1,
    };

    use constant BULLETS => [ qw(* - +) ];

    ##
    # STATIC

    sub clear_buffer {
        rightnow(CLEAR_BUF);
    }

    sub set_filetype {
        my ($ft) = @_;

        rightnow(SET_FT . $ft . ENTER);
    }

    ##
    # OBJECT

    sub new {
        my ($pkg)  = shift;
        my ($file) = @_;
        my ($obj);

        $pkg = ref($pkg) || $pkg;
        $obj = bless({}, $pkg);

        $obj->{name}     = $file;
        $obj->{yaml}     = catfile(SLIDEPATH, $file);
        $obj->{contents} = LoadFile($obj->{yaml});
        $obj->{action}   = 0;

        $obj->parse_actions();
    }

    sub parse_actions {
        my ($self) = shift;
        my ($contents) = $self->{contents};
        my ($actions, $current, $new, $add);

        $self->{actions} = $actions = [];
        $new = sub { push(@{ $actions }, $current = []) };
        $add = sub { push(@{ $current }, shift) };

        if (exists(DEFAULT_CONTENTS->{ $self->{contents}{type} })) {
            $self->{contents} = {
                %{ DEFAULT_CONTENTS->{$self->{contents}{type} } },
                %{ $self->{contents} },
            };
        }

        if ($contents->{type} eq 'title') {
            $self->parse_title_slide($new, $add);
        }
        elsif ($contents->{type} eq 'information') {
            $self->parse_information_slide($new, $add);
        }

        $self;
    }

    sub parse_title_slide {
        my ($self) = shift;
        my ($new, $add) = @_;

        $new->();
        $add->(\&display_header);
        $add->(sub {
            rightnow(INSERT);

            foreach my $line (@{ $self->{contents}{subtitles} }) {
                rightnow($line . ENTER);
            }

            rightnow(GOTO_TOP);
        });
    }

    sub parse_information_slide {
        my ($self) = shift;
        my ($new, $add) = @_;

        $new->();
        $add->(\&display_header);

        foreach my $action (@{ $self->{contents}{actions} }) {
            $new->();

            if (ref $action) {
                $action = { %{ &DEFAULT_INFO_ACTION }, %{ $action } };
            }
            else {
                $action = { %{ &DEFAULT_INFO_ACTION }, text => $action };
            }

            if ($action->{type} eq 'bullet') {
                my ($text)  = $action->{text};
                my ($level) = $action->{level};
                my ($char)  = BULLETS->[ $level % scalar(@{ &BULLETS }) ];
                my ($space) = '  ' x $level;

                $text = INSERT. "$space$char $text" . ENTER . ESC;
                $add->(sub { rightnow($text) });
            }
        }
    }

    sub reset {
        my ($self) = shift;
        $self->{action} = 0;
    }

    sub finished {
        my ($self) = shift;
        $self->{action} >= scalar(@{ $self->{actions} });
    }

    sub next {
        my ($self) = shift;

        foreach my $action (@{ $self->{actions}[ $self->{action} ] }) {
            $self->$action();
        }

        ($self->{action})++;
    }

    sub display_header {
        my ($self) = shift;
        my ($char) = HEADERS->{ $self->{contents}{type} };

        clear_buffer();
        set_filetype('markdown');

        # print out the leader - vertical space before the title
        rightnow($self->{contents}{lead} . 'o' . ESC);

        # print out the main title itself
        rightnow('a' . $self->{contents}{title} . ENTER);

        # print out a line of = to make sure the title is registered as such
        # by the markdown syntax processor
        rightnow(($char x length($self->{contents}{title})) . ENTER);

        # go down as many lines as we need to space from the subtitle
        rightnow(ENTER x $self->{contents}{spacer});

        rightnow(ESC);
    }
}
