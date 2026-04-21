<?php
header("Content-Type: application/json");

// ==============================
// 🔌 DATABASE CONNECTION
// ==============================
$conn = mysqli_connect("localhost", "root", "", "fmrdb");

if (!$conn) {
    echo json_encode(["reply" => "Database connection failed"]);
    exit;
}

// ==============================
// 🧠 GET INPUT
// ==============================
$userMessage = $_POST['message'] ?? '';
$userId = $_POST['user_id'] ?? NULL;

if (empty($userMessage)) {
    echo json_encode(["reply" => "No message provided"]);
    exit;
}

// normalize message
$userMessageLower = strtolower($userMessage);

// ==============================
// 🧠 INTENT DETECTION (IMPROVED)
// ==============================
function detectIntent($message) {

    $faq_keywords = ["report", "login", "upload", "status", "account", "camera", "gps", "password"];
    $road_keywords = ["road", "pothole", "drain", "crack", "traffic", "highway", "bridge", "lampu", "banjir", "street"];

    foreach ($road_keywords as $word) {
        if (strpos($message, $word) !== false) {
            return "road";
        }
    }

    foreach ($faq_keywords as $word) {
        if (strpos($message, $word) !== false) {
            return "faq";
        }
    }

    return "other";
}

// ==============================
// 📚 IMPROVED FAQ MATCHING (FIXED)
// ==============================
function getFAQAnswer($conn, $message) {

    $message = strtolower($message);
    $words = explode(" ", $message);

    // get all FAQ
    $sql = "SELECT * FROM faq";
    $result = mysqli_query($conn, $sql);

    if (!$result) return null;

    while ($row = mysqli_fetch_assoc($result)) {

        $question = strtolower($row['question']);

        $matchScore = 0;

        foreach ($words as $w) {
            if (strlen($w) > 2 && strpos($question, $w) !== false) {
                $matchScore++;
            }
        }

        // if at least 2 keyword matches → return answer
        if ($matchScore >= 2) {
            return $row['answer'];
        }
    }

    return null;
}

// ==============================
// 🤖 CALL AI (ROAD QUESTIONS)
// ==============================
function callAI($message) {

    $apiKey = "YOUR_API_KEY_HERE";

    $data = [
        "model" => "openai/gpt-oss-120b",
        "messages" => [
            [
                "role" => "system",
                "content" => "You are a Malaysia road infrastructure assistant.

                Rules:
                - Only answer road-related topics (potholes, drainage, traffic, street lights, safety, public transport facilities, road sign, roadside safety, traffic light).
                - If unrelated, say: I can only help with road and app-related questions.
                - Only provide answers relevant to Malaysia (JKR, local councils, Malaysian road systems).
                - Use Malaysian context (flooding, PBT, JKR, highway systems).
                - If question is outside Malaysia, still answer but relate it to Malaysia system.
                - Keep answers short and simple."
            ],
            [
                "role" => "user",
                "content" => $message
            ]
        ],
        "temperature" => 0.7,
        "max_tokens" => 300
    ];

    $ch = curl_init("https://api.groq.com/openai/v1/chat/completions");

    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        "Content-Type: application/json",
        "Authorization: Bearer $apiKey"
    ]);

    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

    $result = curl_exec($ch);

    file_put_contents(__DIR__ . "/debug_ai.json", $result);

    if (curl_errno($ch)) {
        return "AI service error: " . curl_error($ch);
    }

    $response = json_decode($result, true);

    // 🔥 SAFE CHECK
    if (isset($response["error"])) {
        return "AI Error: " . $response["error"]["message"];
    }

    return $response['choices'][0]['message']['content'] ?? "AI error.";
}

// ==============================
// ❓ SAVE UNANSWERED
// ==============================
function saveUnanswered($conn, $userId, $message, $intent) {

    $msg = mysqli_real_escape_string($conn, $message);

    mysqli_query($conn, "
        INSERT INTO unanswered (user_id, question, detected_intent)
        VALUES ('$userId', '$msg', '$intent')
    ");
}

// ==============================
// 📝 SAVE LOG
// ==============================
function saveLog($conn, $userId, $message, $reply, $intent) {

    $msg = mysqli_real_escape_string($conn, $message);
    $rep = mysqli_real_escape_string($conn, $reply);

    mysqli_query($conn, "
        INSERT INTO chatbot_logs (user_id, user_message, bot_reply, intent)
        VALUES ('$userId', '$msg', '$rep', '$intent')
    ");
}

// ==============================
// 🚀 MAIN PROCESS
// ==============================
$intent = detectIntent($userMessageLower);
$response = "";

if ($intent == "faq") {

    $faqAnswer = getFAQAnswer($conn, $userMessageLower);

    if ($faqAnswer) {
        $response = $faqAnswer;
    } else {
        $response = "Sorry, I couldn't find that in app FAQ.";
        saveUnanswered($conn, $userId, $userMessage, $intent);
    }

} elseif ($intent == "road") {

    $response = callAI($userMessage);

} else {

    $response = "I can only help with app usage and road infrastructure questions.";
    saveUnanswered($conn, $userId, $userMessage, $intent);
}

// ==============================
// 💾 SAVE LOG
// ==============================
saveLog($conn, $userId, $userMessage, $response, $intent);

// ==============================
// 📤 RETURN RESPONSE
// ==============================
echo json_encode([
    "reply" => $response,
    "intent" => $intent
]);

?>