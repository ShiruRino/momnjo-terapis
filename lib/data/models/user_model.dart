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

