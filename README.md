Display::Listings
=================

Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [list-by(…)](#list-by)

    * [Examples:](#examples)

      * [A more complete example:](#a-more-complete-example)

      * [Another example:](#another-example)

        * [An Example of the above code **`list-editors-backups(…)`** at work:](#An-Example-of-the-above-code-list-editors-backups-at-work)

  * [The default callbacks](#the-default-callbacks)

    * [The hash of hashes stuff](#the-hash-of-hashes-stuff)

    * [The array of hashes stuff](#the-array-of-hashes-stuff)

NAME
====

Display::Listings 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.8

TITLE
=====

Display::Listings

SUBTITLE
========

A Raku module for displaying lines in a listing.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Display-Listings/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

A **Raku** module for managing the users GUI Editor preferences in a variety of programs. 

### list-by(…)

This is a multi sub it has two signatures.

```raku
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
```

[Top of Document](#table-of-contents)

And

```raku
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
```

**Note: you have to be careful writing your own callbacks like `:&include-row` you need to get the signature of said callback exactly right or you will run into difficult to debug errors, with no version of the `list-by` multi sub matching etc.** 

[Top of Document](#table-of-contents)

### Examples:

```raku
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
```

[Top of Document](#table-of-contents)

#### A more complete example:

```raku
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
```

[Top of Document](#table-of-contents)

#### Another example

```raku
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
```

[Top of Document](#table-of-contents)

#### An Example of the above code **`list-editors-backups(…)`** at work:

![image not available here go to the github page](/docs/images/sc-list-editors-backups.png)

[Top of Document](#table-of-contents)

The default callbacks
---------------------

### The hash of hashes stuff

```raku
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
```

### The array of hashes stuff

```raku
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
```

