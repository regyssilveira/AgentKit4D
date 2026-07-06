---
name: delphi-ai-contract-design
description: Diretrizes para codificação guiada por IA, design baseado em contratos (Contract-First), validações prematuras e boas práticas de comentários.
---

# Diretrizes para Desenvolvimento Guiado por IA (AI-Driven Development) no Delphi

Estas regras definem o contrato de interação de IA neste repositório para garantir a geração de códigos Delphi corretos, robustos e fáceis de integrar.

## 1. Design Baseado em Contratos (Contract-First)
*   **Assinaturas Prévias**: Antes de escrever a lógica de execução de um método complexo, declare e valide os tipos de dados de entrada, retornos e as interfaces envolvidas. Garanta que a arquitetura do fluxo esteja sólida antes de preencher os corpos dos métodos.
*   **Validação de Parâmetros (Fail-Fast)**: Toda rotina pública exposta deve iniciar validando ativamente seus parâmetros de entrada (ex: testar se objetos obrigatórios estão `Assigned`, ou se strings necessárias não estão vazias) e lançar exceções descritivas imediatamente caso as pré-condições falhem.

---

## 2. Escrita de Código sem Atalhos ou Placeholders
*   **Código Completo**: Não sugira códigos parciais ou incompletos utilizando comentários vazivos como `// lógica de processamento aqui...`. Se for sugerir uma alteração ou criação de rotina, escreva-a integralmente para evitar erros de compilação ou indefinições.
*   **Refatorações Claras**: Ao propor modificações em código existente, apresente as alterações de forma explícita ou forneça blocos de diff completos e inequívocos.

---

## 3. Comentários Limpos e Intencionais
*   **Foco no "Porquê"**: Não insira comentários óbvios que simplesmente traduzam a sintaxe do Delphi (ex: evite `// Loop de 1 a 10` ou `// Construtor`).
*   **Documentação Arquitetural**: Use comentários de forma cirúrgica apenas para esclarecer decisões de design não-óbvias, contornos de bugs de terceiros (workarounds), limites de performance ou regras de negócio fiscais/organizacionais complexas.
