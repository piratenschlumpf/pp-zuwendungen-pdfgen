#!/bin/bash

./do_einzel.sh
./do_sammel.sh
./do_sach.sh

rm -f *.temp

echo "Die LaTeX Dokumente sind nun vorbereitet."
echo ""
echo "WICHTIG: LaTeX wird viel Output erzeugen - einfach ignorieren solange"
echo "         keine Eingabe noetig ist, sonst abbrechen und um Hilfe rufen."
echo ""
echo "Rufe das script ./schritt3.sh zur PDF Generierung auf."
