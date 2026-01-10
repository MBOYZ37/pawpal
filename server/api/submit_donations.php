<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

include_once 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $user_id = $_POST['user_id'];
    $pet_id = $_POST['pet_id'];
    $donation_type = $_POST['donation_type']; 
    $amount = $_POST['amount'];
    $description = $_POST['description'];

    $sql = "INSERT INTO tbl_donations (user_id, pet_id, donation_type, amount, description, donation_date) VALUES (?, ?, ?, ?, ?, NOW())";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssds", $user_id, $pet_id, $donation_type, $amount, $description);

    if ($stmt->execute()) {
        echo json_encode(array("status" => "success", "message" => "Donation submitted successfully"));
    } else {
        echo json_encode(array("status" => "failed", "message" => "Error submitting donation"));
    }
}
?>