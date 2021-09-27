

awk '
	/^a/ {seq=0} 
	/^s/ {
		seq++;
		if($5 == "-") {
			start = $6 - $3;
			end = start - $4;
		} else {
			start = $3;
			end = $3 + $4
		}
		printf("%s\t%d\t%d\t%s", $2, start, end, $5);
		if(seq == 1) printf("\t");
		else printf("\n");
	} 

' $1