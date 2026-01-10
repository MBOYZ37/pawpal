<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$api_key = 'd1c25da7-e50a-407d-9b8c-4bdd70bad8d9';
$collection_id = 'hkucvbds';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $email = $_POST['email'];
    $mobile = $_POST['phone']; 
    $name = $_POST['name'];
    $amount = $_POST['amount'];
    $description = $_POST['description'];

    $amount_cents = floatval($amount) * 100;

    $data = array(
        'collection_id' => $collection_id,
        'email' => $email,
        'mobile' => $mobile,
        'name' => $name,
        'amount' => $amount_cents,
        'description' => $description,
        'callback_url' => "http://localhost/pawpal/api/return_url.php", 
        'redirect_url' => "http://localhost/pawpal/api/payment_success.php" 
    );

    $process = curl_init($host);
    curl_setopt($process, CURLOPT_HEADER, 0);
    curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
    curl_setopt($process, CURLOPT_TIMEOUT, 30);
    curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
    curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
    curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data));

    $return = curl_exec($process);
    curl_close($process);

    $bill = json_decode($return, true);

    if (isset($bill['url'])) {
        echo json_encode(array("status" => "success", "url" => $bill['url'], "bill_id" => $bill['id']));
    } else {
        echo json_encode(array("status" => "failed", "message" => "Billplz Error"));
    }
}
?>