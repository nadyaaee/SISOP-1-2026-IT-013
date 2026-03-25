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
