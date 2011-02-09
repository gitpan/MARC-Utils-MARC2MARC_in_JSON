package MARC::Utils::MARC2MARC_in_JSON;

use 5.008008;
use strict;
use warnings;

our $VERSION = '0.01';

our (@ISA, @EXPORT_OK);
BEGIN {
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT_OK = qw( marc2marc_in_json marc_in_json2marc );
}

use MARC::Record;

sub marc2marc_in_json {
    my( $marc_record ) = @_;

    my %marc_in_json;

    for my $leader ( $marc_record->leader() ) {
        $marc_in_json{'leader'} = $leader;
    }

    for my $field ( $marc_record->fields() ) {

        my $ftag = $field->tag();

        if( $field->is_control_field() ) {
            push @{$marc_in_json{'fields'}}, { $ftag => $field->data() };
        }

        else {
            my $fdata;

            for my $i ( 1, 2 ) {
                $fdata->{"ind$i"} = $field->indicator( $i )
            }

            for my $subfield ( $field->subfields ) {
                push @{$fdata->{'subfields'}}, { $subfield->[0] => $subfield->[1] };
            }

            push @{$marc_in_json{'fields'}}, { $ftag => $fdata };
        }
    }

    \%marc_in_json;  # returned
}

sub marc_in_json2marc {
    my( $marc_in_json ) = @_;

    my $marc_record = MARC::Record->new();

    for my $leader ( $marc_in_json->{'leader'} ) {
        $marc_record->leader( $leader );
    }

    for my $field ( @{$marc_in_json->{'fields'}} ) {
        my( $ftag, $fdata ) = %$field;

        if( ref $fdata ) {
            my @subfields;
            for my $subfield ( @{$fdata->{'subfields'}} ) {
                my( $sftag, $sfdata ) = %$subfield;
                push @subfields, $sftag, $sfdata;
            }
            $marc_record->append_fields( MARC::Field->new(
                $ftag, $fdata->{'ind1'}, $fdata->{'ind2'}, @subfields ) );
        }

        # control field
        else {
            $marc_record->append_fields( MARC::Field->new( $ftag, $fdata ) );
        }
    }

    $marc_record;  #returned
}

1;

__END__

=head1 NAME

MARC::Utils::MARC2MARC_in_JSON - Perl module that provides routines to
convert from a MARC::Record object to a MARC-in-JSON hash structure.

=head1 SYNOPSIS

    use MARC::Utils::MARC2MARC_in_JSON qw( marc2marc_in_json marc_in_json2marc );

    $marc_in_json = marc2marc_in_json( $marc_record );
    $marc_record  = marc_in_json2marc( $marc_in_json );

=head1 DESCRIPTION

MARC::Utils::MARC2MARC_in_JSON - Perl module that provides routines to
convert from a MARC::Record object to a MARC-in-JSON hash structure as
described here:

http://dilettantes.code4lib.org/blog/2010/09/a-proposal-to-serialize-marc-in-json/

Note that I did I<not> say we were converting to JSON (though the name
may seem to imply that).  Instead, we are converting to a hash
structure that is the same as you would get if you deserialized JSON
text (in MARC-in-JSON format) to perl.

If you indeed want JSON, then you can simply use the JSON module to
convert the hash.

=head1 SEE ALSO

MARC::Record
JSON

=head1 AUTHOR

Brad Baxter, E<lt>bmb@galib.uga.eduE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Brad Baxter

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

