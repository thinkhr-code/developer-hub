# Welcome to the ThinkHR Developer's Hub

This github repository contains everything you need to get started using the ThinkHR platform APIs.

## Postman

* ThinkHR APIs.postman_collection.json - examples for every published ThinkHR platform API.
* Sandbox.postman_environment.json - environment definition for our developer's sandbox.
* Production.postman_environment.json - environment definition for production, use with care.
* ThinkHR_Company_Bulk_Sample.csv - Sample text file for use with the /companies/bulk endpoint.
* ThinkHR_User_Bulk_Sample.csv - Sample text file for use with the /user/bulk endpoint.


## Sample Code

Our sample code comes in the following varieties:

* Command Line via curl
* Java
* Javascript
* PHP

### OAuth 2.0

Samples showing how to authenticate using the OAuth 2.0 password flow.  The token returned here is used in the authorization header for subsequent API calls.


## ThinkHR SKUs

The following is a list of available SKUs on the ThinkHR platform and a brief description of what they provide access to.  Depending on your agreement with ThinkHR, not all SKUs may be available in your Master Configuration.

### Master Configuration Only SKUs

These SKUs are only used by the parent organization and should never be added to a custom configuration.

* Reports - Enables the **Reports** tab containing usage and value reports.

### Recommended SKUs for all Configurations

These SKUs are recommended for all configurations.  They represent system features that we feel add value to the user's experience.

* Dashboard Recommended For You - Enables the "Recommended for You" widget on the home page.
* Partner Resources - Enables the **Resources** tab with collateral (partners/brokers only), risk, and safety resources.

### Product Specific SKUs

These SKUs provide access to specific ThinkHR products.  Product availability is based on your Master Configuration.  If there is a product listed which you would like to use but which is not part of your Master Configuration please contact your Account Manager
or Sales Representative.

#### Live

Ask our certified HR experts questions on HR, compliance and/or safety and receive authoritative advice and support.

* HR Advisors - Enables access to HR Advisors hotline and dashboard widget.
* Mobile = Enables access to our advisors through our mobile application.

#### Benefits Compliance Suite (BCS) Elite

Create fully compliant plan documents with an easy-to-use wizard and access to expert help through a dedicated support line staffed with benefits compliance advisors.

* BCS Elite - Enables access to the Benefits Compliance Suite Elite service via the Benefits Document Center.

#### Comply

Access thousands of up-to-date tools, documents, checklists and forms, as well as the latest news and information that support best practices in compliance for any type or size organization.

* Compliance - Enables access to the **Comply** tab and its related resources and materials.
* Calendar - Enables the Compliance Calendar, requires the Compliance SKU.

#### Handbook Builder

Our advanced Handbook Builder lets you meet compliance and legal requirements by creating a customized, all-in-one handbook with all the federal and state policies that apply to your employees and your organization.  You can even get them in Spanish.

To allow you maximum flexibility in your configuration building we provide the following SKUs.  Only one 'Employee Handbook...' SKU is needed per configuration, and Spanish requires one of the other SKUs to add value.

* Employee Handbook Builder - Enables access to Handbooks Library for display and download.
* Employee Handbook Multi State - Enables creation of multi-state, single-state & Federal handbooks within the Employee Handbook Builder.
* Employee Handbook One State - Enables creation of single-state & Federal handbooks within the Employee Handbook Builder.
* Employee Handbook Federal - Enables creation of only Federal handbooks within the Employee Handbook Builder.
* Spanish-language handbooks - Enables handbooks to be translated into Spanish.

#### Learn

Our modern, comprehensive training platform with over 200+ courses covering all of the hot-button topics and compliance essentials.

* Learn Admin - Enables Admins to perform user administration within the Learn system.  Without this SKU, Admins are considered Students.
* Training - Enables access to Learn system as a Student.

#### Single Sign ON

* Single Sign On (SSO) - Usually only included in the master configuration.  Include in a custom configuration if a customer needs their own SSO name and a different authentication field (email or username) from the broker's default.


### Deprecated/System SKUs

These SKUs are being deprecated and moved into the base software.  They will be removed from the Master Configuration in the coming week(s)/month(s) but are listed here to explain how they should be interpreted and used in the interim.

#### Only for the Master Configuration

* restapis - Enables access to the platform's REST APIs

#### Recommended for all Configurations

* My Account - Enables 'My Profile' which allows users to modify their account information.
* System Administration - Provides Broker/RE admins access to the system administration console for managing customers, users and configurations (Brokers only).

