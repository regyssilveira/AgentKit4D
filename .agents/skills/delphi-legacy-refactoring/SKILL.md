---
name: delphi-legacy-refactoring
description: Refatoração incremental de código legado, desacoplamento de interfaces visuais, remoção de estado global e migração Unicode.
---

# Diretrizes para Código Legado e Refatoração Incremental no Delphi

Estas diretrizes fornecem abordagens arquiteturais para modernizar e testar sistemas Delphi acoplados, reduzindo o risco de regressões.

## 1. Desacoplamento de UI (Padrão Humble Object)
*   **Segregação Estrita**: É proibido codificar regras de negócio, cálculos, validações ou queries de banco de dados diretamente em Units de componentes visuais (`TForm`, `TFrame`, `TDataModule`).
*   **Abstração**: A tela deve atuar apenas como uma casca de apresentação ("Humble Object"). Todo evento de clique ou interação do usuário deve delegar a execução imediatamente para classes de serviço puro (`TMyService`), controllers ou presenters que não dependam da interface gráfica.

---

## 2. Testabilidade e Desacoplamento Incremental
*   **Interfaces de Abstração**: Se uma classe legada não pode ser testada de forma isolada (ex: acoplamento rígido a banco de dados global ou APIs de terceiros), crie uma interface (`IServiceGateway`, `IRepository`) para isolar a dependência e injetar um mock no teste de unidade.
*   **Testes de Caracterização**: Antes de alterar uma rotina legada complexa e sem cobertura, escreva testes de unidade para caracterizar seu comportamento atual (registrando as entradas e saídas reais observadas). Isso blinda o sistema contra alterações acidentais de comportamento (regressões) durante a refatoração.

---

## 3. Conformidade de Migração Unicode (Delphi XE+)
*   **Comprimento em Char vs Bytes**: Nunca assuma que o comprimento em caracteres (`Length`) é equivalente ao tamanho do buffer em bytes ao lidar com manipulação direta de memória.
*   **Buffers e Encodings**: Use o tipo `PByte` ou `RawByteString` exclusivamente para o tráfego de dados binários brutos. Para conversões e leituras de arquivos/streams, explicite o encoding usando a classe `TEncoding` (ex: `TEncoding.UTF8`, `TEncoding.ANSI`). Evite casts implícitos de string que causem perda irreversível de caracteres.

---

## 4. Eliminação de Estado Global e Singletons
*   **Injeção de Dependência**: Evite a criação de novas variáveis globais em seções `var` de interface. Passe as dependências necessárias de forma explícita através de parâmetros no construtor da classe (`Constructor Injection`).
*   **Instanciação Controlada**: Evite que as classes dependam diretamente de instâncias estáticas globais (ex: `DataModuleConexao.FDConnection`). Crie instâncias isoladas ou passe a conexão como parâmetro, assegurando que múltiplos testes unitários possam ser executados concorrentemente em threads separadas sem colisão de estado.
