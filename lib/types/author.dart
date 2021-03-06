class Author {
  /// Author's id.
  String? id;

  Author({
    this.id = '',
  });

  factory Author.empty() {
    return Author(
      id: '',
    );
  }

  factory Author.fromJSON(Map<String, dynamic> data) {
    return Author(
      id: data['id'],
    );
  }
}
