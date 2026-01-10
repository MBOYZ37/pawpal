<?php
// --- CORS HEADERS FOR WEB ---
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

// Handle the "Preflight" check (Browser asks: "Can I send data?")
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
// -----------------------------

header('Content-Type: application/json');
include_once 'dbconnect.php';

$response = array();

// Get POST data
$user_id    = isset($_POST['user_id']) ? $_POST['user_id'] : '';
$pet_name   = isset($_POST['pet_name']) ? $_POST['pet_name'] : '';
$pet_type   = isset($_POST['pet_type']) ? $_POST['pet_type'] : '';
$category   = isset($_POST['category']) ? $_POST['category'] : '';
$description= isset($_POST['description']) ? $_POST['description'] : '';
$lat        = isset($_POST['lat']) ? $_POST['lat'] : '';
$lng        = isset($_POST['lng']) ? $_POST['lng'] : '';
$imagesJson = isset($_POST['images']) ? $_POST['images'] : '[]';

// Validate required fields
if (empty($user_id) || empty($pet_name) || empty($pet_type) || empty($category) || empty($description)) {
    $response['status'] = 'error';
    $response['message'] = 'Missing required fields';
    echo json_encode($response);
    exit();
}

// Decode JSON array of base64 images
$images = json_decode($imagesJson, true);
$uploadedFiles = [];

if (!empty($images) && is_array($images)) {
    foreach ($images as $index => $imgBase64) {
        // Decode the base64 string
        $imgData = base64_decode($imgBase64);
        
        if ($imgData !== false) {
            $fileName = 'pet_' . time() . "_$index.png";
            $filePath = '../uploads/' . $fileName;

            // Create uploads folder if not exists
            if (!file_exists('../uploads/')) {
                mkdir('../uploads/', 0777, true);
            }

            if (file_put_contents($filePath, $imgData)) {
                $uploadedFiles[] = $fileName;
            }
        }
    }
}

// Convert uploaded file names to comma-separated string
$imagesStr = implode(',', $uploadedFiles);

// Insert pet into database
$stmt = $conn->prepare("INSERT INTO tbl_pets(user_id, pet_name, pet_type, category, description, images, lat, lng) VALUES(?,?,?,?,?,?,?,?)");
$stmt->bind_param("ssssssss", $user_id, $pet_name, $pet_type, $category, $description, $imagesStr, $lat, $lng);

if ($stmt->execute()) {
    $response['status'] = 'success';
    $response['message'] = 'Pet submitted successfully';
} else {
    $response['status'] = 'error';
    $response['message'] = 'Failed to submit pet: ' . $stmt->error;
}

$stmt->close();
$conn->close();

echo json_encode($response);
?>