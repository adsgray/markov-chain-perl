#!/usr/bin/perl



my %map = ();

# read in a text file line by line
# then generate a table of
# word pair -> next_word mappings
# with frequencies

sub dbg_array {
    my $aref = shift;
    foreach my $ent (@$aref) {
        print "$ent ";
    }
    print "\n";
}

# return true if line should be skipped
sub exclude_line {
    my $line = shift;

    if ($line =~ /^\d+\s+moby-dick\s*$/) {
        return 1;
    }

    if ($line =~ /^chapter\s+\w+\s*$/) {
        return 1;
    }

    if ($line =~ /^vol\./) {
        return 1;
    }

    # chapter headings on each "page"
    if ($line =~ /\d+\s*$/) {
        return 1;
    }

    return 0;
}

sub handle_sentence {
    my $sentence = shift;
    print "hs: $sentence\n";
}

# blank lines and periods are full stops so clear input buffer
my @group = ();

my $sentence = "";
my @sentences = ();
while (my $line = <>) {

    #if ($line =~ /^\s+$/) {
    #    print "blank line!\n";
    #}

    # remove commas etc
    chomp($line);
    $line =~ s/[\$#@~!&*()\[\];,:?^`\\\/]+//g;
    $line = lc($line);

    if (exclude_line($line)) {
        next;
    }

    print "$line\n";


    # split into sentences on period
    @sentences = (@sentences, split ".",$line);
    my $sentence = pop(@sentences);
    handle_sentence($sentence);
}
