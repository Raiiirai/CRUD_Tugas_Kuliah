import 'package:flutter/material.dart';

// Model untuk menyimpan data tugas kuliah.
class Tugas {
  // ID bertambah otomatis setiap kali tugas baru dibuat.
  static int _idTerakhir = 0;

  final int id;
  final String judul;
  final String mataKuliah;
  final String tenggat;
  final String? catatan;

  // Constructor untuk membuat tugas baru dengan ID otomatis.
  Tugas({
    required this.judul,
    required this.mataKuliah,
    required this.tenggat,
    this.catatan,
  }) : id = ++_idTerakhir;

  // Constructor untuk membuat salinan data dengan ID yang tetap sama.
  // Digunakan ketika data tugas diubah.
  Tugas.denganId({
    required this.id,
    required this.judul,
    required this.mataKuliah,
    required this.tenggat,
    this.catatan,
  });
}

void main() {
  runApp(const AplikasiTugasKuliah());
}

class AplikasiTugasKuliah extends StatelessWidget {
  const AplikasiTugasKuliah({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pengelola Tugas Kuliah',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HalamanDaftarTugas(),
    );
  }
}

// Halaman utama untuk menampilkan dan mengelola daftar tugas.
class HalamanDaftarTugas extends StatefulWidget {
  const HalamanDaftarTugas({super.key});

  @override
  State<HalamanDaftarTugas> createState() => _HalamanDaftarTugasState();
}

class _HalamanDaftarTugasState extends State<HalamanDaftarTugas> {
  // Seluruh data disimpan sementara di dalam List.
  final List<Tugas> daftarTugas = [
    Tugas(
      judul: 'Membuat Makalah Pendidikan',
      mataKuliah: 'Pengantar Pendidikan',
      tenggat: '10/11/2026',
      catatan: 'Makalah minimal 10 halaman.',
    ),
    Tugas(
      judul: 'Membuat Program Flutter',
      mataKuliah: 'Pemrograman Mobile',
      tenggat: '12/11/2026',
      catatan: 'Menggunakan fitur CRUD.',
    ),
    Tugas(
      judul: 'Menyusun Laporan Observasi',
      mataKuliah: 'Praktik Pengalaman Lapangan',
      tenggat: '15/11/2026',
      catatan: 'Sertakan dokumentasi kegiatan.',
    ),
  ];

  // CREATE: membuka formulir untuk menambahkan tugas baru.
  Future<void> _bukaFormTambahTugas() async {
    final Tugas? tugasBaru = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(builder: (context) => const HalamanFormTugas()),
    );

    if (!mounted || tugasBaru == null) return;

    setState(() {
      daftarTugas.add(tugasBaru);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil ditambahkan!')),
    );
  }

  // UPDATE: membuka formulir edit dengan data yang sudah terisi.
  Future<void> _bukaFormUbahTugas(Tugas tugas) async {
    final Tugas? tugasDiperbarui = await Navigator.push<Tugas>(
      context,
      MaterialPageRoute(
        builder: (context) => HalamanFormTugas(tugas: tugas),
      ),
    );

    if (!mounted || tugasDiperbarui == null) return;

    // Pencarian dan pembaruan dilakukan berdasarkan ID, bukan indeks lama.
    final int indeksTugas = daftarTugas.indexWhere(
      (item) => item.id == tugasDiperbarui.id,
    );

    if (indeksTugas == -1) return;

    setState(() {
      daftarTugas[indeksTugas] = tugasDiperbarui;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil diubah!')),
    );
  }

  // DELETE: meminta konfirmasi sebelum menghapus data tugas.
  Future<void> _konfirmasiHapusTugas(Tugas tugas) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Tugas?'),
          content: Text(
            'Apakah Anda yakin ingin menghapus tugas "${tugas.judul}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted || konfirmasi != true) return;

    setState(() {
      // Hapus tugas yang ID-nya sesuai dengan tugas yang dipilih.
      daftarTugas.removeWhere((item) => item.id == tugas.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tugas berhasil dihapus!')),
    );
  }

  // Membuka halaman detail tugas.
  void _bukaDetailTugas(Tugas tugas) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HalamanDetailTugas(tugas: tugas)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Tugas Kuliah')),
      body: Column(
        children: [
          // Menampilkan jumlah tugas.
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${daftarTugas.length} tugas tersedia',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menampilkan daftar tugas atau pesan ketika daftar kosong.
          Expanded(
            child: daftarTugas.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada tugas kuliah.\nSilakan tambahkan tugas baru.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: daftarTugas.length,
                    itemBuilder: (context, index) {
                      final tugas = daftarTugas[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.assignment),
                          ),
                          title: Text(
                            tugas.judul,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${tugas.mataKuliah}\n'
                            'Tenggat: ${tugas.tenggat}',
                          ),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                tooltip: 'Ubah tugas',
                                onPressed: () => _bukaFormUbahTugas(tugas),
                                icon: const Icon(Icons.edit_outlined),
                                color: Colors.indigo,
                              ),
                              IconButton(
                                tooltip: 'Hapus tugas',
                                onPressed: () => _konfirmasiHapusTugas(tugas),
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                              ),
                            ],
                          ),
                          // Item tetap dapat ditekan untuk melihat detail.
                          onTap: () => _bukaDetailTugas(tugas),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormTambahTugas,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Tugas'),
      ),
    );
  }
}

// Formulir yang digunakan bersama untuk tambah dan ubah tugas.
class HalamanFormTugas extends StatefulWidget {
  final Tugas? tugas;

  const HalamanFormTugas({super.key, this.tugas});

  @override
  State<HalamanFormTugas> createState() => _HalamanFormTugasState();
}

class _HalamanFormTugasState extends State<HalamanFormTugas> {
  final _formKey = GlobalKey<FormState>();

  final _judulController = TextEditingController();
  final _mataKuliahController = TextEditingController();
  final _tenggatController = TextEditingController();
  final _catatanController = TextEditingController();

  bool get _modeEdit => widget.tugas != null;

  @override
  void initState() {
    super.initState();

    // Jika mode edit, isi semua input dengan data tugas sebelumnya.
    final tugas = widget.tugas;
    if (tugas != null) {
      _judulController.text = tugas.judul;
      _mataKuliahController.text = tugas.mataKuliah;
      _tenggatController.text = tugas.tenggat;
      _catatanController.text = tugas.catatan ?? '';
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _mataKuliahController.dispose();
    _tenggatController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // Menentukan tanggal awal pada DatePicker berdasarkan nilai input saat ini.
  DateTime _tanggalAwalPicker() {
    final bagianTanggal = _tenggatController.text.split('/');

    if (bagianTanggal.length == 3) {
      final hari = int.tryParse(bagianTanggal[0]);
      final bulan = int.tryParse(bagianTanggal[1]);
      final tahun = int.tryParse(bagianTanggal[2]);

      if (hari != null && bulan != null && tahun != null) {
        return DateTime(tahun, bulan, hari);
      }
    }

    return DateTime.now();
  }

  // Memilih tanggal tenggat menggunakan DatePicker.
  Future<void> _pilihTenggat() async {
    final DateTime? tanggalDipilih = await showDatePicker(
      context: context,
      initialDate: _tanggalAwalPicker(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Pilih Tenggat Tugas',
    );

    if (tanggalDipilih == null) return;

    final tanggal =
        '${tanggalDipilih.day.toString().padLeft(2, '0')}/'
        '${tanggalDipilih.month.toString().padLeft(2, '0')}/'
        '${tanggalDipilih.year}';

    setState(() {
      _tenggatController.text = tanggal;
    });
  }

  // Memvalidasi input lalu mengembalikan data ke halaman daftar tugas.
  void _simpanTugas() {
    if (!_formKey.currentState!.validate()) return;

    final judul = _judulController.text.trim();
    final mataKuliah = _mataKuliahController.text.trim();
    final tenggat = _tenggatController.text.trim();
    final catatan = _catatanController.text.trim().isEmpty
        ? null
        : _catatanController.text.trim();

    final Tugas tugasDisimpan;

    if (_modeEdit) {
      // Pertahankan ID lama agar identitas tugas tidak berubah.
      tugasDisimpan = Tugas.denganId(
        id: widget.tugas!.id,
        judul: judul,
        mataKuliah: mataKuliah,
        tenggat: tenggat,
        catatan: catatan,
      );
    } else {
      // Tugas baru mendapatkan ID otomatis dari constructor.
      tugasDisimpan = Tugas(
        judul: judul,
        mataKuliah: mataKuliah,
        tenggat: tenggat,
        catatan: catatan,
      );
    }

    Navigator.pop(context, tugasDisimpan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Ubah Tugas' : 'Tambah Tugas Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input judul tugas.
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  hintText: 'Masukkan judul tugas',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  final judul = value?.trim() ?? '';

                  if (judul.isEmpty) {
                    return 'Judul tugas wajib diisi.';
                  }
                  if (judul.length < 3) {
                    return 'Judul minimal 3 karakter.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input mata kuliah.
              TextFormField(
                controller: _mataKuliahController,
                decoration: const InputDecoration(
                  labelText: 'Mata Kuliah',
                  hintText: 'Masukkan nama mata kuliah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Mata kuliah wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input tenggat waktu.
              TextFormField(
                controller: _tenggatController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Tenggat Waktu',
                  hintText: 'Pilih tanggal tenggat',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    onPressed: _pilihTenggat,
                    icon: const Icon(Icons.date_range),
                  ),
                ),
                onTap: _pilihTenggat,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tenggat waktu wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Catatan tetap bersifat opsional.
              TextFormField(
                controller: _catatanController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan tugas',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _simpanTugas,
                icon: const Icon(Icons.save),
                label: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan Tugas'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman untuk menampilkan detail tugas.
class HalamanDetailTugas extends StatelessWidget {
  final Tugas tugas;

  const HalamanDetailTugas({super.key, required this.tugas});

  @override
  Widget build(BuildContext context) {
    final String isiCatatan =
        tugas.catatan == null || tugas.catatan!.trim().isEmpty
        ? 'Tidak ada catatan.'
        : tugas.catatan!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Tugas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assignment, size: 48, color: Colors.indigo),
                  const SizedBox(height: 20),

                  const Text(
                    'ID Tugas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('${tugas.id}'),
                  const Divider(height: 32),

                  const Text(
                    'Judul Tugas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(tugas.judul, style: const TextStyle(fontSize: 18)),
                  const Divider(height: 32),

                  const Text(
                    'Mata Kuliah',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(tugas.mataKuliah),
                  const Divider(height: 32),

                  const Text(
                    'Tenggat Waktu',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(tugas.tenggat),
                  const Divider(height: 32),

                  const Text(
                    'Catatan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(isiCatatan),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
