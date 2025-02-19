class CardModel {
  final int id;
  final int userId;
  final String cardNumber;
  final String cardHolderName;
  final String expirationDate;
  final String cvv;
  final String createdAt;
  final bool frozen;

  CardModel({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expirationDate,
    required this.cvv,
    required this.createdAt,
    required this.frozen,
  });

  // Método para convertir el JSON en un objeto CardModel
  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      userId: json['userId'],
      cardNumber: json['cardNumber'],
      cardHolderName: json['cardHolderName'],
      expirationDate: json['expirationDate'],
      cvv: json['cvv'],
      createdAt: json['createdAt'],
      frozen: json['frozen'],
    );
  }
}
