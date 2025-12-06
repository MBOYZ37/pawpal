<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');

include_once 'dbconnect.php';

$response = array();

if (isset($_POST['user_id'], $_POST['pet_name'], $_POST['pet_type'], $_POST['category'], $_POST['description'], $_POST['images'], $_POST['lat'], $_POST['lng'])) {

    $user_id = $_POST['user_id'];
    $pet_name = $_POST['pet_name'];
    $pet_type = $_POST['pet_type'];
    $category = $_POST['category'];
    $description = $_POST['description'];
    $images_json = $_POST['images'];
    $lat = $_POST['lat'];
    $lng = $_POST['lng'];

    $image_paths = array();

    $images = json_decode($images_json, true);
    if ($images && count($images) > 0) {
        foreach ($images as $index => $img) {
            $img_data = base64_decode($img);
            $filename = 'images/' . uniqid('pet_') . '.png';
            
            if (!file_exists('images')) {
                mkdir('images', 0777, true);
            }

            if (file_put_contents($filename, $img_data)) {
                $image_paths[] = $filename;
            }
        }
    }

    $images_str = json_encode($image_paths);

    $stmt = $conn->prepare("INSERT INTO pets (user_id, pet_name, pet_type, category, description, images, lat, lng) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    $stmt->bind_param("isssssss", $user_id, $pet_name, $pet_type, $category, $description, $images_str, $lat, $lng);

    if ($stmt->execute()) {
        $response['status'] = 'success';
        $response['message'] = 'Pet submitted successfully';
    } else {
        $response['status'] = 'error';
        $response['message'] = 'Failed to submit pet: ' . $stmt->error;
    }

    $stmt->close();

} else {
    $response['status'] = 'error';
    $response['message'] = 'Incomplete data';
}

echo json_encode($response);
?>
