import 'package:json_annotation/json_annotation.dart';

part 'marvel_response.g.dart';

@JsonSerializable(genericArgumentFactories: true, constructor: '_')
class MarvelResponse<T> {
  final T data;

  const MarvelResponse._({required this.data});

  factory MarvelResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$MarvelResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$MarvelResponseToJson(this, toJsonT);
}
