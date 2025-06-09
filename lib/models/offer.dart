class Offer {
  String id;
  String title;
  String description;
  String location;
  String salary;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.salary,
  });

  factory Offer.fromMap(Map<String, dynamic> data, String documentId) {
    return Offer(
      id: documentId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      salary: data['salary'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'location': location,
      'salary': salary,
    };
  }
}
