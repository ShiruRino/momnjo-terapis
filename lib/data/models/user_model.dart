class UserProfile {
  final String username;
  final String namaLengkap;
  final String nickname;
  final String email;
  final String noTelp;
  final String foto;
  final String address;
  final int idGerai;
  final String namaGerai;
  final String kodeGerai;
  final int idPegawai;
  final String position;
  final String workInBranch;

  const UserProfile({
    required this.username,
    required this.namaLengkap,
    required this.nickname,
    required this.email,
    required this.noTelp,
    required this.foto,
    this.address = '',
    required this.idGerai,
    required this.namaGerai,
    required this.kodeGerai,
    required this.idPegawai,
    required this.position,
    required this.workInBranch,
  });

  factory UserProfile.empty() => const UserProfile(
        username: '',
        namaLengkap: '',
        nickname: '',
        email: '',
        noTelp: '',
        foto: '',
        address: '',
        idGerai: 0,
        namaGerai: '',
        kodeGerai: '',
        idPegawai: 0,
        position: '',
        workInBranch: '',
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username']?.toString() ?? '',
      namaLengkap: json['nama_lengkap']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? (json['username']?.toString() ?? ''),
      email: json['email']?.toString() ?? '',
      noTelp: json['no_telp']?.toString() ?? '',
      foto: json['foto']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      idGerai: json['id_gerai'] is int ? json['id_gerai'] : int.tryParse(json['id_gerai']?.toString() ?? '0') ?? 0,
      namaGerai: json['nama_gerai']?.toString() ?? '',
      kodeGerai: json['kode_gerai']?.toString() ?? '',
      idPegawai: json['id_pegawai'] is int ? json['id_pegawai'] : int.tryParse(json['id_pegawai']?.toString() ?? '0') ?? 0,
      position: json['position']?.toString() ?? 'Terapis',
      workInBranch: json['work_in_branch']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'nama_lengkap': namaLengkap,
      'nickname': nickname,
      'email': email,
      'no_telp': noTelp,
      'foto': foto,
      'address': address,
      'id_gerai': idGerai,
      'nama_gerai': namaGerai,
      'kode_gerai': kodeGerai,
      'id_pegawai': idPegawai,
      'position': position,
      'work_in_branch': workInBranch,
    };
  }

  UserProfile copyWith({
    String? namaLengkap,
    String? nickname,
    String? email,
    String? noTelp,
    String? foto,
    String? address,
    int? idGerai,
    String? namaGerai,
    String? kodeGerai,
    int? idPegawai,
    String? position,
    String? workInBranch,
  }) {
    return UserProfile(
      username: username,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      noTelp: noTelp ?? this.noTelp,
      foto: foto ?? this.foto,
      address: address ?? this.address,
      idGerai: idGerai ?? this.idGerai,
      namaGerai: namaGerai ?? this.namaGerai,
      kodeGerai: kodeGerai ?? this.kodeGerai,
      idPegawai: idPegawai ?? this.idPegawai,
      position: position ?? this.position,
      workInBranch: workInBranch ?? this.workInBranch,
    );
  }
}

