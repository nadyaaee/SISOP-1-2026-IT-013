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
