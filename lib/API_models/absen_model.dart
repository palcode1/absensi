// absen_model.dart

import 'dart:convert';

AbsensiResponse absensiResponseFromJson(String str) =>
    AbsensiResponse.fromJson(json.decode(str));

String absensiResponseToJson(AbsensiResponse data) =>
    json.encode(data.toJson());

class AbsensiResponse {
  final String? message;
  final AbsensiData? data;

  AbsensiResponse({this.message, this.data});

  factory AbsensiResponse.fromJson(Map<String, dynamic> json) =>
      AbsensiResponse(
        message: json["message"],
        data: json["data"] == null ? null : AbsensiData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"message": message, "data": data?.toJson()};
}

class AbsensiData {
  final int? id;
  final int? userId;
  final DateTime? checkIn;
  final String? checkInLocation;
  final String? checkInAddress;
  final DateTime? checkOut;
  final String? checkOutLocation;
  final String? checkOutAddress;
  final String? status;
  final dynamic alasanIzin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? checkInLat;
  final double? checkInLng;
  final double? checkOutLat;
  final double? checkOutLng;

  AbsensiData({
    this.id,
    this.userId,
    this.checkIn,
    this.checkInLocation,
    this.checkInAddress,
    this.checkOut,
    this.checkOutLocation,
    this.checkOutAddress,
    this.status,
    this.alasanIzin,
    this.createdAt,
    this.updatedAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutLat,
    this.checkOutLng,
  });

  factory AbsensiData.fromJson(Map<String, dynamic> json) => AbsensiData(
    id: json["id"],
    userId: json["user_id"],
    checkIn:
        json["check_in"] == null ? null : DateTime.tryParse(json["check_in"]),
    checkInLocation: json["check_in_location"],
    checkInAddress: json["check_in_address"],
    checkOut:
        json["check_out"] == null ? null : DateTime.tryParse(json["check_out"]),
    checkOutLocation: json["check_out_location"],
    checkOutAddress: json["check_out_address"],
    status: json["status"],
    alasanIzin: json["alasan_izin"],
    createdAt:
        json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"]),
    updatedAt:
        json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"]),
    checkInLat: json["check_in_lat"]?.toDouble(),
    checkInLng: json["check_in_lng"]?.toDouble(),
    checkOutLat: json["check_out_lat"]?.toDouble(),
    checkOutLng: json["check_out_lng"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "check_in": checkIn?.toIso8601String(),
    "check_in_location": checkInLocation,
    "check_in_address": checkInAddress,
    "check_out": checkOut?.toIso8601String(),
    "check_out_location": checkOutLocation,
    "check_out_address": checkOutAddress,
    "status": status,
    "alasan_izin": alasanIzin,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "check_in_lat": checkInLat,
    "check_in_lng": checkInLng,
    "check_out_lat": checkOutLat,
    "check_out_lng": checkOutLng,
  };
}
