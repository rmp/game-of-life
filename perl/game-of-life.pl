#!/usr/local/bin/perl
# -*- mode: cperl; tab-width: 8; indent-tabs-mode: nil; basic-offset: 2 -*-
# vim:ts=8:sw=2:et:sta:sts=2
#########
# Author:        rmp
# Created:       2012-10-12
# Last Modified: $Date: 2012-10-12 19:09:00 +0100 (Fri, 12 Oct 2012) $
# Id:            $Id$
# $HeadURL$
#
use strict;
use warnings;
use Time::HiRes qw(sleep);
use Readonly;
use English qw(-no_match_vars);
use Carp;

Readonly::Scalar my $WIDTH      => 78;
Readonly::Scalar my $HEIGHT     => 21;
Readonly::Scalar my $TURN_DELAY => 0.1;

our $VERSION = '0.01';

my $grid  = init();
my $turns = 0;
while(1) {
  render($grid);
  $grid = turn($grid);
  sleep $TURN_DELAY;
  $turns++;
}

sub init {
  #########
  # initialise with a manual input from the DATA block below
  #
  local $RS = undef;
  my $data  = <data>;
  my $out   = [
	       map { [split //smx, $_] }
	       map { split /\n/smx, $_ }
	       $data
	      ];

  #########
  # fill the matrix with space
  #
  for my $y (0..$HEIGHT-1) {
    for my $x (0..$WIDTH-1) {
      $out->[$y]->[$x] ||= 0;
      $out->[$y]->[$x] = rand >= 0.2 ? 0 : 1; # initialise with some random data
    }
  }
  return $out;
}

#########
# draw to stdout/screen
#
sub render {
  my ($in) = @_;
  system $OSNAME eq 'MSWin32' ? 'cls' : 'clear';

  print q[+], q[-]x$WIDTH, "+\n" or croak qq[Error printing: $ERRNO];
  for my $y (@{$in}) {
    print q[|] or croak qq[Error printing: $ERRNO];
    print map { $_ ? q[O] : q[ ] } @{$y} or croak qq[Error printing: $ERRNO];
    print "|\r\n" or croak qq[Error printing: $ERRNO];
  }
  print q[+], q[-]x$WIDTH, "+\n" or croak qq[Error printing: $ERRNO];

  return 1;
}

#########
# the fundamental Game of Life rules
#
sub turn {
  my ($in) = @_;
  my $out  = [];

  for my $y (0..$HEIGHT-1) {
    for my $x (0..$WIDTH-1) {
      my $topedge    = $y-1;
      my $bottomedge = $y+1;
      my $leftedge   = $x-1;
      my $rightedge  = $x+1;

      my $checks = [
		    grep { $_->[0] >= 0 && $_->[0] < $HEIGHT } # Y boundary checking
		    grep { $_->[1] >= 0 && $_->[1] < $WIDTH }  # X boundary checking
		    [$topedge,    $leftedge],
		    [$topedge,    $x],
		    [$topedge,    $rightedge],
		    [$y,          $leftedge],
		    [$y,          $rightedge],
		    [$bottomedge, $leftedge],
		    [$bottomedge, $x],
		    [$bottomedge, $rightedge],
		   ];

      my $alive = scalar
	          grep { $_ }
	          map { $in->[$_->[0]]->[$_->[1]] }
		  @{$checks};

      $out->[$y]->[$x] = (($in->[$y]->[$x] && $alive == 2) ||
			  $alive == 3);
    }
  }
  return $out;
}

__DATA__
0000000010
0000000111
0000000101
0000000111
0000000010

