#!/usr/local/bin/perl5.002 -wT

##++
##  Simple examples that retrieves data from test.db. You can find
##  more examples in the documentation -- Sprite.doc.
##
##  Shishir Gundavaram
##  June 18, 1996
##--

use Sprite;

$rdb = new Sprite;

##++
##  Set the delimiter. The default delimiter is ",".
##--

$rdb->set_delimiter ("Read", ",");

##++
##  This is not required as "UNIX" is the default.
##--

$rdb->set_os ("UNIX");

##++
##  Send the query to the database.
##--

@data = $rdb->sql (<<End_of_Query);

    select * from test.db 
    where (Years  >= 10) and 
          (Points >= 20) and
          (Championships >= 1)

End_of_Query

##++
##  Check the data returned by the database.
##--

$status = shift (@data);
$no_elements = scalar (@data);

if (!$status) {
    die "Sprite database error. Check your query!", "\n";
} elsif (!$no_elements) {
    print "There are no records that match your criteria!", "\n";
    exit (0);
} else {

    ##++
    ##  Shut off warnings temporarily.
    ##--

    local $^W = 0;

    ##++
    ##   Display the data.
    ##--

    write;

    foreach $record (@data)
    {
        ($player, $years, $points, $rebounds, $assists, $championships)
	    = split (/\0/, $record, 6);

        write;
    }

}

##++
##  Close the database
##--

$rdb->close;

exit (0);

##++
##  Define formats for display.
##--

format STDOUT_TOP = 
Player                    Years  Points  Rebounds  Assists  Championships
-------------------------------------------------------------------------
.

format STDOUT =
@<<<<<<<<<<<<<<<<<<<<<<<< @||||  @|||||  @|||||||  @||||||  @||||||||||||
$player,                  $years, $points, $rebounds, $assists, $championships
.
