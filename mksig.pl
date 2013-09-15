#<!-- -*- encoding: utf-8n -*- -->
use strict;
use warnings;
use utf8;

use Encode;
use Encode::JP;

use Data::Dumper;

use GD;
use GD::Text;

my $PI = 3.1415;
my $PI2 = $PI*2;

my %gOptions = ();
$gOptions{'font'} = "c:\\windows\\fonts\\msgothic.ttc";
$gOptions{'diameter'} = 100; # 直径
$gOptions{'angle'} = 18; # 罫線位置角度
$gOptions{'psize'} = $gOptions{'diameter'}/10; # 文字サイズ
$gOptions{'bcolor'} = 0xffffff; # background color. white
$gOptions{'fcolor'} = 0x000000; # front color. black
$gOptions{'o'} = 'tmp.png'; # output file.

print "mksig ver. 0.13.09.15.\n";
my $argv = getOptions(\@ARGV, \%gOptions); # オプションを抜き出す
my $args = @{$argv};
if( $args != 3 ){
	print  "Usage: mksig [options] <string1> <string2> <string3>\n";
	print  "  options : -font : absolute font path.($gOptions{'font'})\n";
	print  "          : -angle : angle.default is $gOptions{'angle'}.\n";
	print  "          : -diameter : diameter.default is $gOptions{'diameter'}.\n";
	print  "          : -psize : point font size. default is diameter/10.\n";
	print  "          : -o : output file.default is $gOptions{'o'}\n";
	printf "          : -fcolor : front color.default is 0x%x.\n", $gOptions{'fcolor'};
	printf "          : -bcolor : background color.default is 0x%x.\n", $gOptions{'bcolor'};
	print  "          : -dbg : debug mode.\n";
	print  "https://github.com/oya3/mksig\n";
    exit;
}

$gOptions{'font_path'} = $gOptions{'font'};
$gOptions{'font_path'} =~ s/^(.+)\\(.+)$/$1/;
$gOptions{'radius'} = $gOptions{'diameter'}/2;

my @gInString = ();
$gInString[0] = $argv->[0]; # 会社名
$gInString[1] = $argv->[1]; # 年月日
$gInString[2] = $argv->[2]; # 名前

printf ("font[%s]\n", $gOptions{'font'});
printf ("font_path[%s]\n", $gOptions{'font_path'});
printf ("diameter[%d]\n", $gOptions{'diameter'});
printf ("radius[%d]\n", $gOptions{'radius'});
printf ("angle[%d]\n", $gOptions{'angle'});
printf ("psize[%d]\n", $gOptions{'psize'});
printf ("fcolor[0x%x]\n", $gOptions{'fcolor'});
printf ("bcolor[0x%x]\n", $gOptions{'bcolor'});
printf ("o[%s]\n", $gOptions{'o'});

GD::Text->font_path($gOptions{'font_path'});

# my $diameter = 100; # 直径
# my $radius = $diameter/2; # 半径
# my $angle = 18; # 罫線位置
# my $psize = $diameter/10; # 文字サイズ
# my @inString = ("会社名", "年月日", "氏名");

# 新しいイメージを作成
my $im = new GD::Image( $gOptions{'diameter'}, $gOptions{'diameter'});
my $tmpim = new GD::Image( $gOptions{'diameter'}, $gOptions{'diameter'}); #tmp

# 色を確保
# １つ目は透過色となるので必ずbackgroundColorをallocateすること。
my $backgroundColor = $im->colorAllocate(($gOptions{'bcolor'}>>16)&0xff,
										 ($gOptions{'bcolor'}>> 8)&0xff,
										 ($gOptions{'bcolor'}&0xff));

my $frontColor = $im->colorAllocate(($gOptions{'fcolor'}>>16)&0xff,
									($gOptions{'fcolor'}>> 8)&0xff,
									($gOptions{'fcolor'}&0xff));


# 背景色を透明にし、インターレース化
$im->transparent($backgroundColor);
$im->interlaced('true');

# 円形を描画
$im->arc( $gOptions{'radius'}, $gOptions{'radius'}, # center
		  $gOptions{'diameter'}, $gOptions{'diameter'}, # width, height
		  0, 360, $frontColor);

my($sx1,$sy1) = getPos(    -$gOptions{'angle'}, $gOptions{'radius'});
my($ex1,$ey1) = getPos( 180+$gOptions{'angle'}, $gOptions{'radius'});

my($sx2,$sy2) = getPos(     $gOptions{'angle'}, $gOptions{'radius'});
my($ex2,$ey2) = getPos( 180-$gOptions{'angle'}, $gOptions{'radius'});

#print "$sx1,$sy1 - $ex1,$ey1\n";
#print "$sx2,$sy2 - $ex2,$ey2\n";
$im->line( $sx1+$gOptions{'radius'}, $sy1+$gOptions{'radius'},
		   $ex1+$gOptions{'radius'}, $ey1+$gOptions{'radius'}, $frontColor);
$im->line( $sx2+$gOptions{'radius'}, $sy2+$gOptions{'radius'},
		   $ex2+$gOptions{'radius'}, $ey2+$gOptions{'radius'}, $frontColor);

setString($gOptions{'radius'}, $sy1+$gOptions{'radius'}-2, $gInString[0], $frontColor);
setString($gOptions{'radius'}, $gOptions{'radius'}+$gOptions{'psize'}/2, $gInString[1], $frontColor);
setString($gOptions{'radius'}, $sy2+$gOptions{'radius'}+$gOptions{'psize'}+4, $gInString[2], $frontColor);

exportFile($im, $gOptions{'o'});

exit;

sub exportFile
{
	my ($im, $file) = @_;
	my $file_sjis = encode('cp932', $file);
	open( OUT, "> $file_sjis") or die( "Cannot open file: $file_sjis" );
	binmode OUT;
	print OUT $im->png();
	close OUT;
}

sub getOptions
{
	my ($argv,$options) = @_;
	my @newAragv = ();
	for(my $i=0; $i< @{$argv}; $i++){
		my $key = decode('cp932', $argv->[$i]);
		if( $key =~ /^-(font|angle|psize|diameter|o)$/ ){
			$options->{$1} = decode('cp932', $argv->[$i+1]);
			$i++;
		}
		elsif( $key =~ /^-(fcolor|bcolor)$/ ){
			my $key = $1;
			my $value = $argv->[$i+1];
			$value =~ s/^0x([0-9a-fA-F]+)$/$1/;
			$options->{$key} = hex($value);
			print "$key:$argv->[$i+1]\n";
			$i++;
		}
		elsif( $key =~ /^-(dbg)$/ ){
			$options->{$1} = 1;
		}
		else{
			push @newAragv, $key;
		}
	}
	return (\@newAragv);
}

sub getPos
{
	my ($angle, $radius) = @_;
	my $x = cos($PI2*$angle/360) * $radius;
	my $y = sin($PI2*$angle/360) * $radius;
	return ($x, $y);
}

sub setString
{
	my ($x, $y, $string, $color) = @_;
	my @res = $tmpim->stringTTF($color, $gOptions{'font'}, # color, font
								$gOptions{'psize'}, 0, 0, 0, # psize, angle, x, y,
								encode('utf-8',$string) );
	my $string_width = $res[2];
	my $string_height = abs($res[5]-$res[3]);
	$im->stringTTF($color, $gOptions{'font'},
				   $gOptions{'psize'}, 0, $x - $string_width/2, $y,
				   encode('utf-8', $string) );
}
