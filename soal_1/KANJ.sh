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
