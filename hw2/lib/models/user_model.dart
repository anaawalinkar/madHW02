class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime registrationDate;

  UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.registrationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'registrationDate': registrationDate.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      role: map['role'],
      registrationDate: DateTime.fromMillisecondsSinceEpoch(map['registrationDate']),
    );
  }
}