import 'package:fix_my_road/features/profile/screens/change_password.dart';

class AppText {

  // ===== LOGIN SCREEN =====
  static String welcome(bool en) => en ? 'Welcome Back !' : 'Selamat Kembali!';
  static String subtitle(bool en) => en ? 'Please log in to continue' : 'Sila log masuk untuk meneruskan';
  static String email(bool en) => en ? 'Email' : 'Emel';
  static String password(bool en) => en ? 'Password' : 'Kata Laluan';
  static String rememberMe(bool en) => en ? 'Remember Me' : 'Ingat Saya';
  static String login(bool en) => en ? 'Log In' : 'Log Masuk';
  static String noAccount(bool en) => en ? "Don't have an account?" : 'Tiada akaun?';
  static String signUp(bool en) => en ? 'Sign Up' : 'Daftar';
  static String forgotPassword(bool en) => en ? 'Forgot Password?' : 'Lupa Kata Laluan?';

  // ===== REGISTRATION SCREEN =====
  static String createAccount(bool en) => en ? 'Create Your Account' : 'Cipta Akaun Anda';
  static String emailAddress(bool en) => en ? 'Email Address' : 'Alamat Emel';
  static String inputEmail(bool en) => en ? 'Your Email' : 'Emel Anda';
  static String verificationCode(bool en) => en ? 'Verification Code' : 'Kod Pengesahan';
  static String inputVerificationCode(bool en) => en ? 'Input Verification Code' : 'Masukkan Kod Pengesahan';
  static String verificationButton(bool en) => en ? 'Send Code' : 'Hantar Kod';
  static String phoneNumber(bool en) => en ? 'Phone Number' : 'Nombor Telefon';
  static String inputPhone(bool en) => en ? 'Your Phone Number' : 'Nombor Telefon Anda';
  static String inputPassword(bool en) => en ? 'Your Password' : 'Kata Laluan Anda';
  static String passwordHint(bool en) => en ? 'Min 6 chars · 1 uppercase · 1 lowercase · 1 number' : 'Min 6 aksara · 1 huruf besar · 1 huruf kecil · 1 nombor';
  static String confirmPassword(bool en) => en ? 'Confirm Password' : 'Sahkan Kata Laluan';
  static String inputConfirm(bool en) => en ? 'Confirm Your Password' : 'Sahkan Kata Laluan Anda';
  static String haveAccount(bool en) => en ? 'Already have an account?' : 'Sudah ada akaun?';
  static String register(bool en) => en ? 'Sign Up' : 'Daftar'; 

   // ===== COMPLETE PROFILE SCREEN =====
  static String completeProfile(bool en) => en ? 'Complete Your Profile' : 'Lengkapkan Profil Anda';
  static String firstName(bool en) => en ? 'First Name' : 'Nama Pertama';
  static String inputFirstName(bool en) => en ? 'Your First Name' : 'Nama Pertama Anda';
  static String lastName(bool en) => en ? 'Last Name' : 'Nama Akhir';
  static String inputLastName(bool en) => en ? 'Your Last Name' : 'Nama Akhir Anda';
  static String address(bool en) => en ? 'Address' : 'Alamat';
  static String inputAddress(bool en) => en ? 'Your Address' : 'Alamat Anda';
  static String postalCode(bool en) => en ? 'Postal Code' : 'Pos Kod';
  static String inputPostalCode(bool en) => en ? 'Your Postal Code' : 'Pos Kod Anda';
  static String state(bool en) => en ? 'State' : 'Negeri';
  static String inputState(bool en) => en ? 'Select Your State' : 'Pilih Negeri Anda';
  static String city(bool en) => en ? 'City' : 'Bandar';
  static String inputCity(bool en) => en ? 'Select Your City' : 'Pilih Bandar Anda';
  static String doneButton(bool en) => en ? 'Done' : 'Selesai';

  // ===== FORGOT PASSWORD SCREEN =====
  static String forgotYourPassword(bool en) => en ? 'Forgot Your Password?' : ' Lupa Kata Laluan Anda?';
  static String enterEmailResetCode(bool en) => en ? 'Enter your email address below to receive a password reset code.' : 'Masukkan alamat emel anda di bawah untuk menerima kod tetapan semula kata laluan.';
  static String rememberPassword(bool en) => en ? 'Remember password?' : 'Ingat kata laluan?';
  static String loginShort(bool en) => en ? 'Login' : 'Log Masuk';
  static String sendCode(bool en) => en ? 'Send Code' : 'Hantar Kod';
  
  // ===== PASSCODE SCREEN =====
  static String enterPasscode(bool en) => en ? 'Enter Passcode' : 'Masukkan Kod Laluan';
  static String enterPasscodeDesc(bool en) => en ? 'Please enter the passcode sent to your email to reset your password.' : 'Sila masukkan kod laluan yang dihantar ke emel anda untuk menetapkan semula kata laluan anda.';
  static String didntReceiveCode(bool en) => en ? "Didn't receive the code?" : 'Tidak menerima kod?';
  static String resend(bool en) => en ? 'Resend' : 'Hantar Semula'; 

  // ===== RESET PASSWORD SCREEN =====
  static String resetPassword(bool en) => en ? 'Reset Password' : 'Tetapkan Semula Kata Laluan';
  static String enterNewPassword(bool en) => en ? 'Enter your new password.' : 'Masukkan kata laluan baru anda.';
  static String newPassword(bool en) => en ? 'New Password' : 'Kata Laluan Baru';
  static String reset(bool en) => en ? 'Confirm' : 'Sahkan'; 

  // ===== HOME SCREEN =====
  static String letsFix(bool en) => en ? "Let's fix some roads today" : 'Mari kita perbaiki jalan hari ini';
  static String whatToDo(bool en) => en ? 'What would you like to do?' : 'Apa yang ingin anda lakukan?';
  static String viewMap(bool en) => en ? 'View Map' : 'Lihat Peta';
  static String reportStatus(bool en) => en ? 'Report Status' : 'Status Laporan';
  static String nearbyIssues(bool en) => en ? 'Nearby Issues' : 'Masalah Terdekat';
  static String viewAll(bool en) => en ? 'Show All' : 'Tampilkan Semua';
  static String locationPermissionDenied(bool en) => en ? 'Location permission not allowed' : 'Izin lokasi tidak diizinkan';
  static String noNearbyIssues(bool en) => en ? 'No nearby issues found.' : 'Tidak ditemukan masalah terdekat.';
  static String away(bool en) => en ? 'away' : 'dari sini';
  static String issueNotFound(bool en) => en ? 'Failed to load issue details' : 'Gagal memuat detail masalah';
  static String beTheFirstToReport(bool en) => en ? 'No nearby issues found.\nBe the first to report!' : 'Tidak ditemukan masalah terdekat.\nJadilah yang pertama melaporkan!';
  static String resolutionJourney(bool en) => en ? 'Resolution Journey' : 'Perjalanan Penyelesaian';
  static String reportedDate(bool en) => en ? 'Reported Date' : 'Tarikh Laporan';
  static String priority(bool en) => en ? 'Priority' : 'Keutamaan';
  static String stageApproved(bool en) => en ? "REPORTED" : "DILAPORKAN";
  static String stageInProgress(bool en) => en ? "IN PROGRESS" : "DALAM PROSES";
  static String stageCompleted(bool en) => en ? "COMPLETED" : "SELESAI";
  static String statusReported(bool en) => en ? "Reported" : "Dilaporkan";
  static String statusInProgress(bool en) => en ? "In Progress" : "Dalam Proses";
  static String navigateToLocation(bool en) => en ? 'Navigate to Location' : 'Arahkan ke Lokasi';
  static String openInMaps(bool en) => en ? 'Open in Maps' : 'Buka di Peta';
  static String locationDetailUnavailable(bool en) => en ? 'Location details unavailable' : 'Butiran lokasi tidak tersedia';
  static String unknownDate(bool en) => en ? 'Unknown Date' : 'Tarikh Tidak Diketahui';
  




  // ===== PROFILE SCREEN =====
  static String myProfile(bool en) => en ? 'My Profile' : 'Profil Saya';
  static String user(bool en) => en ? 'User' : 'Pengguna';
  static String editProfile(bool en) => en ? 'Edit Profile' : 'Sunting Profil';
  static String changePassword(bool en) => en ? 'Change Password' : 'Tukar Kata Laluan';
  static String chooseLanguage(bool en) => en ? 'Choose Language' : 'Pilih Bahasa';
  static String contact(bool en) => en ? 'Contact' : 'Hubungi';
  static String logout(bool en) => en ? 'Log Out' : 'Log Keluar';
  static String save(bool en) => en ? 'Save' : 'Simpan';
  static String contactUs(bool en) => en ? 'Contact Us' : 'Hubungi Kami';
  static String selectLanguage(bool en) => en ? 'Select Language' : 'Pilih Bahasa';
  static String chooseImageSource(bool en) => en ? 'Choose Image Source' : 'Pilih Sumber Imej';

  // ===== ADD REPORT SCREEN =====
  static const Map<String, Map<String, String>> types = {
    'Drainage': {
      'en': 'Drainage',
      'ms': 'Saliran / Banjir',
    },
    'Pothole': {
      'en': 'Pothole',
      'ms': 'Lubang Jalan',
    },
    'Public Transport': {
      'en': 'Public Transport Facilities',
      'ms': 'Kemudahan Pengangkutan Awam',
    },
    'Road Sign': {
      'en': 'Road Sign',
      'ms': 'Papan Jalan',
    },
    'Roadside Safety': {
      'en': 'Roadside Safety',
      'ms': 'Keselamatan Tepi Jalan',
    },
    'Street Light': {
      'en': 'Street Light',
      'ms': 'Lampu Jalan',
    },
    'Traffic Light': {
      'en': 'Traffic Light',
      'ms': 'Lampu Isyarat',
    },
    'Other': {
      'en': 'Other',
      'ms': 'Lain-lain',
    },
  };
  static List<String> getList(bool isEnglish) {
    return types.values.map((e) => isEnglish ? e['en']! : e['ms']!).toList();
  }
  static String addReport(bool en) => en ? 'Add Report' : 'Tambah Laporan';
  static String reportType(bool en) => en ? 'Type of Issue' : 'Jenis Masalah';
  static String selectType(bool en) => en ? 'Select Report Type' : 'Pilih Jenis Laporan';
  static String title(bool en) => en ? 'Title' : 'Tajuk';
  static String inputTitle(bool en) => en ? 'Enter a brief title for your report' : 'Masukkan tajuk singkat';
  static String description(bool en) => en ? 'Description' : 'Deskripsi'; 
  static String inputDescription(bool en) => en ? 'Describe the issue in detail' : 'Jelaskan masalah secara terperinci';
  static String location(bool en) => en ? 'Location' : 'Lokasi';
  static String selectLocation(bool en) => en ? 'Select Location from Map' : 'Pilih Lokasi dari Peta';
  static String photos(bool en) => en ? 'Photos' : 'Gambar';
  static String addImages(bool en) => en ? 'Add Photos (max 3)' : 'Tambah Gambar (maks 3)';
  static String submitReport(bool en) => en ? 'Submit Report' : 'Hantar Laporan';


  static String issueType(String? type, bool isEnglish) {
    if (type == null) return isEnglish ? "OTHER" : "LAIN-LAIN";

    // 1. Normalize DB value (lowercase, trim)
    final normalized = type.toLowerCase().trim();

    const Map<String, Map<String, String>> mapping = {
      "drainage": {"en": "Drainage", "bm": "Banjir"},
      "other": {"en": "Other", "bm": "Lain-lain"},
      "pothole": {"en": "Pothole", "bm": "Lubang Jalan"},
      "public transport facilities": {"en": "Public Transport Facilities", "bm": "Kemudahan Pengangkutan Awam"},
      "road sign": {"en": "Road Sign", "bm": "Tanda Jalan"},
      "roadside safety": {"en": "Roadside Safety", "bm": "Keselamatan Tepi Jalan"},
      "street light": {"en": "Street Light", "bm": "Lampu Jalan"},
      "traffic light": {"en": "Traffic Light", "bm": "Lampu Isyarat"},
    };

    final mapped = mapping[normalized];

    // 2. Get the translated string
    String result = "";
    if (mapped != null) {
      result = isEnglish ? mapped["en"]! : mapped["bm"]!;
    } else {
      result = type; // Fallback to raw DB value if not found
    }

    return result;
  }

  //========REPORT STATUS========
  static String noReports(bool en) => en ? 'No reports found.' : 'Tiada laporan dijumpai';
  static String submittedOn(bool en) => en ? 'Submitted On' : 'Tarikh Hantar';
  static String details(bool en) => en ? 'Details' : 'Butiran';

  // ===== FILTERS =====
  static String all(bool en) => en ? 'All' : 'Semua';
  static String pending(bool en) => en ? 'Pending' : 'Menunggu';
  static String approved(bool en) => en ? 'Approved' : 'Diluluskan';
  static String inProgress(bool en) => en ? 'In Progress' : 'Dalam Proses';
  static String rejected(bool en) => en ? 'Rejected' : 'Ditolak';
  static String completed(bool en) => en ? 'Completed' : 'Selesai';

  // ===== DETAIL PAGE =====
  static String noPhoto(bool en) => en ? 'No photo provided.' : 'Tiada gambar disediakan.';
  static String noDescription(bool en) => en ? 'No description provided.' : 'Tiada penerangan disediakan.';

  // ======== EDIT REPORT ========
  static String editReport(bool en) => en ? 'Edit Report' : 'Sunting Laporan';
  static String maxUpload(bool en) => en ? 'Maximum 3 photos allowed' : 'Maksimum 3 gambar dibenarkan'; 
  static String takePhoto(bool en) => en ? 'Take Photo' : 'Ambil Gambar';
  static String chooseGallery(bool en) => en ? 'Choose from Gallery' : 'Pilih dari Galeri';  
  static String addPhotos(bool en) => en ? 'Add Photos (max 3)' : 'Tambah Foto (maksimum 3)';  

  //======== ERROR AND SUCCESS ========
  static String updateReportSuccess(bool en) => en ? 'Report updated successfully!' : 'Laporan berjaya dikemas kini!';
  static String submitReportSuccess(bool en) => en ? 'Report submitted successfully!' : 'Laporan berjaya dihantar!';
  static String failedToUpload(bool en) => en ? 'Failed to Upload. Please Try Again Later' : 'Gagal untuk Hantar Laporan, Sila Cuba Sebentar Lagi';
  static String somethingWrong(bool en) => en ? 'Something went wrong. Please try again later' : 'Sila cuba sebentar lagi';
  static String maxImagesWarning(bool isEnglish, int remainingSlots) {
    return isEnglish
        ? "Only $remainingSlots images were added (Max 3 allowed)"
        : "Hanya $remainingSlots imej ditambah (Maksimum 3 dibenarkan)";
  }
  static String uploadFailed(bool en) => en ? 'Upload Failed' : 'Gagal untuk Muat Naik';

}
