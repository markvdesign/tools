#!/bin/bash
# Lazy recon script

# Run this script in the root folder you want the recon to be put in.

url=$1

if [ ! -d "$url" ];then
  mkdir $url
fi

if [ ! -d "$url/recon" ];then
  mkdir $url/recon
fi

if [ ! -d "$url/recon/scans" ];then
  mkdir $url/recon/scans
fi

if [ ! -f "$url/recon/scans/nmap.txt" ];then
  touch $url/recon/scans/namp.txt
fi

if [ ! -d "$url/recon/ffuf" ];then
  mkdir $url/recon/ffuf
fi

if [ ! -f "$url/recon/ffuf/directorybrute.txt" ];then
  touch $url/recon/ffuf/directorybrute.txt
fi

if [ ! -d "$url/recon/assetfinder" ];then
  mkdir $url/recon/assetfinder
fi

if [ ! -d "$url/recon/httprobe" ];then
  mkdir $url/recon/httprobe
fi

if [ ! -d "$url/recon/gowitness" ];then
  mkdir $url/recon/gowitness
fi

if [ ! -d "$url/recon/wayback" ];then
  mkdir $url/recon/wayback
fi

if [ ! -d "$url/recon/wayback/params" ];then
  mkdir $url/recon/wayback/params
fi

if [ ! -d "$url/recon/wayback/extensions" ];then
  mkdir $url/recon/wayback/extensions
fi

echo "[+] Harvesting subdomains with assetfinder.... Thanks Tomnomnom"
assetfinder $url >> $url/recon/nonfiltereddomains.txt
cat $url/recon/nonfiltereddomains.txt | grep $url | sort -u >> $url/recon/assetfinder/domains.txt
rm $url/recon/nonfiltereddomains.txt

# TODO: Removing this just for the moment for testing
# echo "[+] Harvesting subdomains with Amass..."
# amass enum -d $url >> $url/recon/f.txt
# sort -u $url/recon/f.txt >> $url/recon/domains
# rm $url/recon/f.txt

echo "[+] Checking for live hosts... Thanks again Tom"
cat $url/recon/assetfinder/domains.txt | httprobe --prefer-https >> $url/recon/httprobe/a.txt
sort -u $url/recon/httprobe/a.txt > $url/recon/httprobe/hosts.txt
cat $url/recon/httprobe/hosts.txt | awk -F '/' '{print $3}' >> $url/recon/scans/nmapscanhosts.txt
rm $url/recon/httprobe/a.txt

echo "[+] Scanning for open ports..."
nmap -iL $url/recon/scans/nmapscanhosts.txt -T4 -oA $url/recon/scans/nmap.txt

echo "[+] Creating screen shots..."
# Example  gowitness file --source=urls.txt --threads=4 --resolution="1200,750" --log-format=json --log-level=warn --timeout=60 --destination="Desktop/Screenshots/"
gowitness file --source=$url/recon/httprobe/hosts.txt --threads=10 --timeout=10 --destination=$ur/recon/gowitness/

echo "[+] Directory Brute Forcing with FFUF..."
 ffuf -w ~/tools/SecLists/Discovery/Web-Content/common.txt -u https://$url/FUZZ -H "X-WeAreHackerOne: Antl3rz" -o $url/recon/ffuf/directorybrute.txt

echo "[+] Scraping wayback data..."
cat $url/recon/assetfinder/domains.txt | waybackurls >> $url/recon/wayback/wayback_output.txt
sort -u $url/recon/wayback/wayback_output.txt

# echo "[+] Pulling and compiling all possible params found in wayback data..."
# cat $url/recon/wayback/wayback_output.txt | grep '?*=' | cut -d '=' -f 1 | sort -u >> $url/recon/wayback/params/wayback_params.txt
# for line in $(cat $url/recon/wayback/params/wayback_params.txt);do echo $line'=';done

# echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."
# for line in $(cat $url/recon/wayback/wayback_output.txt);do
# 	ext="${line##*.}"
# 	if [[ "$ext" == "js" ]]; then
# 		echo $line >> $url/recon/wayback/extensions/js1.txt
# 		sort -u $url/recon/wayback/extensions/js1.txt >> $url/recon/wayback/extensions/js.txt
# 	fi
# 	if [[ "$ext" == "html" ]];then
# 		echo $line >> $url/recon/wayback/extensions/jsp1.txt
# 		sort -u $url/recon/wayback/extensions/jsp1.txt >> $url/recon/wayback/extensions/jsp.txt
# 	fi
# 	if [[ "$ext" == "json" ]];then
# 		echo $line >> $url/recon/wayback/extensions/json1.txt
# 		sort -u $url/recon/wayback/extensions/json1.txt >> $url/recon/wayback/extensions/json.txt
# 	fi
# 	if [[ "$ext" == "php" ]];then
# 		echo $line >> $url/recon/wayback/extensions/php1.txt
# 		sort -u $url/recon/wayback/extensions/php1.txt >> $url/recon/wayback/extensions/php.txt
# 	fi
# 	if [[ "$ext" == "aspx" ]];then
# 		echo $line >> $url/recon/wayback/extensions/aspx1.txt
# 		sort -u $url/recon/wayback/extensions/aspx1.txt >> $url/recon/wayback/extensions/aspx.txt
# 	fi
# done

# rm $url/recon/wayback/extensions/js1.txt
# rm $url/recon/wayback/extensions/jsp1.txt
# rm $url/recon/wayback/extensions/json1.txt
# rm $url/recon/wayback/extensions/php1.txt
# rm $url/recon/wayback/extensions/aspx1.txt

echo "[+]...... We Are Done!!!!! ......."
