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

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      idCustomer: json['id_customer']?.toString() ?? json['id']?.toString() ?? json['id_cust']?.toString() ?? '',
      fullname: json['fullname']?.toString() ??
          json['nama_lengkap']?.toString() ??
          json['nama_cust']?.toString() ??
          json['nama_customer']?.toString() ??
          json['customer_name']?.toString() ??
          json['customer_fullname']?.toString() ??
          json['pelanggan']?.toString() ??
          json['nama']?.toString() ??
          json['name']?.toString() ??
          '',
      phone: json['phone']?.toString() ??
          json['no_telp']?.toString() ??
          json['telepon']?.toString() ??
          json['hp']?.toString() ??
          json['customer_phone']?.toString() ??
          json['nomor_telepon']?.toString() ??
          '',
      alamatDomisili: json['alamat_domisili']?.toString() ??
          json['alamat']?.toString() ??
          json['address']?.toString() ??
          '',
      catatanAlamat: json['catatan_alamat']?.toString() ?? json['catatan']?.toString(),
      ruangan: json['ruangan']?.toString() ?? json['room']?.toString() ?? json['nama_room']?.toString() ?? json['bed']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_customer': idCustomer,
      'fullname': fullname,
      'phone': phone,
      'alamat_domisili': alamatDomisili,
      'catatan_alamat': catatanAlamat,
      'ruangan': ruangan,
    };
  }
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

  factory TreatmentItem.fromJson(Map<String, dynamic> json) {
    return TreatmentItem(
      productId: json['product_id']?.toString() ?? json['id_product']?.toString() ?? json['id_item']?.toString() ?? '',
      productName: json['product_name']?.toString() ??
          json['treatment']?.toString() ??
          json['nama_treatment']?.toString() ??
          json['nama_item']?.toString() ??
          '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : (json['qty'] is int ? json['qty'] : int.tryParse(json['quantity']?.toString() ?? json['qty']?.toString() ?? '1') ?? 1),
      satuan: json['satuan']?.toString() ?? 'Menit',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'satuan': satuan,
    };
  }
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
    this.tekananDarahSistolik = '',
    this.tekananDarahDiastolik = '',
    this.suhuTubuh = '',
    this.keluhan = '',
    this.alergi = '',
    this.catatanKhusus = '',
    this.tinggiBadan = '',
    this.beratBadan = '',
    this.hasilPemeriksaan = '',
    this.catatanTerapis = '',
  });

  String get tekananDarahDisplay =>
      tekananDarahSistolik.isNotEmpty && tekananDarahDiastolik.isNotEmpty
          ? '$tekananDarahSistolik / $tekananDarahDiastolik'
          : '';

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    final td = json['tekanan_darah']?.toString() ?? '';
    final parts = td.split('/');
    return MedicalRecord(
      tekananDarahSistolik: parts.isNotEmpty ? parts[0].trim() : '',
      tekananDarahDiastolik: parts.length > 1 ? parts[1].trim() : '',
      suhuTubuh: json['suhu_tubuh']?.toString() ?? '',
      keluhan: json['keluhan']?.toString() ?? '',
      alergi: json['alergi']?.toString() ?? '',
      catatanKhusus: json['catatan_khusus']?.toString() ?? '',
      tinggiBadan: json['tinggi_badan']?.toString() ?? '',
      beratBadan: json['berat_badan']?.toString() ?? '',
      hasilPemeriksaan: json['hasil_pemeriksaan']?.toString() ?? '',
      catatanTerapis: json['catatan_terapis']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tekanan_darah': '$tekananDarahSistolik/$tekananDarahDiastolik',
      'suhu_tubuh': suhuTubuh,
      'keluhan': keluhan,
      'alergi': alergi,
      'catatan_khusus': catatanKhusus,
      'tinggi_badan': tinggiBadan,
      'berat_badan': beratBadan,
      'hasil_pemeriksaan': hasilPemeriksaan,
      'catatan_terapis': catatanTerapis,
    };
  }

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
    this.remainingSeconds = 0,
    this.isPaused = false,
  });

  factory JobTimer.fromJson(Map<String, dynamic> json) {
    final durasiDetik = json['durasi_standar_detik'] is int
        ? json['durasi_standar_detik']
        : int.tryParse(json['durasi_standar_detik']?.toString() ??
                json['durasi_detik']?.toString() ??
                '0') ??
            0;
    return JobTimer(
      durasiStandarDetik: durasiDetik,
      elapsedSeconds: json['elapsed_seconds'] is int
          ? json['elapsed_seconds']
          : int.tryParse(json['elapsed_seconds']?.toString() ?? '0') ?? 0,
      remainingSeconds: json['remaining_seconds'] is int
          ? json['remaining_seconds']
          : int.tryParse(json['remaining_seconds']?.toString() ?? '$durasiDetik') ?? durasiDetik,
      isPaused: json['is_paused'] == true || json['is_paused'] == 1 || json['is_paused'] == '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durasi_standar_detik': durasiStandarDetik,
      'elapsed_seconds': elapsedSeconds,
      'remaining_seconds': remainingSeconds,
      'is_paused': isPaused,
    };
  }

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
  final String? fotoArrived;
  final String? fotoArrivedUrl;
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
    this.fotoArrived,
    this.fotoArrivedUrl,
    this.namaGerai = '',
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    // Kategori
    final katStr = json['kategori_layanan']?.toString().toLowerCase() ?? 'homecare';
    final kategori = katStr.contains('onsite') ? KategoriLayanan.onsite : KategoriLayanan.homecare;

    // Status Layanan
    final statStr = json['status_layanan']?.toString().toLowerCase() ?? 'menunggu';
    StatusLayanan status;
    if (statStr.contains('arrived')) {
      status = StatusLayanan.arrived;
    } else if (statStr.contains('dijeda')) {
      status = StatusLayanan.dijeda;
    } else if (statStr.contains('proses')) {
      status = StatusLayanan.proses;
    } else if (statStr.contains('selesai')) {
      status = StatusLayanan.selesai;
    } else {
      status = StatusLayanan.menunggu;
    }

    // Status Transaksi
    final trxMap = json['transaksi'] is Map<String, dynamic> ? json['transaksi'] as Map<String, dynamic> : null;
    final trxStatusStr = trxMap?['status_transaksi']?.toString().toLowerCase() ?? '';
    final statusTrx = trxStatusStr.contains('closed') ? StatusTransaksi.closed : StatusTransaksi.open;

    // Timestamps
    DateTime? waktuJadwal;
    final rawJadwal = json['waktu_jadwal'] ??
        json['jadwal'] ??
        json['tgl_jadwal'] ??
        json['waktu'] ??
        trxMap?['tgl_transaksi'] ??
        json['tgl_transaksi'] ??
        json['tgl'];
    if (rawJadwal != null) {
      try {
        waktuJadwal = DateTime.parse(rawJadwal.toString());
      } catch (_) {}
    }

    DateTime? waktuArrived;
    final rawArrived = json['waktu_arrived'] ?? json['arrived_at'];
    if (rawArrived != null) {
      try {
        waktuArrived = DateTime.parse(rawArrived.toString());
      } catch (_) {}
    }

    DateTime? waktuMulai;
    final rawMulai = json['waktu_mulai'] ?? json['start_at'] ?? json['started_at'];
    if (rawMulai != null) {
      try {
        waktuMulai = DateTime.parse(rawMulai.toString());
      } catch (_) {}
    }

    DateTime? waktuSelesai;
    final rawSelesai = json['waktu_selesai'] ?? json['completed_at'] ?? json['selesai_at'];
    if (rawSelesai != null) {
      try {
        waktuSelesai = DateTime.parse(rawSelesai.toString());
      } catch (_) {}
    }

    // Customer
    CustomerModel customer;
    if (json['customer'] is Map<String, dynamic>) {
      customer = CustomerModel.fromJson(json['customer'] as Map<String, dynamic>);
    } else if (json['pelanggan'] is Map<String, dynamic>) {
      customer = CustomerModel.fromJson(json['pelanggan'] as Map<String, dynamic>);
    } else if (json['customer'] is String && (json['customer'] as String).isNotEmpty) {
      customer = CustomerModel(
        idCustomer: json['id_customer']?.toString() ?? json['id_cust']?.toString() ?? '',
        fullname: json['customer'] as String,
        phone: json['customer_phone']?.toString() ?? json['phone']?.toString() ?? json['no_telp']?.toString() ?? '',
        alamatDomisili: json['customer_alamat']?.toString() ?? json['alamat']?.toString() ?? '',
        catatanAlamat: json['catatan_alamat']?.toString() ?? json['catatan']?.toString(),
        ruangan: json['ruangan']?.toString() ?? json['room']?.toString() ?? json['nama_room']?.toString(),
      );
    } else {
      customer = CustomerModel(
        idCustomer: json['id_customer']?.toString() ?? json['id_cust']?.toString() ?? '',
        fullname: json['customer_fullname']?.toString() ??
            json['nama_cust']?.toString() ??
            json['nama_customer']?.toString() ??
            json['customer_name']?.toString() ??
            json['fullname']?.toString() ??
            json['nama_lengkap']?.toString() ??
            json['pelanggan']?.toString() ??
            json['nama']?.toString() ??
            '',
        phone: json['customer_phone']?.toString() ??
            json['phone']?.toString() ??
            json['no_telp']?.toString() ??
            json['telepon']?.toString() ??
            json['hp']?.toString() ??
            '',
        alamatDomisili: json['customer_alamat']?.toString() ??
            json['alamat_domisili']?.toString() ??
            json['alamat']?.toString() ??
            '',
        catatanAlamat: json['catatan_alamat']?.toString() ?? json['catatan']?.toString(),
        ruangan: json['ruangan']?.toString() ?? json['room']?.toString() ?? json['nama_room']?.toString(),
      );
    }

    // Fallback merge root level fields if customer map lacked them
    if (customer.fullname.isEmpty) {
      final rootName = json['customer_fullname']?.toString() ??
          json['nama_cust']?.toString() ??
          json['nama_customer']?.toString() ??
          json['customer_name']?.toString() ??
          json['fullname']?.toString() ??
          json['nama_lengkap']?.toString() ??
          json['pelanggan']?.toString() ??
          json['nama']?.toString();
      if (rootName != null && rootName.isNotEmpty) {
        customer = CustomerModel(
          idCustomer: customer.idCustomer,
          fullname: rootName,
          phone: customer.phone.isNotEmpty
              ? customer.phone
              : (json['customer_phone']?.toString() ?? json['phone']?.toString() ?? json['no_telp']?.toString() ?? ''),
          alamatDomisili: customer.alamatDomisili.isNotEmpty
              ? customer.alamatDomisili
              : (json['customer_alamat']?.toString() ?? json['alamat_domisili']?.toString() ?? json['alamat']?.toString() ?? ''),
          catatanAlamat: customer.catatanAlamat ?? json['catatan_alamat']?.toString() ?? json['catatan']?.toString(),
          ruangan: customer.ruangan ?? json['ruangan']?.toString() ?? json['room']?.toString() ?? json['nama_room']?.toString(),
        );
      }
    }
    if (customer.ruangan == null || customer.ruangan!.isEmpty) {
      final rootRoom = json['ruangan']?.toString() ?? json['room']?.toString() ?? json['nama_room']?.toString() ?? json['bed']?.toString();
      if (rootRoom != null && rootRoom.isNotEmpty) {
        customer = CustomerModel(
          idCustomer: customer.idCustomer,
          fullname: customer.fullname,
          phone: customer.phone,
          alamatDomisili: customer.alamatDomisili,
          catatanAlamat: customer.catatanAlamat,
          ruangan: rootRoom,
        );
      }
    }

    // Item
    TreatmentItem item;
    if (json['item'] is Map<String, dynamic>) {
      item = TreatmentItem.fromJson(json['item'] as Map<String, dynamic>);
    } else if (json['treatment'] is Map<String, dynamic>) {
      item = TreatmentItem.fromJson(json['treatment'] as Map<String, dynamic>);
    } else {
      item = TreatmentItem(
        productId: json['product_id']?.toString() ?? json['id_product']?.toString() ?? json['id_item']?.toString() ?? '',
        productName: json['product_name']?.toString() ??
            json['treatment']?.toString() ??
            json['nama_treatment']?.toString() ??
            json['nama_item']?.toString() ??
            '',
      );
    }

    // Durasi standar
    final durasiMenit = json['durasi_standar'] is int
        ? json['durasi_standar']
        : int.tryParse(json['durasi_standar']?.toString() ??
                json['durasi']?.toString() ??
                json['duration']?.toString() ??
                json['durasi_menit']?.toString() ??
                '0') ??
            0;

    // Timer
    JobTimer timer;
    if (json['timer'] is Map<String, dynamic>) {
      timer = JobTimer.fromJson(json['timer'] as Map<String, dynamic>);
    } else {
      final durasiDetik = durasiMenit * 60;
      timer = JobTimer(
        durasiStandarDetik: durasiDetik,
        elapsedSeconds: 0,
        remainingSeconds: durasiDetik,
      );
    }

    // Medical Record
    MedicalRecord? medicalRecord;
    if (json['medical_record'] is Map<String, dynamic>) {
      medicalRecord = MedicalRecord.fromJson(json['medical_record'] as Map<String, dynamic>);
    } else if (json['rekam_medis'] is Map<String, dynamic>) {
      medicalRecord = MedicalRecord.fromJson(json['rekam_medis'] as Map<String, dynamic>);
    }

    final id = json['id_job_status'] is int
        ? json['id_job_status']
        : int.tryParse(json['id_job_status']?.toString() ?? '0') ?? 0;

    return JobModel(
      idJobStatus: id,
      idTransaksi: json['id_transaksi']?.toString() ?? (id > 0 ? 'TRX-$id' : '-'),
      idBooking: json['id_booking']?.toString() ?? (id > 0 ? 'BKG-$id' : '-'),
      kategoriLayanan: kategori,
      statusLayanan: status,
      statusTransaksi: statusTrx,
      terapis: json['terapis']?.toString() ?? '',
      durasiStandar: durasiMenit,
      waktuJadwal: waktuJadwal,
      waktuArrived: waktuArrived,
      waktuMulai: waktuMulai,
      waktuSelesai: waktuSelesai,
      isPaused: json['is_paused'] == true || json['is_paused'] == 1 || json['is_paused'] == '1',
      customer: customer,
      item: item,
      timer: timer,
      medicalRecord: medicalRecord,
      catatanKedatangan: json['catatan_arrived']?.toString() ?? json['catatan_kedatangan']?.toString(),
      fotoArrived: json['foto_arrived']?.toString(),
      fotoArrivedUrl: json['foto_arrived_url']?.toString(),
      namaGerai: trxMap?['nama_gerai']?.toString() ??
          json['nama_gerai']?.toString() ??
          json['gerai_name']?.toString() ??
          '',
    );
  }

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
    String? fotoArrived,
    String? fotoArrivedUrl,
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
      fotoArrived: fotoArrived ?? this.fotoArrived,
      fotoArrivedUrl: fotoArrivedUrl ?? this.fotoArrivedUrl,
      namaGerai: namaGerai,
    );
  }
}

