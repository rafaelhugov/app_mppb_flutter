class ComboItem {
  final int id;
  final String descricao;

  ComboItem({required this.id, required this.descricao});

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: json['id'] as int,
      descricao: (json['descricao'] ?? json['nome'] ?? '') as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComboItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
