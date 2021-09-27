
CHROM=$1
INFILE=$2

awk -v chrom=$CHROM '
	/^a/ {seq=0}
	/^s/ {seq++}
	/^s/ && seq==2 {
		n[$2]+=length($7); 
		tot+=length($7);
		seq++
	} 
	END {
		for(i in n) printf("%s\t%s\t%d\t%.4f\n",chrom, i,n[i], n[i]/tot)
	}
' $INFILE | sort -n -b -r -k 3