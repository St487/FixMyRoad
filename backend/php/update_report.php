<?php
header('Content-Type: application/json');
header("Access-Control-Allow-Origin: *");
include 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["status" => "error", "message" => "Invalid request method."]);
    exit;
}

$report_id    = isset($_POST['report_id']) && is_numeric($_POST['report_id']) ? (int)$_POST['report_id'] : null;
$user_id      = isset($_POST['user_id']) && is_numeric($_POST['user_id']) ? (int)$_POST['user_id'] : null;
$title        = isset($_POST['title']) ? trim($_POST['title']) : null;
$description  = isset($_POST['description']) ? trim($_POST['description']) : null;
$issue_type   = isset($_POST['type']) ? trim($_POST['type']) : null;
$location_text= isset($_POST['address']) ? trim($_POST['address']) : null;
$latitude     = isset($_POST['latitude']) && is_numeric($_POST['latitude']) ? (float)$_POST['latitude'] : null;
$longitude    = isset($_POST['longitude']) && is_numeric($_POST['longitude']) ? (float)$_POST['longitude'] : null;
$existingPhotos = isset($_POST['existing_photos']) ? $_POST['existing_photos'] : [];

if (!$report_id || !$user_id || !$title || !$description || !$issue_type || !$location_text || $latitude === null || $longitude === null) {
    echo json_encode(["status" => "error", "message" => "All required fields must be filled."]);
    exit;
}

// Handle image uploads (optional)
$photos = ['photo1' => null, 'photo2' => null, 'photo3' => null];
if (isset($_FILES['images'])) {
    $targetDir = "uploads/reports/";
    if (!file_exists($targetDir)) mkdir($targetDir, 0777, true);

    foreach ($_FILES['images']['tmp_name'] as $key => $tmpName) {
        if ($key > 2) break;
        $originalName = $_FILES['images']['name'][$key];
        $extension = pathinfo($originalName, PATHINFO_EXTENSION);
        $fileName = time() . '_' . uniqid() . '.' . $extension;
        $targetFilePath = $targetDir . $fileName;
        if (move_uploaded_file($tmpName, $targetFilePath)) {
            $photos["photo" . ($key + 1)] = $targetFilePath;
        }
    }
}

// Build update statement
$updateFields = "issue_type=?, title=?, description=?, location_text=?, latitude=?, longitude=?, updated_at=NOW(), updated_by=?";
$params = [$issue_type, $title, $description, $location_text, $latitude, $longitude, $user_id];

// Add photos if uploaded
foreach ($photos as $index => $photo) {
    if ($photo !== null) {
        $updateFields .= ", $index=?";
        $params[] = $photo;
    }
}

$stmt = $conn->prepare("UPDATE report SET $updateFields WHERE report_id=?");
$params[] = $report_id;

$types = '';
foreach ($params as $param) {
    if (is_int($param)) {
        $types .= 'i';
    } elseif (is_float($param)) {
        $types .= 'd';
    } else {
        $types .= 's';
    }
}

// Bind params
$stmt->bind_param($types, ...$params);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Report updated successfully."]);
} else {
    echo json_encode(["status" => "error", "message" => "Failed to update report: ".$stmt->error]);
}

$stmt->close();
$conn->close();
?>