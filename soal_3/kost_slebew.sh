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
