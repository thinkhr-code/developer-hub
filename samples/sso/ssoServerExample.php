<?php
//
// ThinkHR Platform - Server side SSO example in PHP
// 
// Developers:
//   To Register for Client Id and Client Secret: See Account Team
// 
// Errors:
//   Link will be blank on error
//

// Use a random hashcode for security
if ($_GET['hashCode'] != 'DKKLASKDLKUUEOQIEUOQS7QW9E87Q9ALSDKHKJDASHKJH') {
    die();
}

include('SsoCrypt.php');

$authCode  = !empty($_GET["AuthCode"]) ? $_GET["AuthCode"] : 'your default SSO AuthCode here';
$ssoId     = !empty($_GET["username"]) ? $_GET["username"] : '';
$redirect  = !empty($_GET["redirect"]) ? $_GET["redirect"] : '';
$link      = !empty($_GET["link"]) ? $_GET["link"] : "//apps.thinkhr.com/api/v1/throne/sso.json";
$publicKey = !empty($_GET["publicKey"]) ? $_GET["publicKey"] :'your default public key (e.g. clientId) here';
$encryptor = new SsoCrypt();
$ssoUrl    = $encryptor->encrypt($authCode, $ssoId, $redirect);
?>
<!DOCTYPE html>
<html>
<head>
    <title>SSO Example</title>
</head>
<body>
    <p>
        <a href="<?php echo $link; ?>?accessToken=<?= $ssoUrl; ?>&publicKey=<?php echo $publicKey;?>">Please click here to login</a>
    </p>
</body>
</html>
