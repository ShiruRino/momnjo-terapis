class GeraiContact {
  final int idGerai;
  final String namaGerai;
  final String kodeGerai;
  final String kontakWa;
  final String waNumber;
  final String waLink;
  final String kontakGerai;
  final String lokasiGerai;
  final String kota;
  final String provinsi;

  const GeraiContact({
    required this.idGerai,
    required this.namaGerai,
    required this.kodeGerai,
    required this.kontakWa,
    required this.waNumber,
    required this.waLink,
    required this.kontakGerai,
    required this.lokasiGerai,
    required this.kota,
    required this.provinsi,
  });

  factory GeraiContact.fromJson(Map<String, dynamic> json) {
    return GeraiContact(
      idGerai: json['id_gerai'] is int ? json['id_gerai'] : int.tryParse(json['id_gerai']?.toString() ?? '1') ?? 1,
      namaGerai: json['nama_gerai']?.toString() ?? '',
      kodeGerai: json['kode_gerai']?.toString() ?? '',
      kontakWa: json['kontak_wa']?.toString() ?? '',
      waNumber: json['wa_number']?.toString() ?? '',
      waLink: json['wa_link']?.toString() ?? '',
      kontakGerai: json['kontak_gerai']?.toString() ?? '',
      lokasiGerai: json['lokasi_gerai']?.toString() ?? '',
      kota: json['kota']?.toString() ?? '',
      provinsi: json['provinsi']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_gerai': idGerai,
      'nama_gerai': namaGerai,
      'kode_gerai': kodeGerai,
      'kontak_wa': kontakWa,
      'wa_number': waNumber,
      'wa_link': waLink,
      'kontak_gerai': kontakGerai,
      'lokasi_gerai': lokasiGerai,
      'kota': kota,
      'provinsi': provinsi,
    };
  }
}

