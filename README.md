# NAME

remmy.pl - A script to convert reminder type files into iCalendar format

# SYNOPSIS

    remmy.pl < reminderfile > icsfile

# DESCRIPTION

This single Perl script convert reminders as used by Dianne Skoll's powerful command line program **remind** to the iCalendar format (**.ics**). iCalendar is a widely accepted standard for calendar entries and can be read by popular application like Microsoft's Outlook, Apple's iCal or Google Calendar. *remmy.pl* parses *remind*s input file and tries to adopt many of the sophisticated rules for reminders as implemented in *remind*.

*remmy.pl* solely relies on Perl, an installation of *remind* is not necessary.

**Note** that this script is neither a replacement nor an improvement of *remind*, in fact, it handles only a very limited subset of *remind* specification for parsing reminder-type input files.

While *remmy* is build with reference to RFC2445, full compliance cannot be ensured.

# OPTIONS

not in use

# DEPENDENCIES

- Perl UUID::Tiny 
- Perl DateTime

# COMPATIBILITIES AND LIMITATIONS

The man page of *remind* lists several examples using the REM command.
Currently, **remmy** supports examples 1 to 18 as given in subsection
INTERPRETATION OF DATE SPECIFICATIONS. The output of **remmy** has been
successfully tested with MS Outlook 2003 and Apple iCal 4.0.

**remmy** supports the local time. It is planned to switch to UTC
calendar specification in a future version.

The rule "weekday and day" present is limited in a way that there are no
"jumps" to the following month if the next weekday is in the next month.
This leads to the functionality that the specified day clusters the rule
into the 4 weeks of a month, meaning the rule will always be the 1st,
2nd, 3rd or 4th weekday of every month.

# TESTS AND BUGS

Inspired from *remind*'s man page, some test cases have been defined in
the file `testreminders`. The output from *remmy* is in
`okreminders.ics`. Each calender event should work as specified and
expected. It was not tested with all calender application. 

A quick test for the output:

    diff -I ORGANIZER -I UID -I DTSTAMP okreminders.ics <(cat testreminders|./remmy.pl)

Please report bugs to the author or improve the code by yourself and
share the changes. You are encouraged to test **remmy**s output with
your preferred calendar application.

# HOMEPAGE

[https://github.com/smartmic/remmy.git](https://github.com/smartmic/remmy.git)

# LICENSE

Copyright (c) 2012 by Martin Michel

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# REFERENCES

The *remind* manual.

The *RFC2445* specification.

Mark Atwood has written a similar programm which uses the output of the
*remind -s* command. See [rem2ics](https://metacpan.org/pod/rem2ics).

# SEE ALSO

[remind](https://dianne.skoll.ca/projects/remind/), [rem2ics](https://metacpan.org/pod/rem2ics)
