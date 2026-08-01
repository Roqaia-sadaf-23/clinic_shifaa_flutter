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
  static const String doctors = "$server/Doctors";
  // ignore: constant_identifier_names
  static const String Adddoctors = "$server/Doctors/create";
  static String doctorById(int id) => "$server/Doctors/$id";
  static const String currentDoctor = "$server/Doctors/me";
  static const String updateCurrentDoctorProfile = "$server/Doctors/updateme";
  static const String updateCurrentPersonImage = "$server/Person/me/image";
  //http://192.168.8.4:5210/api/Person/me/image
  // Patients
  static const String patients = "$server/Patient";
  static const String createPatient = "$server/Patient/create";
  static String patientById(int id) => "$server/Patient/$id";

  // Appointments
  static const String createAppointment = "$server/Appointments/create";
  static const String patientAppointments = "$server/Appointments/patient/me";
  static String appointmentById(int id) => "$server/Appointments/$id";

  static String availableSlots({required int doctorId, required String date}) =>
      "$server/Appointments/available-slots?doctorId=$doctorId&date=$date";

  static String cancelAppointment(int id) => "$server/Appointments/$id/cancel";

  static String completeAppointment(int id) =>
      "$server/Appointments/$id/complete";
  static const String doctorAppointmentSummary =
      "$server/Appointments/doctor/me/summary";
  static const String todayDoctorAppointments =
      "$server/Appointments/doctor/me/today";
  static const String doctorAppointments = "$server/Appointments/doctor/me";
  static const String doctorPatients =
      "$server/Appointments/doctor/me/patients";
  static String doctorPatientAppointments(int patientId) =>
      "$server/Appointments/doctor/me/patients/$patientId/appointments";

  // Medical Records
  static const String medicalRecords = "$server/MedicalRecordContreoler/All";
  static String medicalRecordById(int id) =>
      "$server/MedicalRecordContreoler/$id,GetMedicalRecordById";
  static const String createMedicalRecord = "$server/MedicalRecordContreoler";
  static String doctorPatientMedicalRecords(int patientId) =>
      "$server/MedicalRecordContreoler/doctor/me/patients/$patientId";

  // Payments
  static const String payments = "$server/Payment/All";
  static const String createPayment = "$server/Payment/create";
  static String paymentById(int id) => "$server/Payment/$id";
  static String doctorPatientPayments(int patientId) =>
      "$server/Payment/doctor/me/patients/$patientId";

  // Prescriptions
  static const String prescriptions = "$server/PrescriptionControler";
  static String prescriptionById(int id) => "$server/PrescriptionControler/$id";
  static const String createPrescription =
      "$server/PrescriptionControler/create";
  static String doctorPatientPrescriptions(int patientId) =>
      "$server/PrescriptionControler/doctor/me/patients/$patientId";

  // Roles
  static const String roles = "$server/Role";

  // Specialties
  static const String specialties = "$server/Specialties";

  //country
  static const String countries = "$server/Country";

  //Images
  static const String images = "$server/Images/GetImage/";
  static String uploadImage = "$server/Images/UploadImage";
}
