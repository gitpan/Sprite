#!/usr/local/bin/perl5

##++
##    Sprite v3.1
##    Last modified: June 18, 1996
##
##    Copyright (c) 1995, 1996
##    Shishir Gundavaram and O'Reilly & Associates
##    All Rights Reserved
##
##    E-Mail: shishir@ora.com
##
##    Permission to use, copy, modify and distribute is hereby granted,
##    providing  that  no charges are involved and the above  copyright
##    notice and this permission appear in all copies and in supporting
##    documentation. Requests for other distribution  rights, including
##    incorporation in commercial  products,  such as  books,  magazine
##    articles, or CD-ROMS should be made to the authors.
##
##    This  program  is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY;  without  even  the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
##--

#############################################################################

=head1 NAME

Sprite - Perl 5.0 module to manipulate text delimited databases.

=head1 SYNOPSIS

    use Sprite;

    $rdb = new Sprite ();

    $rdb->set_delimiter ("Read", "::");
    $rdb->set_delimiter ("Write", "::");

    $rdb->set_os ("UNIX");

    $rdb->sql (<<Query);
        .
        .
        .
    Query

    $rdb->close ();
    $rdb->close ($database);

=head1 DESCRIPTION

Here is a simple database where the fields are delimted by commas:

    Player,Years,Points,Rebounds,Assists,Championships
    ...                                                         
    Larry Joe Bird,12,28,10,7,3
    Michael Jordan,10,33,6,5,3
    Earvin Magic Johnson,12,22,7,12,5
    ...

I<Note:> The first line must contain the field names (case sensitive).

=head1 Supported SQL Commands

Here are a list of the SQL commands that are supported by Sprite:

=over 5

=item I<select> - retrieves records that match specified criteria:

    select col1 [,col2] from database 
        where (cond1 OPERATOR value1) 
        [and|or cond2 OPERATOR value2 ...] 

The '*' operator can be used to select all columns.

The I<database> is simply the file that contains the data. 
If the file is not in the current directory, the path must 
be specified. 

Sprite does I<not> support multiple tables (or commonly knows
as "joins").

Valid column names can be used where [cond1..n] and 
[value1..n] are expected, such as: 

I<Example 1>:

    select Player, Points from my_db
        where (Rebounds > Assists) 

The following SQL operators can be used: =, <, >, <=, >=, <> 
as well as Perl's special operators: =~ and !~. The =~ and !~ 
operators are used to specify regular expressions, such as: 

I<Example 2>:

    select * from my_db
        where (Name =~ /Bird$/i) 

Selects records where the Name column ends with 
"Bird" (case insensitive). For more information, look at 
a manual on regexps. 

=item I<update> - updates records that match specified criteria. 

    update database set (cond1 OPERATOR value1)[,(cond2 OPERATOR value2)...]*
       where (cond1 OPERATOR value1)
       [and|or cond2 OPERATOR value2 ...] 

    * = This feature was added as of version 3.1.

I<Example>:

    update my_db 
	set Championships = (Championships + 1) 
        where (Player = 'Larry Joe Bird') 

   update my_db
        set Championships = (Championships + 1),
	    Years = (12)

        where (Player = 'Larry Joe Bird')

=item I<delete> - removes records that match specified criteria:

    delete from database 
        where (cond1 OPERATOR value1) 
        [and|or cond2 OPERATOR value2 ...] 

I<Example>:

    delete from my_db
        where (Player =~ /Johnson$/i) or
              (Years > 12) 

=item I<alter> - simplified version of SQL-92 counterpart

Removes the specified column from the database. The 
other standard SQL functions for alter table are not 
supported:

    alter table database 
        drop column column-name 

I<Example>:

    alter table my_db 
        drop column Championships 

=item I<insert> - inserts a record into the database:

    insert into database 
        (col1, col2, ... coln) 
    values 
        (val1, val2, ... valn) 

I<Example>:

    insert into my_db 
        (Player, Years, Points, Championships) 
    values 
        ('Kareem Abdul-Jabbar', 21, 27, 5) 

I<Note:> You do not have to specify all of the fields in the 
database! Sprite also does not require you to specify 
the fields in the same order as that of the database. 

I<Note:> You should make it a habit to quote strings. 

=back

=head1 METHODS

Here are the four methods that are available:

=over 5

=item I<set_delimiter>

The set_delimiter function sets the read and write delimiter 
for the the SQL command. The delimiter is not limited to
one character; you can have a string, and even a regexp (for reading only).

I<Return Value>

None

=item I<set_os>

The set_os function can be used to notify Sprite as to the
operating system that you're using. Valid arguments are:
"UNIX", "VMS", "MSDOS", "NT" and "MacOS". UNIX is the default.

I<Return Value>

The previous OS value

=item I<sql>

The sql function is used to pass a SQL command to this module. All 
of the SQL commands described above are supported. The I<select> SQL 
command returns an array containing the data, where the first element
is the status. All of the other other SQL commands simply return a status.

I<Return Value>
    1 - Success
    0 - Error

=item I<close>

The close function closes the file, and destroys the database object. 
You can pass a filename to the function, in which case Sprite will 
save the database to that file. 

I<Return Value>

None

=back

=head1 EXAMPLES

Here are two simple examples that illustrate some of the functions of this
module:

=head2 I<Example 1>

    #!/usr/local/bin/perl5 

    use Sprite; 

    $rdb = new Sprite (); 

    # Sets the read delimiter to a comma (,) character. The delimiter
    # is not limited to one character; you can have a string, or even
    # a regexp.

    $rdb->set_delimiter ("Read", ","); 

    # Retrieves all records that match the criteria.

    @data = $rdb->sql (<<End_of_Query);

        select * from /shishir/nba
            where (Points > 25) 

    End_of_Query

    # Close the database and destroy the database object (i.e $rdb).
    # Since we did not pass a argument to this function, the data
    # is not updated in any manner.

    $rdb->close (); 

    # The first element of the array indicates the status.

    $status = shift (@data);
    $no_records = scalar (@data);

    if (!$status) {
	die "Sprite database error. Check your query!", "\n";
    } elsif (!$no_records) {
	print "There are no records that match your criteria!", "\n";
	exit (0);
    } else {
        print "Here are the records that match your criteria: ", "\n";

        # The database returns a record where each field is
        # separated by the "\0" character.

    	foreach $record (@data) { 
            $record =~ s/\0/,/g;
            print $record, "\n";
        }
    } 

=head2 I<Example 2>

    #!/usr/local/bin/perl5 

    use Sprite; 

    $rdb = new Sprite (); 
    $rdb->set_delimiter ("Read", ","); 

    # Deletes all records that match the specified criteria. If the
    # query contains an error, Sprite returns a status of 1.

    $rdb->sql (<<Delete_Query) 
		|| die "Database Error. Check your query", "\n";

        delete from /shishir/nba
            where (Rebounds <= 5) 

    Delete_Query

    # Access the database again! This time, select all the records that
    # match the specified criteria. The database is updated *internally*
    # after the previous delete statement.

    # Notice the fact that the full path to the database does not
    # need to specified after the first SQL command. This
    # works correctly as of version 3.1.

    @data = $rdb->sql (<<End_of_Query);

        select Player from nba
            where (Points > 25)

    End_of_Query

    # Sets the write delimiter to the (:) character, and outputs the
    # updated information to the file: "nba.new". If you do not pass
    # an argument to the close function after you update the database,
    # the modified information will not be saved.

    $rdb->set_delimiter ("Write", ":"); 
    $rdb->close ("nba.new"); 

    # The first element of the array indicates the status.

    $status = shift (@data);
    $no_records = scalar (@data);

    if (!$status) {
	die "Sprite database error. Check your query!", "\n";
    } elsif (!$no_records) {
	print "There are no records that match your criteria!", "\n";
	exit (0);
    } else {
        print "Here are the records that match your criteria: ", "\n";

        # The database returns a record where each field is
        # separated by the "\0" character.

    	foreach $record (@data) { 
            $record =~ s/\0/,/g;
            print $record, "\n";
        }
    } 

=head1 ADVANTAGES

Here are the advantages of Sprite over mSQL by David Hughes available on
the Net: 

Allows for column names to be specified in the update command:

Perl's Regular Expressions allows for powerful pattern matching

The database is stored as text. Very Important! Information
can be added/modified/removed with a text editor.

Can add/delete columns quickly and easily

=head1 DISADVANTAGES

Here are the disadvantages of Sprite compared to mSQL: 

I<Speed>. No where close to mSQL! Sprite was designed to be 
used to manipulate very small databases (~1000-2000 records).

Does not have the ability to "join" multiple tables (databases) 
during a search operation. This will be added soon! 

=head1 RESTRICTIONS

=over 5

=item 1

If a value for a field contains the comma (,) character or the field 
delimiter, then you need to quote the value. Here is an example:

    insert into $database
    (One, Two)
    values
    ('$some_value', $two)

The information in the variable $some_value I<might> contain
the delimiter, so it is quoted -- you can use either the single
quote (') or the double quote (").

=item 2

All single quotes and double quotes within a value must be escaped.
Looking back at the previous example, if you think the variable
$some_value contains quotes, do the following:

    $some_value =~ s/(['"])/\\$1/g;

=item 3

If a field's value contains a newline character, you need to convert
the newline to some other character (or string):

    $some_value =~ s/\n/<BR>/g;

=item 4

If you want to search a field by using a regular expression:

    select * from $database
        where (Player =~ /Bird/i)

the only delimiter you are allowed is the standard one (i.e I</../>).
You I<cannot> use any other delimeter:

    select * from $database
        where (Player =~ m|Bird|i)

=item 5

Field names can only be made up of the following characters:

    "A-Z", "a-z", and "_"

In other words,
    
    [A-Za-z_]

=item 6

If your update value contains parentheses, you need to escape
them:

   $rdb->sql (<<End_of_Query);

    update my_db
        set Phone = ('\\(111\\) 222 3333')
        where (Name = /Gundavaram\$/i)

   End_of_Query

Notice how the "$" (matches end of line) is escaped as well!

=back

=head1 SEE ALSO

RDB (available at the Metronet Perl archive)

=head1 REVISION HISTORY

=over 5

=item v3.1 - June 18, 1996

Added the following features:

=over 3

=item *

As of this version, Sprite allows you to update multiple fields with a 
single I<update> command. See the I<Supported SQL Commands> section above.

=item * 

You can execute your scripts with the following:

	#!/usr/local/bin/perl5 -wT

	use strict;

Sprite no longer generates the "Use of uninitialized value..."
errors.

=item *

For records that don't contain quotes or escaped strings, Perl's
split is used to dramatically speed up database loading.

=item *

The I<set_os> function will allow you to set the operating system
that you're using. 

=item *

Added a "require 5.002" as Sprite fails on versions of Perl older
than 5.002 with the following error:
 
    "Bad free() ignored at Sprite.pm..."

=back

Fixed the following bugs:

=over 3

=item *

If you call the I<close> method with a database as an argument 
I<without> opening a database first, Sprite will warn you as
opposed to wiping out the database, as was the case in earlier
versions of Sprite.

=item *

Sprite no longer chops off the trailing "0" on records.

=item *

The I<drop column> works as it should.

=item *

You can safely escape parentheses in the I<update> command.

=item *

Extra spaces between field names in the I<select> command and
values in the I<update> command no longer cause fatal errors. 

=item *

In earlier versions of Sprite, if you opened two databases
that were located in different directories, I<but> with the
same name, Sprite incorrectly assumed that it was the same database.
As a result, the second database would never be loaded.

=item *

Can be used on the Mac OS and Windows NT.

=back

=item v3.01 - March 5, 1996

Fixed a bug in I<parse_expression> subroutine so that it recognizes
the "_" character as valid in field names.

=item v3.0 - Febraury 20, 1996

Totally re-wrote parser; works reasonably well even in the worst case
scenarios.

=item v2.0 - November 23, 1995

Fixed *numerous* errors in parsing, and added pod style documentation.

=item v1.5 - September 10, 1995

Created Perl 5 module instead of a command-line interface.

=item v1.0 - September 7, 1995

Initial Release

=back

=head1 ACKNOWLEDGEMENTS

I would like to thank the following for finding bugs and offering
suggestions:

=over 5

=item Dave Moore (dmoore@videoactv.com)

=item Shane Hutchins (hutchins@ctron.com)

=item Josh Hochman (josh@bcdinc.com)

=item Barry Harrison (barryh@topnet.net)

=item Lisa Farley (lfarley@segue.com)

=item Loyd Gore (lgore@ascd.org)

=item Tanju Cataltepe (tanju@netlabs.net)

=back

=head1 COPYRIGHT INFORMATION

                         Copyright (c) 1995, 1996
               Shishir Gundavaram and O' Reilly & Associates
                            All Rights Reserved

    Permission to use, copy, modify and distribute is hereby granted,
    providing  that  no charges are involved and the above  copyright
    notice and this permission appear in all copies and in supporting
    documentation. Requests for other distribution  rights, including
    incorporation in commercial  products,  such as  books,  magazine
    articles, or CD-ROMS should be made to the authors.

    This  program  is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY;  without  even  the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

###############################################################################

package Sprite;

require 5.002;

use File::Basename;
use Cwd;

##++
##  Global Variables
##--

$Sprite::exclusive_lock = 2;
$Sprite::unlock         = 8;

##++
##  Public Methods and Constructor
##--

sub new
{
    my $self = {};

    bless $self;
    $self->initialize ();

    return ($self);
}

sub initialize
{
    my $self = shift;

    $$self{DB_commands} = '^(select|update|delete|alter|insert)';

    $$self{DB_table} = "";
    $$self{DB_file}  = "";

    $self->define_errors ();
    $self->set_delimiter ();

    return (1);
}

sub set_delimiter
{
    my ($self, $type, $delimiter) = @_;

    $type = "other" unless ($type);

    $type =~ tr/A-Z/a-z/;

    if ($type eq "read") {
	$$self{DB_read} = $delimiter;
    } elsif ($type eq "write") {
	$$self{DB_write} = $delimiter;
    } else {
	$$self{DB_read} = $$self{DB_write} = ",";
    }

    return (1);
}

sub set_os
{
    my ($self, $os) = shift;
    my $return_value;

    $os = "UNIX"  unless ($os);
    $os = "MSDOS" if ($os eq "NT");

    $return_value = fileparse_set_fstype ($os);

    return ($return_value);
}

sub sql
{
    my ($self, $sql_query) = @_;
    my ($command, $sql_status);

    $sql_query =~ s/\n/ /g;
    $sql_query =~ s/^\s*(.*?)\s*$/$1/;

    if ($sql_query =~ /^$$self{DB_commands}/io) {
	$command = $&;

	$sql_status = $self->$command ($sql_query);

	if (ref ($sql_status) eq "ARRAY") {
	    return 1, @{$sql_status};
	} else {
	    if ($sql_status <= 0) {
		$self->display_error ($sql_status);
		return (0);
	    } else {
		return (1);
	    }
	}
    } else {
	return (0);
    }
}

sub display_error
{	
    my ($self, $error) = @_;

    print STDERR $$self{DB_errors}->{$error}, "\n";
	
    return (1);
}

sub close
{
    my ($self, $file) = @_;
    my $status;

    $status = 1;

    if ($file) {
	$status = $self->write_file ($file);

	$self->display_error ($status) if ($status <= 0);
    }

    ##++
    ##  Destroy object!
    ##--

    undef %$self;

    return ($status);
}

##++
##  Private Methods
##--

sub define_errors
{
    my $self = shift;
    my $errors;

    $errors = {};

    $$errors{'-501'} = 'Could not open specified database.';
    $$errors{'-502'} = 'Specified column(s) not found.';
    $$errors{'-503'} = 'Incorrect format in [select] statement.';
    $$errors{'-504'} = 'Incorrect format in [update] statement.';
    $$errors{'-505'} = 'Incorrect format in [delete] statement.';
    $$errors{'-506'} = 'Incorrect format in [drop column] statement.';
    $$errors{'-507'} = 'Incorrect format in [alter table] statement.';
    $$errors{'-508'} = 'Incorrect format in [insert] command.';
    $$errors{'-509'} = 'The no. of columns does not match no. of values.';
    $$errors{'-510'} = 'A severe error! Check your query carefully.';
    $$errors{'-511'} = 'Cannot write the database to output file.';
    $$errors{'-512'} = 'Unmatched quote in expression.';
    $$errors{'-513'} = "Need to open the database first!";

    $$self{DB_errors} = $errors;

    return (1);
}

sub parse_expression
{
    my ($self, $query) = @_;

    ##++
    ##  Hack to remove "Use of uninitialized value..." warnings.
    ##--

    $query = "" unless ($query);

    ##++
    ##  The expression: "([^"\\]*(\\.[^"\\]*)*)" was provided by
    ##  Jeffrey Friedl. Thanks Jeffrey!
    ##--

    $query =~ s!"([^"\\]*(\\.[^"\\]*)*)"|                     # Double quotes
                '([^'\\]*(\\.[^'\\]*)*)'|                     # Single quotes
                (m{0,1})/([^/\\]*(\\.[^/\\]*)*)/(i{0,1})|     # Regexps
                ([A-Za-z_]+)|                                 # Fields
	        ([`;])                                        # Very Dangerous
               !                                       

        if     ($1)    { qq|"$1"|; } 
        elsif  ($3)    { qq|"$3"|; }
        elsif  ($6)    { "$5/$6/$8"; }
        elsif  ($9)    { if ( ($9 eq "and") || ($9 eq "or") ) { "$9"; } 
                         else { "\$\$_{$9}"; } }
        elsif  ($10)   { ""; } 

    !gex;

    $query =~ s/>=\s*(['"])/ ge $1/g;
    $query =~ s/<=\s*(['"])/ le $1/g;
    $query =~ s/=\s*(['"])/ eq $1/g;
    $query =~ s/<>\s*(['"])/ ne $1/g;
    $query =~ s/<\s*(['"])/ lt $1/g;
    $query =~ s/>\s*(['"])/ gt $1/g;

    $query =~ s/([^><!])=([^~])\s*/$1 == $2/g;
    $query =~ s/<>/ != /g;

    return ($query);
}

sub check_columns
{
    my ($self, $column) = @_;
    my (@split_columns, $check_status);

    $check_status = 1;
    @split_columns = split (/,\s*/, $column);

    foreach (@split_columns) {
	$check_status = 0 if ($$self{DB_fields} !~ /\b$_\b/);
    }

    return ($check_status);
}

sub parse_columns
{
    my ($self, $command, $columns, $condition, $values) = @_;
    my (@all_columns, $column, @temp_array, $parse_status, $temp_string);

    local $SIG{"__WARN__"} = sub { $parse_status = -510 };
    local $^W = 0;

    $parse_status = 1;
    $temp_string  = "";

    @all_columns = split(/,\s*/, $columns);

    foreach ( @{$$self{DB_records}} ) {
	if ( (!$condition) || (eval ($condition)) ) {
	    foreach $column (@all_columns) {
		if ($command eq "select") {
		    $temp_string = join ("\0", $temp_string, $$_{$column});
		} elsif ($command eq "update") {
		    $$_{$column} = eval ($$values{$column});
		} elsif ($command eq "drop") {
		    delete $$_{$column};
		    $$self{DB_fields} =~ s/(^|,)$column(,|$)/$1/;
		    $$self{DB_fields} =~ s/,$//;
                }
	    }

	    if ($command eq "select") {
	        $temp_string =~ s/^\0//;
		push @temp_array, $temp_string;
		$temp_string = "";
	    }
	}
    }

    if ( ($parse_status <= 0) || ($command ne "select") ) {
        return ($parse_status);
    } else {
	return (\@temp_array);
    }
}

sub check_for_reload
{
    my ($self, $file) = @_;
    my ($table, $reload_status, %ENV);

    $reload_status = 1;

    $table = basename ($file);
    $file  = join ("/", fastcwd, $file) if ($table eq $file);

    if ( ($$self{DB_table} ne $table) || ($$self{DB_file} ne $file) ) {
	stat ($file);

	if ( (-e _) && (-T _) && (-s _) && (-r _) ) {
	    if (defined ($$self{DB_records})) {
	        undef $$self{DB_records};
	    }

	    $$self{DB_records} = $self->load_database ($file);

	} else {
	    $reload_status = 0;
	}
    }

    return ($reload_status);
}

sub select
{
    my ($self, $query) = @_;
    my ($select_columns, $select_table, $select_condition,
	$values_or_error);

    if ($query =~ /^select\s+([\w\*, ]+)\s+from\s+([\w\-\/\.\:\\]+)/i) {
	$select_columns = $1;
	$select_table = $2;

	$self->check_for_reload ($select_table) || return (-501);

	$select_columns =~ s/\s//g;

	if ($select_columns eq '*') {
	    $select_columns = $$self{DB_fields};
	}

	$self->check_columns ($select_columns) || return (-502);

	if ($query =~ /\s+where\s+(.+)$/i) {
	    $select_condition = $self->parse_expression ($1);
	}

	$values_or_error = $self->parse_columns ("select", 
						 $select_columns,
						 $select_condition, undef);

	return ($values_or_error);
    } else {
	return (-503);
    }
}

sub update
{
    my ($self, $query) = @_;
    my ($update_table, $condition, %columns, $update_columns, 
	$update_value, $update_condition, $status);

    ##++
    ##  Hack to allow parenthesis to be escaped!
    ##--

    $query =~ s/\\([()])/sprintf ("%%\0%d", ord ($1))/ge;

    if ($query =~ /^update\s+([\w\-\/\.\:\\]+)\s+set\s+/ig) {
	$update_table = $1;

        while ($query =~ m|(\w+)\s*=\s*(\(.+?\))(\s*,\s*){0,1}|g) {
	    ($update_value = $2) =~ s/%\0(\d{2})/pack ("C", $1)/ge;
	    $update_value = $self->parse_expression ($update_value);

	    $columns{$1} = $update_value;
        }

	$update_columns = join (",", keys %columns);

	$self->check_for_reload ($update_table) || return (-501);
	$self->check_columns ($update_columns)  || return (-502);

	if ($query =~ /\s+where\s+(.+)$/i) {
	    ($condition = $1) =~ s/%\0(\d+)/pack ("C", $1)/ge;
	    $update_condition = $self->parse_expression ($condition);
	}

	$status = $self->parse_columns ("update", $update_columns, 
 					$update_condition, \%columns);

	return ($status);
    } else {
	return (-504);
    }
}

sub delete 
{
    my ($self, $query) = @_;
    my ($delete_table, $delete_condition, $status);

    if ($query =~ /^delete\s+from\s+([\w\-\/\.\:\\]+)\s+where\s+(.+)$/i) {
	$delete_table = $1;
	$delete_condition = $self->parse_expression ($2);

	$self->check_for_reload ($delete_table) || return (-501);

	$status = $self->delete_rows ($delete_condition);

	return ($status);
    } else {
	return (-505);
    }
}

sub delete_rows
{
    my ($self, $condition) = @_;
    my $delete_status;

    local $SIG{"__WARN__"} = sub { $delete_status = -510 };
    local $^W = 0;

    $delete_status = 1;

    foreach (@{$$self{DB_records}}) {
	undef %$_ if (eval ($condition));
    }

    return ($delete_status);
}

sub alter
{
    my ($self, $query) = @_;
    my ($alter_table, $alter_column, $status);

    if ($query =~ /^alter\s+table\s+([\w\-\/\.\:\\]+)\s+/i) {
	$alter_table = $1;

	if ($query =~ /\s+drop\s+column\s+(\w+)$/i) {
	    $alter_column = $1;

	    $self->check_for_reload ($alter_table) || return (-501);
	    $self->check_columns ($alter_column)   || return (-502);
					
	    $status = $self->parse_columns ("drop", $alter_column, 
					    undef, undef);

	    return ($status);
	} else {
	    return (-506);
	}
    } else {
	return (-507);
    }
}

sub insert
{
    my ($self, $query) = @_;
    my ($insert_table, $insert_columns, $insert_values, $status);

    if ($query =~ 
     /^insert\s+into\s+([\w\-\/\.\:\\]+)\s+\((.+?)\)\s+values\s+\((.+)\)$/i) {

	$insert_table = $1;
	$insert_columns = $2;
	$insert_values = $3;

	$insert_columns =~ s/\s//g;

	$self->check_for_reload ($insert_table) || return (-501);
	$self->check_columns ($insert_columns)  || return (-502);

	$status = $self->insert_data ($insert_columns, $insert_values);
					      
	return ($status);
    } else {
	return (-508);
    }
}

sub insert_data
{
    my ($self, $columns, $values) = @_;
    my (@split_columns, @split_values, $no_columns, $no_values, 
	$loop, $temp_hash);

    @split_columns = split (/,\s*/, $columns);
    @split_values  = $self->quotewords (',\s*', $values);

    $no_columns = $#split_columns;
    $no_values  = $#split_values;

    if ($no_columns == $no_values) {
        $temp_hash = {};

	for ($loop=0; $loop <= $no_columns; $loop++) {
	    $_ = $split_columns[$loop];

	    if ($$self{DB_fields} =~ /\b$_\b/) {
		$$temp_hash{$_} = $split_values[$loop];
	    }
	}

	push @{$$self{DB_records}}, $temp_hash;

	return (1);
    } else {
	return (-509);
    }
}						    

sub write_file
{
    my ($self, $new_file) = @_;
    my (@all_columns, $record, $column, $column_data, $temp_string, 
	$write_status);

    local $^W = 0;

    $write_status = (defined ($$self{DB_records})) ? 1 : -513;

    if (($write_status >= 1) && 
	(open (RDB_FILE, ">" . $new_file))) {

	flock (RDB_FILE, $Sprite::exclusive_lock);

	$$self{DB_fields} =~ s/,\s*/$$self{DB_write}/g;

	print RDB_FILE $$self{DB_fields}, "\n";

	@all_columns = split(/$$self{DB_write}/, $$self{DB_fields});

	foreach $record ( @{$$self{DB_records}} ) {
	    next unless (defined (%$record));

	    $temp_string = "";

	    foreach $column (@all_columns) {
		$column_data = $$record{$column};
		$column_data =~ s/(['"])/\\$1/g;

		if ($column_data =~ /($$self{DB_write})|(['"])/) {
			$column_data = qq|"$column_data"|;
		}
			
		$temp_string = join ($$self{DB_write}, 
				     $temp_string, $column_data);
						     
	    }

	    $temp_string =~ s/^$$self{DB_write}//;
	    print RDB_FILE $temp_string, "\n";
	}

	flock (RDB_FILE, $Sprite::unlock);
	close (RDB_FILE);
    } else {
	$write_status = ($write_status < 1) ? $write_status : -511;
    }

    return ($write_status);
}

sub load_database 
{
    my ($self, $file) = @_;
    my (@fields, @database, @record, $hash, $loop, $no_fields);

    open (RDB_FILE, "<" . $file);
    flock (RDB_FILE, $Sprite::exclusive_lock);

    $$self{DB_table} = basename ($file);
    $$self{DB_file}  = $file;

    $_ = <RDB_FILE>;
    s/^\s*(.*?)\s*$/$1/;

    @fields = split(/$$self{DB_read}/);
    $$self{DB_fields} = join (",", @fields);
    $no_fields = $#fields;

    @database = ();

    while (<RDB_FILE>) {
	s/^\s*(.*?)\s*$/$1/;
	next if (!$_);

	if (/['"\\]/) {
            @record = $self->quotewords ($$self{DB_read}, $_);
        } else {
            @record = split (/$$self{DB_read}/, $_);
        }

	$hash = {};

	for ($loop=0; $loop <= $no_fields; $loop++) {
	    $$hash{$fields[$loop]} = $record[$loop];
	}

	push @database, $hash;
    }
	
    flock (RDB_FILE, $Sprite::unlock);
    close (RDB_FILE);

    return (\@database);
}

##++
##  NOTE: Derived from lib/Text/ParseWords.pm. Thanks Hal!
##--

sub quotewords {
    my ($self, $delim, $line) = @_;
    my (@words, $snippet, $field);

    $_ = $line;

    while (length) {
	$field = '';

	for (;;) {

            $snippet = '';
	    if (s/^"([^"\\]*(\\.[^"\\]*)*)"//) {
		$snippet = $1;
	    } elsif (s/^'([^'\\]*(\\.[^'\\]*)*)'//) {
		$snippet = $1;
	    } elsif (/^["']/) {
		$self->display_error (-512);
		die;
	    } elsif (s/^\\(.)//) {
                $snippet = $1;
            } elsif (!length || s/^$delim//) {
	        last;
	    } else {
                while (length && !(/^$delim/ || /^['"\\]/)) {
		   $snippet .=  substr ($_, 0, 1);
                   substr ($_, 0, 1) = '';
                }
	    }

	    $field .= $snippet;
	}
        
        $field =~ s/\\(.)/$1/g;
	$field =~ s/^\s*(.*?)\s*$/$1/;

	push (@words, $field);
    }

    return (@words);
}


