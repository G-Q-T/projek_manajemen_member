import 'package:flutter/material.dart';
import 'database.dart';
import 'anggota.dart';

void main() => runApp(AnggotaApp());

class AnggotaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manajemen Anggota',
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.green,
      ),
      home: AnggotaPage(),
    );
  }
}

class AnggotaPage extends StatefulWidget {
  @override
  _AnggotaPageState createState() => _AnggotaPageState();
}

class _AnggotaPageState extends State<AnggotaPage> {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;
  late List<Anggota> anggotaList = [];
  List<Anggota> filteredAnggotaList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAnggota();
    searchController.addListener(_filterAnggota);
  }

  void _filterAnggota() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredAnggotaList = anggotaList
          .where((anggota) =>
              anggota.nama.toLowerCase().contains(query) ||
              anggota.id.toString().contains(query))
          .toList();
    });
  }

  Future<void> _fetchAnggota() async {
    final list = await dbHelper.getAllAnggota();
    setState(() {
      anggotaList = list;
      filteredAnggotaList = list;
    });
  }

  void _showForm([Anggota? anggota]) async {
    final TextEditingController namaController = TextEditingController(
      text: anggota?.nama ?? '',
    );
    final TextEditingController noTeleponController = TextEditingController(
      text: anggota?.noTelepon ?? '',
    );
    final TextEditingController waktuBergabungController =
        TextEditingController(text: anggota?.waktuBergabung ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(anggota == null ? 'Tambah Anggota' : 'Edit Anggota'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: noTeleponController,
              decoration: InputDecoration(labelText: 'No Telepon'),
            ),
            TextField(
              controller: waktuBergabungController,
              decoration: InputDecoration(labelText: 'Waktu Bergabung'),
              readOnly: true,
              onTap: () async {
                DateTime initialDate = DateTime.now();
                final DateTime? selectedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (selectedDate != null) {
                  waktuBergabungController.text =
                      '${selectedDate.toLocal()}'.split(' ')[0];
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final nama = namaController.text;
              final noTelepon = noTeleponController.text;
              final waktuBergabung = waktuBergabungController.text;

              if (nama.isEmpty || noTelepon.isEmpty || waktuBergabung.isEmpty) {
                return;
              }

              final newAnggota = Anggota(
                id: anggota?.id,
                nama: nama,
                noTelepon: noTelepon,
                waktuBergabung: waktuBergabung,
              );

              if (anggota == null) {
                await dbHelper.insertAnggota(newAnggota);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Anggota berhasil ditambahkan!'),
                    backgroundColor:
                        Colors.green, // Hijau untuk notifikasi sukses
                  ),
                );
              } else {
                await dbHelper.updateAnggota(newAnggota);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Anggota berhasil diperbarui!'),
                    backgroundColor: const Color(0xFF6144EF),
                  ),
                );
              }

              Navigator.of(context).pop();
              _fetchAnggota();
            },
            child: Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteAnggota(int id) async {
    await dbHelper.deleteAnggota(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anggota berhasil dihapus!'),
        backgroundColor: Colors.red, // Merah untuk notifikasi hapus
      ),
    );
    _fetchAnggota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manajemen Anggota')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Cari Anggota (ID/Nama)',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredAnggotaList.isEmpty
                ? Center(child: Text('Belum ada anggota.'))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16.0,
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Nama')),
                        DataColumn(label: Text('No Telepon')),
                        DataColumn(label: Text('Waktu Bergabung')),
                        DataColumn(label: Text('Aksi')),
                      ],
                      rows: filteredAnggotaList.map((anggota) {
                        return DataRow(cells: [
                          DataCell(Text(anggota.id.toString())),
                          DataCell(
                            Text(
                              anggota.nama,
                              overflow: TextOverflow
                                  .ellipsis, // Menambahkan elipsis pada teks panjang
                            ),
                          ),
                          DataCell(Text(anggota.noTelepon)),
                          DataCell(Text(anggota.waktuBergabung)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize
                                  .min, // Menghindari kolom aksi menjadi terlalu lebar
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: const Color(0xFF6144EF)),
                                  onPressed: () => _showForm(anggota),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteAnggota(anggota.id!),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(),
        backgroundColor: const Color(0xFF4CAF50), // Hijau untuk tombol tambah
      ),
    );
  }
}
