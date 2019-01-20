#!/usr/bin/perl

=head1 NAME

remmy.pl - A script to convert reminder type files into iCalendar format

=head1 SYNOPSIS

remmy.pl < reminderfile > icsfile

=head1 DESCRIPTION

This single Perl script convert reminders as used by Dianne Skoll's powerful command line program B<remind> to the iCalendar format (B<.ics>). iCalendar is a widely accepted standard for calendar entries and can be read by popular application like Microsoft's Outlook, Apple's iCal or Google Calendar. I<remmy.pl> parses I<remind>s input file and tries to adopt many of the sophisticated rules for reminders as implemented in I<remind>.

While B<remmy> is build upon the specification of the RFC2445, full compliance cannot be ensured.

=head1 OPTIONS

not in use

=head1 DEPENDENCIES

Perl UUID::Tiny E<10> E<8>Perl DateTime


=head1 COMPATIBILITIES AND LIMITATIONS

The man page of I<remind> lists several examples using the REM command. Currently, B<remmy> supports examples 1 to 18 as given in subsection INTERPRETATION OF DATE SPECIFICATIONS. The output of B<remmy> has been successfully tested with MS Outlook 2003 and Apple iCal 4.0.

B<remmy> supports the local time. It is planned to switch to UTC calendar specification in a future version.

The rule "weekday and day" present is limited in a way that there are no "jumps" to the following month if the next weekday is in the next month. This leads to the functionality that the specified day clusters the rule into the 4 weeks of a month, meaning the rule will always be the 1st, 2nd, 3rd or 4th weekday of every month.

=head1 BUGS

Please report bugs to the author or improve the code by yourself and share the
changes. You are encouraged to test B<remmy>s output with your preferred calendar application.

=head1 HOMEPAGE

L<https://github.com/smartmic/remmy.git>

=head1 LICENSE

Copyright (c) 2012 by Martin Michel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

=head1 REFERENCES

The I<remind> manual.

The I<RFC2445> specification.

Mark Atwood has written a similar programm which uses the output of the I<remind -s> command. See L<rem2ics>.

=head1 SEE ALSO

L<remind>, L<rem2ics>

=cut

use strict;
use warnings;
use UUID::Tiny ':std';
use DateTime;
use POSIX;

my $corpname = "acme";
my $scriptname = "remmy";
my $scriptversion = 0.1;

my @userinput = <STDIN>;
my $lineno=1;

&create_start;

foreach my $line (@userinput) {
    #  Checking the input for valid Reminders
    unless (($line =~ /^REM\s.+\sMSG/) 
    || ($line =~ /^REM\s.+\s[AT|UNTIL|DURATION]\s.+\sMSG/)
    || ($line =~ /^REM\s.+\sAT\s.+\s[UNTIL|DURATION]\s.+\sMSG/))
    {
        #print "\nNo valid reminder.\n";
    }
    # --- END Checking the input for valid Reminders

    #  Extracting the information
    else {
        &static_hdr;
        my @values = split(/REM|AT|DURATION|UNTIL|MSG/, $userinput[$lineno-1]);
        my $fields = scalar (@values); 
        
        #  Field 1 after "REM" will always be parsed for date information...
        my ($y,@mo,$dy,$delta); # month variable can be variable also
        my @rfcdays = qw(SU MO TU WE TH FR SA);
        my ($sec,$min,$hour,$today,$month,$yr19,@rest) = localtime(time);
        my $day;
        #my $utc_off = (int `date +%z`)/100;
        my @weekdays = qw(Sun Mon Tue Wed Thu Fri Sat);
        my $dint = 0;
        my $addweek;
        my $backflag = "";

        foreach my $val ($values[1] =~ m/ (\d+)/g) {
            if ($val ~~ [1..31]) {	
                $dy = $val;
                if ($values[1] =~ m/$val\s\+(\d+)/) {
                    $delta = $1; 
                    print "BEGIN:VALARM\n";
                    $delta = (int $1)*1440;
                    printf qq{TRIGGER:-PT%dM\n},$delta;
                    print "ACTION:DISPLAY\n"
                    . "DESCRIPTION:Reminder\n"
                    . "END:VALARM\n";
                }
                if ($values[1] =~ m/$val\s-(\d+)/) {
                    $backflag = "-";
                }
            }
            if ($val ~~ [1990..2075]) {	
                $y = $val;
                my $yrule_1 = "BYDAY=" . join(',',@rfcdays);
                #print "$yrule_1\n";
            }
        }
        

        my @months = qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
        my $mint = 0;
        my @morule_1 = "BYMONTH=";
        foreach my $month (@months) {
            $mint++;
            if ($values[1] =~ /$month/i) {
                push (@mo,$mint);
                push(@morule_1,"$mo[0],");
                #last;
            }
        }
        
        my @wrule_1 = "BYDAY=";
        my ($fdflag,$numwk,$dy_org);	
        my @wkpos;
        foreach my $day (@weekdays) {
            if ($values[1] =~ /$day/i) {
                if (($dint - $today) < 0) {$addweek = 7;}
                else {$addweek = 0;}
                
                my $daydiff = $dint - $today + $addweek;
                my @nextday =  localtime(time + (86400 * $daydiff));
                if (!defined $fdflag && !defined $dy && !defined $mo[0] &&
                !defined $y) {
                    ($dy,$mo[0],$y) = @nextday[3..5]; 
                    $y = $y+1900;
                    $mo[0]++;
                }
                #last;
                $fdflag = 1;
                if (defined $dy) {
                    #$numwk = ($dy,4)[$dy > 4];
                    if ($dy <= 7) { $numwk = 1 };
                    if ($dy > 7 and $dy <= 14) { $numwk = 2; }
                    if ($dy > 14 and $dy <= 21) { $numwk = 3; }
                    if ($dy > 21) { $numwk = 4; }
                    push(@wrule_1,"+$numwk");
                }
                push (@wkpos, $dint);
                push(@wrule_1,"$rfcdays[$dint],");
            }
            $dint++;
        }

        if (!defined $dy && !defined $day) { 
            my $dyrule = "RRULE:FREQ=DAILY;INTERVAL=1;";
            if (defined $y) {	
                my $lastmonth;
                if (!defined $mo[0]) {$mo[0]=1;$lastmonth=12;} else {$lastmonth = $mo[0];}
                $dyrule = $dyrule.sprintf("UNTIL=%04d%02d%02d",
                    $y,$lastmonth,&monthdays($y,$lastmonth));
            }
            elsif (defined $mo[0]) {
                $dyrule = $dyrule.join("",@morule_1);
                chop($dyrule);
            }
            print $dyrule."\n";
        }

        
        if (!defined $mo[0] && defined $dy) { 
            my $morule = "RRULE:FREQ=MONTHLY;INTERVAL=1;BYMONTHDAY=$backflag$dy;";
            if (defined $addweek) {
                my @a = split(/BYMONTHDAY/,$morule);
                $morule = $a[0].join("",@wrule_1);
            }
            chop($morule);
            print $morule."\n";
        }
        elsif (!defined $y && !defined $addweek) { 
            my $yrule = "RRULE:FREQ=YEARLY;INTERVAL=1;BYMONTHDAY=$dy;"; 
            $yrule = $yrule.join("",@morule_1);
            chop($yrule);
            print $yrule."\n";
        }
       
        my $wkrule;
        if (defined $addweek && !defined $dy) {
            $wkrule = "RRULE:FREQ=WEEKLY;WKST=SU;";
            $wkrule = $wkrule.join("",@wrule_1);
            if (defined $mo[0])  {
                chop($wkrule);
                $wkrule = $wkrule.";".join("",@morule_1);
            }
            if (!defined $mo[0] and defined $y) {
                chop($wkrule);
                $wkrule = $wkrule.";UNTIL=$y"."1231";
                $mo[0] = 1;
            }
            print $wkrule."\n";
        }

        unless (defined $dy) {$dy=1;}

        unless (defined $y) {
            $y = $yr19+1900;
            if (defined $mo[0] && $mo[0]<$month+1){$y++;}    
            if (defined $mo[0] && $mo[0]==2 && $dy==29) {
                while (&leapyear ($y) == 365) {$y++;}
            }
        }
        
        unless (defined $mo[0]) {
            $mo[0] = $month+1;
            while (&monthdays($y,$mo[0]) < $dy) {$mo[0]++;}
        }

        if (defined $wkrule) {

            # DateTime uses different counting than RFC/remmy for Sunday:
            if ($wkpos[0] == 0) {$wkpos[0] = 7;}

            ($y,$mo[0],$dy) = &finddate($y,$mo[0],$dy,$wkpos[0]);
        }

        # --- END Field 1 after "REM" will always be parsed for date information...
       

        my $dtstart = sprintf("DTSTART:%04d%02d%02d",$y,$mo[0],$dy);
        my $dtend = sprintf("DTEND:%04d%02d%02d",$y,$mo[0],$dy);

        #  Field after AT is scanned for time specifications...
        my $h = 0;my $m = 0;my $s = 0;

        unless ($userinput[$lineno-1] =~ /AT/) {}
        else {
            my @mytime = ($line =~ /AT\s+(\d+):(\d+)\s+?\+?(\d+)?/);
            $h = $mytime[0];
            $m = $mytime[1];
            $s = 0;
            if (defined $mytime[2]) {
                print "BEGIN:VALARM\n";
                printf qq{TRIGGER:-PT%dM\n},$mytime[2];
                print "ACTION:DISPLAY\n"
                . "DESCRIPTION:Reminder\n"
                . "END:VALARM\n";

            }
            $dtstart = $dtstart.sprintf("T%02d%02d%02d",$h,$m,$s);
            $dtend = $dtend.sprintf("T%02d%02d%02d",$h,$m,$s);
        }
        
        # --- END Field after AT is scanned for time specifications...
        
        print $dtstart."\n";
        print $dtend."\n";
        #printf qq{DTSTART:%04d%02d%02dT%02d%02d%02d\n}, $y,$mo[0],$dy,$h,$m,$s;
        # Note that year and month has been corrected in the expression above...
        #printf qq{DTEND:%04d%02d%02dT%02d%02d%02d\n}, $y,$mo[0],$dy,$h,$m,$s;
        
        #  Last field after MSG is scanned for messages

        unless ($line =~ /MSG/) {print "SUMMARY:\n";}
        else {
            if ($values[-1] =~ /%"(.+?)%"/) {print"SUMMARY:$1\n";}
        }

        my $content = $values[-1];
        $content =~ s/%.//g;
        print "SUMMARY:$content";
        print "DESCRIPTION:$content";
        # --- END Last field after MSG is scanned for messages

        #  Timestamp for entry
        printf qq{DTSTAMP:%04d%02d%02dT%02d%02d%02d\n}, $yr19+=1900,$month+=1,$today,$hour,$min,$sec;
        # --- END Timestamp for entry

        print "END:VEVENT\n";
                
    }
    # --- END Extracting the information

    $lineno++;
}

&create_end;

# --- START Functions
#
sub create_start {
    print "BEGIN:VCALENDAR\n"
    . "VERSION:2.0\n"
    . "PRODID:-//$corpname//NONSGML $scriptname v$scriptversion\n"
    . "METHOD:PUBLISH\n";
}

sub create_end {
    print "\nEND:VCALENDAR\n";
}

sub static_hdr {
	print "\nBEGIN:VEVENT\n";
	
	#  Organizer entry
	my $idname =  `id -nu`;
	my $hostname = `uname -n`;
	my $address = join('@',$idname,$hostname);
	$address =~ s/\n//g;
	print "ORGANIZER:MAILTO:$address\n";	
	# --- END Organizer entry
	
	#  UUID Generation 
	my $uuid = uc(create_uuid_as_string(UUID_V1));
	#$uuid =~ s/\n//g;
	print "UID:$uuid\n";
	# --- END UUID Generation 
	
	print "LOCATION:see description\n"
	. "CLASS:PUBLIC\n";
}

sub leapyear {
    my $tage;
	if ( $_[0] % 400 == 0 || ( $_[0] % 4 == 0 && $_[0] % 100 != 0 ) ) {$tage=366;}
      	else {$tage=365;}
    return $tage;
}

sub monthdays {
	my ($tage,$mtage);
    $tage = &leapyear($_[0]);
    if ( $_[1] == 2 ) {
		if ( $tage == 365 ) {$mtage=28;} else {$mtage=29;}
      	}
	elsif ( $_[1] == 4 || $_[1] == 6 || $_[1] == 9 || $_[1] == 11 ) {$mtage=30;}
	else {$mtage=31;}
	return $mtage;
}

sub finddate {
    my $dt = DateTime->new(
        year    => $_[0],
        month   => $_[1],
        day     => $_[2],
    );
    my $dur = DateTime::Duration->new(
        days     => 1,
    );

    while ($dt->day_of_week != $_[3]) {
        $dt = $dt + $dur;
    }
    return ($dt->year, $dt->month, $dt->day);
}


# --- END Functions
