#!/bin/bash

cd $1
mv stress_test_report.html stress_test_report1.html
cp ~/camera-test/templates/stress_test_report.html .
cd ~/camera-test/tools; git pull; source libs.sh
./genStressReport.py -d $1 -p umi -R
