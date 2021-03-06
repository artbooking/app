class ShareUrls {
  String read;
  String write;

  ShareUrls({
    this.read = '',
    this.write = '',
  });

  factory ShareUrls.empty() {
    return ShareUrls(
      read: '',
      write: '',
    );
  }

  factory ShareUrls.fromJSON(Map<String, dynamic>? data) {
    if (data == null) {
      return ShareUrls.empty();
    }

    return ShareUrls(
      read: data['read'] ?? '',
      write: data['write'] ?? '',
    );
  }
}
