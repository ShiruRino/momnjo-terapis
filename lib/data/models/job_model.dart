enum KategoriLayanan {
  homecare,
  onsite,
}

enum StatusLayanan {
  menunggu,
  arrived,
  proses,
  dijeda,
  selesai,
}

enum StatusTransaksi {
  open,
  closed,
}

class CustomerModel {
  final String idCustomer;
  final String fullname;
  final String phone;
  final String alamatDomisili;
  final String? catatanAlamat;
  final String? ruangan;

  const CustomerModel({
    required this.idCustomer,
    required this.fullname,
    required this.phone,
    required this.alamatDomisili,
    this.catatanAlamat,
    this.ruangan,
  });
}

class TreatmentItem {
  final String productId;
  final String productName;
  final int quantity;
  final String satuan;

  const TreatmentItem({
    required this.productId,
    required this.productName,
    this.quantity = 1,
    this.satuan = 'Menit',
  });
}

class MedicalRecord {
  final String tekananDarahSistolik;
  final String tekananDarahDiastolik;
  final String suhuTubuh;
  final String keluhan;
  final String alergi;
  final String catatanKhusus;
  final String tinggiBadan;
  final String beratBadan;
  final String hasilPemeriksaan;
  final String catatanTerapis;

  const MedicalRecord({
    this.tekananDarahSistolik = '120',
    this.tekananDarahDiastolik = '80',
    this.suhuTubuh = '36.5',
    this.keluhan = '',
    this.alergi = '',
    this.catatanKhusus = '',
    this.tinggiBadan = '158',
    this.beratBadan = '62',
    this.hasilPemeriksaan = 'Kondisi umum baik, tidak ada keluhan khusus.',
    this.catatanTerapis = '',
  });

  String get tekananDarahDisplay => '$tekananDarahSistolik / $tekananDarahDiastolik';

  MedicalRecord copyWith({
    String? tekananDarahSistolik,
    String? tekananDarahDiastolik,
    String? suhuTubuh,
    String? keluhan,
    String? alergi,
    String? catatanKhusus,
    String? tinggiBadan,
    String? beratBadan,
    String? hasilPemeriksaan,
    String? catatanTerapis,
  }) {
    return MedicalRecord(
      tekananDarahSistolik: tekananDarahSistolik ?? this.tekananDarahSistolik,
      tekananDarahDiastolik: tekananDarahDiastolik ?? this.tekananDarahDiastolik,
      suhuTubuh: suhuTubuh ?? this.suhuTubuh,
      keluhan: keluhan ?? this.keluhan,
      alergi: alergi ?? this.alergi,
      catatanKhusus: catatanKhusus ?? this.catatanKhusus,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      beratBadan: beratBadan ?? this.beratBadan,
      hasilPemeriksaan: hasilPemeriksaan ?? this.hasilPemeriksaan,
      catatanTerapis: catatanTerapis ?? this.catatanTerapis,
    );
  }
}

class JobTimer {
  final int durasiStandarDetik;
  final int elapsedSeconds;
  final int remainingSeconds;
  final bool isPaused;

  const JobTimer({
    required this.durasiStandarDetik,
    this.elapsedSeconds = 0,
    this.remainingSeconds = 5400,
    this.isPaused = false,
  });

  JobTimer copyWith({
    int? durasiStandarDetik,
    int? elapsedSeconds,
    int? remainingSeconds,
    bool? isPaused,
  }) {
    return JobTimer(
      durasiStandarDetik: durasiStandarDetik ?? this.durasiStandarDetik,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

class JobModel {
  final int idJobStatus;
  final String idTransaksi;
  final String idBooking;
  final KategoriLayanan kategoriLayanan;
  final StatusLayanan statusLayanan;
  final StatusTransaksi statusTransaksi;
  final String terapis;
  final int durasiStandar; // minutes
  final DateTime? waktuJadwal;
  final DateTime? waktuArrived;
  final DateTime? waktuMulai;
  final DateTime? waktuSelesai;
  final bool isPaused;
  final DateTime? pausedAt;
  final int pausedTotalSeconds;
  final CustomerModel customer;
  final TreatmentItem item;
  final MedicalRecord? medicalRecord;
  final JobTimer timer;
  final String? catatanKedatangan;
  final String? catatanPenyelesaian;
  final String namaGerai;

  const JobModel({
    required this.idJobStatus,
    required this.idTransaksi,
    required this.idBooking,
    required this.kategoriLayanan,
    required this.statusLayanan,
    this.statusTransaksi = StatusTransaksi.open,
    required this.terapis,
    required this.durasiStandar,
    this.waktuJadwal,
    this.waktuArrived,
    this.waktuMulai,
    this.waktuSelesai,
    this.isPaused = false,
    this.pausedAt,
    this.pausedTotalSeconds = 0,
    required this.customer,
    required this.item,
    this.medicalRecord,
    required this.timer,
    this.catatanKedatangan,
    this.catatanPenyelesaian,
    this.namaGerai = 'Mom N Jo Dharmawangsa',
  });

  bool get isHomecare => kategoriLayanan == KategoriLayanan.homecare;
  bool get isOnsite => kategoriLayanan == KategoriLayanan.onsite;
  bool get isClosed => statusTransaksi == StatusTransaksi.closed;

  JobModel copyWith({
    StatusLayanan? statusLayanan,
    StatusTransaksi? statusTransaksi,
    DateTime? waktuArrived,
    DateTime? waktuMulai,
    DateTime? waktuSelesai,
    bool? isPaused,
    DateTime? pausedAt,
    int? pausedTotalSeconds,
    MedicalRecord? medicalRecord,
    JobTimer? timer,
    String? catatanKedatangan,
    String? catatanPenyelesaian,
  }) {
    return JobModel(
      idJobStatus: idJobStatus,
      idTransaksi: idTransaksi,
      idBooking: idBooking,
      kategoriLayanan: kategoriLayanan,
      statusLayanan: statusLayanan ?? this.statusLayanan,
      statusTransaksi: statusTransaksi ?? this.statusTransaksi,
      terapis: terapis,
      durasiStandar: durasiStandar,
      waktuJadwal: waktuJadwal,
      waktuArrived: waktuArrived ?? this.waktuArrived,
      waktuMulai: waktuMulai ?? this.waktuMulai,
      waktuSelesai: waktuSelesai ?? this.waktuSelesai,
      isPaused: isPaused ?? this.isPaused,
      pausedAt: pausedAt ?? this.pausedAt,
      pausedTotalSeconds: pausedTotalSeconds ?? this.pausedTotalSeconds,
      customer: customer,
      item: item,
      medicalRecord: medicalRecord ?? this.medicalRecord,
      timer: timer ?? this.timer,
      catatanKedatangan: catatanKedatangan ?? this.catatanKedatangan,
      catatanPenyelesaian: catatanPenyelesaian ?? this.catatanPenyelesaian,
      namaGerai: namaGerai,
    );
  }
}

