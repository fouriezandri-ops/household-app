/// Item priority. Not every list uses this (only admin to-dos, currently).
enum Priority {
  low,
  medium,
  high;

  static Priority? fromValue(String? value) =>
      value == null ? null : Priority.values.byName(value);
}
