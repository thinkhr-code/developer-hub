#!/usr/bin/perl

use strict;
use warnings;

use CGI::Carp;
use CGI;
use Data::Dumper;
use HTTP::Request::Common;
use JSON qw( decode_json );
use LWP::UserAgent;

# Constants belong to the ThinkHR Sales Demo Broker account
use constant {
   PublicKey => 'your clientId here',
   SecretKey => 'your clientSecret here'
};

my $cgi = CGI->new();
my $publicKey = $cgi->param( 'publicKey' ) || PublicKey;
my $secretKey = $cgi->param( 'secretKey' ) || SecretKey;
my $domain = $cgi->param( 'domain' ) || 'thinkhr';
my $userName = $cgi->param( 'userName' ) || '';
my $baseURL = "https://restapis.$domain.com";
my $tokenURL = "$baseURL/v1/oauth/identity/token";
my $srcFile = 'oidcSample.html';

my $companies = [];
my $users = [];
my $issues = [];
my $alerts = [];

my $ua = LWP::UserAgent->new();
my $req = POST $tokenURL, 'User-Agent' => '', 'Content-Type' => 'application/json', Content => '{ "grantType": "sso", "mappedValue": "' . $userName . '" }';
$req->authorization_basic( $publicKey, $secretKey );

my $resp = $ua->request( $req );
my $json = $resp->is_success ? decode_json( $resp->decoded_content ) : \{};

if ( $resp->is_success )
{
   my $token = $$json{ 'access_token' };

   $req = GET "$baseURL/v1/companies?limit=5&isActive=1", 'User-Agent' => '', 'Authorization' => "Bearer $token";
   $resp = $ua->request( $req );

   if ( $resp->is_success )
   {
      $json = decode_json( $resp->decoded_content );
      if ( $$json{ 'totalRecords' } > 0 )
      {
         $companies = $$json{ 'companies' };
      }
   }


   $req = GET "$baseURL/v1/users?limit=5&isActive=1", 'User-Agent' => '', 'Authorization' => "Bearer $token";
   $resp = $ua->request( $req );

   if ( $resp->is_success )
   {
      $json = decode_json( $resp->decoded_content );
      if ( $$json{ 'totalRecords' } > 0 )
      {
         $users = $$json{ 'users' };
      }
   }

   $req = GET "$baseURL/v1/issues?limit=5&isActive=1", 'User-Agent' => '', 'Authorization' => "Bearer $token";
   $resp = $ua->request( $req );

   if ( $resp->is_success )
   {
      $json = decode_json( $resp->decoded_content );
      if ( $$json{ 'totalRecords' } > 0 )
      {
         $issues = $$json{ 'issues' };
      }
   }

   $req = GET "$baseURL/v1/lawalerts?limit=5&jurisdiction=FE&startMonth=2018-01&endMonth=2018-10", 'User-Agent' => '', 'Authorization' => "Bearer $token";
   $resp = $ua->request( $req );

   if ( $resp->is_success )
   {
      $json = decode_json( $resp->decoded_content );
      if ( $$json{ 'totalRecords' } > 0 )
      {
         $alerts = $$json{ 'lawAlerts' };
      }
   }

   data( $companies, $users, $issues, $alerts );
}
else
{
   error( "Unable to retrieve authorization for the provided credentials" );
}

sub debug
{
   my $text = shift;

   if ( !$ENV{ 'GATEWAY_INTERFACE' } )
   {
      print $text;
   }
}

sub data
{
   my ( $companies_ref, $users_ref, $issues_ref, $alerts_ref ) = @_;
   my @companies = @{ $companies_ref };
   my @users = @{ $users_ref };
   my @issues = @{ $issues_ref };
   my @alerts = @{ $alerts_ref };
   my $output = do { local( @ARGV, $/ ) = $srcFile; <> }; # One line hack to read in the file contents in a single go.
   my $message = '';

   if ( $#companies > 0 )
   {
      $message .= outputHeader( 'Companies' );
      $message .= output4( 1, 'ID', 'Name', 'Phone', 'Since' );

      foreach my $rec ( @companies )
      {
         $message .= output4( 0, $$rec{'companyId'}, $$rec{'companyName'}, $$rec{'companyPhone'}, $$rec{'companySince'} );
      }
   }

   if ( $#users > 0 )
   {
      $message .= outputHeader( 'Users' );
      $message .= output4( 1, 'ID', 'First Name', 'Last Name', 'User Name' );

      foreach my $rec ( @$users )
      {
         $message .= output4( 0, $$rec{'userId'}, $$rec{'firstName'}, $$rec{'lastName'}, $$rec{'userName'} );
      }
   }

   if ( $#issues > 0 )
   {
      $message .= outputHeader( 'Issues' );
      $message .= output4( 1, 'ID', 'Category', 'Status', 'Created' );

      foreach my $rec ( @$issues )
      {
         $message .= output4( 0, $$rec{'issueId'}, $$rec{'Category'}, $$rec{'status'}, $$rec{'created'} );
      }
   }

   if ( $#alerts > 0 )
   {
      $message .= outputHeader( 'Federal Law Alerts June - October, 2018' );
      $message .= output3( 1, 'Title', 'Jurisdiction', 'Publication Date' );

      foreach my $rec ( @$alerts )
      {
         $message .= output3( 0, $$rec{'title'}, $$rec{'jurisdiction'}, $$rec{'publicationDate'} );
      }
   }

   $output =~ s/<!-- data -->/$message/;

   print "Content-Type: text/html\n\n$output";
}

sub error
{
   my $message = shift;
   my $output = do { local( @ARGV, $/ ) = $srcFile; <> }; # One line hack to read in the file contents in a single go.

   $message = '<div class="row"><div class="col-sm-12 card-wrap" style="margin-top:10px"><div class="card"><font color="red"><center>' . $message . "</center></font></div></div></div>\n\n";
   $output =~ s/<!-- error -->/$message/;
   $output =~ s/\.\.\/sso/sso/;

   print "Content-Type: text/html\n\n$output";
}

sub outputHeader
{
   my $title = shift;

      return <<EOF;
   <div class="row">
      <div id="card-1" class="col-sm-12 card-wrap">
         <h4 style="margin:0px;font-weight: normal;font-size: 26px;">$title</h4>
      </div>
   </div>
EOF
}

sub output3
{
   my( $header, @data ) = @_;
   my $card = $header ? 'card-header' : 'card-wrap';

   return <<EOF;
   <div class="row $card" style="margin-top:10px">
      <div class="col-sm-4">
         $data[0]
      </div>
      <div class="col-sm-4">
         $data[1]
      </div>
      <div class="col-sm-4">
         $data[2]
      </div>
   </div>
EOF
}



sub output4
{
   my( $header, @data ) = @_;
   my $card = $header ? 'card-header' : 'card-wrap';

   return <<EOF;
   <div class="row $card" style="margin-top:10px">
      <div class="col-sm-3">
         $data[0]
      </div>
      <div class="col-sm-3">
         $data[1]
      </div>
      <div class="col-sm-3">
         $data[2]
      </div>
      <div class="col-sm-3">
         $data[3]
      </div>
   </div>
EOF
}


