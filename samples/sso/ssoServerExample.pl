#!/usr/bin/perl

# ThinkHR Platform - Server side SSO example in PERL
#
# This example assumes that all required information has been posted here.  Response will be a standard HTTP redirect to
# the requested location (if any) or the ThinkHR application home page.
#
# Developers:
#   To Register for Client Id and Client Secret: See Account Team
#
# Errors:
#   Error is printed to STDOUT

use strict;
use warnings;

use CGI::Carp;
use CGI;
use Crypt::CBC;
use Crypt::Digest::SHA256 qw( sha256 sha256_hex );
use Crypt::OpenSSL::AES;
use Crypt::OpenSSL::Random qw( random_bytes );
use Digest::SHA qw( hmac_sha256 );
use JSON;
use LWP::UserAgent;
use MIME::Base64;

use constant {
   AuthCode => 'your SSO AuthCode here',
   PublicKey => 'your clientId here',
   SecretKey => 'your clientSecret here'
};

my $cgi = CGI->new();
my $authCode = $cgi->param( 'authCode' ) || AuthCode;
my $publicKey = $cgi->param( 'publicKey' ) || PublicKey;
my $secretKey = $cgi->param( 'secretKey' ) || SecretKey;
my $domain = $cgi->param( 'domain' ) || 'thinkhr';   # thinkhr and thinkhr-sandbox are acceptable here
my $userName = $cgi->param( 'userName' ) || '';      # what user are we signing in?
my $redirectTo = $cgi->param( 'redirectTo' ) || '';  # where should they land once signed in?  If empty users lands on the dashboard

my $baseURL = "https://apps.$domain.com";
my $redirect = '';

my $url = "$baseURL/api/v1/throne/sso.json?accessToken=";

# Generate the random IV we'll need for our encryption
my $randomIV = random_bytes( 16 );

if ( !$randomIV )
{
   # This shouldn't happen, but just in case.
   print "Failed random generation\n\n";
}

# Configure the key we're going to use to be a sha256 hash of the secret key
my $key = sha256( $secretKey );

#
# To create an AccessCode you must:
#    * Use AES 256bit Cipher-Block-Chaining (CBC)
#    * Key is a SHA-256 Hash of your clientSecret
#    * Generate a HMAC using the encrypted text and your hash'd key
#    * Create the AccesToken by concatenating the randomIV, HMAC and Cipher together, then encode with base64, then encode for URL

my $cipher = Crypt::CBC->new(
   -cipher => 'Crypt::OpenSSL::AES',
   -header => 'none',
   -padding => 'standard',
   -literal_key => 1,
   -iv => $randomIV,
   -key => $key,   # Encrypt my data using a SHA256 hash of my Secret Key
   -keysize => 32 # 256 bits
);

my $plainText = $cgi->param( 'text' ) || join( '|', $authCode, $userName, $redirectTo );
my $cipherText = $cipher->encrypt( $plainText );
my $hmac = hmac_sha256( $cipherText, $key );
my $accessToken = encode_base64( "$randomIV$hmac$cipherText", '' );
my $urlAccessToken = urlEncode( $accessToken );

# The final URL is .../sso.json?accessToken=<generatedAccessToken>&publicKey=<yourClientId>
print $cgi->redirect( "$url$urlAccessToken&publicKey=$publicKey" );

# URL encoding is a simple transformation so using a local function instead of loading a library.
sub urlEncode
{
   my $url = shift;

   $url =~ s/ /+/g;
   $url =~ s/([^A-Za-z0-9\+-])/sprintf("%%%02X", ord($1))/seg;

   return $url;
}

