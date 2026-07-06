# Manual de SOLID e Clean Code no Delphi

Este manual descreve as diretrizes de design, padrões de nomenclatura e boas práticas arquiteturais do Delphi para manter a base de código legível, limpa e de fácil manutenção futura.

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

## 3. Boas Práticas Gerais de Código Limpo

*   **Evite Estado Global**: Variáveis globais em units (`var` na seção `interface` ou `implementation`) causam acoplamento oculto e dificultam testes unitários paralelos. Prefira encapsular o estado dentro de instâncias de classes gerenciadas.
*   **Nomes Descritivos**: Nomes de métodos devem ser verbos descritivos do comportamento (ex: `RegisterCustomer` em vez de `DoProcessCustomer`).
*   **Parâmetros Limpos**: Evite assinaturas de métodos com mais de 3 ou 4 parâmetros. Se necessário, agrupe parâmetros em uma estrutura de record ou classe de configuração (DTO).
*   **Fail-Fast (Validações Prematuras)**: Valide os argumentos de entrada logo no início do método. Se um parâmetro for inválido, lance uma exceção imediatamente, poupando processamento e mantendo a indentação do código principal mais limpa.
