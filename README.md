# Welcome to the ThinkHR Developer's Hub

This github repository contains everything you need to get started using the ThinkHR platform APIs.

1. [Postman](#postman)
2. [Sample Code](#sample-code)
   1. [Oauth 2.0](#sample-code-oauth)
   2. [Excel](#sample-code-excel)
   2. [SSO](#sample-code-SSO)


## Postman

* ThinkHR APIs.postman_collection.json - examples for every published ThinkHR platform API.
* Sandbox.postman_environment.json - environment definition for our developer's sandbox.
* Production.postman_environment.json - environment definition for production, use with care.
* ThinkHR_Company_Bulk_Sample.csv - Sample text file for use with the /companies/bulk endpoint.
* ThinkHR_User_Bulk_Sample.csv - Sample text file for use with the /user/bulk endpoint.


<a id="sample-code"></a>
## Sample Code

Our sample code comes in the following varieties (not all samples have all varieties):

* Command Line via curl
* Excel / VBA
* Java
* Javascript
* PERL
* PHP

<a id="sample-code-oauth"></a>
### OAuth 2.0

Samples showing how to authenticate using the OAuth 2.0 password flow.  The token returned here is used in the authorization header for subsequent API calls.


<a id="sample-code-excel"></a>
### Excel

Sample showing how to invoke the ThinkHR APIs from Excel.

#### DataLoadViaVBA.xlsm

This spreadsheet (Password: ThinkHR) uses VBA to download from the ThinkHR platform all companies, users and configurations associated with the provided account credentials.  You will need your Client Id, Client Secret, ThinkHR username and password.

Use the Settings button to enter your credentials, or just click the Download button and you'll be prompted for them.  Credentials are hidden from view, but the password of the spreadsheet should be changed for your own security.


<a id="sample-code-sso"></a>
### Single Sign-On (SSO)

ThinkHR's SSO solution utilizes an access token encoded from an Authentication Code, a username and optionally a destination.  This token can be generated on the client side using Javascript, or on the server side using your language of choice. We've provided samples of both versions to get your started.


