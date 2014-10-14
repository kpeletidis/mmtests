# ExtractDbench4
package MMTests::ExtractDbench4;
use MMTests::SummariseMultiops;
use VMR::Stat;
our @ISA = qw(MMTests::SummariseMultiops); 
use strict;

sub new() {
	my $class = shift;
	my $self = {
		_ModuleName  => "Dbench4",
		_DataType    => MMTests::Extract::DATA_MBYTES_PER_SECOND,
		_ResultData  => []
	};
	bless $self, $class;
	return $self;
}

sub extractReport($$$) {
	my ($self, $reportDir, $reportName) = @_;
	my @clients;

	my @files = <$reportDir/noprofile/dbench-*.log>;
	if ($files[0] eq "") {
		@files = <$reportDir/noprofile/tbench-*.log>;
	}
	foreach my $file (@files) {
		my @split = split /-/, $file;
		$split[-1] =~ s/.log//;
		push @clients, $split[-1];
	}
	@clients = sort { $a <=> $b } @clients;

	foreach my $client (@clients) {
		my $nr_samples = 0;
		my $file = "$reportDir/noprofile/dbench-$client.log";
		if (! -e $file) {
			$file = "$reportDir/noprofile/tbench-$client.log";
		}
		open(INPUT, $file) || die("Failed to open $file\n");
		while (<INPUT>) {
			my $line = $_;
			if ($line =~ /execute/) {
				my @elements = split(/\s+/, $_);

				$nr_samples++;
				push @{$self->{_ResultData}}, [ "mb/sec-$client", $nr_samples, $elements[3] ];

				next;
			}
		}
		close INPUT;
	}

	my @ops;
	foreach my $client (@clients) {
		push @ops, "mb/sec-$client";
	}

	$self->{_Operations} = \@ops;
}

1;
