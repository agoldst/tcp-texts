
generated/ecco-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py -h ecco-tcp/headers.ecco/* > $@

eebo_root := eebo-tcp1/headers/header_temp
generated/eebo-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py -h $(eebo_root) > $@
