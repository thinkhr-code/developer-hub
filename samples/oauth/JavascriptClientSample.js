// Include jquery script   
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.min.js"></script>

function make_base_auth(user, password) {
  var clientCredentials = user + ':' + password;
  var hash = window.btoa(clientCredentials);
  return "Basic " + hash;
}


function execute() {
	var username = "<<Your username>>";
	var password = "<<Your password>>";
	var consumer_key = "<<Your consumer_key>>";
	var consumer_secret = "<<Your consumer_secret>>" ;
	var oauth_token_url = "<<Your oauth token API url>>";
	
	$.ajax
	  ({
	    type: "POST",
	    url: oauth_token_url,
	    dataType: 'json',
	    data: "grant_type=password&username=" + username+ "&password="+password + "",
	    beforeSend: function (xhr){ 
	        xhr.setRequestHeader('Authorization', make_base_auth(username, password)); 
	    },
	    success: function (data){
			console.log(data);
	        alert('Thanks for your comment!'); 
	    }
	});
}

