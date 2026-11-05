class ReportSummary {
  final DateTime startPeriode;
  final DateTime endPeriode;
  final String? kodeGerai;
  final double komisiReguler5Persen;
  final double komisiRedeem5Persen;
  final double totalKomisi5Persen;

  // Omzet
  final double treatmentSebelumDiskon;
  final double treatmentSetelahDiskon;
  final double paketSebelumDiskon;
  final double paketSetelahDiskon;
  final double pendapatanRedeem;
  final double totalSebelumDiskon;
  final double totalSetelahDiskon;

  // Pengerjaan stats
  final int totalTreatment;
  final double totalNominal;
  final int totalItem;

  // Override stats
  final double totalOverrideMasuk;
  final double totalOverrideKeluar;
  final double totalOverrideBersih;
  final int totalOverrideItems;

  const ReportSummary({
    required this.startPeriode,
    required this.endPeriode,
    this.kodeGerai,
    required this.komisiReguler5Persen,
    required this.komisiRedeem5Persen,
    required this.totalKomisi5Persen,
    this.treatmentSebelumDiskon = 0.0,
    this.treatmentSetelahDiskon = 0.0,
    this.paketSebelumDiskon = 0.0,
    this.paketSetelahDiskon = 0.0,
    this.pendapatanRedeem = 0.0,
    this.totalSebelumDiskon = 0.0,
    this.totalSetelahDiskon = 0.0,
    this.totalTreatment = 0,
    this.totalNominal = 0.0,
    this.totalItem = 0,
    this.totalOverrideMasuk = 0.0,
    this.totalOverrideKeluar = 0.0,
    this.totalOverrideBersih = 0.0,
    this.totalOverrideItems = 0,
  });

  factory ReportSummary.empty() => ReportSummary(
        startPeriode: DateTime.now(),
        endPeriode: DateTime.now(),
        komisiReguler5Persen: 0.0,
        komisiRedeem5Persen: 0.0,
        totalKomisi5Persen: 0.0,
        treatmentSebelumDiskon: 0.0,
        treatmentSetelahDiskon: 0.0,
        paketSebelumDiskon: 0.0,
        paketSetelahDiskon: 0.0,
        pendapatanRedeem: 0.0,
        totalSebelumDiskon: 0.0,
        totalSetelahDiskon: 0.0,
        totalTreatment: 0,
        totalNominal: 0.0,
        totalItem: 0,
        totalOverrideMasuk: 0.0,
        totalOverrideKeluar: 0.0,
        totalOverrideBersih: 0.0,
        totalOverrideItems: 0,
      );

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    final periodeMap = json['periode'] is Map<String, dynamic> ? json['periode'] as Map<String, dynamic> : null;
    final omzetMap = json['omzet'] is Map<String, dynamic> ? json['omzet'] as Map<String, dynamic> : null;
    final pengerjaanStats = json['pengerjaan_stats'] is Map<String, dynamic> ? json['pengerjaan_stats'] as Map<String, dynamic> : null;
    final overrideStats = json['override_stats'] is Map<String, dynamic> ? json['override_stats'] as Map<String, dynamic> : null;

    final now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, 1);
    DateTime end = DateTime(now.year, now.month + 1, 0);
    if (periodeMap?['start_date'] != null) {
      try { start = DateTime.parse(periodeMap!['start_date'].toString()); } catch (_) {}
    }
    if (periodeMap?['end_date'] != null) {
      try { end = DateTime.parse(periodeMap!['end_date'].toString()); } catch (_) {}
    }

    double parseNum(dynamic val, [double def = 0.0]) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '$def') ?? def;
    }

    int parseInt(dynamic val, [int def = 0]) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '$def') ?? def;
    }

    return ReportSummary(
      startPeriode: start,
      endPeriode: end,
      kodeGerai: periodeMap?['kode_gerai']?.toString(),
      komisiReguler5Persen: parseNum(json['komisi_reguler_5_persen'], 0.0),
      komisiRedeem5Persen: parseNum(json['komisi_redeem_5_persen'], 0.0),
      totalKomisi5Persen: parseNum(json['total_komisi_5_persen'], 0.0),
      treatmentSebelumDiskon: parseNum(omzetMap?['treatment_sebelum_diskon'], 0.0),
      treatmentSetelahDiskon: parseNum(omzetMap?['treatment_setelah_diskon'], 0.0),
      paketSebelumDiskon: parseNum(omzetMap?['paket_sebelum_diskon'], 0.0),
      paketSetelahDiskon: parseNum(omzetMap?['paket_setelah_diskon'], 0.0),
      pendapatanRedeem: parseNum(omzetMap?['pendapatan_redeem'], 0.0),
      totalSebelumDiskon: parseNum(omzetMap?['total_sebelum_diskon'], 0.0),
      totalSetelahDiskon: parseNum(omzetMap?['total_setelah_diskon'], 0.0),
      totalTreatment: parseInt(pengerjaanStats?['total_treatment'] ?? pengerjaanStats?['total_items'] ?? pengerjaanStats?['total_qty'], 0),
      totalNominal: parseNum(pengerjaanStats?['total_nominal'], 0.0),
      totalItem: parseInt(pengerjaanStats?['total_items'], 0),
      totalOverrideMasuk: parseNum(overrideStats?['total_override_masuk'], 0.0),
      totalOverrideKeluar: parseNum(overrideStats?['total_override_keluar'], 0.0),
      totalOverrideBersih: parseNum(overrideStats?['total_override_masuk'], 0.0) - parseNum(overrideStats?['total_override_keluar'], 0.0),
      totalOverrideItems: parseInt(overrideStats?['total_override_items'], 0),
    );
  }
}

class PengerjaanItem {
  final int id;
  final DateTime tanggal;
  final String kategoriTipe; // 'reguler' or 'redeem'
  final String customerName;
  final String customerPhone;
  final String productName;
  final String noTransaksi;
  final int jumlah;
  final double nominalPerItem;
  final double totalNominal;
  final String? namaPaket;
  final String? idPaket;
  final String? dijualOleh;

  const PengerjaanItem({
    required this.id,
    required this.tanggal,
    required this.kategoriTipe,
    required this.customerName,
    this.customerPhone = '0812 3456 7890',
    required this.productName,
    required this.noTransaksi,
    required this.jumlah,
    required this.nominalPerItem,
    required this.totalNominal,
    this.namaPaket,
    this.idPaket,
    this.dijualOleh,
  });

  factory PengerjaanItem.fromJson(Map<String, dynamic> json) {
    DateTime tgl = DateTime.now();
    final rawDate = json['tgl'] ?? json['tanggal'];
    if (rawDate != null) {
      try { tgl = DateTime.parse(rawDate.toString()); } catch (_) {}
    }
    double parseNum(dynamic val, [double def = 0.0]) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '$def') ?? def;
    }

    final rawKet = (json['keterangan'] ??
            json['kategori_tipe'] ??
            json['tipe'] ??
            json['kategori'] ??
            json['status_item'])
        ?.toString()
        .trim() ?? '';
    final rawKetLower = rawKet.toLowerCase();

    String kat;
    if (rawKetLower.contains('override')) {
      kat = 'Redeem Override';
    } else if (rawKetLower.contains('paket lama') || rawKetLower.contains('old package')) {
      kat = 'Paket Lama';
    } else if (rawKetLower.contains('redeem') || json['is_redeem'] == true) {
      kat = 'Redeem Paket';
    } else if (rawKetLower.contains('normal') ||
        rawKetLower.contains('reguler') ||
        rawKetLower.contains('regular') ||
        rawKetLower.contains('treatment') ||
        rawKetLower.contains('single') ||
        rawKetLower.contains('layanan')) {
      kat = 'Treatment Reguler';
    } else if (rawKet.isNotEmpty) {
      kat = rawKet;
    } else {
      kat = (json['is_redeem'] == true) ? 'Redeem Paket' : 'Treatment Reguler';
    }

    return PengerjaanItem(
      id: json['no'] is int ? json['no'] : (json['id'] is int ? json['id'] : int.tryParse(json['no']?.toString() ?? json['id']?.toString() ?? '1') ?? 1),
      tanggal: tgl,
      kategoriTipe: kat,
      customerName: json['nama_cust']?.toString() ?? json['customer_name']?.toString() ?? '-',
      customerPhone: json['customer_phone']?.toString() ?? '-',
      productName: json['treatment']?.toString() ?? json['product_name']?.toString() ?? '-',
      noTransaksi: json['id_trx']?.toString() ?? json['no_transaksi']?.toString() ?? '-',
      jumlah: json['qty'] is int ? json['qty'] : (json['jumlah'] is int ? json['jumlah'] : int.tryParse(json['qty']?.toString() ?? json['jumlah']?.toString() ?? '1') ?? 1),
      nominalPerItem: parseNum(json['nominal_satuan'] ?? json['nominal_per_item']),
      totalNominal: parseNum(json['total_nominal']),
      namaPaket: json['package_custom_name']?.toString() ?? json['nama_paket']?.toString(),
      idPaket: json['id_package_custom']?.toString() ?? json['id_paket']?.toString(),
      dijualOleh: json['nama_terapis_package']?.toString() ?? json['dijual_oleh']?.toString(),
    );
  }

  bool get isRedeem =>
      kategoriTipe.toLowerCase().contains('redeem') ||
      kategoriTipe.toLowerCase().contains('paket');
}

class OverrideItem {
  final int id;
  final DateTime tanggal;
  final String tipe; // 'masuk' or 'keluar'
  final String customerName;
  final String customerPhone;
  final String productName;
  final String namaPaket;
  final String idPaket;
  final String noTransaksi;
  final String dijualOleh;
  final String dikerjakanOleh;
  final double dasarKomisi;
  final double rateKomisi; // usually 5%
  final double komisiOverride;

  const OverrideItem({
    required this.id,
    required this.tanggal,
    required this.tipe,
    required this.customerName,
    this.customerPhone = '-',
    required this.productName,
    required this.namaPaket,
    this.idPaket = '-',
    required this.noTransaksi,
    required this.dijualOleh,
    required this.dikerjakanOleh,
    required this.dasarKomisi,
    this.rateKomisi = 5.0,
    required this.komisiOverride,
  });

  factory OverrideItem.fromJson(Map<String, dynamic> json) {
    DateTime tgl = DateTime.now();
    if (json['tanggal'] != null) {
      try { tgl = DateTime.parse(json['tanggal'].toString()); } catch (_) {}
    }
    double parseNum(dynamic val, [double def = 0.0]) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '$def') ?? def;
    }

    return OverrideItem(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      tanggal: tgl,
      tipe: json['tipe']?.toString().toLowerCase() ?? 'masuk',
      customerName: json['customer_name']?.toString() ?? '-',
      customerPhone: json['customer_phone']?.toString() ?? '-',
      productName: json['product_name']?.toString() ?? '-',
      namaPaket: json['nama_paket']?.toString() ?? '-',
      idPaket: json['id_paket']?.toString() ?? '-',
      noTransaksi: json['no_transaksi']?.toString() ?? '-',
      dijualOleh: json['dijual_oleh']?.toString() ?? '-',
      dikerjakanOleh: json['dikerjakan_oleh']?.toString() ?? '-',
      dasarKomisi: parseNum(json['dasar_komisi']),
      rateKomisi: parseNum(json['rate_komisi'], 5.0),
      komisiOverride: parseNum(json['komisi_override']),
    );
  }

  bool get isMasuk => tipe.toLowerCase() == 'masuk';
}

