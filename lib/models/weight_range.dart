class WeightRange {
  double lower;
  double upper;

  WeightRange({
    this.lower,
    this.upper,
  });

  factory WeightRange.fromJson(Map<String, dynamic> parsedJson) {
    return WeightRange(
      lower: double.parse(parsedJson['lower']?.toString()),
      upper: double.parse(parsedJson['upper']?.toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        'lower': lower,
        'upper': upper,
      };
}
