# OpenID Connect Single Sign-On to Data APIs Demonstration Widget #

This is a react application which illustrates using OpenID Connect with ThinkHR APIs to display User constrained data within a native application.

## Dependencies ##

### Node Version ###
(8.10.0) 

## Step 1: Install Dependencies ##
With npm installed, run the following command to install the required packages:
	
$ npm i

## Step 2: Set Node Environment Variables ##

### Public and Private keys obtained from your ThinkHR Account Team

clientId={{ clientId }}
clientSecret={{ clientSecret }}
	
### The REST API endpoint that you wish to run against.

baseUrl=https://restapis.thinkhr.com/

## Step 3: Build Project dist package ##

npm run build

Development Note: Combine Steps 2 and 3 like so - clientId=YourClientId clientSecret=YourClientSecret baseUrl=https://restapis.thinkhr.com/ npm run build
		
## Step 4: Run the application ##

Point your web server of choice to the 'dist' directory
