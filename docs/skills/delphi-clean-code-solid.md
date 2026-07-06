# Manual de SOLID e Clean Code no Delphi

Este manual descreve as diretrizes de design, padrões de nomenclatura, controle de complexidade e boas práticas arquiteturais do Delphi para manter a base de código legível, limpa e de fácil manutenção futura.

---

## 1. Regras de Nomenclatura e Prefixos
No desenvolvimento Delphi, os prefixos são fundamentais para que desenvolvedores e compiladores identifiquem a natureza dos tipos rapidamente:

*   **`T` para Classes e Records**: Todas as classes e registros devem começar com a letra `T` (ex: `TUserService`, `TCustomerRecord`).
*   **`I` para Interfaces**: Todas as declarações de interface devem iniciar com a letra `I` (ex: `IUserRepository`).
*   **`F` para Atributos Privados (Fields)**: Variáveis de escopo privado em classes devem iniciar com a letra `F` e usar camelCase (ex: `FconnectionString`, `FactiveTask`).
*   **`A` para Argumentos/Parâmetros**: Parâmetros de métodos e funções devem começar com `A` (ex: `procedure Save(const ACustomer: TCustomer)`).
*   **`L` para Variáveis Locais**: Variáveis declaradas internamente a métodos e funções (bloco `var` local) devem começar com `L` (ex: `var LQuery: TFDQuery;`).

---

## 2. Princípios SOLID Aplicados ao Delphi

### S - Single Responsibility Principle (Princípio da Responsabilidade Única)
Uma classe deve ter apenas uma única razão para mudar. Evite criar "God Classes" que misturam persistência, regras de negócio e validação.

*   **Incorreto**: Um controlador HTTP que faz a consulta SQL diretamente no banco de dados e formata o JSON de saída.
*   **Correto**:
    *   `TUserController`: Recebe a requisição HTTP.
    *   `TUserService`: Executa as validações de negócio de usuário.
    *   `TUserRepository`: Realiza as operações de banco de dados (FireDAC).

### O - Open/Closed Principle (Princípio Aberto/Fechado)
Módulos e classes devem estar abertos para extensão, mas fechados para modificação.
*   Utilize herança ou composição e interfaces para permitir que novas regras de comportamento sejam adicionadas sem alterar a classe base.

### L - Liskov Substitution Principle (Princípio da Substituição de Liskov)
Classes derivadas devem poder ser substituídas por suas classes bases sem alterar o comportamento correto do sistema.
*   Não lance exceções de "método não implementado" (`ENotImplemented`) em subclasses que herdam comportamentos de classes abstratas. Se a subclasse não executa a ação, a abstração está incorreta.

### I - Interface Segregation Principle (Princípio da Segregação de Interfaces)
Muitas interfaces específicas são melhores do que uma única interface genérica de uso geral.
*   Em vez de declarar uma interface `ICrudRepository` com 10 métodos, prefira segregar em interfaces menores, como `IReadOnlyRepository` e `IWriteOnlyRepository`.

### D - Dependency Inversion Principle (Princípio da Inversão de Dependência)
Dependa de abstrações (interfaces), não de implementações concretas (classes).
*   Não instancie dependências de banco de dados diretamente dentro do construtor de classes de serviço. Injete-as por construtor através de interfaces:

```delphi
// Correto: Dependência injetada por construtor usando interface
constructor TUserService.Create(const ARepository: IUserRepository);
begin
  FRepository := ARepository;
end;
```

---

## 3. Namespaces e Estrutura de Units
Em projetos Delphi corporativos modernos, organize os nomes físicos dos arquivos e unidades usando **namespaces pontuados**, refletindo a arquitetura lógica do sistema.
*   **Regra**: O nome da unit deve seguir o padrão `[NomeDaEmpresa].[Projeto].[Camada].[Funcionalidade]`.
*   **Vantagens**: Isso evita a colisão de nomes de arquivos em grandes projetos e melhora sensivelmente a legibilidade das cláusulas `uses` e a localização física dos arquivos.
*   **Exemplos**:
    *   `MeuApp.Controller.Customer.pas`
    *   `MeuApp.Domain.Customer.Repository.pas`
    *   `MeuApp.Infra.Customer.Repository.pas`

---

## 4. Limites Físicos de Complexidade (Clean Code)
Manter arquivos e rotinas curtos é uma das maneiras mais eficientes de combater a complexidade ciclomática e garantir a testabilidade do código:
*   **Tamanho de Métodos**: Evite criar rotinas com mais de **50 a 80 linhas** de código funcional. Rotinas longas costumam acumular mais de uma responsabilidade. Extraia trechos de código para métodos auxiliares privados.
*   **Tamanho de Arquivos**: Classes e unidades não devem conter mais de **500 a 1000 linhas**. Se o arquivo for maior do que isso, ele deve ser dividido para seguir o SRP (Single Responsibility Principle).

---

## 5. Tratamento de Exceções Seguro (Sem Swallowing)
Capturar erros silenciosamente ("Exception swallowing" ou abafar o erro) mascara bugs sérios e dificulta muito a manutenção corretiva em ambientes produtivos.
*   **Regra de Ouro**: **NUNCA** silencie exceções com blocos `try except end` vazios ou que não registrem logs.
*   **Correto**: Em caso de erros, registre o log detalhado contendo a classe do erro e a stack trace (se disponível) e relance a exceção ou a encapsule em uma exceção de negócio personalizada para que a falha não passe despercebida pelas camadas superiores.

```delphi
try
  LQuery.Open;
except
  on E: Exception do
  begin
    Log.Error('Falha ao executar query: ' + E.Message);
    raise EDatabaseException.Create('Erro interno de acesso aos dados.', E);
  end;
end;
```

---

## 6. Isolamento Estrito de UI (Humble Object)
As janelas de visualização (Forms, Frames e DataModules de tela) devem ser tratadas sob o padrão **Humble Object** (cascas simples de apresentação).
*   **Regra de Ouro**: É proibido codificar regras de negócio, queries de banco de dados ou validações diretamente nos eventos dos componentes de tela (como `OnClick`, `OnShow`, `OnKeyPress`).
*   **Como Resolver**: Os eventos de componentes visuais devem limitar-se a capturar as variáveis de entrada, repassá-las imediatamente para uma classe de serviço ou controller desacoplada de negócio e, posteriormente, atualizar a interface com o resultado da resposta.

---

## 7. Boas Práticas Gerais
*   **Evite Estado Global**: Variáveis globais em units (`var` na seção `interface` ou `implementation`) causam acoplamento oculto e dificultam testes unitários paralelos. Prefira encapsular o estado dentro de instâncias de classes gerenciadas.
*   **Nomes Descritivos**: Nomes de métodos devem ser verbos descritivos do comportamento (ex: `RegisterCustomer` em vez de `DoProcessCustomer`).
*   **Parâmetros Limpos**: Evite assinaturas de métodos com mais de 3 ou 4 parâmetros. Se necessário, agrupe parâmetros em uma estrutura de record ou classe de configuração (DTO).
*   **Fail-Fast (Validações Prematuras)**: Valide os argumentos de entrada logo no início do método. Se um parâmetro for inválido, lance uma exceção imediatamente, poupando processamento e mantendo a indentação do código principal mais limpa.
