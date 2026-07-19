class ApiLinks {
  static const String server = "http://192.168.8.4:5210/api";

  // Auth
  static const String login = "$server/Auth/login";
  static const String refreshToken = "$server/Auth/refresh";
  static const String logout = "$server/Auth/logout";

  // Users
  static const String users = "$server/Users";
  static String userById(int id) => "$server/Users/$id";
  static const String adduser = "$server/Users/register";
  // Doctors
  static const String Adddoctors = "$server/Doctors/create";
  static String doctorById(int id) => "$server/Doctors/$id";
  static const String currentDoctor = "$server/Doctors/me";

  // Patients
  static const String patients = "$server/Patients";
  static String patientById(int id) => "$server/Patients/$id";

  // Appointments
  static const String appointments = "$server/Appointments";
  static String appointmentById(int id) => "$server/Appointments/$id";

  static String appointmentsByUserId(int userId) =>
      "$server/Appointments/user/$userId";

  static String availableSlots({required int doctorId, required String date}) =>
      "$server/Appointments/available-slots?doctorId=$doctorId&date=$date";

  static String cancelAppointment(int id) => "$server/Appointments/$id/cancel";

  static String completeAppointment(int id) =>
      "$server/Appointments/$id/complete";

  // Medical Records
  static const String medicalRecords = "$server/MedicalRecords";
  static String medicalRecordById(int id) => "$server/MedicalRecords/$id";

  // Payments
  static const String payments = "$server/Payments";
  static String paymentById(int id) => "$server/Payments/$id";

  // Prescriptions
  static const String prescriptions = "$server/Prescriptions";
  static String prescriptionById(int id) => "$server/Prescriptions/$id";

  // Roles
  static const String roles = "$server/Role";

  // Specialties
  static const String specialties = "$server/Specialties";

  //country
  static const String countries = "$server/Country";

  //Images
  static const String updateCurrentPersonImage = "$server/Person/me/image";
  static const String images = "$server/Images/GetImage/";
  static String uploadImage = "$server/Images/UploadImage";
}
