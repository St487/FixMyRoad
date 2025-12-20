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
  static String postalCode(bool en) => en ? 'Postal Code' : 'Kod Pos';
  static String inputPostalCode(bool en) => en ? 'Your Postal Code' : 'Kod Pos Anda';
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

}
