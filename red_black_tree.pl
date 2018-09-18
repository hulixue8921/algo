#!/usr/bin/env perl
#===============================================================================
#
#         FILE: red_black_tree.pl
#
#        USAGE: ./red_black_tree.pl
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
#      CREATED: 09/11/2018 02:44:41 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Data::Dumper;

###定义根 b:black  r: red
my $Tree;

#$Tree->{right} = undef;
#$Tree->{left}  = undef;
#$Tree->{10}    = 'data';
#$Tree->{c}     = 'b';

####get node's key
sub tree_key {
    my $node = shift;
    foreach my $key ( keys %$node ) {
        return $key unless $key eq 'left' or $key eq 'right' or $key eq 'c';
    }
}

### input ($Tree , $x (查找的key) , []:to store parents , []:to store location  ) ##
###output ($node ,$parents() , $location() ) ####
sub Search {
    my ( $tree, $x, $parents, $location ) = @_;

    my $key = &tree_key($tree);

    if ($tree) {
        if ( $x > $key ) {
            push @$parents,  $tree;
            push @$location, 'right';
            &Search( $tree->{right}, $x, $parents, $location );
        }
        elsif ( $x < $key ) {
            push @$parents,  $tree;
            push @$location, 'left';
            &Search( $tree->{left}, $x, $parents, $location );
        }
        else {
            return ( $tree, $parents, $location );
        }
    }

}

###input ($Tree , $node , []:store parents , []: store location)
sub Insert {
    my ( $tree, $node, $parents, $location ) = @_;
    $node->{c} = 'r';

    my $key = &tree_key($tree);

    if ($tree) {
        if ( &tree_key($node) > $key ) {
            push @$parents,  $tree;
            push @$location, 'right';
            &Insert( $tree->{right}, $node, $parents, $location );
        }
        elsif ( &tree_key($node) < $key ) {
            push @$parents,  $tree;
            push @$location, 'left';
            &Insert( $tree->{left}, $node, $parents, $location );
        }
        else {
            return;
        }
    }
    else {
        my $p = pop @$parents;
        my $l = pop @$location;

        unless ($l) {
            $node->{c} = 'b';
            $Tree = $node;
            return;
        }

        if ( $p->{c} eq 'b' ) {
            $p->{$l} = $node;
        }
        elsif ( $p->{c} eq 'r' ) {
            $p->{$l} = $node;
            my $g   = $parents->[-1];
            my $gpl = $location->[-1];    #父亲与爷爷的位置关系
            my $gul =
              $gpl eq 'right'
              ? 'left'
              : 'right';                  #叔叔与爷爷的位置关系

            if ( $g->{$gul} ) {
                &P_U( $parents, $location, $p, $g->{$gul}, $g );
            }
            else {
                &P_xU( $parents, $location, $p, $g, $gpl, $l );
            }

        }

    }
}

##have a uncle , and uncle must Red !!!!
sub P_U {
    my ( $parents, $location, $p, $u, $g ) = @_;

    if ( $#$parents eq '0' ) {
        $p->{c} = 'b';
        $u->{c} = 'b';
        $g->{c} = 'b';
        return;
    }
    elsif ( $#$parents eq '1' ) {
        $p->{c} = 'b';
        $u->{c} = 'b';
        $g->{c} = 'r';
        return;
    }
    elsif ( $#$parents eq '-1' ) {
        $p->{c} = 'b';
        $u->{c} = 'b';
        $g->{c} = 'b';
        return;
    }
    else {
        $p->{c} = 'b';
        $u->{c} = 'b';
        $g->{c} = 'r';

        my $node = pop @$parents;
        my $nl   = pop @$location;

        my $P  = pop @$parents;
        my $Pl = pop @$location;

        my $G   = $parents->[-1];
        my $Gpl = $location->[-1];

        my $Gul = $Gpl eq 'right' ? 'left' : 'right';

        if ( $P->{c} eq 'b' ) {
            return;
        }
        else {
            if ( $G->{$Gul}->{c} eq 'r' ) {
                &P_U( $parents, $location, $P, $G->{$Gul}, $G );
            }
            else {
                &P_xU( $parents, $location, $P, $G, $Gpl, $Pl );
            }
        }

    }

}

sub P_xU {
    my ( $parents, $location, $p, $g, $gpl, $l ) = @_;

    if ( $gpl eq 'left' and $l eq 'left' ) {
        &LL_r( $p, $g, $parents, $location );
    }
    elsif ( $gpl eq 'left' and $l eq 'right' ) {
        &LR_r( $p, $g, $parents, $location );
    }
    elsif ( $gpl eq 'right' and $l eq 'right' ) {
        &RR_r( $p, $g, $parents, $location );
    }
    elsif ( $gpl eq 'right' and $l eq 'left' ) {
        &RL_r( $p, $g, $parents, $location );
    }

}

sub LL_r {
    my ( $p, $g, $parents, $location ) = @_;
    $g->{left} = undef;
    my $b = $p->{right};
    $p->{right} = $g;
    $p->{c}     = 'b';
    $g->{c}     = 'r';
    $g->{left}  = $b;

    my $gg  = $parents->[-2];
    my $Ggl = $location->[-2];

    if ($Ggl) {
        $gg->{$Ggl} = $p;
    }
    else {
        $Tree = $p;
    }

}

sub RR_r {
    my ( $p, $g, $parents, $location ) = @_;
    $g->{right} = undef;
    my $b = $p->{left};
    $p->{left}  = $g;
    $p->{c}     = 'b';
    $g->{c}     = 'r';
    $g->{right} = $b;

    my $gg  = $parents->[-2];
    my $Ggl = $location->[-2];

    if ($gg) {
        $gg->{$Ggl} = $p;
    }
    else {
        $Tree = $p;
    }
}

sub LR_r {
    my ( $p, $g, $parents, $location ) = @_;

    my $node = $p->{right};
    ### left rolation
    my $son = $node->{left};
    $p->{right}   = $son;
    $g->{left}    = $node;
    $node->{left} = $p;

    #right rolation
    &LL_r( $node, $g, $parents, $location );
}

sub RL_r {
    my ( $p, $g, $parents, $location ) = @_;
    my $node = $p->{left};
    my $son  = $node->{right};
    $p->{left}     = $son;
    $g->{right}    = $node;
    $node->{right} = $p;
    &RR_r( $node, $g, $parents, $location );

}

sub Travel {
    my $tree = shift;
    my $from = shift;    # $from = 1 前序 | 2 中序 | 3 后序

    my $Print = sub {
        my $tree  = shift;
        my $key   = &tree_key($tree);
        my $color = $tree->{c};
        my $lkey  = &tree_key( $tree->{left} );
        my $rkey  = &tree_key( $tree->{right} );

        if ( $lkey and $rkey ) {
            say "$key color:$color"
              . " left: "
              . &tree_key( $tree->{left} )
              . " right: "
              . &tree_key( $tree->{right} );
        }
        elsif ($rkey) {
            say "$key color: $color" . " right:" . &tree_key( $tree->{right} );

        }
        elsif ($lkey) {
            say "$key color: $color" . " left:" . &tree_key( $tree->{left} );

        }
        else {
            say "$key color: $color";
        }

    };

    if ($tree) {
        if ( $from eq 1 ) {
            $Print->($tree);
            &Travel( $tree->{left},  $from );
            &Travel( $tree->{right}, $from );

        }
        elsif ( $from eq 2 ) {
            &Travel( $tree->{left}, $from );
            $Print->($tree);
            &Travel( $tree->{right}, $from );

        }
        elsif ( $from eq 3 ) {
            &Travel( $tree->{left},  $from );
            &Travel( $tree->{right}, $from );
            $Print->($tree);
        }
    }

}

sub L_rolation {
    my ( $s, $p, $g, $gl ) = @_;
    my $gs = $s->{left};
    $p->{right} = $gs;
    $s->{left}  = $p;

    if ( &tree_key($p) eq &tree_key($Tree) ) {
        $Tree = $s;
    }
    else {
        $g->{$gl} = $s;
    }
}

sub R_rolation {
    my ( $s, $p, $g, $gl ) = @_;
    my $gs = $s->{right};
    $p->{left}  = $gs;
    $s->{right} = $p;

    if ( &tree_key($p) eq &tree_key($Tree) ) {
        $Tree = $s;
    }
    else {
        $g->{$gl} = $s;
    }
}

sub Balance {
    my ( $parents, $location, $color ) = @_;
    my ( $b_l, $b, $B, $P, $L, $p2, $l2 );

    if ( $#$parents eq '-1' ) {
        return;
    }

    $P   = $parents->[-1];
    $L   = $location->[-1];
    $p2  = $parents->[-2];
    $l2  = $location->[-2];
    $b_l = $location->[-1] eq 'right' ? 'left' : 'right';
    $B   = $P->{$b_l};

    return unless $color;

    if ( $color eq 'b' and $B ) {
        ###存在brother
        ###brother is red
        if ( $B->{c} eq 'r' ) {
            $B->{c} = 'b';
            if ( $b_l eq 'left' ) {
                &R_rolation( $B, $P, $p2, $l2 );
            }
            elsif ( $b_l eq 'right' ) {
                &L_rolation( $B, $P, $p2, $l2 );
            }
        }
        elsif ( $B->{c} eq 'b' ) {
            ###brother is black
            ###brother have son , and some is red
            my $Y = $B->{$b_l} ? 1 : 2;
            my $J = $B->{$L}   ? 1 : 2;
            my ( $Y_son, $J_son );
            if ( $Y eq '1' ) {
                $Y_son = $B->{$b_l}->{c} eq 'r' ? 1 : 2;
            }
            else {
                $Y_son = '3';
            }
            if ( $J eq '1' ) {
                $J_son = $B->{$L}->{c} eq 'r' ? 1 : 2;
            }
            else {
                $J_son = '3';
            }

            if ( $Y_son eq '1' ) {
                $B->{$b_l}->{c} = $P->{c};
                $P->{c} = 'b';
                if ( $b_l eq 'right' ) {
                    &L_rolation( $B->{right}, $B, $P,  'right' );
                    &L_rolation( $P->{right}, $P, $p2, $l2 );
                }
                elsif ( $b_l eq 'left' ) {
                    &R_rolation( $B->{left}, $B, $P,  'left' );
                    &R_rolation( $P->{left}, $P, $p2, $l2 );
                }
            }
            elsif ( $J_son eq '1' ) {
                $B->{$L}->{c} = $P->{c};
                $P->{c} = 'b';
                if ( $L eq 'right' ) {
                    &L_rolation( $B->{right}, $B, $P, 'left' );
                    &R_rolation( $P->{left}, $P, $p2, $l2 );
                }
                elsif ( $L eq 'left' ) {
                    &R_rolation( $B->{left}, $B, $P, 'right' );
                    &L_rolation( $P->{right}, $P, $p2, $l2 );
                }
            }
            else {
                ##存在brother , but,brother have no red node
                if ( $P->{c} eq 'r' ) {
                    if ( $b_l eq 'right' ) {
                        &L_rolation( $B, $P, $p2, $l2 );
                    }
                    elsif ( $b_l eq 'left' ) {
                        &R_rolation( $B, $P, $p2, $l2 );
                    }
                }
                elsif ( $P->{c} eq 'b' ) {
                    $B->{c} = 'r';
                    pop @$parents;
                    pop @$location;
                    &Balance( $parents, $location, $color );
                }
            }
        }
    }
    elsif ( $color eq 'b' ) {
        ##不存在brother
        if ( $p2 eq 'b' ) {
            pop @$parents;
            pop @$location;
            &Balance( $parents, $location, $color );
        }
        elsif ( $p2 eq 'r' ) {
            $P->{c} = 'b';
        }
    }
    if ( $color eq 'r' ) {
        return;
    }
}

sub Del {
    my ( $tree, $x ) = @_;
    my ( $node, $parents, $location ) = &Search( $tree, $x, [], [] );
    return unless $node;

    if ( $node->{left} ) {
        my ( $Parents, $Location, $color ) =
          &Left_max( $node, $parents, $location, [], [] );
        push @$parents,  @$Parents;
        push @$location, @$Location;
        &Balance( $parents, $location, $color );
    }
    elsif ( $node->{right} ) {
        my ( $Parents, $Location, $color ) =
          &Right_min( $node, $parents, $location, [], [] );
        push @$parents,  @$Parents;
        push @$location, @$Location;
        &Balance( $parents, $location, $color );
    }
    elsif ( $node->{c} eq 'r' ) {
        my $p = $parents->[-1];
        my $l = $location->[-1];
        $p->{$l} = undef;
    }
    elsif ( $node->{c} eq 'b' ) {
        my $p = $parents->[-1];
        my $l = $location->[-1];
        $p->{$l} = undef;
        &Balance( $parents, $location, 'b' );
    }

}

sub Left_max {
    my ( $node, $parents, $location, $Parents, $Location, $n ) = @_;
    if ($node) {
        unless ($n) {
            push @$Parents,  $node;
            push @$Location, 'left';
            &Left_max( $node->{left}, $parents, $location, $Parents, $Location,
                1 );
        }
        else {
            push @$Parents,  $node   if $node->{right};
            push @$Location, 'right' if $node->{right};
            &Left_max( $node->{right}, $parents, $location, $Parents, $Location,
                1 );
        }
    }
    else {
        my $dnode = $Parents->[0];
        my $dl    = $Location->[0];
        my $Node  = $Parents->[-1];
        my $Nl    = $Location->[-1];
        my $fnode = $Node->{$Nl};
        my $Color = $fnode->{c};
        $fnode->{c} = $dnode->{c};

        if (@$parents) {
            if ( $#$Parents eq 0 ) {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $fnode->{right}      = $dnode->{right};
                $Parents->[0]        = $fnode;
            }
            else {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $Node->{$Nl}         = $fnode->{left};
                $fnode->{right}      = $dnode->{right};
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;

            }
        }
        else {
            ####del node is root####
            if ( $#$Parents eq 0 ) {
                $fnode->{right} = $dnode->{right};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }
            else {
                $Node->{$Nl}    = $fnode->{left};
                $fnode->{right} = $dnode->{right};
                $fnode->{left}  = $dnode->{left};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }

        }

        return ( $Parents, $Location, $Color );
    }

}

sub Right_min {
    my ( $node, $parents, $location, $Parents, $Location, $n ) = @_;
    if ($node) {
        unless ($n) {
            push @$Parents,  $node;
            push @$Location, 'right';
            &Right_min( $node->{right}, $parents, $location, $Parents,
                $Location, 1 );
        }
        else {
            push @$Parents,  $node  if $node->{left};
            push @$Location, 'left' if $node->{left};
            &Right_min( $node->{left}, $parents, $location, $Parents, $Location,
                1 );
        }
    }
    else {
        my $dnode = $Parents->[0];
        my $dl    = $Location->[0];
        my $Node  = $Parents->[-1];
        my $Nl    = $Location->[-1];
        my $fnode = $Node->{$Nl};
        my $Color = $fnode->{c};
        $fnode->{c} = $dnode->{c};
        if (@$parents) {

            if ( $#$Parents eq 0 ) {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;
            }
            else {
                my $l = $location->[-1];
                $parents->[-1]->{$l} = $fnode;
                $Node->{$Nl}         = $fnode->{right};
                $fnode->{right}      = $dnode->{right};
                $fnode->{left}       = $dnode->{left};
                $Parents->[0]        = $fnode;

            }
        }
        else {
            if ( $#$Parents eq 0 ) {
                $fnode->{left} = $dnode->{left};
                $Tree          = $fnode;
                $Parents->[0]  = $fnode;
            }
            else {
                $Node->{$Nl}    = $fnode->{right};
                $fnode->{right} = $dnode->{right};
                $fnode->{left}  = $dnode->{left};
                $Tree           = $fnode;
                $Parents->[0]   = $fnode;
            }
        }

        return ( $Parents, $Location, $Color );
    }

}

my @x = (
    77, 23, 88, 63, 15, 49, 19, 27, 97, 0, 9,  12, 39, 99, 57, 71,
    76, 43, 11, 43, 4,  8,  14, 80, 74, 6, 70, 54, 17
);
my @y = @x;
while (@x) {
    my $p = pop @x;
    my $node = { $p => 'xxx', right => undef, left => undef };
    &Insert( $Tree, $node, [], [] );
}

pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;
pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;pop @y;
while (@y) {
    my $p = pop @y;

   &Del( $Tree, $p );
}

&Travel( $Tree, 1 );
