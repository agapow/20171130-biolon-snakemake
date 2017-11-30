EXE=/homes/pagapow/.linuxbrew/bin/rst2pdf
INFILE=intro-to-snakemake.rst
STYLES=styles.json
STYLES_MIN=styles.min.json
BACKGROUND_SRC=images/background.svg
BACKGROUND=images/background.png
FONT_PATH=/usr/share/fonts/truetype

default: intro-to-snakemake.pdf

$(BACKGROUND): $(BACKGROUND_SRC)
	convert -density 1200 $(BACKGROUND_SRC) $(BACKGROUND)

$(STYLES_MIN): $(STYLES)
	jsmin < $(STYLES) > $(STYLES_MIN)

intro-to-snakemake.pdf: $(INFILE) $(STYLES_MIN) $(BACKGROUND)
	$(EXE) -b 1 $(INFILE) -s $(STYLES_MIN) --fit-literal-mode=truncate
