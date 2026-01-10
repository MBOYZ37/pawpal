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
    if (isset($_POST['pet_id'])) {
        $pet_id = $_POST['pet_id'];
        
        // Optional: Check if the user asking to delete is actually the owner
        // For now, we will trust the app logic
        
        $sql = "DELETE FROM tbl_pets WHERE pet_id = '$pet_id'";
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("status" => "success", "message" => "Pet deleted successfully"));
        } else {
            echo json_encode(array("status" => "failed", "message" => "Error deleting pet"));
        }
    } else {
        echo json_encode(array("status" => "failed", "message" => "Missing Pet ID"));
    }
}
?>