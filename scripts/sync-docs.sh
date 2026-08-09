#!/usr/bin/env bash
#
# Gera o docs_dir do MkDocs a partir do conteúdo da raiz do repositório.
#
# POR QUE ISTO EXISTE
# -------------------
# O mkdocs.yml não define `docs_dir`, então o MkDocs usa o default `docs/` — é o
# conteúdo de `docs/` que vai para o GitHub Pages. E o MkDocs proíbe apontar
# `docs_dir` para a raiz (o diretório do config não pode ser o docs_dir), então
# não dá para simplesmente eliminar a pasta.
#
# Antes deste script o repositório mantinha DUAS cópias de cada arquivo de
# conteúdo — uma na raiz e outra em `docs/`. Editar só a raiz não publicava nada,
# e não havia nenhum aviso: o build passava, o deploy dava verde e o site
# continuava com o texto velho.
#
# Agora a raiz é a fonte única e `docs/` é gerado. Os arquivos gerados estão no
# .gitignore, então não há mais "a outra cópia" para esquecer.
#
# USO
#   ./scripts/sync-docs.sh          gera docs/
#   ./scripts/sync-docs.sh --check  falha se docs/ estiver desatualizado
#
set -euo pipefail
cd "$(dirname "$0")/.."

CHECK=0
[[ "${1:-}" == "--check" ]] && CHECK=1

# Arquivos de conteúdo na raiz do repo que também são páginas do site.
ARQUIVOS=(CHANGELOG.md CONCEPTS.md GLOSSARIO.md SOURCES.md TRUST.md
          ai.txt llms.txt llms-full.txt kb_index.json)

# Diretórios sincronizados por inteiro (o index.md deles é conteúdo, não navegação).
DIRS_COMPLETOS=(artigos normas)

# Diretórios cujo index.md existe SÓ no site (é página de seção, não conteúdo do
# repositório) e por isso é preservado em docs/ em vez de vir da raiz.
DIRS_SEM_INDEX=(faq servicos sobre-engeprag)

destino="docs"
if [[ $CHECK -eq 1 ]]; then
    destino="$(mktemp -d)"
    trap 'rm -rf "$destino"' EXIT
    # o --check compara contra uma cópia limpa do que docs/ deveria ser
    rsync -a --exclude='.*' docs/ "$destino/"
fi

for f in "${ARQUIVOS[@]}"; do
    cp "$f" "$destino/$f"
done

for d in "${DIRS_COMPLETOS[@]}"; do
    rsync -a --delete "$d/" "$destino/$d/"
done

for d in "${DIRS_SEM_INDEX[@]}"; do
    rsync -a --delete --exclude='index.md' "$d/" "$destino/$d/"
done

# Única divergência legítima entre as duas árvores: em `artigos/index.md` o link
# de visão geral aponta para o README do repositório, que não existe como página
# do site — lá a home é `index.md`. A reescrita acontece aqui, na cópia, para que
# não seja preciso manter dois arquivos editáveis só por causa de um link.
if [[ -f "$destino/artigos/index.md" ]]; then
    sed -i.bak 's#](\.\./README\.md)#](../index.md)#' "$destino/artigos/index.md"
    rm -f "$destino/artigos/index.md.bak"
fi

if [[ $CHECK -eq 1 ]]; then
    if diff -r --exclude='.*' "$destino" docs > /tmp/sync-docs-diff.txt 2>&1; then
        echo "✓ docs/ está sincronizado com a raiz"
    else
        echo "✗ docs/ está DESATUALIZADO em relação à raiz:"
        cat /tmp/sync-docs-diff.txt
        echo
        echo "  rode ./scripts/sync-docs.sh e commite o resultado"
        exit 1
    fi
else
    echo "✓ docs/ gerado a partir da raiz"
fi
