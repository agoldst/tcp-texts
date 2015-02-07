
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

generated/ecco-text.tsv: generated/ecco-headers.csv
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



# Bookworm related stuff goes here.

cleanworm:
	-rm -r tcpworm/files/metadata
	-rm -r tcpworm/files/targets

tcpworm:
	git clone git@github.com:Bookworm-Project/BookwormDB $@

tcpworm/files/metadata/jsoncatalog.txt: tcpworm generated/ecco-headers.csv
	mkdir -p tcpworm/files/metadata
	mkdir -p tcpworm/files/texts
	python bookworm_prep/create_catalog.py > $@

tcpworm/files/metadata/field_descriptions.json: field_descriptions.json
	cp $< $@

bookwormBuilt: tcpworm/files/metadata/jsoncatalog.txt tcpworm/files/metadata/field_descriptions.json
	cd tcpworm; make textStream="cat ../generated/ecco-text.tsv"

jsoncatalog.txt:
	python bookworm_prep/create_catalog.py

malletCatalog:
	mkdir tcpworm/extensions
	git clone git@github.com:bmschmidt/Bookworm-Mallet tcpworm/extensions/mallet
	cd tcpworm/extensions/mallet; make



.DEFAULT_GOAL: test

.PHONY: ecco_hdr ecco_xml test eebo_xml
