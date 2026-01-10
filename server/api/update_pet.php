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
    $pet_id = $_POST['pet_id'];
    $pet_name = $_POST['pet_name'];
    $pet_type = $_POST['pet_type'];
    $category = $_POST['category'];
    $description = $_POST['description'];
    
    // We use a prepared statement for security
    $sql = "UPDATE tbl_pets SET pet_name = ?, pet_type = ?, category = ?, description = ? WHERE pet_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $pet_name, $pet_type, $category, $description, $pet_id);
    
    if ($stmt->execute()) {
        echo json_encode(array("status" => "success", "message" => "Pet updated successfully"));
    } else {
        echo json_encode(array("status" => "failed", "message" => "Error updating pet"));
    }
}
?>