---
name: delphi-multithreading-async
description: Programação assíncrona, multithreading, uso de TTask, IFuture, TThread, sincronização de threads e thread-safety em Delphi.
---

# Programação Assíncrona e Multithreading no Delphi

Esta guia estabelece as diretrizes para desenvolvimento assíncrono e paralelo de alta performance, livre de race conditions, deadlocks e congelamento de tela.

## 1. Regra de Ouro do Multithreading
> **NUNCA acesse componentes visuais (VCL/FMX) diretamente de uma thread secundária.**
> Qualquer interação com a UI deve ser despachada para a Main Thread através de `TThread.Queue` (não-bloqueante, recomendado) ou `TThread.Synchronize` (bloqueante).

```pascal
TThread.CreateAnonymousThread(
  procedure
  begin
    // Trabalho pesado em background...
    Sleep(2000); 

    // Atualização da UI segura
    TThread.Queue(nil,
      procedure
      begin
        lblStatus.Caption := 'Processamento concluído!';
      end);
  end).Start;
```

---

## 2. Programação Paralela Moderna (PPL - Parallel Programming Library)
Dê preferência ao uso da PPL (`System.Threading`) em vez de gerenciar threads brutas manualmente.

*   **TTask**: Execução de tarefas leves gerenciadas pelo pool de threads da IDE.
    ```pascal
    var LTask: ITask;
    begin
      LTask := TTask.Run(
        procedure
        begin
          // Executado no ThreadPool
        end);
    end;
    ```
*   **IFuture<T>**: Execução de um cálculo assíncrono que retorna um valor futuramente. A leitura de `LFuture.Value` bloqueará a execução se o cálculo ainda não tiver finalizado.
    ```pascal
    var LFuture: IFuture<Integer>;
    begin
      LFuture := TFuture<Integer>.Create(
        function: Integer
        begin
          Result := ExecutarCalculoPesado;
        end);
      LFuture.Start;
      // ... faz outras operações simultâneas
      ProcessarResultado(LFuture.Value);
    end;
    ```
*   **TParallel.For**: Distribuição das iterações de um loop entre múltiplas threads.
    > [!WARNING]
    > Certifique-se de que cada iteração do `TParallel.For` seja independente e que o acesso a recursos compartilhados seja feito de forma thread-safe (usando locks).

---

## 3. Thread-Safety e Proteção de Recursos
Sempre que duas ou mais threads compartilharem dados (listas, objetos ou contadores), utilize primitivas de sincronização:

*   **TInterlocked**: Operações atômicas sem a necessidade de locks explícitos (ideal para incrementos e atribuições simples de inteiros).
    ```pascal
    TInterlocked.Increment(FProcessedCount);
    ```
*   **TCriticalSection / TMonitor**: Proteção de seções críticas de código de exclusão mútua.
    ```pascal
    FLock.Enter;
    try
      FSharedList.Add(LItem);
    finally
      FLock.Leave; // SEMPRE no finally para evitar deadlocks
    end;
    ```
*   **TThreadList<T>**: Invólucro nativo que envelopa uma lista comum protegendo-a com locks automáticos via `LockList` e `UnlockList`.

---

## 4. Banco de Dados em Multithreading (Conexões Isoladas)
> [!CRITICAL]
> **Nunca compartilhe a mesma instância de TFDConnection (FireDAC) ou conexões dbExpress/ADO entre threads.**
> Cada thread secundária deve abrir sua própria conexão física ao banco de dados e destruí-la ao final da rotina de execução da thread.

```pascal
TTask.Run(
  procedure
  var
    LConnection: TFDConnection;
    LQuery: TFDQuery;
  begin
    LConnection := TFDConnection.Create(nil);
    LQuery := TFDQuery.Create(nil);
    try
      LConnection.ConnectionDefName := 'MeuDef';
      LQuery.Connection := LConnection;
      LQuery.Open('SELECT * FROM TABELA');
      // processamento...
    finally
      LQuery.Free;
      LConnection.Free;
    end;
  end);
```
