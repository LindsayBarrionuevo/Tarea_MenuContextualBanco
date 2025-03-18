class UserModel {
  final int id;
  final String email;
  final String accountNumber;
  final DateTime createdAt;
  double balance;

  UserModel({
    required this.id,
    required this.email,
    required this.accountNumber,
    required this.createdAt,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      accountNumber: json['accountNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      balance:
          json['balance'] ?? 0.0,
    );
  }
}
