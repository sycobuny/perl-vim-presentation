{
    package Slide::Keys;
    $VERSION = 0.1;

    use warnings;
    use strict;

    use constant ESC    => "\e";
    use constant ENTER  => "\r";
    use constant INSERT => 'a';

    use base qw(Exporter);

    our @EXPORT = qw(ESC ENTER INSERT);
}
