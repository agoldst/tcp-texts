
# ecco TCP material from http://www.textcreationpartnership.org/docs/texts/ecco_files.html

test:
	echo "No tests."

ecco_root := ecco-tcp
ecco_headers := $(ecco_root)/headers.ecco

ecco_hdr:
	curl http://www.lib.umich.edu/tcp/docs/texts/ecco/headers.ecco.zip \
	    -o $(ecco_headers).zip
	mkdir -p $(ecco_headers)
	unzip -d $(ecco_headers) $(ecco_headers).zip

generated/ecco-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py -h $(ecco_headers)/* > $@

ecco_xml_zip := xml-200510.ecco.zip xml-200601.ecco.zip xml-200604.ecco.zip xml-200609.ecco.zip xml-200702.ecco.zip xml-200802.ecco.zip xml-200809.ecco.zip xml-200902.ecco.zip xml-200909.ecco.zip xml-201004.ecco.zip xml-201106.ecco.zip

ecco_xml_dir := $(ecco_root)/xml

$(ecco_xml_zip): %.zip:
	curl http://www.lib.umich.edu/tcp/docs/texts/ecco/$< \
	    -o $(ecco_root)/$<

ecco_xml: $(ecco_xml_zip)
	mkdir -p $(ecco_xml_dir)
	for z in $(ecco_xml_zip) ; do \
	    unzip -o -d $(ecco_xml_dir) $$z; \
	    done

generated/ecco-text.tsv:
	python tcp_xml2tsv.py -h $(ecco_xml_dir) > $@

# eebo tcp material has to be downloaded by hand at https://umich.app.box.com/s/nfdp6hz228qtbl2hwhhb
# I have used the P5_snapshot_201501 and headers directories

eebo_root := eebo-tcp1/headers/header_temp
generated/eebo-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py -h $(eebo_root) > $@

eebo_xml_zip := $(wildcard eebo-tcp1/P5_snapshot_201501/*.zip)
eebo_xml_dir := eebo-tcp1/P5_snapshot_201501/xml

eebo_xml: $(eebo_xml_zip)
	mkdir -p $(eebo_xml_dir)
	for z in $(eebo_xml_zip) ; do \
	    unzip -o -d $(eebo_xml_dir) $$z; \
	    done

generated/eebo-text.tsv:
	python tcp_xml2tsv.py -h $(eebo_xml_dir) > $@

.DEFAULT_GOAL: test

.PHONY: ecco_hdr ecco_xml test eebo_xml
