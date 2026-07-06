---
name: delphi-multitarget-compilation
description: Compilação e builds multiplataforma (Win32 e Win64), cobertura de código e boas práticas de scripts de automação.
---

# Compilação e Builds Multiplataforma (Win32 e Win64) no Delphi

Estas diretrizes definem as regras para compilação robusta de projetos e automação de builds locais ou em pipelines de CI/CD.

## 1. Compatibilidade Multiplataforma (Win32 e Win64)
*   Sempre valide o build e execute a suíte de testes unitários em ambas as plataformas Win32 e Win64 utilizando os respectivos compiladores de linha de comando (`dcc32` e `dcc64`).

---

## 2. Cobertura de Código Estável (WoW64)
*   Dê preferência à execução e geração de relatórios de cobertura de código no ambiente x64 (Win64).
*   Sistemas operacionais Windows modernos possuem restrições na camada WoW64 para hooks de depuração de processos 32-bit, o que pode resultar em relatórios contendo 0% de cobertura no x86.

---

## 3. Invocação em Lote (Scripts Batch/CMD)
*   Ao escrever scripts `.bat` ou `.cmd` para Windows que executem o compilador Delphi (`dcc32` / `dcc64`) ou outras ferramentas de linha de comando, sempre preceda as chamadas com o comando `call` (ex: `call dcc32 ...`).
*   Caso contrário, o interpretador de lote do Windows encerrará a execução imediatamente após o encerramento do primeiro comando, impedindo que as tarefas subsequentes sejam executadas.
