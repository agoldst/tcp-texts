
generated/ecco-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py ecco-tcp/headers.ecco/* > $@

