OUTPUT_DIR=build

paper: paper.tex
	xelatex -quiet paper.tex --output-directory $(OUTPUT_DIR)
	bibtex -quiet build/paper
	xelatex -quiet paper.tex --output-directory $(OUTPUT_DIR)
	xelatex -quiet paper.tex --output-directory $(OUTPUT_DIR)
	@echo "BUILD SUCCESS!"

watch:
	watchexec -r -c -e tex make paper

release:
	python3 cicd.py ./build/paper.pdf

clean:
	rm -rf ./build/*
