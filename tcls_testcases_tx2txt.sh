#!/bin/sh
# some testcases for the shell script "tcls_tx2txt.sh" 
#
# Copyright (c) 2015, 2016 Volker Nowarra 
# Complete rewrite in Nov/Dec 2015 
# 
# Permission to use, copy, modify, and distribute this software for any 
# purpose with or without fee is hereby granted, provided that the above 
# copyright notice and this permission notice appear in all copies. 
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES 
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY 
# SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER 
# RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, 
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE 
# USE OR PERFORMANCE OF THIS SOFTWARE. 
# 

typeset -i LOG=0
typeset -i no_cleanup=0
logfile=$0.log

chksum_verify() {
if [ "$1" == "$2" ] ; then
  echo "ok"
else
  echo $1 | tee -a $logfile
  echo "*************** checksum  mismatch, ref is: ********************" | tee -a $logfile
  echo $2 | tee -a $logfile
  echo " " | tee -a $logfile
fi
}
 
to_logfile() {
  # echo $chksum_ref >> $logfile
  cat tmpfile >> $logfile
  echo " " >> $logfile
}

chksum_prep() {
  result=$( $chksum_cmd tmpfile | cut -d " " -f 2 )
  # echo $result | cut -d " " -f 2 >> $logfile
  chksum_verify "$result" "$chksum_ref" 
  if [ $LOG -eq 1 ] ; then to_logfile ; fi
}

proc_help() {
  echo "  "
  echo "usage: $0 -h|-k|-l [1-9]"
  echo "  "
  echo "script does several testcases, mostly with checksums for verification"
  echo "  "
  echo "  -h help"
  echo "  -k keep all the temp files (don't do cleanup)"
  echo "  -l log output to file $0.log"
  echo "  "
}

cleanup() {
  for i in tmp*; do
    if [ -f "$i" ]; then rm $i ; fi
  done
  for i in *hex; do
    if [ -f "$i" ]; then rm $i ; fi
  done
  for i in priv*; do
    if [ -f "$i" ]; then rm $i ; fi
  done
  for i in pub*; do
    if [ -f "$i" ]; then rm $i ; fi
  done
}


testcase1() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 1: checksums of all necessary files             ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 1a: $chksum_cmd tcls_tx2txt.sh" | tee -a $logfile
chksum_ref="1ba1838d6be0ed3eb5e2ee7d12112b210f24731ce8b14f7e84120531d34e3b56"
cp tcls_tx2txt.sh tmpfile
chksum_prep
 
echo "=== TESTCASE 1b: $chksum_cmd trx_in_sig_script.sh" | tee -a $logfile
chksum_ref="a293d19fcf79ad62952c0ba1286dc3e36bc27ff72d56bc8205f4d6871ee64c99" 
cp tcls_in_sig_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1c: $chksum_cmd trx_out_pk_script.sh" | tee -a $logfile
chksum_ref="3910667032ac5d861dd887c3c1ba0ef8d4e759cf79050cdf4e958b4fd7c6bf0c" 
cp tcls_out_pk_script.sh tmpfile
chksum_prep

echo "=== TESTCASE 1d: $chksum_cmd tcls_base58check_enc.sh" | tee -a $logfile
chksum_ref="9edf43a7e7aad6ae511c2dd9bc311a9b63792d0b669c7e72d7d1321887213179" 
cp tcls_base58check_enc.sh tmpfile
chksum_prep
echo " " | tee -a $logfile
}

testcase2() {
# do a testcase with the included example transaction
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 2: parameters testing                           ===" | tee -a $logfile
echo "=== do several testcases with parameters set incorrectly,    ===" | tee -a $logfile
echo "=== and at the end 3 correct settings. This just serves      ===" | tee -a $logfile
echo "=== to verify, that code is executing properly               ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile

echo "=== TESTCASE 2a: wrong params, xyz unknown: ./tcls_tx2txt.sh xyz" | tee -a $logfile
./tcls_tx2txt.sh xyz > tmpfile
chksum_ref="584b2f70a2fe092553e319a0cd457e06698e7bba03ca0009802838c4793738b3" 
chksum_prep

echo "=== TESTCASE 2b: wrong params, -r witout param: ./tcls_tx2txt.sh -r" | tee -a $logfile
./tcls_tx2txt.sh -r > tmpfile
chksum_ref="6242596d0136fef2101d9566fc02dfa5ea9e63076af020742cd47038e5782945" 
chksum_prep

echo "=== TESTCASE 2c: wrong params, -t witout param: ./tcls_tx2txt.sh -t" | tee -a $logfile
./tcls_tx2txt.sh -t > tmpfile
chksum_ref="a548231d5bc61eea18f548d8b63ac4587b0384bc76405784bf9eb1b2c0437c71" 
chksum_prep

echo "=== TESTCASE 2d: wrong params, -u witout param: ./tcls_tx2txt.sh -u" | tee -a $logfile
./tcls_tx2txt.sh -u > tmpfile
chksum_ref="611685688881c2c83dee9910fbbf21e1eb7b90facf599b2e949bc1e339792a18" 
chksum_prep

echo "=== TESTCASE 2e: wrong params, param abc unknown: ./tcls_tx2txt.sh -r abc" | tee -a $logfile
./tcls_tx2txt.sh -r abc > tmpfile
chksum_ref="36b69f0e3ac344a7cc5f867dffa34ad4503789afb4837f4a9fdfa06050af1dbe"
chksum_prep

echo "=== TESTCASE 2f: wrong params, param abc unknown: ./tcls_tx2txt.sh -t abc" | tee -a $logfile
./tcls_tx2txt.sh -t abc > tmpfile
chksum_ref="a44863f60841dd5dcde406c6de79e83b7aa21ff902bfabe6e7f0f2391d2ef10c"
chksum_prep

echo "=== TESTCASE 2g: wrong params, param abc unknown: ./tcls_tx2txt.sh -u abc" | tee -a $logfile
./tcls_tx2txt.sh -u abc > tmpfile
chksum_ref="36b69f0e3ac344a7cc5f867dffa34ad4503789afb4837f4a9fdfa06050af1dbe" 
chksum_prep

echo "=== TESTCASE 2h: wrong params, -r and -u together: ..." | tee -a $logfile
./tcls_tx2txt.sh -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82 -u 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82  > tmpfile
chksum_ref="3cd1e95ea9a161ba8dee7fd957f6a283e1d95ad0f562ac8994d0bf0986219c3e" 
chksum_prep

echo "=== TESTCASE 2i: wrong params, -t and -u together: ..." | tee -a $logfile
./tcls_tx2txt.sh -t 7bec4d7ac4510c39e6845b18188f163718d279f69f832612a864dcfb167abc9c -u def > tmpfile
chksum_ref="3cd1e95ea9a161ba8dee7fd957f6a283e1d95ad0f562ac8994d0bf0986219c3e" 
chksum_prep

echo "=== TESTCASE 2j: wrong params, -f without param: ./tcls_tx2txt.sh -f " | tee -a $logfile
./tcls_tx2txt.sh -f > tmpfile
chksum_ref="35aebd5aff6c4aa9cc5b1510db7d403df0c4221eb58509f9f3576ce0c7503e1a" 
chksum_prep
 
echo "=== TESTCASE 2k: wrong params, file abc unknown: ./tcls_tx2txt.sh -f abc" | tee -a $logfile
./tcls_tx2txt.sh -f abc > tmpfile
chksum_ref="0414167aa53d245a7f3f58c990b87c419df4745095c87d02c0515cfe5ee03718"
chksum_prep
 
echo "=== TESTCASE 2l: show help: ./tcls_tx2txt.sh -h" | tee -a $logfile
./tcls_tx2txt.sh -h > tmpfile
chksum_ref="bbdf2304803a08246f53e62c78a05dde7d7acaac466faf8081bceccf4eceb0ef" 
chksum_prep

echo "=== TESTCASE 2m: show default: ./tcls_tx2txt.sh" | tee -a $logfile
./tcls_tx2txt.sh > tmpfile
chksum_ref="601f35820c9fd5bccb141d44ae14a6a7b0c12837584e592f322737502508e808" 
chksum_prep

echo "=== TESTCASE 2n: show verbose default: ./tcls_tx2txt.sh -v" | tee -a $logfile
./tcls_tx2txt.sh -v > tmpfile
chksum_ref="f9f8e8fc5e0d824a9abe177b75f6e0212f6fdcd1d0fc940085ec0f683c82557e" 
chksum_prep

echo "=== TESTCASE 2o: show very verbose default: ./tcls_tx2txt.sh -vv" | tee -a $logfile
./tcls_tx2txt.sh -vv > tmpfile
chksum_ref="5026c545c18423af444a11d611071b26c6f26ef8c491922dccbdacd21be981e9" 
chksum_prep
echo " " | tee -a $logfile
}

testcase3() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 3: a fairly simple trx, 1 input, 1 output       ===" | tee -a $logfile
echo "===  we check functionality to load data via -t parameter    ===" | tee -a $logfile
echo "===  requires network connection (https://blockchain.info)   ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6" >> $logfile

echo "=== TESTCASE 3a: ./tcls_tx2txt.sh -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="dd9f12ba7348e69ab1ebb52b480c332797ca4874e5403cd4ff3d8006d07ce4ba" 
chksum_prep

echo "=== TESTCASE 3b: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -v -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="f1d0e0c495e6d220cad3d8f9d7d21651b07e2ee1a86eff90b802fd129ca3fada" 
chksum_prep

echo "=== TESTCASE 3c: ./tcls_tx2txt.sh -v -t 30375f40ad... " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 30375f40adcf361f5b2a5074b615ca75e5696909e8bc2f8e553c69631826fcf6 > tmpfile
chksum_ref="59a22b241cd1be823011fb6f7db7f02ce88e2ff5e7cc722effc2eaf007cff67b" 
chksum_prep
echo " " | tee -a $logfile
}


testcase4() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 4: a fairly simple trx, 1 input, 2 outputs      ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/91c91f31b7586b807d0ddc7a1670d10cc34bdef326affc945d4987704c7eed62" >> $logfile

echo "=== TESTCASE 4a: ./tcls_tx2txt.sh -r 010000000117f83..." | tee -a $logfile
./tcls_tx2txt.sh -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="fa58bd83248575ca9cfc9ce1c2fab47996bfbb27ac946510f1dd6b41bc35d293"
chksum_prep

echo "=== TESTCASE 4b: same as 4a, reading from file (param -f)" | tee -a $logfile
echo "010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600" > tmpfile_4b
./tcls_tx2txt.sh -f tmpfile_4b > tmpfile
chksum_ref="fa58bd83248575ca9cfc9ce1c2fab47996bfbb27ac946510f1dd6b41bc35d293"
chksum_prep

echo "=== TESTCASE 4c: same as 4a, verbose (param -v)" | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="16d2e7e46977f3a69a233864a88343a5e03cd10f8a5a37cc0f8d97bc7696be4b"
chksum_prep

echo "=== TESTCASE 4d: same as 4a, verbose (param -vv)" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000117f83daeec34cca28b90390b691d278f658b85b20fae29983acda10273cc7d32010000006b483045022100b95be9ab9148d85d47d51d069923272ad5131505b40b8e27211475305c546c6e02202ae8f2386e0d7afa6ab0acfafa78b0e23e669972d6e656b345b69c6d268aecbd0121020b2b582ca9333957cf8457a4a1b46e5337471cc98582fdf37c58a201dba50dd2feffffff0210201600000000001976a91407ddfbe06b04f3867cae654448174ea2f9a173ea88acda924700000000001976a9143940dcd0bfb7ad9bff322405954949c450742cd588accd3d0600 > tmpfile
chksum_ref="3621810a8759ba0583f0feaa8476581ba8ad20014888869617e955b6a465a8be"
chksum_prep
echo " " | tee -a $logfile
}

testcase5() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 5: a fairly simple trx, 3 inputs, 1 P2SH output ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/4f292aeff2ad2da37b5d5719bf34846938cf96ea7e75c8715bc3edac01b39589" >> $logfile

echo "=== TESTCASE 5a: ./tcls_tx2txt.sh -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="b6139e7da425d70ed8b14b8e682520c91c6e34aaee0ce5fc7f48f166cfca0c90"
chksum_prep

echo "=== TESTCASE 5b: ./tcls_tx2txt.sh -v -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="b0e2560aa175f96176cfd441a86871abdcad58c4b537ab9e818ff6f929703763"
chksum_prep

echo "=== TESTCASE 5c: ./tcls_tx2txt.sh -vv -r 010000000301de569ae..." | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000301de569ae0b3d49dff80f79f7953f87f17f61ca1f6d523e815a58e2b8863d098000000006a47304402203930d1ba339c9692367ae37836b1f21c1431ecb4522e7ce0caa356b9813722dc02204086f7ad81d5d656ab1b6d0fd4709b5759c22c44a0aeb1969c1cdb7c463912fa012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff97e60e0bec78cf5114238678f0b5eab617ca770752796b4c795c9d3ada772da5000000006a473044022046412e2b3f820f846a5e8f1cc92529cb694cf0d09d35cf0b5128cc7b9bf32a0802207f736b322727babd41793aeedfad41cc0541c0a1693e88b2a620bcd664da8551012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffffce559734242e6a6e0608caa07ee1178d5b9e53e0814d61f002930d78422e8402000000006b4830450221009fab428713fa76057e1bd87381614abc270089ddb23c345b0a56114db0fb8fd30220187a80bedfbb6b23bcf4eaf25017be2efdd64f02a732be9f4846142ad3408798012103f6bfdba31cf7e059e19a2b0e60670864d24d7dfe0d7f11045756991271dda237ffffffff011005d0010000000017a91469545b58fd41a120da3f606be313e061ea818edf8700000000 > tmpfile
chksum_ref="0b0b8fe5f78f5d92529b5a10cc4ef0d9681087ca8fd3a8d6955d772f84f5896a"
chksum_prep
echo " " | tee -a $logfile
}

testcase6() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 6: tx with several inputs and outputs           ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/7264f8ba4a85a4780c549bf04a98e8de4c9cb1120cb1dfe8ab85ff6832eff864" >> $logfile

echo "=== TESTCASE 6a: 1 input, 4 outputs - non verbose..." | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="d73f48f73285db8e1d11331d7e3e0a6baada5b36718bf156f548bdcbfeb56da4"
chksum_prep

echo "=== TESTCASE 6b: 1 input, 4 outputs - verbose..." | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="6d0e6d5de957435b784b396154da02f6c33fec4c18402ead23bfc50103cf12cc"
chksum_prep

echo "=== TESTCASE 6c: 1 input, 4 outputs - very verbose..." | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001df64d3e790779777de937eea18884e9b131c9910bdb860b1a5cea225b61e3510020000006b48304502210082e594fdd17f4f2995edc180e5373a664eb56f56420f0c8761a27fa612db2a2b02206bcd4763303661c9ccaac3e4e7f6bfc062f17ce4b6b1b479ee067a05e5a578b10121036932969ec8c5cecebc1ff6fc07126f8cb5589ada69db8ca97a4f1291ead8c06bfeffffff04d130ab00000000001976a9141f59b78ccc26b6d84a65b0d362185ac4683197ed88acf0fcf300000000001976a914f12d85961d3a36119c2eaed5ad0e728a789ab59c88acb70aa700000000001976a9142baaf47baf1bd1e3dad3956db536c3f2e87c237b88ac94804707000000001976a914cb1b1d3c8be7db6416c16a1d29db170930970a3088acce3d0600 > tmpfile
chksum_ref="38feed29c88cc1680746edd560bddaf58b8b71c1062ae7a6147cb5b32ad3437d"
chksum_prep

echo "=== TESTCASE 6d: 4 inputs, 2 outputs, very verbose..." | tee -a $logfile
./tcls_tx2txt.sh -vv -r 01000000046c969e2396497561ebc6fc7cf845022e21b2ebf63e4a6d82544d521310cf3542040000006b483045022100d8cd1b4e6e0999ac397c8d78eae0520366f622be1b062db02479c0aa7f68dde2022070c8d5a4dd2a02b89ee5d4f3b0cf12a46e280dcc9fc405f9d042e93ad3cf20ea01210200a6d3e2a688e720955424cff5a359ee3db7185faad71d5fc8d9c85118dfbd07fffffffffd2dd2b83d84e8f7a076c09256ede7b4d39583da70d9fea181168f36a594b491000000006a473044022030a889577fd95a48ba39fc6f8b059c352fa96618b10b6e42861d23bff3a3300c0220194edb9655edc2a404131b85bb83e68a3acba8f9ebe8a752a58b028f157fca4c0121021093ead70ce7d56115851fb3ca16de1dd39478cdcf2264c94929eaf28571f029ffffffff9ede725ecef99fa5f0e059f26e2bb9f4d6c7783eba4a000e250bf48509820be3000000006a4730440220476940dd78a56e4b66476dd1038e4a305f72b63d21bdc52322e1766c2087341202203a24070a44417588e65e5da348c2b5f96a7efed05d2b28e7b932e76ccdd38d120121029912e17b6e5833d035967dc67b97ce51628a381e451aecfda3d40d679cd1af3fffffffff244887dd1af93418ac9cdda199ae77c557445f280ed91daa04326810bab51ef0010000006a47304402201b68ea684b2d7bd5bfed7f7de589f30253c40908d132f25e718b2f886b18a27f0220230c10572c131c27816c7f73e269bad3312eb737b090034c2e0a2a1c3d0cabb2012102b5e9cba15229ec36732f19fe271de7f8c36ff0901e0a45d3dab6faee6f2f1442ffffffff026f110100000000001976a914ac4aeeedc2a3f4331bc7b40e9e71aa65dcb6b93c88acb5e10e00000000001976a9145140c47d2e2821fd062a412e697e3d08723e71ed88ac00000000 > tmpfile
chksum_ref="142cfa201323861f031504918797a774b0c7e85eb13fefa39cedbb9ce478d17b"
chksum_prep

echo " " | tee -a $logfile
}


testcase7() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 7: this is a transaction to a multisig address  ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/51f7fc9899b068c4a501ffa9b37368fd7c09b3e72e893e989c40c89095f74b79" >> $logfile

echo "=== TESTCASE 7a: " | tee -a $logfile
./tcls_tx2txt.sh -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="7bc8dca9e9cf0cab22455c052af37ad5d5a4dcfc6d395bf2ae69deca4efe636e"
chksum_prep

echo "=== TESTCASE 7b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="900ae8af106773ba41064f76052fee76bdde9e59999cd4b6c959f42fc2553c3b"
chksum_prep

echo "=== TESTCASE 7c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 010000000216f7342825c156476c430f3e2765e0c393283b08246a66d122a45c836554ef03010000006b483045022100dd55b040174c90e85f0d33417dfccd96fa4f6b5ef50c32a1b720c24efc097f73022018d8a6b003b46c578d42ff4221af46068b64dd4e55d2d074175038a6e620e66b012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffffe18f73b450139de5c7375dcd2bd249ef6a42ad19661104df796dccdc98d34722000000006a47304402202e733dd23eb16130c3aa705cd04ffa31928616f2558063281cf642d786bf3eef022010a4d48968c504391c19c1cf67163d5618809bacb644d797a24a05f2130aa9f7012103a86d6cd289a76d1b2b13d362d9f58d1753dd4252be1ef8a404831dd1de45f6c2ffffffff02a6ea17000000000017a914f815b036d9bbbce5e9f2a00abd1bf3dc91e9551087413c0200000000001976a914ff57cb19528c04096067b8db38d18ecd0b37789388ac00000000 > tmpfile
chksum_ref="0136a9fadf2581e321db5dd480a0c154059fd0aea6c094044fa86677c6cd4602"
chksum_prep
echo " " | tee -a $logfile
}


testcase8() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 8: just another multisig trx                    ===" | tee -a $logfile
echo "===  Here we have a multisig in and out address ...          ===" >> $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/c0889855c93eed67d1f5a6b8a31e446e3327ce03bc267f2db958e79802941c73" >> $logfile

echo "=== TESTCASE 8a: " | tee -a $logfile
./tcls_tx2txt.sh -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="a14c0368e2a9f4d40e4ef5a04a893382794ba1b0bccbf5c39295b4a93a23301e"
chksum_prep

echo "=== TESTCASE 8b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="2ba063adf358bd560ce4e511aecedb941a434e235f190c66d1d281038cdfd306"
chksum_prep

echo "=== TESTCASE 8c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 0100000001b9c6777f2d8d710f1e0e3bb5fbffa7cdfd6c814a2257a7cfced9a2205448dd0601000000da0048304502210083a93c7611f5aeee6b0b4d1cbff2d31556af4cd1f951de8341c768ae03f780730220063b5e6dfb461291b1fbd93d58a8111d04fd03c7098834bac5cdf1d3c5fa90d0014730440220137c7320e03b73da66e9cf89e5f5ed0d5743ebc65e776707b8385ff93039408802202c30bc57010b3dd20507393ebc79affc653473a7baf03c5abf19c14e2136c646014752210285cb139a82dd9062b9ac1091cb1f91a01c11ab9c6a46bd09d0754dab86a38cc9210328c37f938748dcbbf15a0e5a9d1ba20f93f2c2d0ead63c7c14a5a10959b5ce8952aeffffffff0280c42b03000000001976a914d199925b52d367220b1e2a2d8815e635b571512f88ac65a7b3010000000017a9145c4dd14b9df138840b34237fdbe9159c420edbbe8700000000 > tmpfile
chksum_ref="38ab25d61a435b76a755d4bc08c8425d013b808e83b53a502d331397ab8e61e4"
chksum_prep
echo " " | tee -a $logfile
}


testcase9() {
echo "================================================================" | tee -a $logfile
echo "=== TESTCASE 9: 4 inputs and 2 outputs (P2SH multisig!)      ===" | tee -a $logfile
echo "===  a long tx, which is fetched via the -t parameter.       ===" >> $logfile
echo "===  requires network connection (https://blockchain.info)   ===" | tee -a $logfile
echo "================================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac" >> $logfile

echo "=== TESTCASE 9a: " | tee -a $logfile
./tcls_tx2txt.sh -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="9b288f00b12cb9a825e745c0c2b61574ca66e2ec1ea6c64cc310b649ed0401cf"
chksum_prep

echo "=== TESTCASE 9b: " | tee -a $logfile
./tcls_tx2txt.sh -v -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="80b44cb3bdcc47d6605854688561138eecf9db8678494f10a9d291712562f0c1"
chksum_prep

echo "=== TESTCASE 9c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 734c48124d391bfff5750bbc39bd18e6988e8ac873c418d64d31cfdc31cc64ac > tmpfile
chksum_ref="0300d54b74957ef45692f2bb9d2f87e2c8d60b0befac824240aab7ede0138d79"
chksum_prep
echo " " | tee -a $logfile
}


testcase10() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 10: 1 input, 4 outputs (one is P2SH script)  ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "https://blockchain.info/de/rawtx/ea9462053d74024ec46dac07c450200194051020698e8640a5a024d8ac085590" >> $logfile

echo "=== TESTCASE 10a: " | tee -a $logfile
./tcls_tx2txt.sh -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="fb6b467c9fccf610be696cba76277d8b1a38289bbfeac001ce64bace57a67d20"
chksum_prep

echo "=== TESTCASE 10b: " | tee -a $logfile
./tcls_tx2txt.sh -v -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="8b231fd8231370babe27ee2b9dbb873a4fbbb7fb0ed49bf4535d7cf3cc305555"
chksum_prep

echo "=== TESTCASE 10c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -r 01000000013153f60f294bc14d0481138c1c9627ff71a580b596987a82e9eebf2ae3de232202000000fc0047304402200c2f9e8805de97fa785b93dcc9072197bf5c1095ea536320ed26c645ec3bfafc02202882258f394449f1b1365ce80eed26fbe01217657729664af6827d041e7e98510147304402206d5cbef275b6972bd8cc00aff666a6ca18f09a5b1d1bf49e6966ad815db7119a0220340e49d4b747c9bd8ac80dbe073525c57da43dc4d2727b789be7e66bed9c6d02014c695221037b7c16024e2e6f6575b7a8c55c581dce7effcd6045bdf196461be8ff88db24f1210223eefa59f9b51ca96e1f4710df3639c58aae32c4cef1dd0333e7478de3dd4c6321034d03a7e6806e734c171be535999239aac76822427c217ee7564ab752cdc12dde53aeffffffff048d40ad120100000017a914fb8e0ce6d2f35c566908fd225b7f96e72df603d3872d5f0000000000001976a914768ac2a2530b2987d2e6506edc71dcf9f0a7b6e688ac00350c00000000001976a91452f28673c5aed9126b91d9eac5cbe1e02276a2cb88ac18b30700000000001976a914f3678c60ec389c7b132b5e5b0e1434b6dcd48f4188ac00000000 > tmpfile
chksum_ref="0d1a155f89048d060b53be7c186b8bd60fc99c6bcb88cafd3b75cc11b9538921"
chksum_prep
echo " " | tee -a $logfile
}

testcase11() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11: *** my first cold storage test ! ***     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 11a: " | tee -a $logfile
./tcls_tx2txt.sh -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="e9f53124d90f720f7a151b1c3fbb9aaaa6788c72528a12330511ad6a62836ffc"
chksum_prep

echo "=== TESTCASE 11b: " | tee -a $logfile
./tcls_tx2txt.sh -v -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="445db649aec3fa3424fbda9905b4b6af97f604b17f04202677654538a4ce5097"
chksum_prep

echo "=== TESTCASE 11c: " | tee -a $logfile
./tcls_tx2txt.sh -vv -u 0100000001bc12683c21e46c380933e83c00ec3929453e3d11cc5a2db9f795372efe03e81d000000001976a914c2df275d78e506e17691fd6f0c63c43d15c897fc88acffffffff01d0a11000000000001976a9140de4457d577bb45dee513bb695bdfdc3b34d467d88ac0000000001000000 > tmpfile
chksum_ref="8690dc5a94b5153402c42cdb1a0eed982963e02b2b4a711df3576b5268cf1f69"
chksum_prep
echo " " | tee -a $logfile
}

testcase12() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12: some special trx ...                     ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 12a: the pizza transaction:" | tee -a $logfile
echo "https://blockchain.info/tx/cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79" >> $logfile
echo "http://bitcoin.stackexchange.com/questions/32305/how-does-the-ecdsa-verification-algorithm-work-during-transaction/32308#32308" >> $logfile
echo "./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000" >> $logfile
./tcls_tx2txt.sh -vv -r 01000000018dd4f5fbd5e980fc02f35c6ce145935b11e284605bf599a13c6d415db55d07a1000000008b4830450221009908144ca6539e09512b9295c8a27050d478fbb96f8addbc3d075544dc41328702201aa528be2b907d316d2da068dd9eb1e23243d97e444d59290d2fddf25269ee0e0141042e930f39ba62c6534ee98ed20ca98959d34aa9e057cda01cfd422c6bab3667b76426529382c23f42b9b08d7832d4fee1d6b437a8526e59667ce9c4e9dcebcabbffffffff0200719a81860000001976a914df1bd49a6c9e34dfa8631f2c54cf39986027501b88ac009f0a5362000000434104cd5e9726e6afeae357b1806be25a4c3d3811775835d235417ea746b7db9eeab33cf01674b944c64561ce3388fa1abd0fa88b06c44ce81e2234aa70fe578d455dac00000000 > tmpfile
chksum_ref="3b73a0465fc20ba9c96c0d1d7b5a47a6a64aefdc04d031b327c01f0e9356cf8c"
chksum_prep

echo "=== TESTCASE 12b: the same pizza tx, but fetched from network" | tee -a $logfile
echo "./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79" >> $logfile
./tcls_tx2txt.sh -vv -t cca7507897abc89628f450e8b1e0c6fca4ec3f7b34cccf55f3f531c659ff4d79 > tmpfile
chksum_ref="63d41c1be8a55497f9d7e927b8b8cd7e938bdb3d852ecf0f959aee13742abf6e"
chksum_prep

echo "=== TESTCASE 12c: nice tx_out script:" | tee -a $logfile
echo "http://bitcoin.stackexchange.com/questions/48673/confused-about-this-particular-multisig-transaction-with-a-maybe-invalid-scrip" >> $logfile
echo "./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10" >> $logfile
./tcls_tx2txt.sh -vv -t c49b3c445c89d832289de0fd3b0281efdcce418333dacd028061e8de9f0a6f10 > tmpfile
chksum_ref="1f7635feb11d101104d87f99a4cfe54b3e3d2516e805da0eef0b5384eaa63884"
chksum_prep

echo "=== TESTCASE 12d: a NullData (OP_RETURN) tx_out script:" | tee -a $logfile
echo "https://blockexplorer.com/api/rawtx/d29c9c0e8e4d2a9790922af73f0b8d51f0bd4bb19940d9cf910ead8fbe85bc9b" >> $logfile
echo "./tcls_tx2txt.sh -vv -r 01000000016ca9aad181967df29c02384f867ea09b90c41d7cee160bbd857d6a7520f45cb4000000006a473044022062ee7002c5483545b81623495e2fd04691fb7685dbc5251bff7581585037822502203df73a07c242cf0fa1611e4d99604801bf75a93c2fb02ac3defef4c369ea5f040121024ee119308c8a6f8a498e1b34bc9b73d91750a9eb4e749b3f45b34ea58f57de01ffffffff010000000000000000fddb036a4dd7035765277265206e6f20737472616e6765727320746f206c6f76650a596f75206b6e6f77207468652072756c657320616e6420736f20646f20490a412066756c6c20636f6d6d69746d656e74277320776861742049276d207468696e6b696e67206f660a596f7520776f756c646e27742067657420746869732066726f6d20616e79206f74686572206775790a49206a7573742077616e6e612074656c6c20796f7520686f772049276d206665656c696e670a476f747461206d616b6520796f7520756e6465727374616e640a0a43484f5255530a4e6576657220676f6e6e61206769766520796f752075702c0a4e6576657220676f6e6e61206c657420796f7520646f776e0a4e6576657220676f6e6e612072756e2061726f756e6420616e642064657365727420796f750a4e6576657220676f6e6e61206d616b6520796f75206372792c0a4e6576657220676f6e6e612073617920676f6f646279650a4e6576657220676f6e6e612074656c6c2061206c696520616e64206875727420796f750a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069740a416e6420696620796f752061736b206d6520686f772049276d206665656c696e670a446f6e27742074656c6c206d6520796f7527726520746f6f20626c696e6420746f20736565202843484f525553290a0a43484f52555343484f5255530a284f6f68206769766520796f75207570290a284f6f68206769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069742028544f2046524f4e54290a0a00000000" >> $logfile
./tcls_tx2txt.sh -vv -r 01000000016ca9aad181967df29c02384f867ea09b90c41d7cee160bbd857d6a7520f45cb4000000006a473044022062ee7002c5483545b81623495e2fd04691fb7685dbc5251bff7581585037822502203df73a07c242cf0fa1611e4d99604801bf75a93c2fb02ac3defef4c369ea5f040121024ee119308c8a6f8a498e1b34bc9b73d91750a9eb4e749b3f45b34ea58f57de01ffffffff010000000000000000fddb036a4dd7035765277265206e6f20737472616e6765727320746f206c6f76650a596f75206b6e6f77207468652072756c657320616e6420736f20646f20490a412066756c6c20636f6d6d69746d656e74277320776861742049276d207468696e6b696e67206f660a596f7520776f756c646e27742067657420746869732066726f6d20616e79206f74686572206775790a49206a7573742077616e6e612074656c6c20796f7520686f772049276d206665656c696e670a476f747461206d616b6520796f7520756e6465727374616e640a0a43484f5255530a4e6576657220676f6e6e61206769766520796f752075702c0a4e6576657220676f6e6e61206c657420796f7520646f776e0a4e6576657220676f6e6e612072756e2061726f756e6420616e642064657365727420796f750a4e6576657220676f6e6e61206d616b6520796f75206372792c0a4e6576657220676f6e6e612073617920676f6f646279650a4e6576657220676f6e6e612074656c6c2061206c696520616e64206875727420796f750a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069740a416e6420696620796f752061736b206d6520686f772049276d206665656c696e670a446f6e27742074656c6c206d6520796f7527726520746f6f20626c696e6420746f20736565202843484f525553290a0a43484f52555343484f5255530a284f6f68206769766520796f75207570290a284f6f68206769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a284f6f6829206e6576657220676f6e6e6120676976652c206e6576657220676f6e6e6120676976650a286769766520796f75207570290a0a5765277665206b6e6f776e2065616368206f7468657220666f7220736f206c6f6e670a596f75722068656172742773206265656e20616368696e672062757420796f7527726520746f6f2073687920746f207361792069740a496e7369646520776520626f7468206b6e6f7720776861742773206265656e20676f696e67206f6e0a5765206b6e6f77207468652067616d6520616e6420776527726520676f6e6e6120706c61792069742028544f2046524f4e54290a0a00000000 > tmpfile
chksum_ref="407f3872d5281d6e9060962e6e001cd7dd121bb40cc547160312bbee549b70f2"
chksum_prep

echo "=== TESTCASE 12e: a 1-of-4 Multisig: " | tee -a $logfile
echo "https://bitcoin.stackexchange.com/questions/60468/signature-scheme-for-p2sh" >> $logfile
echo "./tcls_tx2txt.sh -vv -r 0100000001bdec74e1a37efc77324bb81d2375c5af090ca02debedb7af18fa1e85756d7c2601000000d60047304402204887a352b503da6f212c09ed7e973384d7660f62d2319a15b968252012d134810220695130bc101f44348203c51a50e46f37ed4bc5622795f5dfbddef2affb27e2a8014c8b512102930a11e92103daefde0d30b552f57d303e94a128e763ca9e69ff2006446934442103e74d2113dec75d75cde09a5b46297b1067e4b8b35e63c4c32b8cdbadfdffda1e2103067fcc39ee36d2417684511d1055fdc7d35e54911cb9de9ae30c988b666f675c2102dfb1c2a1c3456c8cb76714706dba77b3f4e7fe5afffc2503b121323a48ebbdcf54aeffffffff01c05d00000000000017a914de5462e6e84cdab5064220343b9331a3af6dbbf18700000000" >> $logfile
./tcls_tx2txt.sh -vv -r 0100000001bdec74e1a37efc77324bb81d2375c5af090ca02debedb7af18fa1e85756d7c2601000000d60047304402204887a352b503da6f212c09ed7e973384d7660f62d2319a15b968252012d134810220695130bc101f44348203c51a50e46f37ed4bc5622795f5dfbddef2affb27e2a8014c8b512102930a11e92103daefde0d30b552f57d303e94a128e763ca9e69ff2006446934442103e74d2113dec75d75cde09a5b46297b1067e4b8b35e63c4c32b8cdbadfdffda1e2103067fcc39ee36d2417684511d1055fdc7d35e54911cb9de9ae30c988b666f675c2102dfb1c2a1c3456c8cb76714706dba77b3f4e7fe5afffc2503b121323a48ebbdcf54aeffffffff01c05d00000000000017a914de5462e6e84cdab5064220343b9331a3af6dbbf18700000000 > tmpfile
chksum_ref="6e828f65d5b59122e094246172864fd16a736e75ea7f47333c16170dca296c61"
chksum_prep

echo " " | tee -a $logfile
}


testcase13() {
# this trx has a complicated input script (PK script?)
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 13:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  this trx has 35 output scripts ...                   ===" >> $logfile
echo "=============================================================" >> $logfile
echo "https://blockchain.info/de/rawtx/7c83fe5ba301e655973e9de8eb9fb5e20ef3a6dd9b46c503679c858399eda50f" >> $logfile

echo "=== TESTCASE 13a: 35 outputs" | tee -a $logfile
  ./tcls_tx2txt.sh -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="954fe43bcd26eed94eca2b51a8639beaa4f2f9cb77c7c3ce83fe03864a8b53c9"
chksum_prep

echo "=== TESTCASE 13b: 35 outputs, verbose" | tee -a $logfile
  ./tcls_tx2txt.sh -v -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="1232d0d7cc8fac099df0d4386ee1ed0b8e1cf331d3e0732e2a5eb00bbc294ee4"
chksum_prep

echo "=== TESTCASE 13c: 35 outputs, very verbose" | tee -a $logfile
  ./tcls_tx2txt.sh -vv -r 01000000014675ab74e5c496c8eecaaa87c6136bc68ebaaac7a25e70ee29b7bbaffad6810f000000008b4830450220296d4f4869a63efdee4c5ea31dcad559b4e03332462ba5442bfdf00a662cb77102210088a7f10361eae3e159ae6a8b5b7a569bf6bfa2de64fb3f5d0552f8be568ba6f50141042a9a97b2109ef496ffb1033576a5635cecc6ab679ad0b7c43d33ddf38b1f44c22ea42d5c01ac2752094ff81e79dda77d8b501a64102207c45fb89ea1ad9229ddffffffff23e8030000000000001976a914801314cd462b98c64dd4c3f4d6474cad11ea39d588ace8030000000000001976a9145bb7d22851413e1d61e8db5395a8c7c537256ea088ace8030000000000001976a914371f197d5ba5e32bd98260eec7f0e51227b6969088ace8030000000000001976a9143e546d0acc0de5aa3d66d7a920900ecbc66c203188ace8030000000000001976a9140337e0710056f114c9c469a68775498df9f9fa1688ace8030000000000001976a9149c628c82aa7b81da7c6a235049eb2979c4a65cfc88ace8030000000000001976a914cd1d7e863f891c493e093ada840ef5a67ad2d6cc88ace8030000000000001976a91476f074340381e6f8a40aec4a6e2d92485679412c88ace8030000000000001976a9140fb87a5071385b6976397d1c53ee16f09139a33488ace8030000000000001976a9143d37873ffd2964a1a4c8bade4852020ec5426d3688ace8030000000000001976a9145d14a857fce8da8edfb8f7d1c4bbc316622b722788ace8030000000000001976a9140a77fdb4cc81631b6ea2991ff60b47d57812d8e788ace8030000000000001976a91454514fe9251b5e381d13171cd6fca63f61d8b72688ace8030000000000001976a914cffe3e032a686cc3f2c9e417865afa8a52ed962b88ace8030000000000001976a914fd9dc3525076c1ffe9c33389ea157d07af2e41d488ace8030000000000001976a9143bedfe927d55a8c8adfe5e4b5dddd4ea3487b4c988ace8030000000000001976a914e49275e86ece605f271f26a9559520eb9c0ae8d888ace8030000000000001976a91469256ba90b0d7e406d86a51d343d157ff0aab7bd88ace8030000000000001976a9148ab0cb809cd893cb0cb16f647d024db94f09d76588ace8030000000000001976a9140688e383f02b528c92e25caae5785ffaa81a26aa88ace8030000000000001976a914d959be6c92037995558f43a55b1c271628f96e8d88ac8038f240000000001976a914d15e54e341d538ce3e9e7596e0dbcda8c12cc08988ace8030000000000001976a91495019a8168e8dcd2ef2d47ca57c1bf49358eb6fe88ace8030000000000001976a914caf67cfe28b511498b0d1792bedeec6b6e8a3c8d88ace8030000000000001976a914082a3adf4c8497fbd7d90f21cbec318b0dfdd2b288ace8030000000000001976a9144c53722fd5b0bc8a5b23ae4efc6233142b69d8ee88ace8030000000000001976a9146abd1edce61a7fdd2d134e8468560ecffb45334e88ace8030000000000001976a914dc3343b674cf2016b8968e6146ba5cc9228f14a488ace8030000000000001976a9145f395a91d07712604d7cd6fabd685b9bfd3900dd88ace8030000000000001976a914fc35239072cd5c19d9f761996951679fb03bb43188ace8030000000000001976a914b1ec1d5e0591abbbe3134c94c37e74d034b9312288ace8030000000000001976a9142d6351944aa38af6aa46d4a74cbb9016cf19ee7e88ace8030000000000001976a914879a49b3822806e0322565d457ce2b5989adaa6188ace8030000000000001976a9145ff26e3f8d542c5bb612e539649eaec0222afc3c88ace8030000000000001976a914105d54a4edcbe114a50bb01c79d230b7ed74a3e488ac00000000 > tmpfile
chksum_ref="2eed04c34c0fddf8cc3ac0136e2ff8e43a845b9c1830061a78a28f9cea06ce9f"
chksum_prep
echo " " | tee -a $logfile
}

testcase14() {
# testcases for SegWit
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 14:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  SEGWIT !!!                                           ===" >> $logfile
echo "=============================================================" >> $logfile

echo "=== TESTCASE 14a: Native P2WPKH tx" | tee -a $logfile
./tcls_tx2txt.sh -r 01000000000102fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f00000000494830450221008b9d1dc26ba6a9cb62127b02742fa9d754cd3bebf337f7a55d114c8e5cdd30be022040529b194ba3f9281a99f2b1c0a19c0489bc22ede944ccf4ecbab4cc618ef3ed01eeffffffef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a0100000000ffffffff02202cb206000000001976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac9093510d000000001976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac000247304402203609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a0220573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee0121025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee635711000000 > tmpfile
chksum_ref="54ddbb52667e98bfe52acde2e54af157237fa670674fa249281646952d9e8417"
chksum_prep

echo "=== TESTCASE 14b: Native P2WPKH tx (verbose on)" | tee -a $logfile
./tcls_tx2txt.sh -v -r 01000000000102fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f00000000494830450221008b9d1dc26ba6a9cb62127b02742fa9d754cd3bebf337f7a55d114c8e5cdd30be022040529b194ba3f9281a99f2b1c0a19c0489bc22ede944ccf4ecbab4cc618ef3ed01eeffffffef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a0100000000ffffffff02202cb206000000001976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac9093510d000000001976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac000247304402203609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a0220573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee0121025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee635711000000 > tmpfile
chksum_ref="66d6eabbed9aaa40b2d94e0bf3b2b1cf71994ba5e8f43d1287a3a81660c3c160"
chksum_prep

echo "=== TESTCASE 14c: Native P2WPKH tx (very verbose on)" | tee -a $logfile
./tcls_tx2txt.sh -vv -r 01000000000102fff7f7881a8099afa6940d42d1e7f6362bec38171ea3edf433541db4e4ad969f00000000494830450221008b9d1dc26ba6a9cb62127b02742fa9d754cd3bebf337f7a55d114c8e5cdd30be022040529b194ba3f9281a99f2b1c0a19c0489bc22ede944ccf4ecbab4cc618ef3ed01eeffffffef51e1b804cc89d182d279655c3aa89e815b1b309fe287d9b2b55d57b90ec68a0100000000ffffffff02202cb206000000001976a9148280b37df378db99f66f85c95a783a76ac7a6d5988ac9093510d000000001976a9143bde42dbee7e4dbe6a21b2d50ce2f0167faa815988ac000247304402203609e17b84f6a7d30c80bfa610b5b4542f32a8a0d5447a12fb1366d7f01cc44a0220573a954c4518331561406f90300e8f3358f51928d43c212a8caed02de67eebee0121025476c2e83188368da1ff3e292e7acafcdb3566bb0ad253f62fc70f07aeee635711000000 > tmpfile
chksum_ref="27cb41edecd4d68fcd91ed58de259dbadc0865398a00191b943843cc747a3800"
chksum_prep

echo "=== TESTCASE 14d: P2SH-P2WPKH tx" | tee -a $logfile
./tcls_tx2txt.sh -T -vv -r 01000000000101db6b1b20aa0fd7b23880be2ecbd4a98130974cf4748fb66092ac4d3ceb1a5477010000001716001479091972186c449eb1ded22b78e40d009bdf0089feffffff02b8b4eb0b000000001976a914a457b684d7f0d539a46a45bbc043f35b59d0d96388ac0008af2f000000001976a914fd270b1ee6abcaea97fea7ad0402e8bd8ad6d77c88ac02473044022047ac8e878352d3ebbde1c94ce3a10d057c24175747116f8288e5d794d12d482f0220217f36a485cae903c713331d877c1f64677e3622ad4010726870540656fe9dcb012103ad1d8e89212f0b92c74d23bb710c00662ad1470198ac48c43f7d6f93a2a2687392040000 > tmpfile
chksum_ref="f07d08a23a236eacb1baa001d105ad41a919554e4bdfdd2dbda39669aaaccf8f"
chksum_prep

echo "=== TESTCASE 14e: Native P2WSH tx" | tee -a $logfile
./tcls_tx2txt.sh -T -vv -r 01000000000102fe3dc9208094f3ffd12645477b3dc56f60ec4fa8e6f5d67c565d1c6b9216b36e000000004847304402200af4e47c9b9629dbecc21f73af989bdaa911f7e6f6c2e9394588a3aa68f81e9902204f3fcf6ade7e5abb1295b6774c8e0abd94ae62217367096bc02ee5e435b67da201ffffffff0815cf020f013ed6cf91d29f4202e8a58726b1ac6c79da47c23d1bee0a6925f80000000000ffffffff0100f2052a010000001976a914a30741f8145e5acadf23f751864167f32e0963f788ac000347304402200de66acf4527789bfda55fc5459e214fa6083f936b430a762c629656216805ac0220396f550692cd347171cbc1ef1f51e15282e837bb2b30860dc77c8f78bc8501e503473044022027dc95ad6b740fe5129e7e62a75dd00f291a2aeb1200b84b09d9e3789406b6c002201a9ecd315dd6a0e632ab20bbb98948bc0c6fb204f2c286963bb48517a7058e27034721026dccc749adc2a9d0d89497ac511f760f45c47dc5ed9cf352a58ac706453880aeadab210255a9626aebf5e29c0e6538428ba0d1dcf6ca98ffdf086aa8ced5e0d0215ea465ac00000000 > tmpfile
chksum_ref="f191a280d19bd5d41125d525bdea5d8a8b373867659e8b7aee409d67e0c796f4"
chksum_prep

echo "=== TESTCASE 14f: P2SH-P2WSH 6-of-6 multisig witness" | tee -a $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010136641869ca081e70f394c6948e8af409e18b619df2ed74aa106c1ca29787b96e0100000023220020a16b5755f7f6f96dbd65f5f0d6ab9418b89af4b1f14a1bb8a09062c35f0dcb54ffffffff0200e9a435000000001976a914389ffce9cd9ae88dcc0631e88a821ffdbe9bfe2688acc0832f05000000001976a9147480a33f950689af511e6e84c138dbbd3c3ee41588ac080047304402206ac44d672dac41f9b00e28f4df20c52eeb087207e8d758d76d92c6fab3b73e2b0220367750dbbe19290069cba53d096f44530e4f98acaa594810388cf7409a1870ce01473044022068c7946a43232757cbdf9176f009a928e1cd9a1a8c212f15c1e11ac9f2925d9002205b75f937ff2f9f3c1246e547e54f62e027f64eefa2695578cc6432cdabce271502473044022059ebf56d98010a932cf8ecfec54c48e6139ed6adb0728c09cbe1e4fa0915302e022007cd986c8fa870ff5d2b3a89139c9fe7e499259875357e20fcbb15571c76795403483045022100fbefd94bd0a488d50b79102b5dad4ab6ced30c4069f1eaa69a4b5a763414067e02203156c6a5c9cf88f91265f5a942e96213afae16d83321c8b31bb342142a14d16381483045022100a5263ea0553ba89221984bd7f0b13613db16e7a70c549a86de0cc0444141a407022005c360ef0ae5a5d4f9f2f87a56c1546cc8268cab08c73501d6b3be2e1e1a8a08824730440220525406a1482936d5a21888260dc165497a90a15669636d8edca6b9fe490d309c022032af0c646a34a44d1f4576bf6a4a74b67940f8faa84c7df9abe12a01a11e2b4783cf56210307b8ae49ac90a048e9b53357a2354b3334e9c8bee813ecb98e99a7e07e8c3ba32103b28f0c28bfab54554ae8c658ac5c3e0ce6e79ad336331f78c428dd43eea8449b21034b8113d703413d57761b8b9781957b8c0ac1dfe69f492580ca4195f50376ba4a21033400f6afecb833092a9a21cfdf1ed1376e58c5d1f47de74683123987e967a8f42103a6d48b1131e94ba04d9737d61acdaa1322008af9602b3b14862c07a1789aac162102d8b661b0b3302ee2f162b09e07a55ad5dfbe673a9f01d9f0c19617681024306b56ae00000000 > tmpfile
chksum_ref="c844255d90fbd43f50dec92ecabb8abf7c8b998df1639f213d8847e06351a823"
chksum_prep

echo "=== TESTCASE 14g: SEGWIT tx" | tee -a $logfile
./tcls_tx2txt.sh -T -vv -r 0200000000010129b0f742d41c6aad58dd0e779ca53b8bed1790465ed59ed20d2b6a3ecc6744920100000000ffffffff0178cdf5050000000016001443aac20a116e09ea4f7914be1c55e4c17aa600b702483045022100e8877e9351abcfc5dc20a9c9f55d7bcde8d64993d135a20568b5b8628ea3f7b102203801629aad6a7ec0960b4d830aedac673d620179753cc6f197eaed866a4959ba012103335134d7414e1d1a154600b124a96f5ef2c6ca21434d2622469a96bd5262fd5600000000 > tmpfile
chksum_ref="49b682d7bc888772b550483ab6e0204c73a9caf9261a7efd1363266ef536ba96"
chksum_prep

echo "=== TESTCASE 14h: SEGWIT P2WPKH tx" | tee -a $logfile
echo "https://blockchainprogramming.azurewebsites.net/checktx?txid=d869f854e1f8788bcff294cc83b280942a8c728de71eb709a2c29d10bfe21b7c" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010115e180dc28a2327e687facc33f10f2a20da717e5548406f7ae8b4c811072f8560100000000ffffffff0100b4f505000000001976a9141d7cd6c75c2e86f4cbf98eaed221b30bd9a0b92888ac02483045022100df7b7e5cda14ddf91290e02ea10786e03eb11ee36ec02dd862fe9a326bbcb7fd02203f5b4496b667e6e281cc654a2da9e4f08660c620a1051337fa8965f727eb19190121038262a6c6cec93c2d3ecd6c6072efea86d02ff8e3328bbd0242b20af3425990ac00000000 > tmpfile
chksum_ref="2451a017e96662685b7971485cfe0abd9120667aba192c5c89b8cb8c18e1983e"
chksum_prep

echo "=== TESTCASE 14i: SEGWIT P2WSH tx" | tee -a $logfile
echo "https://blockchainprogramming.azurewebsites.net/checktx?txid=78457666f82c28aa37b74b506745a7c7684dc7842a52a457b09f09446721e11c" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010115e180dc28a2327e687facc33f10f2a20da717e5548406f7ae8b4c811072f8560200000000ffffffff0188b3f505000000001976a9141d7cd6c75c2e86f4cbf98eaed221b30bd9a0b92888ac02483045022100f9d3fe35f5ec8ceb07d3db95adcedac446f3b19a8f3174e7e8f904b1594d5b43022074d995d89a278bd874d45d0aea835d3936140397392698b7b5bbcdef8d08f2fd012321038262a6c6cec93c2d3ecd6c6072efea86d02ff8e3328bbd0242b20af3425990acac00000000 > tmpfile
chksum_ref="aa8ca00310d9e66b88a4cde828203bfe1d358583018a0d677c27135e5ac0f436"
chksum_prep

echo "=== TESTCASE 14j: SEGWIT P2SH(WPKH) tx" | tee -a $logfile
echo "https://blockchainprogramming.azurewebsites.net/checktx?txid=8139979112e894a14f8370438a471d23984061ff83a9eba0bc7a34433327ec21" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010115e180dc28a2327e687facc33f10f2a20da717e5548406f7ae8b4c811072f85603000000171600141d7cd6c75c2e86f4cbf98eaed221b30bd9a0b928ffffffff019caef505000000001976a9141d7cd6c75c2e86f4cbf98eaed221b30bd9a0b92888ac02483045022100f764287d3e99b1474da9bec7f7ed236d6c81e793b20c4b5aa1f3051b9a7daa63022016a198031d5554dbb855bdbe8534776a4be6958bd8d530dc001c32b828f6f0ab0121038262a6c6cec93c2d3ecd6c6072efea86d02ff8e3328bbd0242b20af3425990ac00000000 > tmpfile
chksum_ref="0c2481c8bc63da6e586ecf17e590687a2915eb0ed40315b58638db04c1964563"
chksum_prep

echo "=== TESTCASE 14k: SEGWIT P2SH(WSH) tx" | tee -a $logfile
echo "https://blockchainprogramming.azurewebsites.net/checktx?txid=954f43dbb30ad8024981c07d1f5eb6c9fd461e2cf1760dd1283f052af746fc88" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010115e180dc28a2327e687facc33f10f2a20da717e5548406f7ae8b4c811072f856040000002322002001d5d92effa6ffba3efa379f9830d0f75618b13393827152d26e4309000e88b1ffffffff0188b3f505000000001976a9141d7cd6c75c2e86f4cbf98eaed221b30bd9a0b92888ac02473044022038421164c6468c63dc7bf724aa9d48d8e5abe3935564d38182addf733ad4cd81022076362326b22dd7bfaf211d5b17220723659e4fe3359740ced5762d0e497b7dcc012321038262a6c6cec93c2d3ecd6c6072efea86d02ff8e3328bbd0242b20af3425990acac00000000 > tmpfile
chksum_ref="7567e0363401358dd6096aec10cfc27677069d93bf5cdba3b10ef5c5fa6aae3d"
chksum_prep

echo "=== TESTCASE 14l: SEGWIT Version 2 tx" | tee -a $logfile
echo "https://blockchain.info/tx/c586389e5e4b3acb9d6c8be1c19ae8ab2795397633176f5a6442a261bbdefc3a?format=hex" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0200000000010140d43a99926d43eb0e619bf0b3d83b4a31f60c176beecfb9d35bf45e54d0f7420100000017160014a4b4ca48de0b3fffc15404a1acdc8dbaae226955ffffffff0100e1f5050000000017a9144a1154d50b03292b3024370901711946cb7cccc387024830450221008604ef8f6d8afa892dee0f31259b6ce02dd70c545cfcfed8148179971876c54a022076d771d6e91bed212783c9b06e0de600fab2d518fad6f15a2b191d7fbd262a3e0121039d25ab79f41f75ceaf882411fd41fa670a4c672c23ffaf0e361a969cde0692e800000000 > tmpfile
chksum_ref="2072823173cbf238b726e5fcaec72853b70f2744a453203c2a017d67ae7f5379"
chksum_prep

echo "=== TESTCASE 14m: SEGWIT Version 1 tx" | tee -a $logfile
echo "https://blockchain.info/tx/4ffb6404517ad30869f125b7f2f23a9058313d736a72a996b1381f1fe6f04e07?format=hex" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0100000000010190939e6b6663d3a0af6bfaae1f4a1e4d95ffe39bc6b020be98d8091f1076e8c800000000171600148cb2bca2a80187907b9e9f0d55785038bcccf019ffffffff0240420f00000000001976a914fd7117d34e720cf89d1c5e386845a726aa34c2f288ac0eea01000000000017a914f56b99b6116ef0cbf38958686c01c5ee88b8e3d08702483045022100cb7a7c77d8d1bf6edf383228a02261620d6274e547e0f5e7795c7a1edc0d1a390220606a36cf4bd4cd46b95ac7d625c73320f5a3d4fe09161061bef041b6fa2f83d60121022240e2d4a20780505c437e9c215cb1c90a3bd3e6f57c4bc55075862e2343b95d00000000 > tmpfile
chksum_ref="8c58c3ecb216cc0b3fefd4ac9e301efa7dfe97d7592e33d95801f25be9739f3e"
chksum_prep

echo "=== TESTCASE 14n: SEGWIT tx" | tee -a $logfile
echo "https://bitcoin.stackexchange.com/questions/60866/create-pay-to-witness-script-hash-in-pay-to-script-hash-address" >> $logfile
./tcls_tx2txt.sh -T -vv -r 01000000000101fc7901dd033f8c02da14f3ac916b6498036b80b4a0b4dc124e02c2bb408034c90000000000ffffffff01b87518000000000017a914a8655acf68f785125561158b0f4db9b5d0044047870400473044022057b571986c07f8ccb231811334ad06ee6f87b722495def2e9511c1da46f3433202207b6e95bdd99e7fc7d319486437cb930d40a4af3cd753c4cb960b330badbf7f35014730440220517ecc6d0a2544276921d8fc2077aec4285ab83b1b21f5eb73cdb6187a0583e4022043fb5ab942f8981c04a54c66a57c4d291fad8514d4a8afea09f01f2db7a8f32901695221038e81669c085a5846e68e03875113ddb339ecbb7cb11376d4163bca5dc2e2a0c1210348c5c3be9f0e6cf1954ded1c0475beccc4d26aaa9d0cce2dd902538ff1018a112103931140ebe0fbbb7df0be04ed032a54e9589e30339ba7bbb8b0b71b15df1294da53ae00000000 > tmpfile
chksum_ref="dc513ab9d15e83c9648dcd6e419c63c149e608d088a27c642dd1746873538487"
chksum_prep

echo "=== TESTCASE 14o: SEGWIT tx" | tee -a $logfile
echo "https://bitcoin.stackexchange.com/questions/60866/create-pay-to-witness-script-hash-in-pay-to-script-hash-address" >> $logfile
./tcls_tx2txt.sh -T -vv -r 010000000001012812fe3916f228cda6c7b57d5464541265a63ad118f430a805eeec8bddbe1cf40000000000ffffffff01a0791800000000002200201e8dda334f11171190b3da72e526d441491464769679a319a2f011da5ad312a10400483045022100cc97f21a7cabc543a9b4ac52424e8f7e420622903f2417a1c08a6af68058ec4a02200baca0b222fc825078d94e8e1b55f174c4828bed16697e4281cda2a0c799eecf01473044022009b8058dc30fa7a13310dd8f1a99c4341c4cd95f771c5a41c4381f956e2344c102205e829c560c0184fd4b4db8971f99711e2a87409afa4df0840b4f12a87b2c8afc0169522102740ec30d0af8591a0dd4a3e3b274e57f3f73bdc0638a9603f9ee6ade0475ba57210311aada919974e882abf0c67b5c0fba00000b26997312ca00345027d22359443021029382591271a79d4b12365fa27c67fad3753150d8eaa987e5a12dc5ba1bb2fa1653ae00000000 > tmpfile
chksum_ref="74bfab0cfb9ca11cdf225f2e860cc9faa8c5ee4257075b2c44947e3b8d3fdddd"
chksum_prep

echo "=== TESTCASE 14p: SEGWIT tx" | tee -a $logfile
echo "https://bitcoin.stackexchange.com/questions/60866/create-pay-to-witness-script-hash-in-pay-to-script-hash-address" >> $logfile
./tcls_tx2txt.sh -T -vv -r 0200000000010117017d17e296b4cd41cd63758bff8aadf214410505ccaeddb4252579ccffa40300000000171600149835f2e0dff9d7f6a4060140696bc7e00b12edd5ffffffff0100b4c404000000001976a914ac19d3fd17710e6b9a331022fe92c693fdf6659588ac024730440220452a58cf56c45edaffb952acccd2f6f2cea523cf82e73b82f8eb5e3b3b1b17c4022011de26884cf693b12f16fdd8fa6c1d96dacb97050907353852895d9b80b3fae101210206f4bad90006f70112129815b25ba585484f1bb4f8b88f8ebaec2c76f543794300000000 > tmpfile
chksum_ref="bfd8d93d6c0dee4cca1fc12507e581809b43eac0b43e38cf8825b2c9d699b2ca"
chksum_prep

echo " " | tee -a $logfile
} 

testcase15() {
# this trx has a complicated input script (PK script?)
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 15:                                          ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "===  working with the TESTNET                             ===" >> $logfile
echo "=============================================================" >> $logfile
echo "=== TESTCASE 15a: TESTNET addresses" | tee -a $logfile

./tcls_tx2txt.sh -T -vv -r 0100000001fc93e12cfbabe8383eba3c8c22d26c8ee941e9d1d98da0cf4f213e62e1ead47500000000fdfd0000473044022041ffcc40daaa2376a505132c63a1df4ea636650facbc870df460625c0661c62802202a03ac32d8bd8c67474c522245a06a79ced9e326e1266b914d2bcacaaa24860e01483045022100ffb0117cf0e8d0d0689f5adf6c5006212728901c07405dfa0cafcc42c9cbe7d6022044d168e217dc50f148ae3aee632e246554d2f9b57b53a2f18e8a68a3036e5a78014c69522103834bd129bf0a2e03d53b74bc2eef8d9a5faed93f37b4938ae7127d430804a3cf2103fae2fa202fbfd9d0a8650f537df154158761ce9ad2460793aed74b946babb9f421038cbc733032dcbed878c727840bef9c2aeb01447e1701c372c46a2ef00f48e02c53aeffffffff01638e582e000000001976a914431c4b76510347bb5f12907a819365f5e2834a1188ac00000000 > tmpfile
chksum_ref="8da989f66e087920c5797af2e8577d3b802ef82461a03c679b1833e315c2eaf6"
chksum_prep

echo " " | tee -a $logfile
} 

testcase16() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 16: SMART CONTRACTS with CHECKLOCKTIMEVERIFY ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 16a: CLTV customer/merchant escrow" | tee -a $logfile
echo " if" >> $logfile
echo "  <merchant pubkey> checksigverify" >> $logfile
echo " else" >> $logfile
echo "  <timestamp> checklocktimeverify drop" >> $logfile
echo " endif" >> $logfile
echo " <customer pubkey> checksig" >> $logfile
echo " " >> $logfile
./tcls_tx2txt.sh -vv -r 0100000001b7de7f18fc09b18b1b3954d4b44d87aea49aca151da83c999bb4f9affced126b01000000e4483045022100ee41613fe9ee94bcfb5643a2b26112c07c31c343a1dd66d3404c3d44735cd3c6022066f464b3f1b7ced77fd0b9485d49a235cca1747f6507d562214e8d4c514cbc4f014730440220354e112587cb66e7ccae412973193e8090eb8862b996b40d0ee14db7c1af8b130220326aacb12f76d1238c06b27534c14fbee951a7b8a6a067ff1a14aacc6fb5603101514c50632102ac7f5515e35069934600c996d0d9d20f5c49955963d6ee75b35e70a5e75df8fead670457b8c356b175682103694c06c4925b146376818adb883eb1b8e248f2a1581f01ca2e3d8e142dde57ffacffffffff02b90b0000000000001976a914a52d532ce7c67f3b67b5dad195f931fc9e3ccc7f88ac9f860100000000001976a91443e9381bce9ae41efe99218ac038adc847af29ee88ac00000000 > tmpfile
chksum_ref="63059a49f5635ba1827aa106ac99f04bc58bd7ae7a8aa45fc7fd75d48d1da277"
chksum_prep

echo "=== TESTCASE 16b: Trustless Payments for Publishing Data" | tee -a $logfile
echo "https://bitcointalk.org/index.php?topic=1300723.msg13387832#msg13387832" >> $logfile
echo " IF" >> $logfile
echo "     HASH160 <Hash160(encryption key)> EQUALVERIFY" >> $logfile
echo "     <publisher pubkey> CHECKSIG" >> $logfile
echo " ELSE" >> $logfile
echo "     <expiry time> CHECKLOCKTIMEVERIFY DROP" >> $logfile
echo "     <buyer pubkey> CHECKSIG" >> $logfile
echo " ENDIF" >> $logfile
./tcls_tx2txt.sh -vv -r 0100000001b431432852ba4f6fc6bab48354e9e389d68ddfd18adb703f5770f6d1d3bd3bda00000000cc47304402204caf58993eceb55c5df0db0c4d96571327a6678c0acd648c21133ca39034b7d70220093a8b935d651d59330b3e6b0e1ce52c3610bad9f6f1b9cd1ae48e7e6528838e0121021844989a2bd7acd127dd7ed51aa2f4d55b32dbb414de6325ae37e05c1067598d4c6076a820c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f26864687637576a914937fe2ee82229d282edec2606c70e755875334c088ac6703c8f505b17576a91420fbf78ba8f2f36feaec0efc5b82d5e07fb261a988ac68010000000110270000000000001976a91420fbf78ba8f2f36feaec0efc5b82d5e07fb261a988acc9f50500 > tmpfile
chksum_ref="251c969c546e194d80a867fd3897aae492f9858f25122584c7beaf31796fe8f8"
chksum_prep

echo "=== TESTCASE 16c: the corresponding CLTV redeem script (tcls_in_sig_script.sh -v ...): " | tee -a $logfile
echo "https://bitcointalk.org/index.php?topic=1300723.msg13433715#msg13433715" >> $logfile
./tcls_in_sig_script.sh -v 4730440220429b09433f70c16b26021bd19f71a7d30087c3bbd7e1255cfda7c00fdc126bed02207219634bd0f66eee1b73e60552bbf177f278ba856b99100bdc610b5da7201685012102681362f33ab4c48884c5f7f5aaf5011d53f0584cf0b257c6c3aff8b0b08241b34c5e76a820c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f26864687637576a9145e6199a3c0ad658480247a0f30e314aee23db1eb88ac67017fb17576a9145e6199a3c0ad658480247a0f30e314aee23db1eb88ac68 > tmpfile
chksum_ref="660c4d02fefaed7fb3ab141f7266be7b3028c653ee13f6ceaa5b3f2c894564b2"
chksum_prep

echo "=== TESTCASE 16d: and the secret reveal method without CLTV (tcls_in_sig_script.sh -v ...): " | tee -a $logfile
echo "https://bitcointalk.org/index.php?topic=1300723.msg13442916#msg13442916" >> $logfile
./tcls_in_sig_script.sh -v 483045022100f384542d66de1a19d5b1181b9894e14d44f34b83e9a190c0c43046486fbb2d9e02205bb2b9795e4f35c40aa38275a900ca01ea5f7d7747fcdb657b0c656a130d20cb012102681362f33ab4c48884c5f7f5aaf5011d53f0584cf0b257c6c3aff8b0b08241b30a313233343536373839304c5e76a820c775e7b757ede630cd0aa1113bd102661ab38829ca52a6422ab782862f26864687637576a9145e6199a3c0ad658480247a0f30e314aee23db1eb88ac67017fb17576a9145e6199a3c0ad658480247a0f30e314aee23db1eb88ac68 > tmpfile
chksum_ref="b7e59df65fa3799b909f001d275116dcdedda048aef925fe64544ec2d23b16ce"
chksum_prep

echo " " | tee -a $logfile
} 


testcase17() {
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 17: SMART CONTRACTS with CHECKSEQUENCEVERIFY ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 17a: CSV escrow or 2-of-2 msig" | tee -a $logfile
echo "https://bitcointalk.org/index.php?topic=1300723.msg13442916#msg13442916" >> $logfile
echo " OP_IF" >> $logfile
echo "    2 [PUBKEY A] [PUBKEY B] 2 OP_CHECKMULTISIG" >> $logfile
echo " OP_ELSE" >> $logfile
echo "    [CSV VALUE] OP_NOP3 OP_DROP" >> $logfile
echo "    OP_DUP OP_HASH160 [PUBKEYHASH B] OP_EQUALVERIFY OP_CHECKSIG" >> $logfile
echo " OP_ENDIF" >> $logfile
./tcls_tx2txt.sh -vv -r 0200000001a3d3b75529ef352627ada990d9668b2bde2230c803ea200f42f58dd020bc95a600000000d347304402205132429c78cbe811209a475532aaaff7d090d9d7cc467739decdb02a83f294c00220524b622d62eca9dabb06a5c9c0af8ac621e5f165d2f5b981ead1f0d50688bf70012103d7c6052544bc42eb2bc0d27c884016adb933f15576a1a2d21cd4dd0f2de0c37d004c666352210265c0023ee6bfe4ec31f902bc5f64c003c0f5af9be37397623b16e963942052012103d7c6052544bc42eb2bc0d27c884016adb933f15576a1a2d21cd4dd0f2de0c37d52ae675ab27576a914937fe2ee82229d282edec2606c70e755875334c088ac680a0000000150c30000000000001976a914937fe2ee82229d282edec2606c70e755875334c088ac00000000 > tmpfile
chksum_ref="15c2738f7f9bb9db7621ec99c52709017797f07ad3dd2840b0c371ea7a60e345"
chksum_prep




echo " " | tee -a $logfile
} 

testcase20() {
# this trx has +50 P2SH signatures and takes a long time to decode
echo "=============================================================" | tee -a $logfile
echo "=== TESTCASE 20: check very long tx                       ===" | tee -a $logfile
echo "=============================================================" | tee -a $logfile
echo "=== trx 20a has +117 txin                                 ===" >> $logfile
echo "=== trx 20b has +50 P2SH signatures                       ===" >> $logfile
echo "=============================================================" >> $logfile
echo "=== TESTCASE 20a: +117 txin ... " | tee -a $logfile
./tcls_tx2txt.sh -vv -t 19312fd6b177257bbc90187040066c3b1e2a398dfa953658d5d068f2119ad45f > tmpfile
chksum_ref="0d596da80b23c0f9db53ee1ab7fb7e28938be8cd6526598caaa8797fb58707a8"
chksum_prep

echo "=== TESTCASE 20b: +50 P2SH addresses" | tee -a $logfile
./tcls_tx2txt.sh -vv -t 1a96838d65a724bee4addcd74b5cef8102fa6e4f5058f73f53c8134021db407a > tmpfile
chksum_ref="0d596da80b23c0f9db53ee1ab7fb7e28938be8cd6526598caaa8797fb58707a8"
chksum_prep
echo " " | tee -a $logfile
} 

all_testcases() {
  testcase1 
  testcase2 
  testcase3 
  testcase4 
  testcase5 
  testcase6 
  testcase7 
  testcase8 
  testcase9 
  testcase10
  testcase11
  testcase12
  testcase13
  testcase14
  testcase15
  testcase16
  testcase17
}

#####################
### here we start ###
#####################
logfile=$0.log
if [ -f "$logfile" ] ; then rm $logfile; fi
echo $date > $logfile

###################################################################
# verify our operating system, cause checksum commands differ ... #
###################################################################
OS=$(uname) 
if [ OS="OpenBSD" ] ; then
  chksum_cmd=sha256
fi
if [ OS="Linux" ] ; then
  chksum_cmd="openssl sha256"
fi
if [ OS="Darwin" ] ; then
  chksum_cmd="openssl dgst -sha256"
fi

################################
# command line params handling #
################################

if [ $# -eq 0 ] ; then
  all_testcases
fi

while [ $# -ge 1 ] 
 do
  case "$1" in
  -h)
     proc_help
     exit 0
     ;;
  -k)
     no_cleanup=1
     shift
     ;;
  -l)
     LOG=1
     shift
     if [ $# -eq 0 ] ; then
       all_testcases
     fi
     ;;
  1|2|3|4|5|6|7|8|9|10|11|12|13|14|15|16|17|20)
     testcase$1 
     shift
     ;;
  *)
     proc_help
     echo "unknown parameter(s), exiting gracefully ..."
     exit 0
     ;;
  esac
done

# clean up?
if [ $no_cleanup -eq 0 ] ; then
  cleanup
fi


