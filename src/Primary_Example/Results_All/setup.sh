sudo rm naive_results.txt rates_results.txt normal_results.txt
sudo touch naive_results.txt rates_results.txt normal_results.txt
sudo rm log*
for i in {1..9}; do sudo touch log_$i.txt; done
for i in {1..9}; do sudo touch log_rates_$i.txt; done
for i in {1..9}; do sudo touch log_normal_$i.txt; done
sudo chown elijah *
sudo chgrp elijah *
