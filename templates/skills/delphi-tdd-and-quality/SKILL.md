---
name: delphi-tdd-and-quality
description: Desenvolvimento Orientado a Testes (TDD), escrita de testes unitários DUnitX e correções de bugs no Delphi.
---

# Qualidade de Código e Desenvolvimento Orientado a Testes (TDD) no Delphi

Estas diretrizes determinam que nenhuma linha de código, nova funcionalidade ou correção de bug seja introduzida sem testes correspondentes.

## 1. Fluxo Geral de TDD (Novas Funcionalidades)
Siga estritamente o ciclo clássico de TDD:
1.  **Escrever o Caso de Teste (Fase Red)**: Antes de codificar qualquer lógica de produção, escreva o teste unitário (utilizando DUnitX) que represente o requisito. Execute a suíte e garanta que o novo teste falhe.
2.  **Codificar a Solução (Fase Green)**: Implemente a lógica de produção estritamente necessária para fazer com que o novo teste passe com sucesso.
3.  **Refatorar o Código (Fase Refactor)**: Refatore o código implementado seguindo os princípios de Clean Code, DRY e KISS, garantindo que toda a suíte de testes continue passando (100% de sucesso).

---

## 2. Correção Orientada a Testes (TDD para Bugs)
Todo bug encontrado ou reportado deve seguir obrigatoriamente a técnica de correção orientada a testes de regressão:
1.  **Mapear o Cenário**: Compreender o bug e identificar os dados e o fluxo onde ele ocorre.
2.  **Escrever o Teste de Regressão**: Criar um caso de teste na suíte correspondente que reproduza fielmente o cenário do bug. O teste deve falhar.
3.  **Corrigir o Bug**: Somente após o teste ter sido validado como falho, implementar a correção lógica no código de produção.
4.  **Validar a Correção**: Executar a suíte de testes e garantir que o novo teste (e os antigos) passem com sucesso absoluto.

---

## 3. Peculiaridades de DUnitX e Compilação
*   **Inferência de Genéricos no DUnitX (`Assert.AreEqual`)**: Para garantir portabilidade de testes e evitar falhas silenciosas ou de inferência em compilações de 64 bits (Win64), explicite o tipo genérico na chamada das assertivas (ex: `Assert.AreEqual<string>`, `Assert.AreEqual<Integer>`). A inferência automática do compilador Delphi x64 pode falhar em assinaturas genéricas com sobrecargas de tipos complexos.
