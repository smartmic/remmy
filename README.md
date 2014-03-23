# NAME

remmy.pl - A script to convert reminder type files into iCalendar format

# SYNOPSIS

remmy.pl < reminderfile > icsfile

# DESCRIPTION

This single Perl script convert reminders as used by David Skoll's powerful command line program __remind__ to the iCalendar format (__.ics__). iCalendar is a widely accepted standard for calendar entries and can be read by popular application like Microsoft's Outlook, Apple's iCal or Google Calendar. _remmy.pl_ parses _remind_s input file and tries to adopt many of the sophisticated rules for reminders as implemented in _remind_.

While __remmy__ is build upon the specification of the RFC2445, full compliance cannot be ensured.

# OPTIONS

not in use

# DEPENDENCIES

Perl UUID::Tiny 
 Perl DateTime

# COMPATIBILITIES AND LIMITATIONS

The man page of _remind_ lists several examples using the REM command. Currently, __remmy__ supports examples 1 to 18 as given in subsection INTERPRETATION OF DATE SPECIFICATIONS. The output of __remmy__ has been successfully tested with MS Outlook 2003 and Apple iCal 4.0.

__remmy__ supports the local time. It is planned to switch to UTC calendar specification in a future version.

The rule "weekday and day" present is limited in a way that there are no "jumps" to the following month if the next weekday is in the next month. This leads to the functionality that the specified day clusters the rule into the 4 weeks of a month, meaning the rule will always be the 1st, 2nd, 3rd or 4th weekday of every month.

# BUGS

Please report bugs to the author or improve the code by yourself and share the
changes. You are encouraged to test __remmy__s output with your preferred calendar application.

# HOMEPAGE

[https://github.com/smartmic/remmy.git](https://github.com/smartmic/remmy.git)

# LICENSE

Copyright (c) 2012 by Martin Michel

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# REFERENCES

The _remind_ manual.

The _RFC2445_ specification.

Mark Atwood has written a similar programm which uses the output of the _remind -s_ command. See [rem2ics](https://metacpan.org/pod/rem2ics).

# SEE ALSO

[remind](https://metacpan.org/pod/remind), [rem2ics](https://metacpan.org/pod/rem2ics)
