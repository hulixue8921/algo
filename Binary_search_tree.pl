#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 1.pl
#
#        USAGE: ./1.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 08/23/2018 04:53:07 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

my $tree->{10} = 'data';
$tree->{left}  = undef;
$tree->{right} = undef;

sub tree_key {
    my $tree = shift;
    my $v;
    foreach my $key ( keys %{$tree} ) {
        unless ( $key eq 'left' or $key eq 'right' ) {
            $v = $key;
        }
    }
    return $v;
}

sub Insert {
    my $tree = shift;
    my $x    = shift;

    my $node->{$x} = 'data';
    $node->{left}  = undef;
    $node->{right} = undef;

    my $treekey = &tree_key($tree);

    if ( $x > $treekey ) {
        if ( $tree->{right} ) {
            &Insert( $tree->{right}, $x );
        }
        else {
            $tree->{right} = $node;
        }
    }
    else {
        if ( $tree->{left} ) {
            &Insert( $tree->{left}, $x );
        }
        else {
            $tree->{left} = $node;
        }
    }

}

sub travel {
    my $tree = shift;
    if ($tree) {
        say &tree_key($tree);
        &travel( $tree->{left} );
        &travel( $tree->{right} );
    }
}

####return list (node  parents  location)####
sub Search {
    my $tree = shift;
    my $x    = shift;
    my $p    = shift;
    my $L    = shift;

    my $t_key = &tree_key($tree);

    if ($tree) {
        if ( $x > $t_key ) {
            push @$p, $tree;
            push @$L, 'right';
            &Search( $tree->{right}, $x, $p, $L );
        }
        elsif ( $x < $t_key ) {
            push @$p, $tree;
            push @$L, 'left';
            &Search( $tree->{left}, $x, $p, $L );
        }
        elsif ( $x eq $t_key ) {
            return ( $tree, pop @{$p}, pop @{$L} );
        }

    }

}
###return ($node , $parents ) ###
sub Left_max {
    my $tree    = shift;
    my $num     = shift;
    my $parents = shift;

    if ($tree) {
        if ( $num eq 0 ) {
            push @$parents, $tree;
            &Left_max( $tree->{left}, 1, $parents );
        }
        else {
            push @$parents, $tree;
            &Left_max( $tree->{right}, 1, $parents );
        }
    }
    else {
        return ( pop @$parents, pop @$parents );
    }

}

###return ($node , $parents ) ###
sub Right_min {
    my $tree    = shift;
    my $num     = shift;
    my $parents = shift;

    if ($tree) {
        if ( $num eq 0 ) {
            push @$parents, $tree;
            &Right_min( $tree->{right}, 1, $parents );
        }
        else {
            push @$parents, $tree;
            &Right_min( $tree->{left}, 1, $parents );
        }
    }
    else {
        return ( pop @$parents, pop @$parents );
    }

}

sub Del {
    my $tree = shift;
    my $x    = shift;

    my ( $dnode, $dparents, $dlocation ) = &Search( $tree, $x, [], [] );


     if ( $dnode->{left} ) {
         my ( $lnode, $lparents ) = &Left_max( $dnode, 0, [] );
         if ( &tree_key($lparents) eq &tree_key($dnode) ) {
             $dparents->{$dlocation}=$lnode;
             $lnode->{right}=$dnode->{right};
         } else {
             $dparents->{$dlocation}=$lnode;
             $lparents->{right}=$lnode->{left};
             $lnode->{left}=$dnode->{left};
             $lnode->{right}=$dnode->{right};
         }


     } elsif ($dnode->{right}) {
         my ( $rnode, $rparents ) = &Right_min( $dnode, 0, [] );
         if ( &tree_key($rparents) eq &tree_key($dnode) ) {
             $dparents->{$dlocation}=$rnode;
             $rnode->{left}=$dnode->{left};
         } else {
             $dparents->{$dlocation}=$rnode;
             $rparents->{left}=$rnode->{right};
             $rnode->{right}=$dnode->{right};
             $rnode->{left}=$dnode->{left};
         }

     }else {
         $dparents->{$dlocation}=undef if $dlocation;
     }
    

}


&Insert( $tree, 11 );
&Insert( $tree, 8 );
&Insert( $tree, 5 );
&Insert( $tree, 9 );
&Insert( $tree, 10.5 );
&Insert( $tree, 15 );
&Insert( $tree, 4 );
&Insert( $tree, 7 );
&Del( $tree, 4 );
&Del( $tree, 7 );
&travel($tree);

=cut
my ($t)=&Search($tree , 29 ,[]);
my ($y)=&Left_max($t ,0);
say Dumper $y;
=cut
