class Anggota {
  final int? id;
  final String nama;
  final String noTelepon;
  final String waktuBergabung;

  Anggota(
      {this.id,
      required this.nama,
      required this.noTelepon,
      required this.waktuBergabung});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'no_telepon': noTelepon,
      'waktu_bergabung': waktuBergabung,
    };
  }

  factory Anggota.fromMap(Map<String, dynamic> map) {
    return Anggota(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      noTelepon: map['no_telepon'] as String,
      waktuBergabung: map['waktu_bergabung'] as String,
    );
  }
}
