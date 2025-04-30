class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String description;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.description,
    required this.rating,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'] ?? '',
      author: (json['volumeInfo']['authors'] as List<dynamic>?)?.join(', ') ?? '',
      coverUrl: json['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
      description: json['volumeInfo']['description'] ?? '',
      rating: (json['volumeInfo']['averageRating'] ?? 0).toDouble(),
    );
  }
}