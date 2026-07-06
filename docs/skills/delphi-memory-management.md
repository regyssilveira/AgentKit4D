# Manual de Gestão de Memória no Delphi

Este manual descreve as diretrizes para prevenção de vazamento de memória (*memory leaks*), regras de herança de destrutores e gerenciamento de ciclo de vida de objetos em plataformas nativas e sob contagem de referência (ARC).

---

## 1. Blocos Try..Finally (Proteção de Recursos)
Toda alocação de objeto que possua escopo temporário local deve ser protegida de forma estrita por blocos `try..finally` para garantir que o objeto seja liberado da memória mesmo se ocorrer uma exceção durante a execução.

### Padrão Homologado (Try..Finally)
```delphi
// Incorreto: Risco de leak se ocorrer erro entre Create e Free
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  LQuery.SQL.Text := 'SELECT * FROM CUSTOMER';
  LQuery.Open;
  LQuery.Free;
end;

// Correto: Liberação garantida no bloco finally
var
  LQuery: TFDQuery;
begin
  LQuery := TFDQuery.Create(nil);
  try
    LQuery.SQL.Text := 'SELECT * FROM CUSTOMER';
    LQuery.Open;
  finally
    LQuery.Free; // ou FreeAndNil(LQuery) se a variável for acessada posteriormente
  end;
end;
```

---

## 2. Destrutores e Construtores Idiomáticos
Para que a limpeza de memória ocorra de forma correta e sem efeitos colaterais na cadeia de herança, respeite as seguintes regras de sintaxe:

*   **Chamar `inherited` no construtor**: A chamada para o construtor da classe pai (`inherited Create` ou `inherited`) deve ocorrer preferencialmente na primeira linha do construtor da classe filha.
*   **Chamar `inherited` no destructor**: Ao sobrescrever o destrutor de uma classe, a chamada `inherited Destroy` (ou simplesmente `inherited`) deve ser feita **obrigatoriamente** na última linha do destrutor.
*   **Utilizar a diretiva `override`**: Sempre declare a assinatura do destrutor usando a diretiva `override` para substituir corretamente a rotina virtual de liberação da classe base.

```delphi
type
  TMyService = class(TBaseService)
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TMyService.Create;
begin
  inherited Create; // Primeira linha
  // Inicialização adicional do filho
end;

destructor TMyService.Destroy;
begin
  // Liberar dependências locais instanciadas pelo filho
  FLocalList.Free;
  
  inherited Destroy; // Última linha
end;
```

---

## 3. Gerenciamento de Ciclo de Vida por Interfaces (ARC)
O Delphi possui contagem de referência automática (ARC) para variáveis baseadas em **interfaces**. Quando um objeto é associado a uma variável de interface, seu tempo de vida é controlado automaticamente pelo compilador.

*   **Evite misturar chamadas**: Nunca instancie um objeto referenciando-o em uma variável de classe e, posteriormente, chame `.Free` se ele também for referenciado por variáveis de interface. Isso gera erros de violação de acesso (*Access Violation*).
*   **Variáveis Temporárias**: Se precisar utilizar interfaces e liberar os recursos ao fim de um escopo, basta atribuir `nil` à variável de interface correspondente (ex: `LService := nil;`).
*   **Mocks de Teste**: Em DUnitX e frameworks como Dext, objetos de mock criados via struct (ex: `Mock<T>`) são registros (records) do Delphi. Records não possuem construtores ou destrutores clássicos de heap e são liberados automaticamente pelo compilador. **Nunca chame `.Free` em um objeto do tipo `Mock<T>`**.

---

## 4. Value Objects (Records)
Para pequenas estruturas de dados sem comportamento complexo ou necessidade de herança (como DTOs ou chaves de valor), prefira utilizar `record` em vez de `class`. Registros são alocados no stack de execução e não no heap de memória, eliminando a necessidade de blocos `try..finally` e chamadas de destruição.
