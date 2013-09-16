use strict;
use warnings;
use utf8;

use Encode;
use Encode::JP;

use Data::Dumper;

use Cwd;
use File::Find;

use Win32::OLE qw(in with);
use Win32::OLE::Const 'Microsoft Excel';
use Win32::OLE::Const 'Microsoft Word';
use Win32::OLE::Variant; # excel 日付 データを読み出すため
$Win32::OLE::Warn = 3; # die on errors...

# ファイル入出力を制御する
use open IN  => ":encoding(cp932)";
use open OUT => ":encoding(cp932)";
# 標準入出力を制御する
binmode STDIN, ':encoding(cp932)';
binmode STDOUT, ':encoding(cp932)';
binmode STDERR, ':encoding(cp932)';

my %gOptions = ();

print "addpic version 0.2013.09.15\n";
my $argv = getOptions(\@ARGV, \%gOptions); # オプションを抜き出す
my $args = @{$argv};
if( $args != 7 ){
	print  "Usage: addpic_xls [options] <pic path> <xls path> <sheet name> <x> <y> <width> <height>\n";
	print  "  options : -dbg : debug mode.\n";
	print  "https://github.com/oya3/mksig\n";
    exit;
}
my %gInParams = ();
$gInParams{'pic_path'} = getAbsolutePath($argv->[0]);
$gInParams{'xls_path'} = getAbsolutePath($argv->[1]);
$gInParams{'sheet_name'} = $argv->[2];
$gInParams{'x'} = $argv->[3];
$gInParams{'y'} = $argv->[4];
$gInParams{'width'} = $argv->[5];
$gInParams{'height'} = $argv->[6];

#print Dumper(\%gInParams);

addPicture(\%gInParams);

exit;

sub getOptions
{
	my ($argv,$options) = @_;
	my @newAragv = ();
	for(my $i=0; $i< @{$argv}; $i++){
		my $key = decode('cp932', $argv->[$i]);
		if( $key =~ /^-(none)$/ ){
			$options->{$1} = decode('cp932', $argv->[$i+1]);
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

sub addPicture
{
	my ($inParams) = @_;
	my $file = $inParams->{'xls_path'};
	$file =~ tr/\//\\/;
	my $file_sjis = encode('cp932', $file);
	my $excel = undef;
	my $book = undef;
	
	eval{
		$excel = Win32::OLE->GetActiveObject('Excel.Application') || Win32::OLE->new('Excel.Application', 'Quit');
		$book = $excel->Workbooks->Open( { 'FileName' => $file_sjis } );
		$excel->{DisplayAlerts} = 'False';
		my $sheet = $book->Worksheets( decode('cp932', $inParams->{'sheet_name'}) );
		$sheet->Shapes->AddPicture( encode('cp932', $inParams->{'pic_path'}), 0, 1,
									$inParams->{'x'},$inParams->{'y'}, $inParams->{'width'}, $inParams->{'height'});
		if( $excel->{Version} < 12 ) {
			$book->SaveAs( $file_sjis, xlExcel9795  ); 
		}
		else{
			$book->SaveAs( $file_sjis, xlWorkbookNormal  ); # office2007だと xlExcel9795 はどうも利用できないらしい。互換モードで保存するなら xlWorkbookNormal とするべきのようである。
		}
	};
	if( $@ ){
		print decode('cp932', $@."\n");
	}
	if( $book ){
		$book->Close;
	}
	if( $excel ){
		$excel->Quit();
	}
}

sub getAbsolutePath
{
	my ($path) = @_;
	if( $path !~ /^[A-Z]\:/ ){
		my $currentPath = decode('cp932', Cwd::getcwd()); # decode cp932 は必要
		$path = $currentPath.'/'.$path;
	}
	return $path;
}

