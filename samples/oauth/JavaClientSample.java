package com.example;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

import org.json.JSONObject;

/**
 * Sample java code to understand how to integrate OAuth API with Basic authorization header
 * 
 * For OAuthToken API integration, used HttpURLConnection. 
 * 
 * There are other client libraries can be also used like HttpOk or HttpClient(http://www.baeldung.com/httpclient-post-http-request).
 * 
 * @author thinkhr
 *
 */
public class JavaClientSample {

    public static final String POST_METHOD = "POST";
    public static final String AUTHORIZATION = "Authorization";
    public static final String BASIC = "Basic ";
    
    
    public static void main(String[] args) {

        String oauthTokenUrl = "<<Thinkhr-OAuth token URL>>"; //Sandbox URL is https://restapis.thinkhr-sandbox.com/v1/oauth/token
        String consumerKey = "<<Your consumer_key>>";
        String consumerSecret = "<<Your consumer secret>>";
        String username = "<<Your user name>>";
        String password = "<<Your password>>";
        
        try {
            URL url = new URL (oauthTokenUrl);
            
            String clientCredentials = Base64.getEncoder().encodeToString((consumerKey + ":" + consumerSecret).getBytes());

            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            
            connection.setRequestMethod(POST_METHOD);
            connection.setDoInput(true);
            connection.setDoOutput(true);
            connection.setRequestProperty(AUTHORIZATION, BASIC + clientCredentials);
            
            String formParameters = getFormParameters(username, password);

            OutputStream os = connection.getOutputStream();
            BufferedWriter writer = new BufferedWriter(
                    new OutputStreamWriter(os));
            writer.write(formParameters);
            
            writer.flush();
            writer.close();
            os.close();
            connection.connect();

            if (connection.getResponseCode() != HttpURLConnection.HTTP_OK) {
                throw new RuntimeException("Failed : HTTP error code : "
                        + connection.getResponseCode());
            }

            BufferedReader br = new BufferedReader(new InputStreamReader(
                    (connection.getInputStream())));

            StringBuilder tokenResponse = new StringBuilder();
            
            String line;
            while ((line = br.readLine()) != null) {
                tokenResponse.append(line);
            }
            
            System.out.println("Output from Server .... \n" + tokenResponse);
            
            connection.disconnect();

            //To convert String into Json
            //Using this lib (org.json) you can convert strings to json objects: http://www.json.org/java/
            JSONObject jsonObj = new JSONObject(tokenResponse.toString());
            System.out.println("Access token " + jsonObj.get("access_token"));
            
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * To build form parameters
     * 
     * @return
     */
    public static String getFormParameters(String username, String password) {
        StringBuilder formParmsSB = new StringBuilder();
        formParmsSB.append("grant_type").append("=").append("password");
        formParmsSB.append("&");
        formParmsSB.append("username").append("=").append(username);
        formParmsSB.append("&");
        formParmsSB.append("password").append("=").append(password);
        return formParmsSB.toString();
    }

}