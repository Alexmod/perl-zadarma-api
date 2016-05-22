#!/usr/bin/env perl 
use strict;
use warnings;
use utf8;
use feature 'say';
use Digest::SHA qw(hmac_sha1_hex);
use MIME::Base64 qw( encode_base64 );
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use Tie::Hash::Sorted;
use Data::URIEncode qw(complex_to_query);

#-------------------------------------------------------------------------------
#  Конфиг API,  путь для обращения и данные для передачи
#-------------------------------------------------------------------------------

my $api_key    = 'В личном кабинете zadarma.com -> API поле Key';
my $secret_key = 'В личном кабинете zadarma.com -> API   Secret';
my $path       = '/v1/info/balance/';
my %data       = ( 'format' => 'json', );

#-------------------------------------------------------------------------------
#  Обработка и формирование авторизационной строки
#-------------------------------------------------------------------------------

tie my %sorted_data, 'Tie::Hash::Sorted', 'Hash' => \%data;
my $query_string = complex_to_query( \%sorted_data );
my $data         = $path . $query_string . md5_hex($query_string);
my $digest       = hmac_sha1_hex( $data, $secret_key );
my $auth         = $api_key . ':' . encode_base64($digest);

#-------------------------------------------------------------------------------
#  Отправка запроса и получение ответа через LWP
#-------------------------------------------------------------------------------

my $browser    = LWP::UserAgent->new;
my @ns_headers = (
    'User-Agent'    => '-',
    'Authorization' => $auth,
);

my $url = 'https://api.zadarma.com' . $path . '?' . $query_string;
my $response = $browser->get( $url, @ns_headers );
if ( $response->is_success ) {
    say $response->decoded_content;
}
else {
    die $response->status_line;
}
