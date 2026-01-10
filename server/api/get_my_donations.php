<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");
include_once 'dbconnect.php';

if (isset($_GET['userid'])) {
    $userid = $_GET['userid'];

    $sql = "SELECT * FROM tbl_donations WHERE user_id = '$userid' ORDER BY donation_date DESC";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $rows = array();
        while ($row = $result->fetch_assoc()) {
            $rows[] = $row;
        }
        echo json_encode(array("status" => "success", "data" => $rows));
    } else {
        echo json_encode(array("status" => "failed", "data" => null));
    }
} else {
    echo json_encode(array("status" => "failed", "data" => null));
}
?>