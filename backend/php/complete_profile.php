<?php
header('Content-Type: application/json');
include 'config.php';

$data = json_decode(file_get_contents("php://input"), true);

$user_id = $data['user_id'] ?? null;
$first_name = trim($data['first_name'] ?? '');
$last_name = trim($data['last_name'] ?? '');
$address = trim($data['address'] ?? '');
$postal_code = trim($data['postal_code'] ?? '');
$state = trim($data['state'] ?? '');
$city = trim($data['city'] ?? '');

// Validation
if (!$user_id || empty($first_name) || empty($last_name) || empty($address) || empty($postal_code) || empty($state) || empty($city)) {
    echo json_encode(['status' => 'error', 'message' => 'Please complete all fields']);
    exit;
}

// Optional: validate postal code (5 digits)
if (!preg_match('/^\d{5}$/', $postal_code)) {
    echo json_encode(['status' => 'error', 'message' => 'Postal code must be 5 digits']);
    exit;
}

// Handle optional profile picture upload
$profile_picture = null;
if (isset($_FILES['profile_picture'])) {
    $targetDir = "uploads/";
    $fileName = basename($_FILES["profile_picture"]["name"]);
    $targetFilePath = $targetDir . time() . "_" . $fileName;

    if (move_uploaded_file($_FILES["profile_picture"]["tmp_name"], $targetFilePath)) {
        $profile_picture = $targetFilePath;
    }
}

// Update user profile
$query = "UPDATE users SET first_name = ?, last_name = ?, address = ?, postal_code = ?, state = ?, city = ?, updated_at = NOW()";
$params = [$first_name, $last_name, $address, $postal_code, $state, $city];

if ($profile_picture) {
    $query .= ", profile_picture = ?";
    $params[] = $profile_picture;
}

$query .= " WHERE user_id = ?";
$params[] = $user_id;

$stmt = $conn->prepare($query);
if ($stmt->execute($params)) {
    echo json_encode(['status' => 'success', 'message' => 'Profile updated successfully']);
} else {
    echo json_encode(['status' => 'error', 'message' => 'Failed to update profile']);
}
?>