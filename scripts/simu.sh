#!/bin/bash


xrun -licqueue -timescale "1ns/1ns" -licqueue -access +rw -f rtl/rtl.f -f tb/tb.f -top tb -gui
