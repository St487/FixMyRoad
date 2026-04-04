<?php
header("Access-Control-Allow-Origin: *");
header('Content-Type: application/json');
include 'config.php';

$data = json_decode(file_get_contents("php://input"), true);

$email = trim($data['email'] ?? '');
$phone_no = trim($data['phone_no'] ?? '');
$password = trim($data['password'] ?? '');

// Basic validation
if (empty($email) || empty($phone_no) || empty($password)) {
    echo json_encode(['status' => 'error', 'message' => 'Please fill all fields']);
    exit;
}

// Check email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode(['status' => 'error', 'message' => 'Invalid email']);
    exit;
}

// Check if email already exists
$stmt = $conn->prepare("SELECT user_id FROM user WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$stmt->store_result();
if ($stmt->num_rows > 0) {
    echo json_encode(['status' => 'error', 'message' => 'Email already registered']);
    exit;
}

// Hash the password
$hashedPassword = password_hash($password, PASSWORD_DEFAULT);

// Insert new user
$stmt = $conn->prepare("INSERT INTO user (email, phone_no, password, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())");
$stmt->bind_param("sss", $email, $phone_no, $hashedPassword);
if ($stmt->execute()) {
    $user_id = $conn->insert_id;

    echo json_encode([
        'status' => 'success',
        'message' => 'Registration successful',
        'user_id' => $user_id,
    ]);
} else {
    echo json_encode([
        'status' => 'error',
        'message' => 'Failed to register user'
    ]);
}
?>