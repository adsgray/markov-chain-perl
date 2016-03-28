#!/usr/bin/perl

# read in a text file line by line
# then generate a table of
# word pair -> next_word mappings
# with frequencies TODO: use frequencies

sub dbg_array {
    my $aref = shift;
    foreach my $ent (@$aref) {
        print "$ent ";
    }
    print "\n";
}

sub dbg_map {
    my $mref = shift;
    foreach my $k (keys %$mref) {
        print "$k -> " . $mref->{$k} . "\n";
    }
}

sub dump_map {
    my $mref = shift;
    foreach my $k (sort keys %$mref) {
        my $submap = $mref->{$k};
        my $next = join ",", keys %$submap;
        # TODO: print out frequencies
        # TODO: print out in json format
        print "$k -> $next\n";
    }
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

    if ($line =~ /^\s*$/) {
        return 1;
    }

    return 0;
}

sub random_key {
    my $href = shift;
    my @keys = keys %{$href};
    my $numkeys = scalar @keys;
    my $k = rand $numkeys;
    return $keys[$k];
}

# TODO: parameterize $depth
my $depth = 5;
my %map = ();

my @buf = ();

sub cleanse_line {
    my $line = shift;
    $line =~ s/[_\-\$#@~*()\[\]^`\\\/]+//g;
    return $line;
}

# side effect: puts stuff into global %map
sub handle_word {
    my $word = shift;
        if (exclude_line($word)) {
            return;
        }
    if (scalar(@buf) == $depth) {
        my $key = join " ", @buf;
        $map{$key}{$word} += 1;
        shift @buf;
    } 

    push (@buf, $word);
}


sub handle_sentence {
    my $sentence = shift;
    my @words = split /\s/, $sentence;
    foreach my $w (@words) {
        handle_word $w;
    }
}


sub handle_sentences {
    my $sref = shift;
    my @sentences = @{$sref};
    foreach my $s (@sentences) {
        handle_sentence $s;
    }
}

# TODO:
# blank lines and periods are full stops so clear input buffer
#my @group = ();

sub get_sentences {
    my $sentence = "";
    my @sentences = ();
    while (my $line = <>) {
    
        chomp($line);
        #$line =~ s/[_"'\-'"\$#@~!&*()\[\];,:?^`\\\/]+//g;
        # better to leave some punctuation
        $line = cleanse_line $line;
        #$line = lc($line);
    
        if (exclude_line($line)) {
            next;
        }
    
        # split into sentences on period
        push (@sentences, split /\./,$line);
    }
    return \@sentences;
}

sub make_sentences {
    my $href = shift;
    my $num = shift;
    my $ret = "";

    my $key = random_key $href;

    $ret = $key . " ";

    while ($num > 0) {
        # this key manipulation could be improved

        if (!defined($href->{$key})) {
            $key = random_key $href;
        }
        my $subkey = random_key $href->{$key};
        $ret .= $subkey . " ";
        @keyarr = split /\s/,$key;
        shift @keyarr;
        push @keyarr,$subkey;
        $key = join " ",@keyarr;
        $num--;
    }

    return $ret;
}

sub make_sentences_char {
    my $href = shift;
    my $num = shift;
    my $ret = "";

    my $key = random_key $href;

    $ret = $key;

    while ($num > 0) {
        if (!defined($href->{$key})) {
            $key = random_key $href;
            $ret .= "\n";
        }
        my $subkey = random_key $href->{$key};
        $ret .= $subkey;
        $key = $subkey;
        $num--;
    }

    return $ret;
}

sub word_based {
    my $sentencesref = get_sentences();
    handle_sentences($sentencesref);

    # TODO: parameterize this stuff:
    #dump_map(\%map);
    $out = make_sentences(\%map, 300);
    print "$out\n";
}

my $savebuf = "";
sub handle_buffer {
    my $buf = shift;
    my $workbuf = $savebuf . $buf;
    my $len = length $workbuf;

    for (my $ct = 0; $ct < $len; $ct++) {
        my $prefix = substr $workbuf, $ct, $depth;
        my $suffix = substr $workbuf, $ct + $depth, $depth;

        $map{$prefix}{$suffix} += 1;
    }

    #$char_index = substr($text, $i, $look_forward);
    #$char_count = substr($text, $i+$look_forward, $look_forward);
    #substr EXPR, OFFSET, LEN

    $savebuf = substr $buf, -$depth;
}

sub character_based {
    my $max = 5;
    my $ct = 0;
    my $buf = "";

    while (my $line = <>) {
        chomp($line);
        $line = cleanse_line $line;
        $buf .= $line;
        $ct++;
        if ($ct >= $max) {
            handle_buffer($buf);
            $ct = 0;
            $buf = "";
        }
    }

    handle_buffer($buf);
#    dump_map(\%map);
    $out = make_sentences_char(\%map, 300);
    print "$out\n";
}

#word_based;
character_based;
