#!/bin/bash
set -eu -o pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <apk>"
    exit 1
fi

FNAME="${1%.*}"
DISASS="$FNAME/apktool/"
DECOMP="$FNAME/decompiled/jdcli"
DECOMP_JADX="$FNAME/decompiled/jadx"
D2J="$FNAME/d2j/"
UNZIPPED="$FNAME/unzipped"

mkdir -p "$FNAME"
mkdir -p "$FNAME/unzipped"
mkdir -p "$D2J"
mkdir -p "$DECOMP"
mkdir -p "$DECOMP_JADX"

echo "Unzipping to $UNZIPPED..."
unzip -q "$1" -d "$UNZIPPED"

echo "Running apktool to $DISASS..."
apktool d -f -o "$DISASS" "$1" &> /dev/null

for f in "$UNZIPPED"/classes*.dex; do
    FBASE=$(basename $f)
    FN="${FBASE%.*}"

    echo "Running dex2jar on $f..."
    d2j-dex2jar.sh -f -e /dev/null "$f" -o "$D2J/$FN.jar" &> /dev/null
done

echo "Running jd-cli to $DECOMP..."
jd-cli -od "$DECOMP" "$D2J/*.jar" &> /dev/null

echo "Running jdax to $DECOMP_JADX..."
jadx -r -d "$DECOMP_JADX" "$1" &> /dev/null
