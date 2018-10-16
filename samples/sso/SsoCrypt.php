<?php
//
// ThinkHR Platform - SSO Helper Class in PHP
// 
// Developers:
//  To Register for Client Id and Client Secret: See Account Team
// 
//  Errors:
//    Link will be blank on error

class SsoCrypt
{
    private $encryptionMethod;
    private $secretKey;
    
    function __construct(){
        $this->encryptionMethod = 'AES-256-CBC';
        $this->secretKey        = 'your clientSecret goes here';
    }

    /**
    * Encrypt sso params
    *
    * @param string $authCode
    * @param string $ssoId
    * @return string
    */
    public function encrypt($authCode = '', $ssoId = '', $redirect = '')
    {
        $result = '';
        if (empty($authCode) || empty($ssoId)) {
            return $result;
        } 

        $string           = $authCode . '|' . $ssoId . '|' . $redirect;
        $string           = urldecode($string);
        $encryptionMethod = $this->encryptionMethod;
        $key              = hash('sha256', $this->secretKey, true);

        $encryptIv = openssl_random_pseudo_bytes(16);
        $cipher    = openssl_encrypt($string, $encryptionMethod, $key, OPENSSL_RAW_DATA, $encryptIv);
        $hash      = hash_hmac('sha256', $cipher, $key, true);
        $result    = urlencode(base64_encode($encryptIv . $hash . $cipher));

        return $result;
    }
}
?>
