
# ecco TCP material from http://www.textcreationpartnership.org/docs/texts/ecco_files.html

test:
	echo "No tests."

ecco_headers := ecco-tcp/headers.ecco

ecco_hdr:
	mkdir -p $(ecco_headers)
	curl -Lo $(ecco_headers).zip \
		http://www.lib.umich.edu/tcp/docs/texts/ecco/headers.ecco.zip
	unzip -d $(ecco_headers) $(ecco_headers).zip

generated/ecco-headers.csv:
	mkdir -p generated
	python tcp_hdr2csv.py -h $(ecco_headers)/* > $@

ecco_xml_zip := ecco-tcp/xml-200510.ecco.zip ecco-tcp/xml-200601.ecco.zip ecco-tcp/xml-200604.ecco.zip ecco-tcp/xml-200609.ecco.zip ecco-tcp/xml-200702.ecco.zip ecco-tcp/xml-200802.ecco.zip ecco-tcp/xml-200809.ecco.zip ecco-tcp/xml-200902.ecco.zip ecco-tcp/xml-200909.ecco.zip ecco-tcp/xml-201004.ecco.zip ecco-tcp/xml-201106.ecco.zip

ecco_xml_dir := ecco-tcp/xml

ecco-tcp/%.zip:
	curl -Lo $@ \
	    http://www.lib.umich.edu/tcp/docs/texts/ecco/$*

ecco_xml: $(ecco_xml_zip)
	mkdir -p $(ecco_xml_dir)
	for z in $(ecco_xml_zip) ; do \
	    unzip -o -d $(ecco_xml_dir) $$z; \
	    done

generated/ecco-text.tsv:
	python tcp_xml2tsv.py -h $(ecco_xml_dir) > $@

# eebo tcp material has to be downloaded by hand at https://umich.app.box.com/s/nfdp6hz228qtbl2hwhhb
# I have used the P5_snapshot_201501 and headers directories

eebo_root := eebo-tcp1
eebo_hdr_dir := $(eebo_root)/headers
eebo_hdr_extracted := $(eebo_hdr_dir)/header_temp

eebo_hdrs: $(eebo_root)/headers.zip
	mkdir -p $(eebo_hdr_dir)
	unzip -o -d $(eebo_root) $(eebo_root)/headers.zip
	for z in $(eebo_hdr_dir)/*.tgz ; do \
	    tar -C $(eebo_hdr_dir) -xzvf $$z; \
	    done

generated/eebo-headers.csv: eebo_hdrs
	mkdir -p generated
	python tcp_hdr2csv.py -h $(eebo_hdr_extracted) > $@

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

.PHONY: ecco_hdr ecco_xml test eebo_xml eebo_hdrs
