#!/bin/bash


vivado -mode tcl -source scripts/syn.tcl

echo ""
echo ""
echo ""
echo "------------------------------------------"
echo "To open the synthesized project in GUI mode, execute the following:"
echo ""
echo "vivado -mode gui backend/results/syn/enduro/enduro.xpr"
echo ""
echo "------------------------------------------"
