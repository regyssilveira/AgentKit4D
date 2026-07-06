# Manual do Dext Framework no Delphi

Este manual apresenta as diretrizes de desenvolvimento com o **Dext Framework** (inspirado no ASP.NET Core), abrangendo o ciclo de injeção de dependências (DI), mapeamento do Dext ORM, criação de endpoints HTTP e testes unitários.

---

## 1. Ordem Crítica das Uses
O compilador Delphi permite apenas um class helper ativo por tipo de dado. Para garantir a disponibilidade de todos os métodos estendidos do framework, declare as units Dext exatamente nesta ordem de prioridade na cláusula `uses`:

1. `Dext`
2. `Dext.Entity` (se usar persistência ORM)
3. `Dext.Web` (**sempre por último**)

```delphi
uses
  Dext,
  Dext.Entity, // Opcional
  Dext.Web;    // Sempre por último
```

---

## 2. Injeção de Dependências (Dext DI)
O Dext gerencia automaticamente a injeção de dependências no construtor de classes cadastradas. Configure os serviços na classe de Startup:

*   **Transient** (`.AddTransient<I, T>`): Nova instância criada a cada requisição do serviço.
*   **Scoped** (`.AddScoped<I, T>`): Instância única persistida durante a execução daquela requisição Web.
*   **Singleton** (`.AddSingleton<I, T>`): Única instância compartilhada globalmente pela aplicação.

```delphi
// Injeção automática pelo construtor da classe de serviço
type
  TUserService = class(TInterfacedObject, IUserService)
  private
    FRepository: IUserRepository;
  public
    constructor Create(const ARepository: IUserRepository); // Injetado automaticamente
  end;
```

---

## 3. Mapeamento de Entidades no Dext ORM
Para mapear propriedades de banco de dados com eficiência e compatibilidade com consultas e ordenações (Order By), atente-se às convenções de tipos:

*   **Smart Types**: Utilize sempre os tipos `IntType`, `StringType`, `DoubleType` e `BoolType` em vez de `Prop<T>` clássicos para propriedades de coluna.
*   **Colunas Anuláveis**: Para colunas que aceitam valor nulo, utilize a composição `Prop<Nullable<T>>` (ex: `Prop<Nullable<Integer>>`) e **nunca** a sintaxe depreciada `Nullable<Prop<T>>`.
*   **uses Necessária**: Certifique-se de incluir a unit `Dext.Entity.Core` na seção `uses` das suas entidades para a correta resolução do tipo genérico `IDbSet<T>`.

---

## 4. Testes com Dext Testing
*   **Mocks**: A classe de simulação `Mock<T>` (de `Dext.Mocks`) é implementada internamente no Delphi como um `record`. Por conta disso, **nunca chame `.Free` em instâncias de `Mock<T>`**, pois a limpeza de memória de registros é feita de forma 100% automática pelo compilador Delphi.
*   **Assertions Fluentes**: Dê preferência ao uso de asserções fluentes que tornam os testes unitários altamente descritivos para IAs e humanos:
    ```delphi
    Value.Should.BeTrue;
    List.Count.Should.Be(10);
    ```
