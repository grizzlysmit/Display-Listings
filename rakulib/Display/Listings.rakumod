unit module Display::Listings:ver<0.1.9>:auth<Francis Grizzly Smit (grizzlysmit@smit.id.au)>;

=begin pod

=head1 Display::Listings

=begin head2

Table of Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item1 L<list-by(…)|#list-by>
=item2 L<Examples:|#examples>
=item3 L<A more complete example:|#a-more-complete-example>
=item3 L<Another example:|#another-example>
=item4 L<An Example of the above code B<C<list-editors-backups(…)>> at work:|#An-Example-of-the-above-code-list-editors-backups-at-work>
=item1 L<The default callbacks|#the-default-callbacks>
=item2 L<The hash of hashes stuff|#the-hash-of-hashes-stuff>
=item2 L<The array of hashes stuff|#the-array-of-hashes-stuff>

=NAME Display::Listings 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.9
=TITLE Display::Listings
=SUBTITLE A Raku module for displaying lines in a listing.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Display-Listings/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

A B<Raku> module for managing the users GUI Editor preferences in a variety of programs. 

=end pod

use Terminal::ANSI::OO :t;
use Terminal::Width;
use Terminal::WCWidth;
use Gzz::Text::Utils;
use Syntax::Highlighters;
#use Grammar::Debugger;
#use Grammar::Tracer;
#use trace;

=begin pod

=head3 list-by(…)

This is a multi sub it has two signatures.

=begin code :lang<raku>

multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D $key-name, Str:D @fields, %defaults, %rows,
                  Int:D :$start-cnt = -3, Bool:D :$starts-with-blank = True,
                  Str:D :$overline-header = '', Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D :$line-at-bottom = '=', Bool:D :$sort = True,
                  Str:D :%flags = default-zip-flags($key-name, @fields), 
                  Str:D :%between-flags = default-zip-flags($key-name, @fields), 
                  Str:D :%head-flags = default-zip-flags($key-name, @fields), 
                  Str:D :%between-head-flags = default-zip-flags($key-name, @fields), 
                  :&include-row:(Str:D $pref, Regex $pat, Str:D $k, Str:D @f, %r --> Bool:D) = &default-include-row, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting --> Bool:D) is export {

=end code

L<Top of Document|#table-of-contents>

And

=begin code :lang<raku>

multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D @fields, %defaults, @rows, Int:D :$start-cnt = -3,
                  Bool:D :$starts-with-blank = True,
                  Str:D :$overline-header = '', Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D :$line-at-bottom = '=', Bool:D :$sort = True,
                  Str:D :%flags = default-zip-flags(@fields), 
                  Str:D :%between-flags = default-zip-flags(@fields), 
                  Str:D :%head-flags = default-zip-flags(@fields), 
                  Str:D :%between-head-flags = default-zip-flags(@fields), 
                  :&include-row:(Str:D $pref, Regex:D $pat, Int:D $i, Str:D @f, %r --> Bool:D) = &default-include-row-array, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value-array, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between-array,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value-array, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between-array,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting-array --> Bool:D) is export {

=end code

B<Note: you have to be careful writing your own callbacks like C<:&include-row> you need to get the signature of said
callback exactly right or you will run into difficult to debug errors, with no version of the C<list-by> multi sub
matching etc.> 

L<Top of Document|#table-of-contents>

=head3 Examples:

=begin code :lang<raku>

use Display::Listings;

my Str:D $prefix = '';
my Str:D $key-name = 'key';
my Str:D @fields = 'host', 'port', 'comment';
my   %defaults = port => 22;

my   %rows = one => { host => 'example.com', type => 'host', port => 22 },
             two => { type => 'alias', host => 'one', comment => 'An alias' },
             three => { port => 345, host => 'www.smit.id.au', type => 'host',
                                                    comment => 'mine all mine' };
my Bool:D $colour = False;
my Bool:D $syntax = True;
my Int:D $page-length = 20;
my Regex:D $pattern = rx:i/ ^ .* 'smit' .* $/;

my @rows = {key => 'one', host => 'example.com', type => 'host', port => 22 },
           { type => 'alias', host => 'one', comment => 'An alias', key => 'two', },
           { port => 345, host => 'www.smit.id.au', type => 'host',
                                            comment => 'mine all mine', key => 'three' };

list-by($prefix, $colour, $syntax, $page-length, $pattern, $key-name,
                                                         @fields, %defaults, %rows);

list-by($prefix, $colour, $syntax, $page-length, $pattern, @fields, %defaults, @rows);

$pattern = rx/ ^ .* $/;

list-by($prefix, $colour, $syntax, $page-length, $pattern, $key-name,
                                                         @fields, %defaults, %rows);

list-by($prefix, $colour, $syntax, $page-length, $pattern,
                                                         @fields, %defaults, @rows);

=end code

L<Top of Document|#table-of-contents>

=head4 A more complete example:

=begin code :lang<raku>

use Terminal::ANSI::OO :t;
use Display::Listings;

sub list-by-all(Str:D $prefix, Bool:D $colour, Bool:D $syntax,
                    Int:D $page-length, Regex:D $pattern --> Bool:D) is export {
    my Str:D $key-name = 'key';
    my Str:D @fields = 'host', 'port', 'comment';
    my   %defaults = port => 22;
    sub include-row(Str:D $prefix, Regex:D $pattern, Str:D $key,
                                                Str:D @fields, %row --> Bool:D) {
        return True if $key.starts-with($prefix, :ignorecase) && $key ~~ $pattern;
        for @fields -> $field {
            my Str:D $value = '';
            with %row{$field} { #`««« if %row{$field} does not exist then a Any
                                      will be returned, and if some cases, you
                                      may return undefined values so use some
                                      sort of guard this is one way to do that,
                                      you could use %row{$field}:exists or
                                      :!exists or // perhaps.
                                      TIMTOWTDI rules as always. »»»
                $value = ~%row{$field};
            }
            return True if $value.starts-with($prefix, :ignorecase)
                                                         && $value ~~ $pattern;
        }
        return False;
    } # sub include-row(Str:D $prefix, Regex:D $pattern,
                                        Str:D $key, @fields, %row --> Bool:D) #
    sub head-value(Int:D $indx, Str:D $field, Bool:D $colour,
                                        Bool:D $syntax, Str:D @fields --> Str:D) {
        if $syntax {
            t.color(0, 255, 255) ~ $field;
        } elsif $colour {
            t.color(0, 255, 255) ~ $field;
        } else {
            return $field;
        }
    } #`««« sub head-value(Int:D $indx, Str:D $field,
                                        Bool:D $colour, Bool:D $syntax,
                                        Str:D @fields --> Str:D) »»»
    sub head-between(Int:D $idx, Str:D $field, Bool:D $colour,
                                        Bool:D $syntax, Str:D @fields --> Str:D) {
        if $colour {
            if $syntax {
                given $field {
                    when 'key'     { return t.color(0, 255, 255) ~ ' sep '; }
                    when 'host'    { return t.color(0, 255, 255) ~ ' : ';   }
                    when 'port'    { return t.color(0, 255, 255)   ~ ' # ';   }
                    when 'comment' { return t.color(0, 0, 255)   ~ '  ';    }
                    default { return ''; }
                }
            } else {
                given $field {
                    when 'key'     { return t.color(0, 255, 255)   ~ ' sep '; }
                    when 'host'    { return t.color(0, 255, 255)   ~ ' : ';   }
                    when 'port'    { return t.color(0, 255, 255)   ~ ' # ';   }
                    when 'comment' { return t.color(0, 255, 255)   ~ '  ';    }
                    default { return ''; }
                }
            }
        } else {
            given $field {
                when 'key'     { return ' sep '; }
                when 'host'    { return ' : ';   }
                when 'port'    { return ' # ';   }
                when 'comment' { return '  ';    }
                default        { return '';      }
            }
        }
    } #`««« sub head-between(Int:D $idx, Str:D $field, Bool:D $colour,
                            Bool:D $syntax, Str:D @fields --> Str:D) »»»
    sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour,
                        Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        if $syntax {
            given $field {
                when 'key'     { return t.color(0, 255, 255) ~ ~$value; }
                when 'host'    {
                    my Str:D $type = %row«type»;
                    if $type eq 'host' {
                        return t.color(255, 0, 255) ~ ~$value;
                    } else {
                        return t.color(0, 255, 255) ~ ~$value;
                    }
                }
                when 'port'    { 
                    my Str:D $type = %row«type»;
                    if $type eq 'host' {
                        return t.color(255, 0, 255) ~ ~$value;
                    } else {
                        return t.color(255, 0, 255) ~ '';
                    }
                }
                when 'comment' { return t.color(0, 0, 255) ~ ~$value; }
                default        { return t.color(255, 0, 0) ~ '';      }
            } # given $field #
        } elsif $colour {
            given $field {
                when 'key'     { return t.color(0, 0, 255) ~ ~$value; }
                when 'host'    { return t.color(0, 0, 255) ~ ~$value; }
                when 'port'    { 
                    my Str:D $type = %row«type»;
                    if $type eq 'host' {
                        return t.color(0, 0, 255) ~ ~$value;
                    } else {
                        return t.color(0, 0, 255) ~ '';
                    }
                }
                when 'comment' { return t.color(0, 0, 255) ~ ~$value; }
                default        { return t.color(255, 0, 0) ~ '';      }
            }
        } else {
            given $field {
                when 'key'     { return ~$value; }
                when 'host'    { return ~$value; }
                when 'port'    { 
                    my Str:D $type = %row«type»;
                    if $type eq 'host' {
                        return ~$value;
                    } else {
                        return '';
                    }
                }
                when 'comment' { return ~$value; }
                default        { return '';      }
            }
        }
    } #`««« sub field-value(Int:D $idx, Str:D $field, $value, Bool:D
                            $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) »»»
    sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax,
                                                Str:D @fields, %row --> Str:D) {
        if $syntax {
                given $field {
                    when 'key'     {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return t.color(255, 0, 0) ~ '  => ';
                        } else {
                            return t.color(255, 0, 0) ~ ' --> ';
                        }
                    }
                    when 'host'    {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return t.color(255, 0, 0) ~ ' : ';
                        } else {
                            return t.color(255, 0, 0) ~ '   ';
                        }
                    }
                    when 'port'    { return t.color(0, 0, 255) ~ ' # '; }
                    when 'comment' { return t.color(0, 0, 255) ~ '  ';  }
                    default        { return t.color(255, 0, 0) ~ '';    }
                }
        } elsif $colour {
                given $field {
                    when 'key'     {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return t.color(0, 0, 255) ~ '  => ';
                        } else {
                            return t.color(0, 0, 255) ~ ' --> ';
                        }
                    }
                    when 'host'    {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return t.color(0, 0, 255) ~ ' : ';
                        } else {
                            return t.color(0, 0, 255) ~ '   ';
                        }
                    }
                    when 'port'    { return t.color(0, 0, 255) ~ ' # '; }
                    when 'comment' { return t.color(0, 0, 255) ~ '  ';  }
                    default        { return t.color(255, 0, 0) ~ '';    }
                }
        } else {
                given $field {
                    when 'key'     {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return '  => ';
                        } else {
                            return ' --> ';
                        }
                    }
                    when 'host'    {
                        my Str:D $type = %row«type»;
                        if $type eq 'host' {
                            return ' : ';
                        } else {
                            return '   ';
                        }
                    }
                    when 'port'    { return ' # '; }
                    when 'comment' { return '  ';  }
                    default        { return '';    }
                }
        }
    } #`««« sub between(Int:D $idx, Str:D $field, Bool:D $colour,
                    Bool:D $syntax, Str:D @fields, %row --> Str:D) »»»
    sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) {
        if $colour {
            if $syntax { 
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue
                                  if $cnt == -3; # three heading lines. #
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue
                                                          if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue
                                                          if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !!
                                  t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
            } else {
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue
                                                          if $cnt == -3;
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue
                                                          if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue
                                                          if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !!
                              t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
            }
        } else {
            return '';
        }
    } #`««« sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) »»»
    return list-by($prefix, $colour, $syntax, $page-length, $pattern, $key-name, @fields,
                            %defaults, %the-lot, :&include-row, :&head-value, :&head-between,
                            :&field-value, :&between, :&row-formatting);
} #`««« sub list-by-all(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax,
                        Int:D $page-length, Regex:D $pattern --> Bool:D) is export »»»

=end code

L<Top of Document|#table-of-contents>

=head4 Another example

=begin code :lang<raku>

use Terminal::ANSI::OO :t;
use Display::Listings;
use File::Utils;


sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export {
    $colour = True if $syntax;
    my IO::Path @backups = $editor-config.IO.dir(:test(rx/ ^ 
                                                           'editors.' \d ** 4 '-' \d ** 2 '-' \d ** 2
                                                               [ 'T' \d **2 [ [ '.' || ':' ] \d ** 2 ] ** {0..2} [ [ '.' || '·' ] \d+ 
                                                                   [ [ '+' || '-' ] \d ** 2 [ '.' || ':' ] \d ** 2 || 'z' ]?  ]?
                                                               ]?
                                                           $
                                                         /
                                                       )
                                                );
    my $actions = EditorsActions;
    @backups .=grep: -> IO::Path $fl { 
                                my @file = $fl.slurp.split("\n");
                                Editors.parse(@file.join("\x0A"), :enc('UTF-8'), :$actions).made;
                            };
    @backups .=sort;
    my @_backups = @backups.map: -> IO::Path $f {
          my %elt = backup => $f.basename, perms => symbolic-perms($f, :$colour, :$syntax),
                      user => $f.user, group => $f.group, size => $f.s, modified => $f.modified;
          %elt;
    };
    my Str:D @fields = 'perms', 'size', 'user', 'group', 'modified', 'backup';
    my       %defaults;
    my Str:D %fancynames = perms => 'Permissions', size => 'Size',
                             user => 'User', group => 'Group',
                             modified => 'Date Modified', backup => 'Backup';
    sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) {
        my Str:D $value = ~(%row«backup» // '');
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
        return False;
    } # sub include-row(Str:D $prefix, Regex:D $pattern, Int:D $idx, Str:D @fields, %row --> Bool:D) #
    sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        #dd $indx, $field, $colour, $syntax, @fields;
        if $colour {
            if $syntax { 
                return t.color(0, 255, 255) ~ %fancynames{$field};
            } else {
                return t.color(0, 255, 255) ~ %fancynames{$field};
            }
        } else {
            return %fancynames{$field};
        }
    } # sub head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
        return ' ';
    } # sub head-between(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) #
    sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D »»»
        #dd $val, $value, $field;
        if $syntax {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return t.color(255, 0, 0) ~ format-bytes($size);
                }
                when 'user'     { return t.color(255, 255, 0) ~ uid2username(+$value);    }
                when 'group'    { return t.color(255, 255, 0) ~ gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return t.color(0, 0, 235) ~ $dt.Str;  
                }
                when 'backup'   { return t.color(255, 0, 255) ~ $val; }
                default         { return t.color(255, 0, 0) ~ $val;   }
            } # given $field #
        } elsif $colour {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return t.color(0, 0, 255) ~ format-bytes($size);
                }
                when 'user'     { return t.color(0, 0, 255) ~ uid2username(+$value);    }
                when 'group'    { return t.color(0, 0, 255) ~ gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return t.color(0, 0, 255) ~ $dt.Str;  
                }
                when 'backup'   { return t.color(0, 0, 255) ~ $val;   }
                default         { return t.color(255, 0, 0) ~ $val;   }
            } # given $field #
        } else {
            given $field {
                when 'perms'    { return $val; }
                when 'size'     {
                    my Int:D $size = +$value;
                    return format-bytes($size);
                }
                when 'user'     { return uid2username(+$value);    }
                when 'group'    { return gid2groupname(+$value);   }
                when 'modified' {
                    my Instant:D $m = +$value;
                    my DateTime:D $dt = $m.DateTime.local;
                    return $dt.Str;  
                }
                when 'backup'   { return $val;   }
                default         { return $val;   }
            } # given $field #
        }
    } # sub field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
        return ' ';
    } # sub between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) #
    sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) {
        if $colour {
            if $syntax { 
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            } else {
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
                return t.bg-color(0, 0, 127) ~ t.bold ~ t.bright-blue if $cnt == -2;
                return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
                return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,195,0)) ~ t.bold ~ t.bright-blue;
            }
        } else {
            return '';
        }
    } # sub row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) #
    return list-by($prefix, $colour, $syntax, $page-length,
                  $pattern, @fields, %defaults, @_backups,
                  :!sort,
                  :&include-row, 
                  :&head-value, 
                  :&head-between,
                  :&field-value, 
                  :&between,
                  :&row-formatting);
} #`««« sub list-editors-backups(Str:D $prefix,
                         Bool:D $colour is copy,
                         Bool:D $syntax,
                         Regex:D $pattern,
                         Int:D $page-length --> Bool:D) is export »»»

=end code

L<Top of Document|#table-of-contents>

=head4 An Example of the above code B<C<list-editors-backups(…)>> at work:

!L<image not available here go to the github page|/docs/images/sc-list-editors-backups.png>

L<Top of Document|#table-of-contents>

=end pod

sub default-include-row(Str:D $prefix, Regex:D $pattern, Str:D $key, Str:D @fields, %row --> Bool:D) is export {
    return True if $key.starts-with($prefix, :ignorecase) && $key ~~ $pattern;
    for @fields -> $field {
        my Str:D $value = '';
        with %row{$field} { #`««« if %row{$field} does not exist then a Any will be retured,
                                  and if some cases, you may return undefined values so use
                                  some sort of guard this is one way to do that, you could
                                  use %row{$field}:exists or :!exists or // perhaps.
                                  TIMTOWTDI rules as always. »»»
            $value = ~%row{$field};
        }
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
    }
    return False;
}

sub default-head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 255, 255) ~ $field;
        } else {
            return t.color(0, 255, 255) ~ $field;
        }
    } else {
        return $field;
    }
}

sub default-field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
    my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D; if
                                           this asumption is false you will
                                           need to wrte your own function
                                           to pass to list-by(…) »»»
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 0, 255) ~ $val;
        } else {
            return t.color(0, 0, 255) ~ $val;
        }
    } else {
        return $val;
    }
}

sub default-head-between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) is export {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        } else {
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        }
    } else {
        return '';
    }
}

multi sub default-zip-flags(Str:D $key-name, Str:D @fields --> Hash[Str:D] ) is export {
    my Str:D %hash = @fields Z=> @fields.map: { '-' };
    %hash{$key-name} = '-';
    return %hash;
}

multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D $key-name, Str:D @fields, %defaults, %rows,
                  Int:D :$start-cnt = -3, Bool:D :$starts-with-blank = True,
                  Str:D :$overline-header = '', Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D :$line-at-bottom = '=', Bool:D :$sort = True,
                  Str:D :%flags = default-zip-flags($key-name, @fields), 
                  Str:D :%between-flags = default-zip-flags($key-name, @fields), 
                  Str:D :%head-flags = default-zip-flags($key-name, @fields), 
                  Str:D :%between-head-flags = default-zip-flags($key-name, @fields), 
                  :&include-row:(Str:D $pref, Regex $pat, Str:D $k, Str:D @f, %r --> Bool:D) = &default-include-row, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting --> Bool:D) is export {
    $colour = True if $syntax;
    my Str:D @result;
    ############################################
    #                                          #
    #    calculate the widths for each field   #
    #                                          #
    ############################################
    # set the widths to the widths of the headings. #
    my Int:D $key-width         = hwcswidth(&head-value(  0, $key-name, $colour, $syntax, @fields));
    my Int:D $key-between-width = hwcswidth(&head-between(0, $key-name, $colour, $syntax, @fields));
    my Int:D @field-widths      = @fields.kv.map: -> Int:D $ind, Str:D $elt { hwcswidth(&head-value(  $ind + 1, $elt,   $colour, $syntax, @fields))};
    my Int:D @between-widths    = @fields.kv.map: -> Int:D $ind, Str:D $fld { hwcswidth(&head-between($ind + 1, $fld, $colour, $syntax, @fields)) };
    my Int:D $no-more-fields    = ((@fields.elems > 0) ?? -1 !! 0); # -1 represents infinity #
    ROW: for %rows.kv -> $key, %row {
        if &include-row($prefix, $pattern, $key, @fields, %row) {
            $key-width         = max($key-width,         hwcswidth(&field-value(0, $key-name, $key, $colour, $syntax, @fields, %row)));
            $key-between-width = max($key-between-width, hwcswidth(&between(    0, $key-name,       $colour, $syntax, @fields, %row)));
            for @fields.kv -> $ind, $field {
                if %row{$field}:!exists { # as soon as a field does'nt exist we assume the rest dont exist,  for that row  #
                    if %defaults{$field}:!exists {
                        next ROW;
                    } else { 
                        %rows{$key}{$field} = %defaults{$field};
                    }
                }
                my $value = %row{$field};
                my $w                 = hwcswidth(&field-value($ind + 1, $field, $value, $colour, $syntax, @fields, %row));
                @field-widths[$ind]   = max(@field-widths[$ind],   $w);
                my Int:D $between     = hwcswidth(&between(    $ind + 1, $field,         $colour, $syntax, @fields, %row));
                @between-widths[$ind] = max(@between-widths[$ind], $between);
                $no-more-fields = max($no-more-fields, $ind + 1);
            } # for @fields.kv -> $ind, $field #
        } # if &include-row($prefix, $pattern, $key, @fields, %row) #
    } # ROW: for %rows.kv -> $key, %row #
    my Int:D $width = $key-width + $key-between-width + ([+] @field-widths) + ([+] @between-widths);
    $no-more-fields = @fields.elems if $no-more-fields < 0;
    ############################################
    #                                          #
    #             Colect the data              #
    #                                          #
    ############################################
    DATA: for %rows.kv -> $key, %row {
        if &include-row($prefix, $pattern, $key, @fields, %row) {
            my Str:D $cline = '';
            my Str:D $flag         = %flags{$key-name};
            my Str:D $between-flag = %between-flags{$key-name};
            $cline ~= Sprintf "%$flag*s", $key-width,                 &field-value(0, $key-name, $key, $colour, $syntax, @fields, %row);
            $cline ~= Sprintf "%$between-flag*s", $key-between-width, &between(    0, $key-name,       $colour, $syntax, @fields, %row);
            loop ( my Int:D $indx = 0; $indx < $no-more-fields; $indx++ ) {
                my $value;
                my Str:D $field = @fields[$indx];
                if %row{$field}:!exists { # as soon as a field does'nt exist we assume the rest dont exist,  for that row  #
                    if %defaults{$field}:!exists {
                        $value =  '';
                    } else { 
                        $value = %defaults{$field};
                    }
                } else {
                    $value = %row{$field};
                }
                my Str:D $flag         = %flags{$field};
                my Str:D $between-flag = %between-flags{$field};
                $cline ~= Sprintf "%$flag*s", @field-widths[$indx],       &field-value($indx + 1, $field, $value, $colour, $syntax, @fields, %row);
                $cline ~= Sprintf "%$between-flag*s", @between-widths[$indx], &between($indx + 1, $field,         $colour, $syntax, @fields, %row);
            }
            @result.push($cline);
        }
    } # DATA: for %rows.kv -> $key, %row #
    my Int:D $cnt = $start-cnt;
    ##################
    #                #
    #  print header  #
    #                #
    ##################
    my Str:D $hline = '';
    if $starts-with-blank {
        if $overline-header eq '' {
            $hline = centre($overline-header, $width);
        } else {
            $hline = centre('', $width, $overline-header);
        }
        put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        $hline = '';
    }
    my Str:D $flag         = %head-flags{$key-name};
    my Str:D $between-flag = %between-head-flags{$key-name};
    $hline ~= Sprintf "%$flag*s",         $key-width,         &head-value(  0, $key-name, $colour, $syntax, @fields);
    $hline ~= Sprintf "%$between-flag*s", $key-between-width, &head-between(0, $key-name, $colour, $syntax, @fields);
    for @fields.kv -> $ind, $field {
        last unless $ind < $no-more-fields;
        my Str:D $flag         = %head-flags{$field};
        my Str:D $between-flag = %between-head-flags{$field};
        $hline ~= Sprintf "%$flag*s",         @field-widths[$ind],   &head-value(  $ind + 1, $field, $colour, $syntax, @fields);
        $hline ~= Sprintf "%$between-flag*s", @between-widths[$ind], &head-between($ind + 1, $field, $colour, $syntax, @fields);
    }
    put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
    $cnt++;
    if $underline-header {
        if $underline eq '' {
            $hline = centre($underline, $width);
        } else {
            $hline = centre('', $width, $underline);
        }
        put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        $hline = '';
    }
    ######################################
    #                                    #
    #           print the rows           #
    #                                    #
    ######################################
    @result .=sort( { .lc } ) if $sort;
    for @result -> $value {
        put &row-formatting($cnt, $colour, $syntax) ~ Sprintf("%-*s", $width, $value) ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        ##########################################
        #                                        #
        #    print page ending and beginning     #
        #    to make pages.                      #
        #                                        #
        ##########################################
        if $cnt % $page-length == 0 {
            $cnt = $start-cnt;
            if $starts-with-blank {
                if $overline-header eq '' {
                    $hline = centre($overline-header, $width);
                } else {
                    $hline = centre('', $width, $overline-header);
                }
                put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
                $cnt++;
                $hline = '';
            }
            $hline ~= Sprintf "%-*s", $key-width,         &head-value(  0, $key-name, $colour, $syntax, @fields);
            $hline ~= Sprintf "%-*s", $key-between-width, &head-between(0, $key-name, $colour, $syntax, @fields);
            for @fields.kv -> $ind, $field {
                $hline ~= Sprintf "%-*s", @field-widths[$ind],   &head-value($ind + 1, $field, $colour, $syntax, @fields);
                $hline ~= Sprintf "%-*s", @between-widths[$ind], &head-between($ind + 1, $field, $colour, $syntax, @fields);
            }
            put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
            $cnt++;
            if $underline-header {
                if $underline eq '' {
                    $hline = centre($underline, $width);
                } else {
                    $hline = centre('', $width, $underline);
                }
                put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
                $cnt++;
                $hline = '';
            }
        } # if $cnt % $page-length == 0 #
    } # for @result.sort( { .lc } ) -> $value #
    if $put-line-at-bottom {
        $cnt = $start-cnt;
        if $colour {
            if $line-at-bottom eq '' {
                put &row-formatting($cnt, $colour, $syntax) ~ centre('', $width) ~ t.text-reset;
            } else {
                put &row-formatting($cnt, $colour, $syntax) ~ centre('', $width, $line-at-bottom) ~ t.text-reset;
            }
            $cnt++;
        } else {
            if $line-at-bottom eq '' {
                "".say;
            } else {
                say centre('', $width, $line-at-bottom);
            }
        }
    }
    return True;
} #`««« multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D $key-name, Str:D @fields, %defaults, %rows,
                  Int:D :$start-cnt = -3,
                  Bool:D :$starts-with-blank = True, Str:D :$overline-header = '',
                  Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D :$line-at-bottom = '=', Bool:D :$sort = True,
                  :&include-row:(Str:D $pref, Regex $pat, Str:D $k, Str:D @f, %r --> Bool:D) = &default-include-row, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting --> Bool:D) is export »»»

=begin pod

=head2 The default callbacks

=head3 The hash of hashes stuff

=begin code :lang<raku>

sub default-include-row(Str:D $prefix, Regex:D $pattern, Str:D $key, Str:D @fields, %row --> Bool:D) is export {
    return True if $key.starts-with($prefix, :ignorecase) && $key ~~ $pattern;
    for @fields -> $field {
        my Str:D $value = '';
        with %row{$field} { #`««« if %row{$field} does not exist then a Any will be retured,
                                  and if some cases, you may return undefined values so use
                                  some sort of guard this is one way to do that, you could
                                  use %row{$field}:exists or :!exists or // perhaps.
                                  TIMTOWTDI rules as always. »»»
            $value = ~%row{$field};
        }
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
    }
    return False;
}

sub default-head-value(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 255, 255) ~ $field;
        } else {
            return t.color(0, 255, 255) ~ $field;
        }
    } else {
        return $field;
    }
}

sub default-field-value(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
    my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D; if
                                           this asumption is false you will
                                           need to wrte your own function
                                           to pass to list-by(…) »»»
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 0, 255) ~ $val;
        } else {
            return t.color(0, 0, 255) ~ $val;
        }
    } else {
        return $val;
    }
}

sub default-head-between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-between(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-row-formatting(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) is export {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        } else {
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        }
    } else {
        return '';
    }
}

multi sub default-zip-flags(Str:D $key-name, Str:D @fields --> Hash[Str:D] ) is export {
    my Str:D %hash = @fields Z=> @fields.map: { '-' };
    %hash{$key-name} = '-';
    return %hash;
}

=end code

L<Top of Document|#table-of-contents>

=head3 The array of hashes stuff

=begin code :lang<raku>

sub default-include-row-array(Str:D $prefix, Regex:D $pattern, Int:D $indx, Str:D @fields, %row --> Bool:D) is export {
    for @fields -> $field {
        my Str:D $value = ~(%row{$field} // '');
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
    }
    return False;
}

sub default-head-value-array(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 255, 255) ~ $field;
        } else {
            return t.color(0, 255, 255) ~ $field;
        }
    } else {
        return $field;
    }
}

sub default-field-value-array(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
    my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D; if
                                           this asumption is false you will
                                           need to wrte your own function
                                           to pass to list-by(…) »»»
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 0, 255) ~ $val;
        } else {
            return t.color(0, 0, 255) ~ $val;
        }
    } else {
        return $val;
    }
}

sub default-head-between-array(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-between-array(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-row-formatting-array(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) is export {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        } else {
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        }
    } else {
        return '';
    }
}

multi sub default-zip-flags(Str:D @fields --> Hash[Str:D] ) is export {
    my Str:D %hash = @fields Z=> @fields.map: { '-' };
    return %hash;
}

=end code

L<Top of Document|#table-of-contents>

=end pod

sub default-include-row-array(Str:D $prefix, Regex:D $pattern, Int:D $indx, Str:D @fields, %row --> Bool:D) is export {
    for @fields -> $field {
        my Str:D $value = ~(%row{$field} // '');
        return True if $value.starts-with($prefix, :ignorecase) && $value ~~ $pattern;
    }
    return False;
}

sub default-head-value-array(Int:D $indx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 255, 255) ~ $field;
        } else {
            return t.color(0, 255, 255) ~ $field;
        }
    } else {
        return $field;
    }
}

sub default-field-value-array(Int:D $idx, Str:D $field, $value, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) {
    my Str:D $val = ~($value // ''); #`««« assumming $value is a Str:D; if
                                           this asumption is false you will
                                           need to wrte your own function
                                           to pass to list-by(…) »»»
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.color(0, 0, 255) ~ $val;
        } else {
            return t.color(0, 0, 255) ~ $val;
        }
    } else {
        return $val;
    }
}

sub default-head-between-array(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-between-array(Int:D $idx, Str:D $field, Bool:D $colour, Bool:D $syntax, Str:D @fields, %row --> Str:D) is export {
    if $idx < @fields.elems {
        return '  ';
    } else {
        return '';
    }
}

sub default-row-formatting-array(Int:D $cnt, Bool:D $colour, Bool:D $syntax --> Str:D) is export {
    if $colour {
        if $syntax { #`««« no real syntax Highlighting here this
                           is a generic function write your own. »»»
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3; # three heading lines. #
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        } else {
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -3;
            return t.bg-color(0, 255, 255) ~ t.bold ~ t.bright-blue if $cnt == -2;
            return t.bg-color(255, 0, 255) ~ t.bold ~ t.bright-blue if $cnt == -1;
            return (($cnt % 2 == 0) ?? t.bg-yellow !! t.bg-color(0,255,0)) ~ t.bold ~ t.bright-blue;
        }
    } else {
        return '';
    }
}

multi sub default-zip-flags(Str:D @fields --> Hash[Str:D] ) is export {
    my Str:D %hash = @fields Z=> @fields.map: { '-' };
    return %hash;
}

multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D @fields, %defaults, @rows, Int:D :$start-cnt = -3,
                  Bool:D :$starts-with-blank = True,
                  Str:D :$overline-header = '', Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D :$line-at-bottom = '=', Bool:D :$sort = True,
                  Str:D :%flags = default-zip-flags(@fields), 
                  Str:D :%between-flags = default-zip-flags(@fields), 
                  Str:D :%head-flags = default-zip-flags(@fields), 
                  Str:D :%between-head-flags = default-zip-flags(@fields), 
                  :&include-row:(Str:D $pref, Regex:D $pat, Int:D $i, Str:D @f, %r --> Bool:D) = &default-include-row-array, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value-array, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between-array,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value-array, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between-array,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting-array --> Bool:D) is export {
    $colour = True if $syntax;
    my Str @result;
    ############################################
    #                                          #
    #    calculate the widths for each field   #
    #                                          #
    ############################################
    # set the widths to the widths of the headings. #
    my Int:D @field-widths = @fields.kv.map: -> Int:D $ind, Str:D $elt { hwcswidth(&head-value($ind, $elt, $colour, $syntax, @fields)) };
    my Int:D @between-widths = @fields.kv.map: -> Int:D $ind, Str:D $field { hwcswidth(&head-between($ind, $field, $colour, $syntax, @fields)) };
    my Int:D $no-more-fields = -1; # -1 represents infinity #
    ROW: for @rows.kv -> $indx, %row {
        if &include-row($prefix, $pattern, $indx, @fields, %row) {
            for @fields.kv -> $ind, $field {
                #dd $indx, %row, $ind, $field;
                my $value;
                if %row{$field}:!exists { # as soon as a field does'nt exist we assume the rest dont exist #
                    if %defaults{$field}:!exists {
                        next ROW;
                    } else {
                        $value = %defaults{$field};
                    }
                } else {
                    $value = %row{$field};
                }
                $no-more-fields = max($no-more-fields, $ind + 1);
                #dd $field, $value;
                my $w = hwcswidth(&field-value($ind, $field, $value, $colour, $syntax, @fields, %row));
                @field-widths[$ind]  = max(@field-widths[$ind], $w);
                my Int:D $between = hwcswidth(&between($ind, $field, $colour, $syntax, @fields, %row));
                @between-widths[$ind] = max(@between-widths[$ind], $between);
            } # for @fields.kv -> $ind, $field #
        } # if &include-row($prefix, $pattern, $key, @fields, %row) #
    } # ROW: for %rows.kv -> $key, %row #
    #dd @field-widths, @between-widths;
    my Int:D $width = ([+] @field-widths) + ([+] @between-widths);
    #dd $width, $no-more-fields;
    $no-more-fields = @fields.elems if $no-more-fields < 0;
    #dd $width, $no-more-fields;
    ############################################
    #                                          #
    #             Colect the data              #
    #                                          #
    ############################################
    DATA: for @rows.kv -> $ind, %row {
        if &include-row($prefix, $pattern, $ind, @fields, %row) {
            my Str:D $cline = '';
            loop ( my Int:D $indx = 0; $indx < $no-more-fields; $indx++ ) {
                my Str:D $field = @fields[$indx];
                my       $value;
                if %row{$field}:!exists { 
                    if %defaults{$field}:!exists {
                        $value = '';
                    } else {
                        $value = %defaults{$field};
                    }
                } else {
                    $value = %row{$field};
                }
                my Str:D $flag = %flags{$field};
                my Str:D $between-flag = %between-flags{$field};
                $cline ~= Sprintf "%$flag*s", @field-widths[$indx],   &field-value($ind, $field, $value, $colour, $syntax, @fields, %row);
                $cline ~= Sprintf "%$between-flag*s", @between-widths[$indx], &between($ind, $field, $colour, $syntax, @fields, %row);
            }
            @result.push($cline);
        }
    } # DATA: for %rows.kv -> $key, %row #
    my Int:D $cnt = $start-cnt;
    ##################
    #                #
    #  print header  #
    #                #
    ##################
    my Str:D $hline = '';
    if $starts-with-blank {
        if $overline-header eq '' {
            $hline = centre($overline-header, $width);
        } else {
            $hline = centre('', $width, $overline-header);
        }
        put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        $hline = '';
    }
    for @fields.kv -> $ind, $field {
        last unless $ind < $no-more-fields;
        my Str:D $flag = %head-flags{$field};
        my Str:D $between-flag = %between-head-flags{$field};
        $hline ~= Sprintf "%$flag*s", @field-widths[$ind],   &head-value($ind, $field, $colour, $syntax, @fields);
        $hline ~= Sprintf "%$between-flag*s", @between-widths[$ind], &head-between($ind, $field, $colour, $syntax, @fields);
    }
    put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
    $cnt++;
    if $underline-header {
        if $underline eq '' {
            $hline = centre($underline, $width);
        } else {
            $hline = centre('', $width, $underline);
        }
        put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        $hline = '';
    }
    ######################################
    #                                    #
    #           print the rows           #
    #                                    #
    ######################################
    @result .=sort( { .lc } ) if $sort;
    for @result -> $value {
        put &row-formatting($cnt, $colour, $syntax) ~ Sprintf("%-*s", $width, $value) ~ ($colour ?? t.text-reset !! '');
        $cnt++;
        ##########################################
        #                                        #
        #    print page ending and beginning     #
        #    to make pages.                      #
        #                                        #
        ##########################################
        if $cnt % $page-length == 0 {
            $cnt = $start-cnt;
            if $starts-with-blank {
                if $overline-header eq '' {
                    $hline = centre($overline-header, $width);
                } else {
                    $hline = centre('', $width, $overline-header);
                }
                put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
                $cnt++;
                $hline = '';
            }
            for @fields.kv -> $ind, $field {
                $hline ~= Sprintf "%-*s", @field-widths[$ind],   &head-value($ind, $field, $colour, $syntax, @fields);
                $hline ~= Sprintf "%-*s", @between-widths[$ind], &head-between($ind, $field, $colour, $syntax, @fields);
            }
            put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
            $cnt++;
            if $underline-header {
                if $underline eq '' {
                    $hline = centre($underline, $width);
                } else {
                    $hline = centre('', $width, $underline);
                }
                put &row-formatting($cnt, $colour, $syntax) ~ $hline ~ ($colour ?? t.text-reset !! '');
                $cnt++;
                $hline = '';
            }
        } # if $cnt % $page-length == 0 #
    } # for @result.sort( { .lc } ) -> $value #
    if $put-line-at-bottom {
        $cnt = $start-cnt;
        if $colour {
            if $line-at-bottom eq '' {
                put &row-formatting($cnt, $colour, $syntax) ~ centre('', $width) ~ t.text-reset;
            } else {
                put &row-formatting($cnt, $colour, $syntax) ~ centre('', $width, $line-at-bottom) ~ t.text-reset;
            }
            $cnt++;
        } else {
            if $line-at-bottom eq '' {
                "".say;
            } else {
                say centre('', $width, $line-at-bottom);
            }
        }
    }
    return True;
} #`««« multi sub list-by(Str:D $prefix, Bool:D $colour is copy, Bool:D $syntax, Int:D $page-length,
                  Regex:D $pattern, Str:D @fields, %defaults, %rows, Int:D :$start-cnt = -3,
                  Bool:D :$starts-with-blank = True,
                  Str:D :$overline-header = '', Bool:D :$underline-header = True, Str:D :$underline = '=',
                  Bool:D :$put-line-at-bottom = True, Str:D $line-at-bottom = '=', Bool:D :$sort = True,
                  :&include-row:(Str:D $pref, Regex $pat, Str:D @f, %r --> Bool:D) = &default-include-row, 
                  :&head-value:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-value, 
                  :&head-between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds --> Str:D) = &default-head-between,
                  :&field-value:(Int:D $idx, Str:D $fld, $val, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-field-value, 
                  :&between:(Int:D $idx, Str:D $fld, Bool:D $c, Bool:D $syn, Str:D @flds, %r --> Str:D) = &default-between,
                  :&row-formatting:(Int:D $cnt, Bool:D $c, Bool:D $syn --> Str:D) = &default-row-formatting --> Bool:D) is export »»»

