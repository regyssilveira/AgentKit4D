---
name: delphi-clean-code-solid
description: Diretrizes de SOLID, Clean Code e padrões de nomenclatura para classes, interfaces, métodos e variáveis em projetos Delphi.
---

# Princípios de Engenharia de Software, SOLID e Clean Code no Delphi

Estas diretrizes definem as boas práticas de legibilidade, responsabilidade e convenções de nomenclatura a serem seguidas rigorosamente.

## 1. Princípios SOLID e Clean Code

*   **S (Single Responsibility Principle)**: Interfaces e classes com responsabilidade única. Se uma classe faz consultas ao banco de dados e ao mesmo tempo desenha na tela, ela deve ser dividida.
*   **O (Open/Closed Principle)**: O código deve ser aberto para extensão, mas fechado para modificação. Use herança, interfaces ou composição para estender o comportamento de classes existentes.
*   **L (Liskov Substitution Principle)**: Classes derivadas devem poder substituir suas classes base sem quebrar o comportamento do sistema.
*   **I (Interface Segregation Principle)**: Prefira múltiplas interfaces específicas a uma única interface genérica complexa.
*   **D (Dependency Inversion Principle)**: Dependa de abstrações (interfaces), não de classes concretas. Utilize injeção de dependência via construtores para facilitar testes unitários e diminuir o acoplamento.
*   **Clean Code**: Nomes expressivos, curtos e autodocumentados para variáveis, funções e métodos. Rotinas pequenas e focadas em realizar uma única tarefa de forma excelente.
*   **DRY (Don't Repeat Yourself)**: Evitar duplicação lógica. Extraia rotinas redundantes para Helpers de classes/records, extension methods ou serviços utilitários bem isolados.
*   **KISS (Keep It Simple, Stupid)**: Priorize a simplicidade lógica. Evite superengenharia e padrões de projeto excessivos quando uma solução simples resolve o problema com clareza.

---

## 2. Nomenclatura Padronizada no Delphi

Para garantir consistência em todo o projeto, utilize os seguintes prefixos e regras de nomenclatura:

*   **Interfaces**: Sempre iniciam com a letra **`I`** em maiúsculo (ex: `IProjectService`, `IBoss4DLogger`).
*   **Classes**: Sempre iniciam com a letra **`T`** em maiúsculo (ex: `TProjectService`, `TMyController`).
*   **Argumentos / Parâmetros de Métodos**: Sempre iniciam com a letra **`A`** em maiúsculo (ex: `const AInstallSingle: string`, `const AConfig: TConfig`).
*   **Variáveis Locais**: Sempre iniciam com a letra **`L`** em maiúsculo (ex: `var LPkgPath: string`, `var LIndex: Integer`).
*   **Campos de Classe (Fields)**: Sempre iniciam com a letra **`F`** em maiúsculo (ex: `FNetClient: IAgentKitNetClient`).
*   **Enumerações (Tipos)**: Devem começar com o prefixo **`T`** (ex: `TMyEnum`) e seus membros com duas ou três letras que identifiquem o tipo (ex: `enumValue1` -> `evValue1`).
