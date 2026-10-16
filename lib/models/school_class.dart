class SchoolClass {
  final String id;
  final String teacherId;
  String name;
  String subject;
  String strand;
  final List<String> studentIds;

  SchoolClass({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.subject,
    required this.strand,
    List<String>? studentIds,
  }) : studentIds = studentIds ?? <String>[];
}
