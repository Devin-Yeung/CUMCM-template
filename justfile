set windows-shell := ["powershell.exe", "-c"]
set shell := ["bash", "-c"]

set dotenv-load # load env variable from .env

FILE := "paper"
OUTDIR := env_var_or_default('OUTDIR', "build")
DEBUG := env_var_or_default('DEBUG', "false")
PDFLATEX_EXTRA_ARGS := ""

@all:
	echo "Compiling TeX Files..."
	just xelatex {{ PDFLATEX_EXTRA_ARGS }}
	just xelatex {{ PDFLATEX_EXTRA_ARGS }}
	just bibtex
	just xelatex {{ PDFLATEX_EXTRA_ARGS }}
	echo "Compilation SUCCESS"

@lite:
	echo "Compiling TeX Files..."
	just xelatex {{ PDFLATEX_EXTRA_ARGS }}
	echo "Compilation SUCCESS"

[windows]
clean:
	Get-ChildItem -Path {{ OUTDIR }} -Include \
	*.zip,*.aux,*.log,*.out,*.toc,*synctex.gz,*.bbl,*.blg \
	-Recurse | ForEach-Object {Remove-Item $_.FullName}

[unix]
clean:
	#!/usr/bin/env bash
	extensions=(".zip" ".aux" ".log" ".out" ".toc" "synctex.gz" ".bbl" ".blg")
	for ext in "${extensions[@]}"; do
		find {{ OUTDIR }} -name "*$ext" -delete
	done

watch task:
	watchexec           \
	-c                  \
	-r                  \
	-e tex,cls,sty      \
	--no-vcs-ignore     \
	--no-project-ignore \
	just {{ task }}

[unix]
cmp old=('HEAD~1') new=('HEAD'):
	git-latexdiff --new {{ new }} --old {{ old }} --output {{ OUTDIR }}

[windows]
cmp old=('HEAD~1') new=('HEAD'):
	scripts/bin/git-latexdiff.exe --new {{ new }} --old {{ old }} --output {{ OUTDIR }}

[unix]
[private]
xelatex *args:
	if {{ DEBUG }}; then \
	xelatex -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex; \
	fi
	@xelatex -interaction=nonstopmode -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex > /dev/null; \

[unix]
[private]
@bibtex *args:
	bibtex {{ OUTDIR }}/{{ FILE }} > /dev/null

[windows]
[private]
@xelatex *args:
	if (${{ DEBUG }}) { xelatex -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex } \
	else { xelatex -interaction=nonstopmode -synctex=1 -output-directory={{ OUTDIR }} {{ args }} {{ FILE }}.tex | out-null }

[windows]
[private]
@bibtex *args:
	bibtex {{ OUTDIR }}/{{ FILE }} | out-null