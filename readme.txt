機能：
電子印を作成する。3行版
Usage: mksig [options] <string1> <string2> <string3>
  options : -font : absolute font path.(c:\\windows\\fonts\\msgothic.ttc).
          : -angle : angle.default is 18.
          : -diameter : diameter.default is 200..
          : -psize : point font size. default is diameter/10.
          : -o : output file.default is tmp.png.
          : -fcolor : front color.default is 0x000000.
          : -bcolor : background color.default is 0xff0000.

エクセルに画像を挿入する。
Usage: addpic_xls [options] <pic path> <xls path> <sheet name> <x> <y> <width> <height>
  options : -dbg : debug mode.

動作確認：
windows 7(32,64)環境のみ

同梱内容：
mksig.pl
addpic_xls.pl
