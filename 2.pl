use strict;
use warnings;
use utf8;
my $log = 'access.log';
my @IPs;
open(my $fh, "<", $log) 
    or die "Can't open < $log!";
while (my $str = <$fh>)
{
	 if ($str =~ /^(\d+\.\d+\.\d+\.\d+)\s+([^\s])+\s+([^\s]+)\s+\[([^\s\]]+)\s+([^\s\]]+)\]\s+"(?:(GET|HEAD|POST)\s+)?([^"]+)"\s+(\d+)\s+\d+\s+"([^"]+)"\s+"([^"]+)"/) {
            push @IPs, {
                    "ip" => $1,
                    "blank" => $2,
                    "user" => $3,
                    "datetime" => $4,
                    "timezone" => $5,
                    "method" => $6,
                    "request" => $7,
                    "status" => $8,
                    "referer" => $9,
                    "user-agent" => $10,
                    "record" => $str,
                    "black" => 0		
                };
        }
}



foreach my $item (@IPs)
{
	if ($$item{'request'} =~ /^\/API/) 	{$$item{black}++;}
	if ($$item{'status'} == 400)	{$$item{black}++;}   
	if (index($$item{'request'}, "x0") != -1)	{$$item{black}++}
	if (index($$item{'user-agent'}, "Python") != -1)	{$$item{black}++;}
	if ($$item{'request'} =~ /^\/Ringing.at.your.dorbell!|API|\/phpmyadmin|testproxy.php/) {$$item{black}++;}
}

my $i = 0;
foreach my $j (sort {$b->{black} <=> $a->{black}} @IPs)
{
	print "$$j{black}, $$j{record} \n";
	$i++;
	if ($i>=50)
	{
		last;
	}
}