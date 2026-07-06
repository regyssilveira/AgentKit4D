---
name: delphi-clean-code-solid
description: Diretrizes de SOLID, Clean Code e padrões de nomenclatura para classes, interfaces, métodos e variáveis em projetos Delphi.
---

# Princípios de Engenharia de Software, SOLID e Clean Code no Delphi

Estas diretrizes definem as boas práticas de legibilidade, responsabilidade única, controle de complexidade e convenções de nomenclatura a serem seguidas rigorosamente.

---

## 1. Princípios SOLID e Clean Code

*   **S (Single Responsibility Principle)**: Interfaces e classes com responsabilidade única. Se uma classe realiza persistência em banco de dados e ao mesmo tempo desenha elementos na tela, ela deve ser dividida.
*   **O (Open/Closed Principle)**: Código aberto para extensão, mas fechado para modificação. Use herança, interfaces ou composição para estender o comportamento de classes existentes sem alterar sua base.
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
*   **Enumerações (Tipos)**: Devem começar com o prefixo **`T`** (ex: `TMyEnum`) e seus membros com duas ou três letras minúsculas que identifiquem o tipo (ex: `enumValue1` -> `evValue1`).

---

## 3. Namespaces e Estrutura de Units
Em projetos Delphi corporativos modernos, organize os nomes físicos dos arquivos e unidades usando **namespaces pontuados**, refletindo a arquitetura lógica do sistema:
*   **Padrão**: `[NomeDaEmpresa].[Projeto].[Camada].[Funcionalidade]`
*   **Exemplos**:
    *   `MeuApp.Controller.Customer.pas` (Unit de Controller)
    *   `MeuApp.Domain.Customer.Repository.pas` (Unit de Contrato de Domínio)
    *   `MeuApp.Infra.Customer.Repository.pas` (Unit de Infraestrutura)

---

## 4. Limites Físicos Saudáveis (Clean Code)
Para evitar a criação de "Classes Deus" (*God Classes*) e métodos gigantescos propensos a bugs e complexidade excessiva, respeite os seguintes limites físicos recomendados:
*   **Linhas por Rotina (Métodos/Funções)**: O ideal é manter rotinas curtas. Evite métodos com mais de **50 a 80 linhas** de código de execução. Se passar desse limite, refatore extraindo trechos lógicos para novos métodos privados.
*   **Linhas por Arquivo (Unit)**: Classes e unidades não devem conter mais de **500 a 1000 linhas**. Se uma unit ultrapassar esse limite, ela provavelmente possui mais de uma responsabilidade única e deve ser dividida.

---

## 5. Tratamento de Exceções Seguro (Sem Swallowing)
Capturar erros silenciosamente mascara problemas estruturais sérios em ambiente produtivo.
*   **Regra Estrita**: **NUNCA** silencie exceções com blocos `try except end` vazios ou sem logging/re-raise:
    ```pascal
    // INCORRETO: Silenciamento cego de exceção (Swallowing)
    try
      LQuery.Open;
    except
      // Abafa o erro silenciosamente
    end;

    // CORRETO: Tratar, registrar o log e relançar ou encapsular o erro
    try
      LQuery.Open;
    except
      on E: Exception do
      begin
        Log.Error('Falha ao abrir query: ' + E.Message);
        raise EDatabaseException.Create('Erro interno de acesso aos dados.', E);
      end;
    end;
    ```

---

## 6. Isolamento Estrito de UI (Humble Object)
As classes de interface de usuário (Forms VCL/FMX, Frames e DataModules de tela) devem ser tratadas estritamente sob o padrão **Humble Object** (cascas burras de apresentação).
*   **Regra Estrita**: É terminantemente proibido declarar lógica de regras de negócio, validações complexas ou queries diretas de banco de dados (FireDAC) nos manipuladores de eventos de componentes de tela (como `OnClick`, `OnShow`, `OnKeyPress`).
*   **Design Recomendado**: O evento da tela deve delegar imediatamente a execução para uma classe de serviço ou controller desacoplada, passando as variáveis necessárias como parâmetros.
