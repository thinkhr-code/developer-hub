<?php
    $params               = [];
    $params['grant_type'] = 'password';
    $params['username']   = '<<Your user name>>';
    $params['password']   = '<<Your password>>';
    $oauth_token_uri      = '<<Thinkhr OAuth token API Url>>'; //Sandbox url : https://restapis.thinkhr-sandbox.com/v1/oauth/token
    $consumer_key         = '<<Your consumer_key>>';
    $consumer_secret      = '<<Your consumer_secret>>';
	
    // Get the Guzzle-client install at your php application.
    // Reference http://docs.guzzlephp.org
    $client      = new GuzzleHttp\Client(['base_uri' => $oauth_token_uri]);
    $responseRaw = $client->post($uri, [
    	'verify'      => false,
    	'form_params' => $params,
    	'auth'        => [
			$consumer_key,
			$consumer_secret
		]
    ]);
    
    $responseObject = json_decode($responseRaw->getBody()->getContents());
    $access_token   = $responseObject->access_token;
    echo $access_token;
