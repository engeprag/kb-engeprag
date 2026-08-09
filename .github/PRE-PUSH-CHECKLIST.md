# Checklist de Verificacao Pre-Push

> **OBRIGATORIO**: Verificar TODOS os itens antes de fazer push para o GitHub.
> Este repositorio e PUBLICO - qualquer informacao pode ser vista por concorrentes.

---

## 1. Verificacao de Conteudo Sensivel

### NUNCA inclua no repositorio publico:

- [ ] **Estrategias de SEO** - Keywords alvo, planos de posicionamento, analises de ranking
- [ ] **Analise competitiva** - Nomes de concorrentes especificos, gaps identificados, vulnerabilidades
- [ ] **Precos e margens** - Tabelas de precos, margens de lucro, estrutura de custos internos
- [ ] **Credenciais de acesso** - Senhas, tokens, chaves de API, acessos FTP/SSH
- [ ] **Informacoes internas** - Processos operacionais detalhados, formulas proprietarias
- [ ] **Dados de clientes** - Nomes, contratos, enderecos, valores pagos
- [ ] **Metricas de negocio** - Faturamento, numero de clientes, taxas de conversao

### Verificar conteudo dos arquivos:

```bash
# Buscar palavras sensiveis
grep -rni "concorrent\|valeprag\|insetkan\|dedrex\|estrateg.*seo\|keyword.*alvo\|gap.*competi" .

# Buscar precos especificos
grep -rni "R\$.*[0-9]\|preco.*real\|margem.*%" .

# Buscar credenciais
grep -rni "senha\|password\|token\|api.*key\|ftp\|ssh.*@" .
```

---

## 2. Verificacao de Commits

### NUNCA inclua nas mensagens de commit:

- [ ] **Referencias a ferramentas de IA** - Claude, ChatGPT, Anthropic, OpenAI, etc.
- [ ] **Co-Authored-By de IA** - Remover qualquer co-autoria de assistentes de IA
- [ ] **Links para ferramentas** - claude.com, openai.com, anthropic.com

### Verificar historico antes do push:

```bash
# Verificar mensagens de commit
git log --format="%B" | grep -i "claude\|anthropic\|openai\|chatgpt\|co-authored"

# Se encontrar, reescrever historico (ver secao 5)
```

---

## 3. Verificacao de Arquivos

### Arquivos que NUNCA devem estar no repositorio:

- [ ] `.env` - Variaveis de ambiente
- [ ] `*.credentials` - Arquivos de credenciais
- [ ] `*-ESTRATEGIA-*.md` - Documentos de estrategia
- [ ] `*-COMPETITIV*.md` - Analises competitivas
- [ ] `*-PRECO*.md` - Tabelas de precos
- [ ] `CREDENCIAIS-*.md` - Credenciais de acesso

### Verificar .gitignore:

```bash
# Garantir que .gitignore inclui:
cat .gitignore | grep -E "\.env|credentials|estrategia|competitiv|preco"
```

---

## 4. Conteudo Permitido (OK para repositorio publico)

### Pode incluir:

- [x] **Diferenciais publicos** - Certificacoes, garantias, qualificacoes da equipe
- [x] **Informacoes educativas** - Artigos sobre pragas, prevencao, legislacao
- [x] **Contatos publicos** - Telefone, email, endereco (ja no site)
- [x] **Comparacoes genericas** - "Concorrentes tipicos" sem nomes especificos
- [x] **Referencias a orgaos** - ANVISA, CREA, IBAMA, etc.

---

## 5. Como Corrigir Problemas

### Se encontrar informacao sensivel em arquivo:

```bash
# 1. Remover/editar o arquivo
# 2. Adicionar ao .gitignore se necessario
# 3. Commitar a correcao
git add .
git commit -m "fix: remove informacao sensivel"
```

### Se encontrar referencia ao Claude em commits:

```bash
# ATENCAO: Isso reescreve o historico!
# Fazer backup antes e informar colaboradores

# Opcao 1: Reescrever todos os commits (mais seguro)
git filter-branch --msg-filter '
  sed -e "s/.*Generated with.*Claude.*//g" \
      -e "s/Co-Authored-By:.*Claude.*//g" \
      -e "s/Co-Authored-By:.*Anthropic.*//g" \
      -e "/^$/d"
' --force HEAD

# Opcao 2: Usar git-filter-repo (mais moderno)
git filter-repo --message-callback '
  return message.replace(b"Generated with Claude Code", b"").replace(b"Co-Authored-By: Claude", b"")
'

# Depois: Force push (CUIDADO!)
git push origin main --force
```

---

## 6. Checklist Final Pre-Push

Antes de executar `git push`, confirme:

- [ ] Executei `grep` para palavras sensiveis e nao encontrei problemas
- [ ] Verifiquei `git log` e nao ha referencias a ferramentas de IA
- [ ] Todos os arquivos de estrategia estao fora do repositorio ou no .gitignore
- [ ] Nenhum dado de cliente ou preco especifico esta nos arquivos
- [ ] O conteudo e educativo/informativo, nao estrategico

---

## 7. Em Caso de Duvida

**PARE e consulte antes de fazer push!**

Se nao tem certeza se uma informacao pode ser publica:
1. Pergunte: "Um concorrente poderia usar isso para copiar nossa estrategia?"
2. Se a resposta for SIM ou TALVEZ -> NAO publique
3. Mantenha em repositorio privado ou local

---

## 8. Contatos para Duvidas

- **Responsavel pelo repositorio**: contato@engeprag.com.br
- **Questoes tecnicas**: Consultar equipe de TI

---

**Ultima atualizacao**: 2026-01-17
**Versao**: 1.0
