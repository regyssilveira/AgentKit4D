---
name: delphi-migration-bde-to-firedac
description: Diretrizes e mapeamentos de expressões regulares para migração de componentes Borland Database Engine (BDE) para FireDAC no Delphi.
---

# Diretrizes para Migração de BDE para FireDAC no Delphi

Esta skill define o guia técnico e o mapeamento de componentes/tipos para migração de projetos Delphi que utilizam o Borland Database Engine (BDE) legado para a tecnologia moderna de acesso a dados FireDAC.

---

## 1. Automatização da Migração (reFind.exe)
O RAD Studio inclui um utilitário de console chamado **`reFind.exe`** (localizado na pasta `bin` da instalação do Delphi). Ele permite processar em lote todo o projeto, substituindo as classes, propriedades e cláusulas `uses` via expressões regulares.

### Como Executar o reFind para BDE
Para rodar a migração em lote em todas as units `.pas` e arquivos de tela `.dfm` de forma recursiva, execute o prompt de comando da pasta do projeto com os caminhos corretos:

```cmd
"C:\Program Files (x86)\Embarcadero\Studio\<VERSAO>\bin\reFind.exe" /s /d:*.pas /d:*.dfm "C:\Users\Public\Documents\Embarcadero\Studio\<VERSAO>\Samples\Object Pascal\Database\FireDAC\Tool\reFind\BDE2FDMigration\FireDAC_Migrate_BDE.txt"
```
*(Substitua `<VERSAO>` pela versão do Delphi instalada, por exemplo: `22.0` para o Delphi 11, `23.0` para o Delphi 12, ou `37.0` para o Delphi 13)*.

---

## 2. Substituição de Classes de Componentes (Mapeamento)
Ao realizar a migração manual ou revisar o resultado do `reFind.exe`, aplique os seguintes mapeamentos de classe:

| Classe Legada BDE | Nova Classe FireDAC | Unit FireDAC Necessária |
| :--- | :--- | :--- |
| `TSession` | `TFDManager` | `FireDAC.Comp.Client` |
| `TDatabase` | `TFDConnection` | `FireDAC.Comp.Client`, `FireDAC.Stan.Intf`, `FireDAC.Stan.Option`, `FireDAC.UI.Intf` |
| `TTable` | `TFDTable` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet` |
| `TQuery` | `TFDQuery` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet`, `FireDAC.DApt` |
| `TStoredProc` | `TFDStoredProc` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet`, `FireDAC.DApt` |
| `TUpdateSQL` | `TFDUpdateSQL` | `FireDAC.Comp.Client` |
| `TBatchMove` | `TFDBatchMove` | `FireDAC.Comp.BatchMove` |
| `TParam` | `TFDParam` | `FireDAC.Stan.Param` |
| `TParams` | `TFDParams` | `FireDAC.Stan.Param` |
| `TBlobStream` | `TFDBlobStream` | `FireDAC.Comp.DataSet` |
| `TAutoIncField` | `TFDAutoIncField` | `FireDAC.Comp.DataSet` |
| `TDBDataSet` / `TBDEDataSet` | `TFDRDBMSDataSet` | `FireDAC.Comp.Client` |
| `EDBEngineError` | `EFDDBEngineException` | `FireDAC.Stan.Error` |

---

## 3. Substituição e Mapeamento de Propriedades
Muitas propriedades de componentes do BDE mudaram de nome ou de estrutura de acesso no FireDAC. Abaixo estão as principais conversões e remoções:

### Propriedades a Mapear/Modificar:
*   `DatabaseName` &rarr; `ConnectionName` (ou `Connection` apontando para o `TFDConnection` correspondente).
*   `AliasName` &rarr; `ConnectionDefName`.
*   `Session.*` &rarr; `FDManager.*`.
*   `IsAlias` &rarr; `IsConnectionDef`.
*   `AddAlias` &rarr; `AddConnectionDef`.
*   `DeleteAlias` &rarr; `DeleteConnectionDef`.
*   `ModifyAlias` &rarr; `ModifyConnectionDef`.
*   `GetAliasParams` &rarr; `GetConnectionDefParams`.
*   `GetAliasNames` &rarr; `GetConnectionDefNames`.
*   `FindDatabase` &rarr; `FindConnection`.
*   `OpenDatabase` &rarr; `OpenConnection`.
*   `CloseDatabase` &rarr; `CloseConnection`.
*   `GetDatabaseNames` &rarr; `GetConnectionNames`.
*   `Unidirectional` &rarr; `FetchOptions.Unidirectional`.
*   `UpdateRecordTypes` &rarr; `FilterChanges`.
*   `RequestLive` &rarr; `UpdateOptions.RequestLive`.
*   `UpdateMode` &rarr; `UpdateOptions.UpdateMode`.
*   `TransIsolation` &rarr; `TxOptions.Isolation`.
*   `TTable.ReadOnly` &rarr; `UpdateOptions.ReadOnly`.
*   `TQuery.DataSource` &rarr; `MasterSource`.
*   `TDatabase.Execute` &rarr; `ExecSQL`.

### Propriedades Obsoletas a Remover (Código e DFM):
*   `SessionName` (o gerenciamento de conexões no FireDAC usa `TFDConnection` e `TFDManager` de forma centralizada ou implicitamente thread-safe via Pools).
*   `PrivateDir`.
*   Propriedade `Origin` nos campos persistentes no `.dfm`.

---

## 4. Tipos, Constantes e Enumerados
Mapeie as definições do BDE para os enumerados correspondentes do FireDAC:

### Isolamento de Transação:
*   `TTransIsolation` &rarr; `TFDTxIsolation` (em `FireDAC.Stan.Option`)
*   `tiDirtyRead` &rarr; `xiDirtyRead`
*   `tiReadCommitted` &rarr; `xiReadCommitted`
*   `tiRepeatableRead` &rarr; `xiRepeatableRead`

### Atualizações (Update Request):
*   `TUpdateKind` &rarr; `TFDUpdateRequest` (em `FireDAC.Phys.Intf`)
*   `ukModify` &rarr; `arUpdate`
*   `ukInsert` &rarr; `arInsert`
*   `ukDelete` &rarr; `arDelete`

### Ações em Erros de Atualização:
*   `TUpdateAction` &rarr; `TFDErrorAction` (em `FireDAC.Stan.Intf`)
*   `uaFail` &rarr; `eaFail`
*   `uaAbort` &rarr; `eaExitFailure`
*   `uaSkip` &rarr; `eaSkip`
*   `uaRetry` &rarr; `eaRetry`
*   `uaApplied` &rarr; `eaApplied`

### Modos do Batch Move:
*   `TBatchMode` &rarr; `TFDBatchMoveMode` (em `FireDAC.Comp.BatchMove`)
*   `batAppend` &rarr; `dmAppend`
*   `batUpdate` &rarr; `dmUpdate`
*   `batAppendUpdate` &rarr; `dmAppendUpdate`
*   `batDelete` &rarr; `dmDelete`
*   `batCopy` &rarr; `dmAlwaysInsert`

---

## 5. Limpeza de Cláusulas Uses (Units Obsoletas)
Remova as seguintes units legadas da cláusula `uses` de todas as suas classes Delphi:
*   `BDE.DBTables`
*   `BDE.BDEConst`
*   `DBTables`
*   `BDEConst`
*   `BDEMTS`
*   `BDE`
