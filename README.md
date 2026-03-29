
# SISOP-1-2026-IT-013
Laporan Resmi Praktikum Sistem Operasi Modul 1


## Penulis
Nadya Putri Agustin \
5027251013

## Soal 1
Analisis Data Penumpang KANJ Menggunakan AWK

```
BEGIN {
    if (ARGC < 3) {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
        exit
    }

    opsi = ARGV[2]
    delete ARGV[2]

    FS = ","
}

NR > 1 {
    count_passenger++

    oldest_name = $1
    age = $2
    kelas = $3
    carriage_name = substr($4, 1, 8)

    if (!(carriage_name in carriage_list)) {
        carriage_list[carriage_name] = 1
        carriage++
    }

    if (NR == 2 || age > max_age) {
        max_age = age
        oldest = oldest_name
    }

    total_age += age

    if (kelas == "Business") {
        business_passenger++
    }
}

END {
    if (opsi == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
    }
    else if (opsi == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " carriage
    }
    else if (opsi == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
    else if (opsi == "d") {
        average_age = int((total_age / count_passenger) + 0.5)
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    }
    else if (opsi == "e") {
        print "Jumlah penumpang business class ada " business_passenger " orang"
    }
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
    }
}
```



#### Setup Program
```
BEGIN {
    if (ARGC < 3) {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
        exit
    }

    opsi = ARGV[2]
    delete ARGV[2]

    FS = ","
}
```

`BEGIN` adalah kode yang dijalankan paling pertama sebelum file dibaca dengan tujuan untuk setup awal sebelum data diproses.

`ARGC` adalah jumlah imput yang dimasukkan saat menjakankan program. 

Contoh:
```
awk -f KANJ.sh passenger.csv a
```
Jumlah input yang dibutuhkan: \
    1. `awk`: Program \
    2. `passenger.csv`: File data \
    3.  `a`: Opsi soal 

Jika input kurang dari 3, maka program akan menampilkan pesan error lalu berhenti (`exit`).
Pesan error yang akan ditampilkan oleh program:
```
Soal tidak dikenali. Gunakan a, b, c, d, atau e.
Contoh penggunaan: awk -f KANJ.sh passenger.csv a
```
`ARGV` adalah daftar input dari user. 

Dimana: 
- `ARGV[0]: awk` 
- `ARGV[1]: passenger.csv` 
- `ARGV[2]: a`

Sehingga `opsi = ARGV[2]` berarti nilai `a` diambil dan disimpan sebagai variabel `opsi`. \
Dengan ini, program akan tahu soal yang harus dikerjakan itu yang mana (a, b, c, d, atau e)

`delete ARGV[2]` digunakan supaya AWK tidak membaca opsi (a/b/c/d/e) sebagai file sehingga perlu menghapusnya dari daftar input.

`FS = ","` dimana `FS` adalah Field Separator (pemisah kolom) dan `","` artinya data dipisahkan oleh koma supaya AWK bisa membaca per kolom dengan benar.

Contoh data:
```
nama,umur,kelas,gerbong
```
Maka: 
- `$1 = nama` 
- `$2 = umur`
- `$3 = kelas` 
- `$4 = gerbong`

#### Eksekusi Program AWK

```
NR > 1 {
    count_passenger++

    oldest_name = $1
    age = $2
    kelas = $3
    carriage_name = substr($4, 1, 8)

    if (!(carriage_name in carriage_list)) {
        carriage_list[carriage_name] = 1
        carriage++
    }

    if (NR == 2 || age > max_age) {
        max_age = age
        oldest = oldest_name
    }

    total_age += age

    if (kelas == "Business") {
        business_passenger++
    }
}
```

`NR` adalah nomor baris sehingga `NR > 1` artinya skip baris pertama atau header.

Contoh:
```
Nama Penumpang,Usia,Kursi Kelas,Gerbong   -> dilewati
Budi Hartanto,34,Economy,Gerbong2    -> mulai diproses
```

`count_passenger++` artinya menambah jumlah penumpang.

 Ambil data dari tiap kolom:
```
oldest_name = $1 
age = $2 
kelas = $3 
```
Artinya:
- `$1` = Nama penumpang 
- `$2` = Usia
- `$3` = Kursi kelas

Ambil nama gerbong:
```
carriage_name = substr($4, 1, 8)
```
Artinya: Ambil 8 karakter pertama dari kolom ke 4

#### Bentuk Fungsi `substr()`
```
substr(teks, mulai, panjang)
```
Dimana:
- `teks`: sumber teks
- `mulai`: mulai dari karakter ke berapa
- `panjang`: ambil berapa karakter

Contoh:
```
Gerbong1
12345678
```
Sehingga:
```
carriage_name = "gerbong1"
```
Ini digunakan agar program membaca jumlah gerbong sebanyak 4.

Hitung jumlah gerbong unik:
```
if (!(carriage_name in carriage_list)) {
    carriage_list[carriage_name] = 1
    carriage++
}
```
Program digunakan untuk mengecek apakah gerbong sudah pernah dihitung. Jika belum, maka gerbong akan disimpan ke list dan jumlah gerbong akan bertambah. Ini untuk menghitung gerbong yang berbeda saja (unik).

Cari penumpang tertua:
```
if (NR == 2 || age > max_age) {
    max_age = age
    oldest = oldest_name
}
```
dimana:
-  `NR == 2` artinya baris data pertama, karena:
    - `NR == 1`: Header (judul kolom)
    - `NR == 2`: Data pertama
- `age > max_age` artinya kalau umur sekarang lebih besar dari data yang tersimpan.
- `||` (OR) artinya program dijalankan kalau salah satu benar. \
Jadi, baris pertama nanti akan langsung mengisi nilai di awal (inisialisasi). Lalu kalau ada umur yang lebih besar maka nilai akan di update.
- `oldest = oldest_name` untuk menyimpan data penumpang tertua

Total umur:
```
total_age += age
```
Semua umur akan dijumlah untuk nanti dihitung rata-ratanya.

Hitung penumpang di business class:
```
if (kelas == "Business") {
    business_passenger++
}
```
Kalau di kursi kelasnya tertulis Business maka jumlah penumpang business class akan bertambah.
#### Output

```
END {
    if (opsi == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
    }
    else if (opsi == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " carriage
    }
    else if (opsi == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
    else if (opsi == "d") {
        average_age = int((total_age / count_passenger) + 0.5)
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    }
    else if (opsi == "e") {
        print "Jumlah penumpang business class ada " business_passenger " orang"
    }
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
    }
}
```
`END` ini akan dijalankan  setelah semua data selesai baca.

Opsi a - Jumlah Penumpang
```
print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
```
Opsi b - Jumlah Gerbong
```
print "Jumlah gerbong penumpang KANJ adalah " carriage
```
Opsi c - Penumpang Tertua
```
print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
```
Opsi d - Rata-rata Umur
```
average_age = int((total_age / count_passenger) + 0.5)
```
Opsi e - Jumlah Penumpang Business Class
```
print "Jumlah penumpang business class ada " business_passenger " orang"
```
Selain opsi a / b / c / d / e, maka program akan menampilkan pesan error
```
print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
```

### Hasil Output Program
#### 1. Opsi a

Input
```
awk -f KANJ.sh passenger.csv a
```
Output:
```
Jumlah seluruh penumpang KANJ adalah 208 orang
```

#### 2. Opsi b 
Input 
```
awk -f KANJ.sh passenger.csv b
```
Output
``` 
Jumlah gerbong penumpang KANJ adalah 4
```

#### 3. Opsi c 
Input 
```
awk -f KANJ.sh passenger.csv c 
```
Output
```
Jaja Mihardja adalah penumpang kereta tertua dengan usia 85 tahun
```

#### 4. Opsi d
Input
```
awk -f KANJ.sh passenger.csv d 
```
Output 
```
Rata-rata usia penumpang adalah 38 tahun
```

#### 5. Opsi e 
Input 
```
awk -f KANJ.sh passenger.csv e 
```
Output
```
Jumlah penumpang business class ada 74 orang
```
### REVISI Soal 1
```
else if (opsi == "d") {
        average_age = int((total_age / count_passenger) + 0.5)
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    }
```
Output dari opsi d adalah 38 tahun. Tetapi, seharusnya hasil dari opsi d adalah 37 tahun (dibulatkan di bawah). 

Kode revisi untuk mendapatkan hasil 37 tahun:
``` 
 else if (opsi == "d") {
        average_age = int((total_age / count_passenger))
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    }
```
`+ 0.5` dihapus agar mendapatkan pembulatan di bawah. 

#### Kode Lengkap REVISI

```
BEGIN {
    if (ARGC < 3) {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
        exit
    }

    opsi = ARGV[2]
    delete ARGV[2]

    FS = ","
}

NR > 1 {
    count_passenger++

    oldest_name = $1
    age = $2
    kelas = $3
    carriage_name = substr($4, 1, 8)

    if (!(carriage_name in carriage_list)) {
        carriage_list[carriage_name] = 1
        carriage++
    }

    if (NR == 2 || age > max_age) {
        max_age = age
        oldest = oldest_name
    }

    total_age += age

    if (kelas == "Business") {
        business_passenger++
    }
}

END {
    if (opsi == "a") {
        print "Jumlah seluruh penumpang KANJ adalah " count_passenger " orang"
    }
    else if (opsi == "b") {
        print "Jumlah gerbong penumpang KANJ adalah " carriage
    }
    else if (opsi == "c") {
        print oldest " adalah penumpang kereta tertua dengan usia " max_age " tahun"
    }
    else if (opsi == "d") {
        average_age = int((total_age / count_passenger))
        print "Rata-rata usia penumpang adalah " average_age " tahun"
    }
    else if (opsi == "e") {
        print "Jumlah penumpang business class ada " business_passenger " orang"
    }
    else {
        print "Soal tidak dikenali. Gunakan a, b, c, d, atau e."
        print "Contoh penggunaan: awk -f KANJ.sh passenger.csv a"
    }
}
```


## Soal 2

#### Buka PDF secara "concatenate"
Tujuannya adalah untuk mendapatkan tautan tersembunyi dari `peta-ekspedisi-amba.pdf`.
```
cat peta-ekspedisi-amba.pdf | grep -a "github"
```
Tautan Tersembunyi
```
https://github.com/pocongcyber77/peta-gunung-kawi.git
```
#### Install Git dan Clone Repo
```
git clone https://github.com/pocongcyber77/peta-gunung-kawi.git
```
Di dalam repo yang sudah di clone terdapat file `gsxtrack.json` yang berisi beberapa titik lokasi.

#### Buat File `parserkoordinat.sh` 
Script `parserkoordinat.sh` akan mengambil data dari file `gsxtrack.json`, mengekstrak informasi penting, lalu menyimpan hasilnya ke dalam file `titik-penting.txt`.

Script `parserkoordinat.sh`
```
#!/bin/bash

# parserkoordinat.sh
# Script untuk mengekstrak id, site_name, latitude, longitude
# dari file gsxtrack.json menggunakan AWK

OUTPUT="titik-penting.txt"
INPUT="gsxtrack.json"

# Kosongkan file output dulu
> "$OUTPUT"

awk '
{
    # Ekstrak id
    if ($0 ~ /"id":/) {
        gsub(/.*"id": "/, "")
        gsub(/".*/, "")
        id = $0
    }

    # Ekstrak site_name
    if ($0 ~ /"site_name":/) {
        gsub(/.*"site_name": "/, "")
        gsub(/".*/, "")
        site_name = $0
    }

    # Ekstrak latitude
    if ($0 ~ /"latitude":/) {
        gsub(/.*"latitude": /, "")
        gsub(/,.*/, "")
        latitude = $0
    }

    # Ekstrak longitude
    if ($0 ~ /"longitude":/) {
        gsub(/.*"longitude": /, "")
        gsub(/,.*/, "")
        longitude = $0

        # Setelah longitude terkumpul, print semua
        print id "," site_name "," latitude "," longitude
    }
}
' "$INPUT" >> "$OUTPUT"

echo "Berhasil! Isi titik-penting.txt:"
cat "$OUTPUT"
```
Memberitahu sistem bahwa script ini harus dijalankan menggunakan Bash.
```
#!/bin/bash
```
Membuat variabel bernama `OUTPUT` dan isi variabelnya adalah `"titik-penting.txt"`.
```
OUTPUT="titik-penting.txt"
```
Membuat variabel bernama `INPUT` dan isi variabelnya adalah `"gsxtrack.json"`.
```
INPUT="gsxtrack.json"
```
Mengosongkan isi file output sebelum data baru ditulis.
```
> "$OUTPUT"
```
Simbol `>` adalah operator redirection. Kalau file belum ada maka file akan dibuat, tetapi kalau file sudah ada maka isinya akan dihapus sampai kosong. Tujuannya adalah supaya hasil baru tidak tercampur hasil lamma.

Menjalankan program AWK
```
awk '
```
Ektrak `id`
```
# Ekstrak id
if ($0 ~ /"id":/) {
    gsub(/.*"id": "/, "")
    gsub(/".*/, "")
    id = $0
}
```
Kode ini mengecek baris yang mengandung `"id":`, lalu menghapus bagian sebelum dan sesudah nilainya sehingga tersisa hanya nilai `id` yang kemudian disimpan ke variabel `id`.

Ekstrak `site_name`
```
# Ekstrak site_name
if ($0 ~ /"site_name":/) {
    gsub(/.*"site_name": "/, "")
    gsub(/".*/, "")
    site_name = $0
}
```
Kode ini mengecek baris yang mengandung `"site_name":`, lalu menghapus bagian sebelum dan sesudah nilainya sehingga tersisa hanya nilai `site_name` yang kemudian disimpan ke variabel `site_name`.

Ekstrak `latitude`
```
# Ekstrak latitude
if ($0 ~ /"latitude":/) {
    gsub(/.*"latitude": /, "")
    gsub(/,.*/, "")
    latitude = $0
}
```
Kode ini mengecek baris yang mengandung `"latitude":`, lalu menghapus bagian sebelum dan sesudah nilainya sehingga tersisa hanya nilai `latitude` yang kemudian disimpan ke variabel `latitude`.

Ekstrak `longitude`
```
# Ekstrak longitude
if ($0 ~ /"longitude":/) {
    gsub(/.*"longitude": /, "")
    gsub(/,.*/, "")
    longitude = $0

    # Setelah longitude terkumpul, print semua
    print id "," site_name "," latitude "," longitude
}
```
Kode ini mencari baris "longitude":, membersihkan teks hingga tersisa nilai longitude, lalu menyimpannya ke variabel longitude dan mencetak semua data (id, site_name, latitude, longitude).

Bagian input dan output
```
' "$INPUT" >> "$OUTPUT"
```
AWK membaca file input `$INPUT` lalu menambahkan hasil prosesnya ke file output `$OUTPUT`.

Menampilkan hasil output
```
echo "Berhasil! Isi titik-penting.txt:"
cat "$OUTPUT"
```
Jalankan
```
chmod +x parserkoordinat.sh
./parserkoordinat.sh
```
Output
```
Berhasil! Isi titik-penting.txt:
node_001,Titik Berak Paman Mas Mba,-7.920000,112.450000
node_002,Basecamp Mas Fuad,-7.920000,112.468100
node_003,Gerbang Dimensi Keputih,-7.937960,112.468100
node_004,Tembok Ratapan Keputih,-7.937960,112.450000
```


#### Hasil Script `parserkoordinat.sh` Disimpan ke `titik-penting.txt`
Isi file `titik-penting.txt`
```
node_001,Titik Berak Paman Mas Mba,-7.920000,112.450000
node_002,Basecamp Mas Fuad,-7.920000,112.468100
node_003,Gerbang Dimensi Keputih,-7.937960,112.468100
node_004,Tembok Ratapan Keputih,-7.937960,112.450000
```
#### Buat File `nemupusaka.sh`
Script `nemupusaka.sh` akan membaca data koordinat dari titik-penting.txt, mengambil dua titik diagonal, menghitung titik tengahnya, lalu menyimpan hasilnya ke posisipusaka.txt.
Script `nemupusaka.sh`
```
#!/bin/bash

# nemupusaka.sh
# Script untuk menghitung titik tengah diagonal persegi
# dari file titik-penting.txt

INPUT="titik-penting.txt"
OUTPUT="posisipusaka.txt"

# Set locale ke C agar AWK pakai titik sebagai desimal
LC_ALL=C awk -F',' '
NR==1 {
    lat1 = $3
    lon1 = $4
}
NR==3 {
    lat3 = $3
    lon3 = $4
}
END {
    lat_tengah = (lat1 + lat3) / 2
    lon_tengah = (lon1 + lon3) / 2
    printf "Koordinat pusat: %.6f,%.6f\n", lat_tengah, lon_tengah
}
' "$INPUT" | tee "$OUTPUT"
```
Memberitahu sistem bahwa script ini harus dijalankan menggunakan Bash.
```
#!/bin/bash
```
Membuat variabel bernama INPUT dan isi variabelnya adalah "titik-penting.txt" sebagai file sumber data.
```
INPUT="titik-penting.txt"
```
Membuat variabel bernama OUTPUT dan isi variabelnya adalah "posisipusaka.txt" sebagai file hasil.
```
OUTPUT="posisipusaka.txt"
```
Menjalankan AWK dengan pemisah koma dan memastikan format angka menggunakan titik desimal.
```
LC_ALL=C awk -F','
```
Mengambil nilai kolom ke-3 dan ke-4 dari baris pertama sebagai latitude dan longitude pertama.
```
NR==1 {
    lat1 = $3
    lon1 = $4
}
```
Mengambil nilai kolom ke-3 dan ke-4 dari baris ketiga sebagai latitude dan longitude kedua.
```
NR==3 {
    lat3 = $3
    lon3 = $4
}
```
Menghitung rata-rata latitude dan longitude sebagai titik tengah.
```
END {
    lat_tengah = (lat1 + lat3) / 2
    lon_tengah = (lon1 + lon3) / 2
    printf "Koordinat pusat: %.6f,%.6f\n", lat_tengah, lon_tengah
}
```
`END` ini akan dijalankan setelah semua data selesai baca.
`%.6f,%.6f` akan menampilkan hasil koordinat dengan 6 angka di belakang koma.

Membaca  file input dan menampilkan hasil ke layar sekaligus menyimpannya ke file output
```
' "$INPUT" | tee "$OUTPUT"
```
Jalankan
```
chmod +x nemupusaka.sh
./nemupusaka.sh
```
Output
```
Koordinat pusat: -7.928980,112.459050
```
#### Hasil Script `nemupusaka.sh` Disimpan ke `posisipusaka.txt`
Isi file `posisipusaka.txt`
```
Koordinat pusat: -7.928980,112.459050
```

## Soal 3
Program manajemen kost untuk mengelola data penghuni dan pembayaran.

#### Buat file `kost_slebew.sh`
```
#!/bin/bash

# ============================================================
#   SISTEM MANAJEMEN KOST SLEBEW
#   Script Utama: kost_slebew.sh
# ============================================================

# --- Definisi Path File & Folder ---
SCRIPT_PATH="$(realpath "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"

DATA_DIR="$BASE_DIR/data"
LOG_DIR="$BASE_DIR/log"
REKAP_DIR="$BASE_DIR/rekap"
SAMPAH_DIR="$BASE_DIR/sampah"

DB_FILE="$DATA_DIR/penghuni.csv"
LOG_FILE="$LOG_DIR/tagihan.log"
REKAP_FILE="$REKAP_DIR/laporan_bulanan.txt"
HISTORY_FILE="$SAMPAH_DIR/history_hapus.csv"

# --- Inisialisasi Folder & File ---
mkdir -p "$DATA_DIR" "$LOG_DIR" "$REKAP_DIR" "$SAMPAH_DIR"
[ ! -f "$DB_FILE" ]      && touch "$DB_FILE"
[ ! -f "$LOG_FILE" ]     && touch "$LOG_FILE"
[ ! -f "$REKAP_FILE" ]   && touch "$REKAP_FILE"
[ ! -f "$HISTORY_FILE" ] && touch "$HISTORY_FILE"

# ============================================================
#   MODE: --check-tagihan (dipanggil oleh Cron)
# ============================================================
if [ "$1" == "--check-tagihan" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    found=0
    while IFS=',' read -r nama kamar harga tgl_masuk status; do
        STATUS_LOWER=$(echo "$status" | tr '[:upper:]' '[:lower:]')
        if [ "$STATUS_LOWER" == "menunggak" ]; then
            echo "[$TIMESTAMP] TAGIHAN: $nama (Kamar $kamar) - Menunggak Rp$harga" >> "$LOG_FILE"
            found=1
        fi
    done < "$DB_FILE"
    if [ "$found" -eq 0 ]; then
        echo "[$TIMESTAMP] TAGIHAN: Tidak ada penghuni menunggak." >> "$LOG_FILE"
    fi
    exit 0
fi

# ============================================================
#   FUNGSI TAMPIL HEADER ASCII
# ============================================================
show_header() {
    clear
    echo ""
    cat << 'EOF'
 ██╗  ██╗ ██████╗ ███████╗████████╗    ███████╗██╗     ███████╗██████╗ ███████╗██╗    ██╗
 ██║ ██╔╝██╔═══██╗██╔════╝╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔════╝██║    ██║
 █████╔╝ ██║   ██║███████╗   ██║       ███████╗██║     █████╗  ██████╔╝█████╗  ██║ █╗ ██║
 ██╔═██╗ ██║   ██║╚════██║   ██║       ╚════██║██║     ██╔══╝  ██╔══██╗██╔══╝  ██║███╗██║
 ██║  ██╗╚██████╔╝███████║   ██║       ███████║███████╗███████╗██████╔╝███████╗╚███╔███╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝       ╚══════╝╚══════╝╚══════╝╚═════╝ ╚══════╝ ╚══╝╚══╝
EOF
    echo ""
    echo "============================================================"
    echo "            SISTEM MANAJEMEN KOST SLEBEW"
    echo "============================================================"
    echo " ID | OPTION"
    echo "------------------------------------------------------------"
    echo "  1 | Tambah Penghuni Baru"
    echo "  2 | Hapus Penghuni"
    echo "  3 | Tampilkan Daftar Penghuni"
    echo "  4 | Update Status Penghuni"
    echo "  5 | Cetak Laporan Keuangan"
    echo "  6 | Kelola Cron (Pengingat Tagihan)"
    echo "  7 | Exit Program"
    echo "============================================================"
}

# ============================================================
#   OPSI 1: TAMBAH PENGHUNI BARU
# ============================================================
tambah_penghuni() {
    echo "============================================"
    echo "             TAMBAH PENGHUNI"
    echo "============================================"

    # Input Nama
    read -rp "Masukkan Nama: " nama
    if [ -z "$nama" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Input Kamar
    read -rp "Masukkan Kamar: " kamar
    if ! [[ "$kamar" =~ ^[0-9]+$ ]]; then
        echo "[!] Nomor kamar harus berupa angka."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Cek kamar unik
    if grep -q "^[^,]*,$kamar," "$DB_FILE" 2>/dev/null; then
        echo "[!] Kamar $kamar sudah ditempati. Pilih nomor kamar lain."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Input Harga Sewa
    read -rp "Masukkan Harga Sewa: " harga
    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "[!] Harga sewa harus berupa angka positif."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Input Tanggal Masuk
    read -rp "Masukkan Tanggal Masuk (YYYY-MM-DD): " tgl_masuk
    # Validasi format tanggal
    if ! [[ "$tgl_masuk" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "[!] Format tanggal salah. Gunakan YYYY-MM-DD."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Validasi tanggal tidak melebihi hari ini
    today=$(date "+%Y-%m-%d")
    if [[ "$tgl_masuk" > "$today" ]]; then
        echo "[!] Tanggal masuk tidak boleh melebihi hari ini ($today)."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Validasi tanggal valid (misal bulan/hari masuk akal)
    if ! date -d "$tgl_masuk" &>/dev/null; then
        echo "[!] Tanggal tidak valid."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Input Status
    read -rp "Masukkan Status Awal (Aktif/Menunggak): " status
    status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')
    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[!] Status harus 'Aktif' atau 'Menunggak'."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Normalisasi kapitalisasi
    if [ "$status_lower" == "aktif" ]; then
        status="Aktif"
    else
        status="Menunggak"
    fi

    # Simpan ke database
    echo "$nama,$kamar,$harga,$tgl_masuk,$status" >> "$DB_FILE"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================================
#   OPSI 2: HAPUS PENGHUNI
# ============================================================
hapus_penghuni() {
    echo "============================================"
    echo "             HAPUS PENGHUNI"
    echo "============================================"

    read -rp "Masukkan nama penghuni yang akan dihapus: " nama_hapus

    if [ -z "$nama_hapus" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Cek apakah penghuni ada (case-insensitive)
    baris=$(grep -i "^$nama_hapus," "$DB_FILE" | head -n1)
    if [ -z "$baris" ]; then
        echo "[!] Penghuni \"$nama_hapus\" tidak ditemukan."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Tambahkan tanggal penghapusan dan arsipkan
    tgl_hapus=$(date "+%Y-%m-%d")
    echo "$baris,$tgl_hapus" >> "$HISTORY_FILE"

    # Hapus dari database utama (case-insensitive, hapus baris pertama yang cocok)
    tmp_file=$(mktemp)
    nama_hapus_lower=$(echo "$nama_hapus" | tr '[:upper:]' '[:lower:]')
    deleted=0
    while IFS= read -r line; do
        nama_baris=$(echo "$line" | cut -d',' -f1 | tr '[:upper:]' '[:lower:]')
        if [ "$nama_baris" == "$nama_hapus_lower" ] && [ "$deleted" -eq 0 ]; then
            deleted=1
        else
            echo "$line" >> "$tmp_file"
        fi
    done < "$DB_FILE"
    mv "$tmp_file" "$DB_FILE"

    echo ""
    echo "[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================================
#   OPSI 3: TAMPILKAN DAFTAR PENGHUNI (menggunakan AWK)
# ============================================================
tampilkan_penghuni() {
    echo ""
    if [ ! -s "$DB_FILE" ]; then
        echo "============================================================"
        echo "              DAFTAR PENGHUNI KOST SLEBEW"
        echo "============================================================"
        echo "  (Belum ada penghuni terdaftar)"
        echo "============================================================"
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    awk -F',' '
    BEGIN {
        sep  = "============================================================"
        dash = "------------------------------------------------------------"
        printf "%s\n", sep
        printf "%*s\n", 45, "DAFTAR PENGHUNI KOST SLEBEW"
        printf "%s\n", sep
        printf " %-4s| %-15s| %-7s| %-15s| %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
        printf "%s\n", dash
        total=0; aktif=0; menunggak=0
    }
    {
        total++
        harga_fmt = sprintf("Rp%'"'"'d", $3)
        # Format harga dengan titik ribuan menggunakan sub
        n = $3
        formatted = ""
        while (length(n) > 3) {
            formatted = "." substr(n, length(n)-2) formatted
            n = substr(n, 1, length(n)-3)
        }
        formatted = n formatted
        harga_fmt = "Rp" formatted

        status_val = $5
        printf " %-4d| %-15s| %-7s| %-15s| %s\n", total, $1, $2, harga_fmt, status_val
        printf "%s\n", dash

        low = tolower(status_val)
        if (low == "aktif")      aktif++
        else if (low == "menunggak") menunggak++
    }
    END {
        printf " Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif, menunggak
        printf "%s\n", sep
    }
    ' "$DB_FILE"

    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================================
#   OPSI 4: UPDATE STATUS PENGHUNI
# ============================================================
update_status() {
    echo "============================================================"
    echo "                    UPDATE STATUS"
    echo "============================================================"

    read -rp "Masukkan Nama Penghuni: " nama_update

    if [ -z "$nama_update" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Cek apakah penghuni ada
    nama_update_lower=$(echo "$nama_update" | tr '[:upper:]' '[:lower:]')
    baris=$(awk -F',' -v n="$nama_update_lower" 'tolower($1)==n {print; exit}' "$DB_FILE")
    if [ -z "$baris" ]; then
        echo "[!] Penghuni \"$nama_update\" tidak ditemukan."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    read -rp "Masukkan Status Baru (Aktif/Menunggak): " status_baru
    status_baru_lower=$(echo "$status_baru" | tr '[:upper:]' '[:lower:]')
    if [ "$status_baru_lower" != "aktif" ] && [ "$status_baru_lower" != "menunggak" ]; then
        echo "[!] Status harus 'Aktif' atau 'Menunggak'."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Normalisasi
    if [ "$status_baru_lower" == "aktif" ]; then
        status_norm="Aktif"
    else
        status_norm="Menunggak"
    fi

    # Update di file
    tmp_file=$(mktemp)
    updated=0
    while IFS=',' read -r n k h t s; do
        n_lower=$(echo "$n" | tr '[:upper:]' '[:lower:]')
        if [ "$n_lower" == "$nama_update_lower" ] && [ "$updated" -eq 0 ]; then
            echo "$n,$k,$h,$t,$status_norm" >> "$tmp_file"
            updated=1
        else
            echo "$n,$k,$h,$t,$s" >> "$tmp_file"
        fi
    done < "$DB_FILE"
    mv "$tmp_file" "$DB_FILE"

    echo ""
    echo "[√] Status $nama_update berhasil diubah menjadi: $status_norm"
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================================
#   OPSI 5: CETAK LAPORAN KEUANGAN
# ============================================================
cetak_laporan() {
    echo ""

    if [ ! -s "$DB_FILE" ]; then
        echo "============================================================"
        echo "             LAPORAN KEUANGAN KOST SLEBEW"
        echo "============================================================"
        echo "  Belum ada data penghuni."
        echo "============================================================"
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    laporan=$(awk -F',' '
    BEGIN { total_aktif=0; total_menunggak=0; kamar=0 }
    {
        kamar++
        low = tolower($5)
        if (low == "aktif")       total_aktif += $3
        else if (low == "menunggak") total_menunggak += $3
    }
    function fmt(n,    r,f) {
        f=""
        while (length(n) > 3) {
            f = "." substr(n, length(n)-2) f
            n = substr(n, 1, length(n)-3)
        }
        return n f
    }
    END {
        sep = "============================================================"
        dash = "------------------------------------------------------------"
        print sep
        printf "%*s\n", 45, "LAPORAN KEUANGAN KOST SLEBEW"
        print sep
        printf " %-30s: Rp%s\n", "Total pemasukan (Aktif)", fmt(total_aktif)
        printf " %-30s: Rp%s\n", "Total tunggakan",         fmt(total_menunggak)
        printf " %-30s: %d\n",   "Jumlah kamar terisi",     kamar
        print dash
    }
    ' "$DB_FILE")

    echo "$laporan"

    # Daftar penghuni menunggak
    echo " Daftar penghuni menunggak:"
    menunggak_list=$(awk -F',' 'tolower($5)=="menunggak" {print "   - " $1 " (Kamar " $2 ") Rp" $3}' "$DB_FILE")
    if [ -z "$menunggak_list" ]; then
        echo "   Tidak ada tunggakan."
    else
        echo "$menunggak_list"
    fi
    echo "============================================================"

    # Simpan laporan ke file
    {
        echo "$laporan"
        echo " Daftar penghuni menunggak:"
        if [ -z "$menunggak_list" ]; then
            echo "   Tidak ada tunggakan."
        else
            echo "$menunggak_list"
        fi
        echo "============================================================"
        echo " Dicetak pada: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "============================================================"
    } > "$REKAP_FILE"

    echo ""
    echo "[√] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
}

# ============================================================
#   OPSI 6: KELOLA CRON
# ============================================================
kelola_cron() {
    while true; do
        echo ""
        echo "===================================="
        echo "         MENU KELOLA CRON"
        echo "===================================="
        echo " 1. Lihat Cron Job Aktif"
        echo " 2. Daftarkan Cron Job Pengingat"
        echo " 3. Hapus Cron Job Pengingat"
        echo " 4. Kembali"
        echo "===================================="
        read -rp "Pilih [1-4]: " pilih_cron

        case "$pilih_cron" in
            1)
                echo ""
                echo "--- Daftar Cron Job Pengingat Tagihan ---"
                hasil=$(crontab -l 2>/dev/null | grep -- "--check-tagihan")
                if [ -z "$hasil" ]; then
                    echo "  (Tidak ada cron job pengingat aktif)"
                else
                    echo "$hasil"
                fi
                echo ""
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            2)
                read -rp "Masukkan Jam (0-23): " jam
                read -rp "Masukkan Menit (0-59): " menit

                if ! [[ "$jam" =~ ^[0-9]+$ ]] || [ "$jam" -lt 0 ] || [ "$jam" -gt 23 ]; then
                    echo "[!] Jam tidak valid (0-23)."
                    read -rp "Tekan [ENTER] untuk kembali ke menu..."
                    continue
                fi
                if ! [[ "$menit" =~ ^[0-9]+$ ]] || [ "$menit" -lt 0 ] || [ "$menit" -gt 59 ]; then
                    echo "[!] Menit tidak valid (0-59)."
                    read -rp "Tekan [ENTER] untuk kembali ke menu..."
                    continue
                fi

                # Format 2 digit
                jam_fmt=$(printf "%02d" "$jam")
                menit_fmt=$(printf "%02d" "$menit")

                # Hapus cron lama (overwrite/update)
                crontab -l 2>/dev/null | grep -v -- "--check-tagihan" | crontab -

                # Tambahkan cron baru
                (crontab -l 2>/dev/null; echo "$menit_fmt $jam_fmt * * * $SCRIPT_PATH --check-tagihan") | crontab -
                echo ""
                echo "[√] Cron job pengingat berhasil didaftarkan pukul $(printf "%02d" "$jam"):$(printf "%02d" "$menit")."
                echo ""
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            3)
                hasil=$(crontab -l 2>/dev/null | grep -- "--check-tagihan")
                if [ -z "$hasil" ]; then
                    echo "[!] Tidak ada cron job pengingat yang aktif."
                else
                    crontab -l 2>/dev/null | grep -v -- "--check-tagihan" | crontab -
                    echo ""
                    echo "[√] Cron job pengingat tagihan berhasil dihapus."
                    echo ""
                fi
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
            4)
                return
                ;;
            *)
                echo "[!] Pilihan tidak valid."
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
        esac
    done
}

# ============================================================
#   MAIN LOOP
# ============================================================
while true; do
    show_header
    read -rp "Enter option [1-7]: " pilihan

    case "$pilihan" in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampilkan_penghuni ;;
        4) update_status ;;
        5) cetak_laporan ;;
        6) kelola_cron ;;
        7)
            echo ""
            echo "  Terima kasih telah menggunakan Sistem Manajemen Kost Slebew!"
            echo "  Sampai jumpa, Mas Amba! 👋"
            echo ""
            exit 0
            ;;
        *)
            echo "[!] Opsi tidak valid. Pilih antara 1-7."
            read -rp "Tekan [ENTER] untuk kembali ke menu..."
            ;;
    esac
done
```

Memberitahu sistem bahwa script ini harus dijalankan menggunakan Bash.
```
#!/bin/bash
```

Menentukan lokasi script dan folder utama
```
SCRIPT_PATH="$(realpath "$0")"
BASE_DIR="$(dirname "$SCRIPT_PATH")"
```
Program akan mencari tahu lokasi file script ini sendiri, lalu mengambil folder tempat script berada supaya semua file data disimpan di tempat yang benar.

Menentukan folder penyimpanan
```
DATA_DIR="$BASE_DIR/data"
LOG_DIR="$BASE_DIR/log"
REKAP_DIR="$BASE_DIR/rekap"
SAMPAH_DIR="$BASE_DIR/sampah"
```
Pembagian folder berdasarkan fungsi. 

Menentukan file-file yang dipakai
```
DB_FILE="$DATA_DIR/penghuni.csv"
LOG_FILE="$LOG_DIR/tagihan.log"
REKAP_FILE="$REKAP_DIR/laporan_bulanan.txt"
HISTORY_FILE="$SAMPAH_DIR/history_hapus.csv"
```

Membuat folder dan file kalau belum ada
```
mkdir -p "$DATA_DIR" "$LOG_DIR" "$REKAP_DIR" "$SAMPAH_DIR"
[ ! -f "$DB_FILE" ]      && touch "$DB_FILE"
[ ! -f "$LOG_FILE" ]     && touch "$LOG_FILE"
[ ! -f "$REKAP_FILE" ]   && touch "$REKAP_FILE"
[ ! -f "$HISTORY_FILE" ] && touch "$HISTORY_FILE"
```
Memastikan semua folder dan file yang dibutuhkan sudah ada. Kalau folder dan file belum ada, maka akan langsung dibuat.

Mode khusus buat cek tagihan otomatis
```
if [ "$1" == "--check-tagihan" ]; then
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    found=0
    while IFS=',' read -r nama kamar harga tgl_masuk status; do
        STATUS_LOWER=$(echo "$status" | tr '[:upper:]' '[:lower:]')
        if [ "$STATUS_LOWER" == "menunggak" ]; then
            echo "[$TIMESTAMP] TAGIHAN: $nama (Kamar $kamar) - Menunggak Rp$harga" >> "$LOG_FILE"
            found=1
        fi
    done < "$DB_FILE"
    if [ "$found" -eq 0 ]; then
        echo "[$TIMESTAMP] TAGIHAN: Tidak ada penghuni menunggak." >> "$LOG_FILE"
    fi
    exit 0
fi
```
Bagian ini dipakai kalau script dijalankan dengan argumen `--check-tagihan`, biasanya oleh cron.
Cara kerjanya:
- Baca file data penghuni satu per satu.
- Cek siapa yang statusnya `menunggak`.
- Tulis ke file log.

Fungsi untuk menampilkan menu utama
```
show_header() {
    clear
    echo ""
    cat << 'EOF'
 ██╗  ██╗ ██████╗ ███████╗████████╗    ███████╗██╗     ███████╗██████╗ ███████╗██╗    ██╗
 ██║ ██╔╝██╔═══██╗██╔════╝╚══██╔══╝    ██╔════╝██║     ██╔════╝██╔══██╗██╔════╝██║    ██║
 █████╔╝ ██║   ██║███████╗   ██║       ███████╗██║     █████╗  ██████╔╝█████╗  ██║ █╗ ██║
 ██╔═██╗ ██║   ██║╚════██║   ██║       ╚════██║██║     ██╔══╝  ██╔══██╗██╔══╝  ██║███╗██║
 ██║  ██╗╚██████╔╝███████║   ██║       ███████║███████╗███████╗██████╔╝███████╗╚███╔███╔╝
 ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝       ╚══════╝╚══════╝╚══════╝╚═════╝ ╚══════╝ ╚══╝╚══╝
EOF
    echo ""
    echo "============================================================"
    echo "            SISTEM MANAJEMEN KOST SLEBEW"
    echo "============================================================"
    echo " ID | OPTION"
    echo "------------------------------------------------------------"
    echo "  1 | Tambah Penghuni Baru"
    echo "  2 | Hapus Penghuni"
    echo "  3 | Tampilkan Daftar Penghuni"
    echo "  4 | Update Status Penghuni"
    echo "  5 | Cetak Laporan Keuangan"
    echo "  6 | Kelola Cron (Pengingat Tagihan)"
    echo "  7 | Exit Program"
    echo "============================================================"
}
```
`clear` digunakan untuk membersihkan layar terminal.

#### Fungsi Tambah Penghuni

Input Nama
```
tambah_penghuni() {
    echo "============================================"
    echo "             TAMBAH PENGHUNI"
    echo "============================================"

    # Input Nama
    read -rp "Masukkan Nama: " nama
    if [ -z "$nama" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    ...
}
```
Menampilkan judul menu lalu minta user isi nama penghuni. Kalau nama kosong, proses langsung dihentikan supaya data yang masuk nggak asal-asalan.

Input Kamar
```
    # Input Kamar
    read -rp "Masukkan Kamar: " kamar
    if ! [[ "$kamar" =~ ^[0-9]+$ ]]; then
        echo "[!] Nomor kamar harus berupa angka."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Cek kamar unik
    if grep -q "^[^,]*,$kamar," "$DB_FILE" 2>/dev/null; then
        echo "[!] Kamar $kamar sudah ditempati. Pilih nomor kamar lain."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
```
Program minta nomor kamar, lalu dicek apakah isinya benar-benar angka. Setelah itu dicek juga apakah kamar tersebut sudah dipakai penghuni lain, jadi satu kamar nggak bisa diisi dua orang di data.

Input Harga
```
    # Input Harga Sewa
    read -rp "Masukkan Harga Sewa: " harga
    if ! [[ "$harga" =~ ^[0-9]+$ ]] || [ "$harga" -le 0 ]; then
        echo "[!] Harga sewa harus berupa angka positif."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
```
Memastikan harga sewa harus berupa angka dan nilainya lebih dari nol. Jadi input kayak huruf, kosong, atau angka minus akan langsung ditolak.

Input Tanggal Masuk
```
    # Input Tanggal Masuk
    read -rp "Masukkan Tanggal Masuk (YYYY-MM-DD): " tgl_masuk
    # Validasi format tanggal
    if ! [[ "$tgl_masuk" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "[!] Format tanggal salah. Gunakan YYYY-MM-DD."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Validasi tanggal tidak melebihi hari ini
    today=$(date "+%Y-%m-%d")
    if [[ "$tgl_masuk" > "$today" ]]; then
        echo "[!] Tanggal masuk tidak boleh melebihi hari ini ($today)."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Validasi tanggal valid (misal bulan/hari masuk akal)
    if ! date -d "$tgl_masuk" &>/dev/null; then
        echo "[!] Tanggal tidak valid."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

```
Program minta tanggal masuk dengan format tahun-bulan-hari, lalu dicek tiga hal:
- Formatnya benar.
- Tanggalnya tidak boleh di masa depan.
- Tanggal itu memang valid.
Contohnya, 2025-02-30 bakal ditolak karena bukan tanggal yang masuk akal.

Input Status Penghuni 
```
    # Input Status
    read -rp "Masukkan Status Awal (Aktif/Menunggak): " status
    status_lower=$(echo "$status" | tr '[:upper:]' '[:lower:]')
    if [ "$status_lower" != "aktif" ] && [ "$status_lower" != "menunggak" ]; then
        echo "[!] Status harus 'Aktif' atau 'Menunggak'."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi
    # Normalisasi kapitalisasi
    if [ "$status_lower" == "aktif" ]; then
        status="Aktif"
    else
        status="Menunggak"
    fi
```
Memastikan status awal penghuni cuma boleh dua pilihan, yaitu `Aktif` atau `Menunggak`. Kalau user nulis dengan huruf kecil atau campur-campur, program tetap akan merapikan hasil akhirnya supaya format data tetap konsisten.

Simpan input data ke file `penghuni.csv`
```
    echo "$nama,$kamar,$harga,$tgl_masuk,$status" >> "$DB_FILE"
    echo ""
    echo "[√] Penghuni \"$nama\" berhasil ditambahkan ke Kamar $kamar dengan status $status."
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
```

#### Fungsi Hapus Penghuni
Cari data terlebih dahulu
```
hapus_penghuni() {
    echo "============================================"
    echo "             HAPUS PENGHUNI"
    echo "============================================"

    read -rp "Masukkan nama penghuni yang akan dihapus: " nama_hapus

    if [ -z "$nama_hapus" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Cek apakah penghuni ada (case-insensitive)
    baris=$(grep -i "^$nama_hapus," "$DB_FILE" | head -n1)
    if [ -z "$baris" ]; then
        echo "[!] Penghuni \"$nama_hapus\" tidak ditemukan."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    ...
}
```
Fungsi ini digunakan untuk menghapus penghuni berdasarkan nama Program akan cari nama itu di database tanpa peduli huruf besar atau kecil, lalu kalau tidak ketemu maka proses dibatalkan.

Arsipkan data sebelum dihapus
```
    tgl_hapus=$(date "+%Y-%m-%d")
    echo "$baris,$tgl_hapus" >> "$HISTORY_FILE"
```
Sebelum data dihapus dari database utama, data lama disimpan dulu ke file riwayat hapus.

Hapus dari database utama
```
tmp_file=$(mktemp)
    nama_hapus_lower=$(echo "$nama_hapus" | tr '[:upper:]' '[:lower:]')
    deleted=0
    while IFS= read -r line; do
        nama_baris=$(echo "$line" | cut -d',' -f1 | tr '[:upper:]' '[:lower:]')
        if [ "$nama_baris" == "$nama_hapus_lower" ] && [ "$deleted" -eq 0 ]; then
            deleted=1
        else
            echo "$line" >> "$tmp_file"
        fi
    done < "$DB_FILE"
    mv "$tmp_file" "$DB_FILE"

    echo ""
    echo "[√] Data penghuni \"$nama_hapus\" berhasil diarsipkan ke sampah/history_hapus.csv dan dihapus dari sistem."
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
```
Cara hapusnya bukan langsung edit file asli, tapi bikin file sementara dulu. Setiap baris dibaca satu-satu, kalau itu nama yang mau dihapus, barisnya dilewati. Kalau bukan, baris disalin ke file sementara. Setelah selesai, file sementara menggantikan file asli, jadi prosesnya lebih aman.

#### Fungsi Tampilkan Penghuni
Cek data kosong atau tidak 
```
tampilkan_penghuni() {
    echo ""
    if [ ! -s "$DB_FILE" ]; then
        echo "============================================================"
        echo "              DAFTAR PENGHUNI KOST SLEBEW"
        echo "============================================================"
        echo "  (Belum ada penghuni terdaftar)"
        echo "============================================================"
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    ...
}
```
Program mengecek dulu apakah file data penghuni kosong. Kalau kosong, user langsung diberi tahu bahwa belum ada penghuni terdaftar.

Menampilkan tabel penghuni dengan AWK
```
awk -F',' '
    BEGIN {
        sep  = "============================================================"
        dash = "------------------------------------------------------------"
        printf "%s\n", sep
        printf "%*s\n", 45, "DAFTAR PENGHUNI KOST SLEBEW"
        printf "%s\n", sep
        printf " %-4s| %-15s| %-7s| %-15s| %s\n", "No", "Nama", "Kamar", "Harga Sewa", "Status"
        printf "%s\n", dash
        total=0; aktif=0; menunggak=0
    }
    {
        total++
        harga_fmt = sprintf("Rp%'"'"'d", $3)
        # Format harga dengan titik ribuan menggunakan sub
        n = $3
        formatted = ""
        while (length(n) > 3) {
            formatted = "." substr(n, length(n)-2) formatted
            n = substr(n, 1, length(n)-3)
        }
        formatted = n formatted
        harga_fmt = "Rp" formatted

        status_val = $5
        printf " %-4d| %-15s| %-7s| %-15s| %s\n", total, $1, $2, harga_fmt, status_val
        printf "%s\n", dash

        low = tolower(status_val)
        if (low == "aktif")      aktif++
        else if (low == "menunggak") menunggak++
    }
    END {
        printf " Total: %d penghuni | Aktif: %d | Menunggak: %d\n", total, aktif, menunggak
        printf "%s\n", sep
    }
    ' "$DB_FILE"

    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
```
Data penghuni ditampilkan satu per satu ke tabel. Program juga menghitung berapa penghuni yang statusnya aktif dan berapa yang menunggak.
Program memecah angka per tiga digit dari belakang lalu menambahkan titik sebagai pemisah ribuan.

#### Fungsi Update Status
Cari penghuni
```
update_status() {
    echo "============================================================"
    echo "                    UPDATE STATUS"
    echo "============================================================"

    read -rp "Masukkan Nama Penghuni: " nama_update

    if [ -z "$nama_update" ]; then
        echo "[!] Nama tidak boleh kosong."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Cek apakah penghuni ada
    nama_update_lower=$(echo "$nama_update" | tr '[:upper:]' '[:lower:]')
    baris=$(awk -F',' -v n="$nama_update_lower" 'tolower($1)==n {print; exit}' "$DB_FILE")
    if [ -z "$baris" ]; then
        echo "[!] Penghuni \"$nama_update\" tidak ditemukan."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    ...
}
```
Bagian ini dipakai untuk mencari penghuni yang statusnya mau diubah. Kalau nama kosong atau tidak ditemukan di database, proses langsung berhenti.

Input status baru 
```
    read -rp "Masukkan Status Baru (Aktif/Menunggak): " status_baru
    status_baru_lower=$(echo "$status_baru" | tr '[:upper:]' '[:lower:]')
    if [ "$status_baru_lower" != "aktif" ] && [ "$status_baru_lower" != "menunggak" ]; then
        echo "[!] Status harus 'Aktif' atau 'Menunggak'."
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    # Normalisasi
    if [ "$status_baru_lower" == "aktif" ]; then
        status_norm="Aktif"
    else
        status_norm="Menunggak"
    fi
```
User memasukkan status baru, lalu dicek apakah statusnya sesuai dengan dua pilihan yang diperbolehkan. Tujuannya supaya data status tetap seragam dan nggak muncul macam-macam tulisan yang bikin database berantakan. Kalau user nulis dengan huruf kecil atau campur-campur, program tetap akan merapikan hasil akhirnya supaya format data tetap konsisten.

Simpan perubahan status 
```
    # Update di file
    tmp_file=$(mktemp)
    updated=0
    while IFS=',' read -r n k h t s; do
        n_lower=$(echo "$n" | tr '[:upper:]' '[:lower:]')
        if [ "$n_lower" == "$nama_update_lower" ] && [ "$updated" -eq 0 ]; then
            echo "$n,$k,$h,$t,$status_norm" >> "$tmp_file"
            updated=1
        else
            echo "$n,$k,$h,$t,$s" >> "$tmp_file"
        fi
    done < "$DB_FILE"
    mv "$tmp_file" "$DB_FILE"

    echo ""
    echo "[√] Status $nama_update berhasil diubah menjadi: $status_norm"
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
```
Cara update status mirip seperti hapus data, yaitu program bikin file sementara dulu, lalu salin semua isi database. Bedanya, kalau nama yang dicari ketemu, statusnya diganti dengan yang baru, sisanya tetap disalin seperti semula.

#### Fungsi Cetak Laporan Keuangan
Cek data terlebih dahulu
```
cetak_laporan() {
    echo ""

    if [ ! -s "$DB_FILE" ]; then
        echo "============================================================"
        echo "             LAPORAN KEUANGAN KOST SLEBEW"
        echo "============================================================"
        echo "  Belum ada data penghuni."
        echo "============================================================"
        read -rp "Tekan [ENTER] untuk kembali ke menu..."
        return
    fi

    ...
}
```
Program mengecek dulu apakah ada data penghuni. Kalau belum ada, laporan tidak bisa dibuat.

Menghitung isi laporan dengan AWK
```
    laporan=$(awk -F',' '
    BEGIN { total_aktif=0; total_menunggak=0; kamar=0 }
    {
        kamar++
        low = tolower($5)
        if (low == "aktif")       total_aktif += $3
        else if (low == "menunggak") total_menunggak += $3
    }
    function fmt(n,    r,f) {
        f=""
        while (length(n) > 3) {
            f = "." substr(n, length(n)-2) f
            n = substr(n, 1, length(n)-3)
        }
        return n f
    }
    END {
        sep = "============================================================"
        dash = "------------------------------------------------------------"
        print sep
        printf "%*s\n", 45, "LAPORAN KEUANGAN KOST SLEBEW"
        print sep
        printf " %-30s: Rp%s\n", "Total pemasukan (Aktif)", fmt(total_aktif)
        printf " %-30s: Rp%s\n", "Total tunggakan",         fmt(total_menunggak)
        printf " %-30s: %d\n",   "Jumlah kamar terisi",     kamar
        print dash
    }
    ' "$DB_FILE")

    echo "$laporan"
```
Bagian ini menghitung isi laporan berdasarkan semua data penghuni. 
3 hal yang dihitung:
- Total pemasukan dari penghuni aktif.
- Total tunggakan dari penghuni yang belum bayar.
- Jumlah kamar yang terisi.

Program ini mengubah angka biasa jadi format ribuan. Jadi angka pemasukan dan tunggakan ditampilkan seperti uang rupiah, bukan angka polos panjang.

Menampilkan daftar penghuni menunggak
```
    # Daftar penghuni menunggak
    echo " Daftar penghuni menunggak:"
    menunggak_list=$(awk -F',' 'tolower($5)=="menunggak" {print "   - " $1 " (Kamar " $2 ") Rp" $3}' "$DB_FILE")
    if [ -z "$menunggak_list" ]; then
        echo "   Tidak ada tunggakan."
    else
        echo "$menunggak_list"
    fi
    echo "============================================================"
```
Setelah total laporan dihitung, program juga menampilkan daftar siapa saja yang masih menunggak. Kalau tidak ada yang menunggak, program menampilkan pesan bahwa tidak ada tunggakan.

Menyimpan laporan ke file
```
    # Simpan laporan ke file
    {
        echo "$laporan"
        echo " Daftar penghuni menunggak:"
        if [ -z "$menunggak_list" ]; then
            echo "   Tidak ada tunggakan."
        else
            echo "$menunggak_list"
        fi
        echo "============================================================"
        echo " Dicetak pada: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "============================================================"
    } > "$REKAP_FILE"

    echo ""
    echo "[√] Laporan berhasil disimpan ke rekap/laporan_bulanan.txt"
    echo ""
    read -rp "Tekan [ENTER] untuk kembali ke menu..."
```
Bagian ini menyimpan seluruh isi laporan ke file `laporan_bulanan.txt`.

#### Fungsi Kelola Cron
Menu pengingat otomatis
```
kelola_cron() {
    while true; do
        echo ""
        echo "===================================="
        echo "         MENU KELOLA CRON"
        echo "===================================="
        echo " 1. Lihat Cron Job Aktif"
        echo " 2. Daftarkan Cron Job Pengingat"
        echo " 3. Hapus Cron Job Pengingat"
        echo " 4. Kembali"
        echo "===================================="
        read -rp "Pilih [1-4]: " pilih_cron

        ...
}
```
Lihat Cron Aktif
```
                hasil=$(crontab -l 2>/dev/null | grep -- "--check-tagihan")
                if [ -z "$hasil" ]; then
                    echo "  (Tidak ada cron job pengingat aktif)"
                else
                    echo "$hasil"
                fi
```
Bagian ini mengecek apakah ada jadwal otomatis yang sudah terdaftar untuk pengecekan tagihan. Kalau ada, jadwalnya ditampilkan. Kalau tidak ada, user diberi tahu bahwa belum ada pengingat aktif.

Tambah Cron Baru
```
                read -rp "Masukkan Jam (0-23): " jam
                read -rp "Masukkan Menit (0-59): " menit

                if ! [[ "$jam" =~ ^[0-9]+$ ]] || [ "$jam" -lt 0 ] || [ "$jam" -gt 23 ]; then
                    echo "[!] Jam tidak valid (0-23)."
                    read -rp "Tekan [ENTER] untuk kembali ke menu..."
                    continue
                fi
                if ! [[ "$menit" =~ ^[0-9]+$ ]] || [ "$menit" -lt 0 ] || [ "$menit" -gt 59 ]; then
                    echo "[!] Menit tidak valid (0-59)."
                    read -rp "Tekan [ENTER] untuk kembali ke menu..."
                    continue
                fi

                # Format 2 digit
                jam_fmt=$(printf "%02d" "$jam")
                menit_fmt=$(printf "%02d" "$menit")

                # Hapus cron lama (overwrite/update)
                crontab -l 2>/dev/null | grep -v -- "--check-tagihan" | crontab -

                # Tambahkan cron baru
                (crontab -l 2>/dev/null; echo "$menit_fmt $jam_fmt * * * $SCRIPT_PATH --check-tagihan") | crontab -
                echo ""
                echo "[√] Cron job pengingat berhasil didaftarkan pukul $(printf "%02d" "$jam"):$(printf "%02d" "$menit")."
                echo ""
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
```
Program ini akan otomatis menghapus cron lama terlebih dahulu agar tidak terjadi duplikasi jadwal, lalu menggantinya dengan jadwal yang baru.


Hapus Cron
```
                hasil=$(crontab -l 2>/dev/null | grep -- "--check-tagihan")
                if [ -z "$hasil" ]; then
                    echo "[!] Tidak ada cron job pengingat yang aktif."
                else
                    crontab -l 2>/dev/null | grep -v -- "--check-tagihan" | crontab -
                    echo ""
                    echo "[√] Cron job pengingat tagihan berhasil dihapus."
                    echo ""
                fi
                read -rp "Tekan [ENTER] untuk kembali ke menu..."
                ;;
```
Bagian ini dipakai kalau user mau menghapus jadwal pengingat yang sebelumnya sudah dibuat. Program akan cari cron yang berhubungan dengan --check-tagihan, lalu menghapusnya dari daftar crontab.

#### Main Loop 
```
while true; do
    show_header
    read -rp "Enter option [1-7]: " pilihan

    case "$pilihan" in
        1) tambah_penghuni ;;
        2) hapus_penghuni ;;
        3) tampilkan_penghuni ;;
        4) update_status ;;
        5) cetak_laporan ;;
        6) kelola_cron ;;
        7)
            echo ""
            echo "  Terima kasih telah menggunakan Sistem Manajemen Kost Slebew!"
            echo "  Sampai jumpa, Mas Amba! 👋"
            echo ""
            exit 0
            ;;
        *)
            echo "[!] Opsi tidak valid. Pilih antara 1-7."
            read -rp "Tekan [ENTER] untuk kembali ke menu..."
            ;;
    esac
done
```
Ini adalah bagian inti program yang terus berulang menampilkan menu utama. Begitu user pilih angka, program langsung menjalankan fungsi yang sesuai dengan menu tersebut.

Kalau user pilih 7, program berhenti dan menampilkan pesan penutup. Kalau user salah input, program kasih peringatan lalu balik lagi ke menu utama.




### Output 

Menu Utama 

![Menu Utama](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/menu-utama.png?raw=true)

Tambah Penghuni Baru

![Tambah Penghuni](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/tambah-penghuni.png?raw=true)

Hapus Penghuni 

![Hapus Penghuni](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/hapus-penghuni.png?raw=true)

Tampilkan Daftar Penghuni

![Daftar Penghuni](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/daftar-penghuni.png?raw=true)

Update Status Penghuni

![Status Penghuni](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/update-status.png?raw=true)

Cetak Laporan Keuangan

![Laporan Keuangan](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/laporan-keuangan.png?raw=true)

Kelola Cron (Pengingat Tagihan)
- Menu KelolaCron

![Menu Cron](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/menu-cron.png?raw=true)

- Lihat Cron Job Aktif

![CronJob Aktif](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/cronJob-aktif.png?raw=true)

- Daftarkan Cron Job Pengingat

![Daftarkan CronJob](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/daftar-cronJob.png?raw=true)

- Hapus Cron Job Pengingat

![Hapus CronJob](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/hapus-cronJob.png?raw=true)

Exit Program

![Exit Program](https://github.com/nadyaaee/SISOP-1-2026-IT-013/blob/main/Assets/exit.png?raw=true)
