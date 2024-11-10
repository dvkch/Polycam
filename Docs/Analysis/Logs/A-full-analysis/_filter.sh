#!/usr/bin/env bash

rm ./**/output_*_filtered.txt

FILES="./**/output_*.txt"
for f in $FILES; do
    filename=$(basename -- "$f")
    extension="${filename##*.}"
    filename="${f%.*}"

    awk '(!/DEBUG/ && !/SrcMan/ && !/PcSerial/ && !/PcThreads/ && !/PcVideoOut/ && !/PcConfig/ && !/PcVideoIn/ && !/QRead/ && !/read response/) || /GetPositionRsp/ { $1=""; $2=""; print $0 }' "$f" > "${filename}_filtered.$extension"
done
