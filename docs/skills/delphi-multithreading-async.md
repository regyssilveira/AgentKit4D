# Manual de Multithreading e Programação Assíncrona no Delphi

Este manual descreve as diretrizes para programação paralela utilizando a Parallel Programming Library (PPL), proteção de recursos críticos com sessões e thread-safety nas conexões de banco de dados no Delphi.

---

## 1. Programação Paralela com a PPL (`TTask` e `IFuture`)
A PPL (Parallel Programming Library) é a biblioteca padrão e moderna para concorrência e assincronismo no Delphi.

*   **`TTask`**: Usado para executar tarefas assíncronas em segundo plano que não retornam resultados imediatos.
*   **`IFuture<T>`**: Usado para calcular valores assincronamente que serão consumidos posteriormente de forma bloqueante na chamada de `.Value`.

### Exemplo Prático com TTask
```delphi
procedure TMainForm.BtnLoadDataClick(Sender: TObject);
begin
  // Rodar tarefa pesada em thread de background da ThreadPool
  TTask.Run(
    procedure
    begin
      // Simular processamento pesado
      Sleep(2000); 

      // Sincronizar retorno na UI principal
      TThread.Queue(nil,
        procedure
        begin
          ShowMessage('Dados carregados com sucesso!');
        end);
    end);
end;
```

---

## 2. Sincronização e Thread-Safety na UI
A VCL (Visual Component Library) e o FireMonkey (FMX) não são thread-safe. Qualquer interação com controles visuais (alterar texto de Edits, atualizar Labels, preencher Grids) a partir de uma thread secundária deve ser sincronizada com a thread principal.

*   **`TThread.Synchronize`**: Pausa a thread secundária e executa a rotina na thread principal. Use com moderação, pois bloqueia a execução paralela.
*   **`TThread.Queue` (Recomendado)**: Envia a rotina para execução assíncrona na fila da thread principal, permitindo que a thread secundária continue seu trabalho sem bloquear.

---

## 3. Isolamento de Conexões de Banco de Dados
A regra número um da persistência concorrente no Delphi é: **Conexões físicas de banco de dados (como `TFDConnection` e seus componentes filhos) não podem ser compartilhadas entre múltiplas threads**.

*   **O Padrão Correto**: Cada Thread/Task deve criar, usar e destruir sua própria conexão física local ao banco de dados.
*   **Uso de Connection Pools**: Utilize o recurso de pool de conexões do FireDAC para evitar o custo de abrir novas conexões a cada execução concorrente:

```delphi
// Exemplo de Task com Conexão de Banco Exclusiva
TTask.Run(
  procedure
  begin
    var LConnection := TFDConnection.Create(nil);
    try
      // Configurar a conexão baseada em uma definição de pool
      LConnection.ConnectionDefName := 'MyPoolConnection';
      LConnection.Connected := True;

      var LQuery := TFDQuery.Create(nil);
      try
        LQuery.Connection := LConnection;
        LQuery.SQL.Text := 'UPDATE INVENTORY SET STOCK = STOCK - 1 WHERE ID = 10';
        LQuery.ExecSQL;
      finally
        LQuery.Free;
      end;
    finally
      LConnection.Free; // Libera e devolve a conexão física ao Pool
    end;
  end);
```

---

## 4. Proteção de Recursos Compartilhados
Quando múltiplas threads precisam ler e escrever no mesmo recurso em memória (ex: uma lista global ou cache compartilhado), proteja o recurso usando primitivas de sincronização para evitar condições de corrida (*Race Conditions*).

*   Use **`TCriticalSection`** (da unit `System.SyncObjs`) ou locks leves para proteger o acesso de leitura/escrita concorrente:

```delphi
procedure TSharedCache.SetCacheValue(const AKey, AValue: string);
begin
  FCriticalSection.Acquire;
  try
    FDictionary.AddOrSetValue(AKey, AValue);
  finally
    FCriticalSection.Release;
  end;
end;
```
