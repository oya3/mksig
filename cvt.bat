rem perl mksig.pl -o default.png "oya3" "2013/9/15" "OYA"

perl mksig.pl -o red.png -diameter 400 -fcolor 0xff0000 "会社名" "2013/9/15" "表示 機能"
perl addpic_xls.pl red.png Book1.xls Sheet1 0 0 100 100
