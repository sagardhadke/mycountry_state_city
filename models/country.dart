class Country {
  final String name;
  final String isoCode;
  final String phoneCode;
  final String flag;
  final String currency;

  Country({
    required this.name,
    required this.isoCode,
    required this.phoneCode,
    required this.flag,
    required this.currency,
  });

  static Country fromJson(Map<String, dynamic> json) => Country(
        name: json['name'],
        isoCode: json['isoCode'],
        phoneCode: json['phoneCode'],
        currency: json['currency'],
        flag: json['flag'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'isoCode': isoCode,
        'phoneCode': phoneCode,
        'currency': currency,
        'flag': flag,
      };
}
