<?php
header("Access-Control-Allow-Origin: *");
include 'dbconnect.php';

if ($_SERVER['REQUEST_METHOD'] != 'POST') {
    http_response_code(405);
    echo json_encode(array('error' => 'Method Not Allowed'));
    exit();
}

$user_id     = $_POST['user_id'];
$pet_name    = addslashes($_POST['pet_name']);
$pet_type    = $_POST['pet_type'];
$category    = $_POST['category'];
$description = addslashes($_POST['description']);
$lat         = $_POST['lat'];
$lng         = $_POST['lng'];

// Decode JSON array of images
$imagesArray = json_decode($_POST['images'], true);

if (!is_array($imagesArray) || count($imagesArray) == 0) {
    sendJsonResponse(array('status' => 'failed', 'message' => 'No images provided'));
    exit();
}

// Insert new pet into database without image first
$sqlinsertpets = "INSERT INTO tbl_pets(user_id, pet_name, pet_type, category, description, lat, lng) 
                  VALUES ('$user_id','$pet_name','$pet_type','$category','$description','$lat','$lng')";

try {
    if ($conn->query($sqlinsertpets) === TRUE) {

        // Get last inserted pet ID
        $last_id = $conn->insert_id;

        $savedImagePaths = [];

        foreach ($imagesArray as $index => $encodedimage) {
            $decodedImage = base64_decode($encodedimage);
            $imagepath = "../uploads/pets_" . $last_id . "_" . ($index + 1) . ".png";
            file_put_contents($imagepath, $decodedImage);
            $savedImagePaths[] = "uploads/pets_" . $last_id . "_" . ($index + 1) . ".png";
        }

        // Save all image paths in DB as comma-separated
        $imagesPathString = implode(",", $savedImagePaths);

        $sqlupdate = "UPDATE tbl_pets SET images_path = '$imagesPathString' WHERE pet_id = '$last_id'";
        $conn->query($sqlupdate);

        $response = array('status' => 'success', 'message' => 'Pet added successfully');
        sendJsonResponse($response);

    } else {
        $response = array('status' => 'failed', 'message' => 'Pet not added');
        sendJsonResponse($response);
    }
} catch (Exception $e) {
    $response = array('status' => 'failed', 'message' => $e->getMessage());
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>