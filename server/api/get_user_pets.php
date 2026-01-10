<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include_once 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $userid = $_GET['userid']; 

    $query = "
        SELECT 
            p.pet_id, 
            p.user_id, 
            p.pet_name, 
            p.pet_type, 
            p.category, 
            p.description, 
            p.images as images_path, 
            p.lat, 
            p.lng, 
            p.created_at,
            u.name, 
            u.email, 
            u.phone, 
            u.reg_date
        FROM tbl_pets p
        JOIN tbl_users u ON p.user_id = u.user_id
        WHERE p.user_id = '$userid'
        ORDER BY p.pet_id DESC
    ";

    $result = $conn->query($query);

    if ($result && $result->num_rows > 0) {
        $data = [];
        while ($row = $result->fetch_assoc()) {
            $data[] = $row;
        }
        echo json_encode(["status" => "success", "data" => $data]);
    } else {
        echo json_encode(["status" => "success", "data" => []]);
    }
}
?>