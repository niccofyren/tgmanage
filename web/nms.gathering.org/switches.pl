#! /usr/bin/perl
# vim:ts=8:sw=8

use CGI qw(fatalsToBrowser);
use DBI;
use lib '../../include';
use nms;
use nms::web;
use strict;
use warnings;
use Data::Dumper;

$nms::web::cc{'max-age'} = "60";

my $q2 = $nms::web::dbh->prepare('select switch,sysname,placement,ip,switchtype,poll_frequency,community,last_updated from switches natural join placements');

$q2->execute();
while (my $ref = $q2->fetchrow_hashref()) {
	$ref->{'placement'} =~ /\((-?\d+),(-?\d+)\),\((-?\d+),(-?\d+)\)/;
	my ($x1, $y1, $x2, $y2) = ($1, $2, $3, $4);
	my $sysname = $ref->{'sysname'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'switchtype'} = $ref->{'switchtype'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'management'}{'ip'} = $ref->{'ip'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'management'}{'poll_frequency'} = $ref->{'poll_frequency'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'management'}{'community'} = $ref->{'community'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'management'}{'last_updated'} = $ref->{'last_updated'};
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'placement'}{'x'} = $x2;
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'placement'}{'y'} = $y2;
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'placement'}{'width'} = $x1 - $x2;
	$nms::web::json{'switches'}{$ref->{'sysname'}}{'placement'}{'height'} = $y1 - $y2;
}

my $q4 = $nms::web::dbh->prepare('select linknet, (select sysname from switches where switch = switch1) as sysname1, addr1, (select sysname from switches where switch = switch2) as sysname2,addr2 from linknets');
$q4->execute();
while (my $ref = $q4->fetchrow_hashref()) {
	$nms::web::json{'linknets'}{$ref->{'linknet'}} = $ref;
}

finalize_output();
