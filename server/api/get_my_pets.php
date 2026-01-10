<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include_once 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] == 'GET') {

    // QUERY UPDATED TO MATCH YOUR ACTUAL DB COLUMNS
    // tbl_users columns: user_id, name, email, phone, reg_date
    // tbl_pets columns:  pet_id, images, etc.
    
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
        WHERE 1=1 
    ";

    // 1. Search Logic
    if (isset($_GET['search']) && !empty($_GET['search'])) {
        $search = $conn->real_escape_string($_GET['search']);
        $query .= " AND (p.pet_name LIKE '%$search%' OR p.pet_type LIKE '%$search%' OR p.description LIKE '%$search%')";
    }

    // 2. Filter Logic
    if (isset($_GET['category']) && !empty($_GET['category']) && $_GET['category'] != 'All') {
        $category = $conn->real_escape_string($_GET['category']);
        $query .= " AND p.pet_type = '$category'";
    }

    $query .= " ORDER BY p.pet_id DESC";

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