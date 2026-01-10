<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once 'dbconnect.php';

$response = array('status' => 'failed', 'message' => 'Unknown error');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $userid = $_POST['userid'];
    $name = $_POST['name'];
    $phone = $_POST['phone'];
    $password = $_POST['password'];
    $image = $_POST['image'];

    $sql = "UPDATE tbl_users SET name = ?, phone = ? WHERE user_id = ?";

    if (!empty($password)) {
        $sha1pass = sha1($password);
        $sql = "UPDATE tbl_users SET name = ?, phone = ?, password = '$sha1pass' WHERE user_id = ?";
    }

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $name, $phone, $userid);
    
    if ($stmt->execute()) {
        if (!empty($image)) {
            $decoded_string = base64_decode($image);
            $path = '../assets/profile/';
            $filename = "profile_$userid.png";
            
            if (!file_exists($path)) {
                mkdir($path, 0777, true);
            }
            
            file_put_contents($path . $filename, $decoded_string);
        }
        
        $response['status'] = 'success';
        $response['message'] = 'Profile updated successfully';
    } else {
        $response['message'] = 'Database update failed';
    }
}

echo json_encode($response);
?>