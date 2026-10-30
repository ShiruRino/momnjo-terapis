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
    this.treatmentSebelumDiskon = 7000000.0,
    this.treatmentSetelahDiskon = 6500000.0,
    this.paketSebelumDiskon = 2000000.0,
    this.paketSetelahDiskon = 2000000.0,
    this.pendapatanRedeem = 1000000.0,
    this.totalSebelumDiskon = 9000000.0,
    this.totalSetelahDiskon = 8500000.0,
    this.totalTreatment = 28,
    this.totalNominal = 6000000.0,
    this.totalItem = 28,
    this.totalOverrideMasuk = 75000.0,
    this.totalOverrideKeluar = 25000.0,
    this.totalOverrideBersih = 50000.0,
    this.totalOverrideItems = 4,
  });
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

  bool get isRedeem => kategoriTipe.toLowerCase() == 'redeem';
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
    this.customerPhone = '0812 3456 7890',
    required this.productName,
    required this.namaPaket,
    this.idPaket = 'PKT-20261015-0003',
    required this.noTransaksi,
    required this.dijualOleh,
    required this.dikerjakanOleh,
    required this.dasarKomisi,
    this.rateKomisi = 5.0,
    required this.komisiOverride,
  });

  bool get isMasuk => tipe.toLowerCase() == 'masuk';
}

