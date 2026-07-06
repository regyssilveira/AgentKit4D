---
name: delphi-migration-dbx-to-firedac
description: Diretrizes e mapeamentos de expressões regulares para migração de componentes dbExpress (DBX) para FireDAC no Delphi.
---

# Diretrizes para Migração de dbExpress (DBX) para FireDAC no Delphi

Esta skill define o guia técnico e o mapeamento de componentes, propriedades e tipos para migração de projetos Delphi baseados na tecnologia dbExpress (DBX) para o framework moderno FireDAC.

---

## 1. Automatização da Migração (reFind.exe)
O RAD Studio inclui o utilitário de console **`reFind.exe`** (localizado na pasta `bin` da instalação do Delphi). Ele permite processar em lote todo o projeto, substituindo as classes, propriedades e cláusulas `uses` via expressões regulares.

### Como Executar o reFind para DBX
Para rodar a migração em lote em todas as units `.pas` e arquivos de tela `.dfm` de forma recursiva, execute o prompt de comando da pasta do projeto com os caminhos corretos:

```cmd
"C:\Program Files (x86)\Embarcadero\Studio\<VERSAO>\bin\reFind.exe" /s /d:*.pas /d:*.dfm "C:\Users\Public\Documents\Embarcadero\Studio\<VERSAO>\Samples\Object Pascal\Database\FireDAC\Tool\reFind\DBX2FDMigration\FireDAC_Migrate_DBX.txt"
```
*(Substitua `<VERSAO>` pela versão do Delphi instalada, por exemplo: `22.0` para o Delphi 11, `23.0` para o Delphi 12, ou `37.0` para o Delphi 13)*.

---

## 2. Substituição de Classes de Componentes (Mapeamento)
Ao realizar a migração manual ou revisar o resultado do `reFind.exe`, aplique os seguintes mapeamentos de classe:

| Classe Legada dbExpress | Nova Classe FireDAC | Unit FireDAC Necessária |
| :--- | :--- | :--- |
| `TSQLConnection` | `TFDConnection` | `FireDAC.Comp.Client`, `FireDAC.Stan.Intf`, `FireDAC.Phys.Intf`, `FireDAC.DBX.Migrate` |
| `TSQLDataSet` | `TFDQuery` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet` |
| `TSQLQuery` | `TFDQuery` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet`, `FireDAC.DApt` |
| `TSQLTable` | `TFDTable` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet` |
| `TSQLStoredProc` | `TFDStoredProc` | `FireDAC.Comp.Client`, `FireDAC.Comp.DataSet`, `FireDAC.DApt` |
| `TSQLBlobStream` | `TFDBlobStream` | `FireDAC.Comp.DataSet` |
| `TAutoIncField` | `TFDAutoIncField` | `FireDAC.Comp.DataSet` |
| `TParam` | `TFDParam` | `FireDAC.Stan.Param` |
| `TParams` | `TFDParams` | `FireDAC.Stan.Param` |
| `TTransactionDesc` | `TFDDBXTransactionDesc` | `FireDAC.Stan.Option`, `FireDAC.DBX.Migrate` |
| `TDBXTransaction` | `TFDDBXTransaction` | `FireDAC.Stan.Option`, `FireDAC.DBX.Migrate` |
| `TProcParamList` | `TFDDBXProcParamList` | `FireDAC.DBX.Migrate` |
| `TDBXError` | `EFDDBEngineException` | `FireDAC.Stan.Error` |

---

## 3. Substituição e Mapeamento de Propriedades
Muitas propriedades específicas do dbExpress não possuem representação direta e devem ser removidas, enquanto outras foram renomeadas ou reorganizadas no FireDAC.

### Propriedades a Mapear/Modificar:
*   `SQLConnection` &rarr; `Connection`
*   `ConnectionName` &rarr; `ConnectionDefName`
*   `KeepConnection` &rarr; `ResourceOptions.KeepConnection`
*   `SQLHourGlass` &rarr; `ResourceOptions.SilentMode`
*   `ParamCheck` &rarr; `ResourceOptions.ParamCreate`
*   `SortFieldNames` &rarr; `IndexFieldNames`
*   `TSQLConnection.ActiveStatements` &rarr; `RefCount`
*   `TSQLConnection.CloseDataSets` &rarr; `ReleaseClients(rmDisconnect)`
*   `TSQLConnection.Execute` / `ExecuteDirect` &rarr; `ExecSQL`
*   `TSQLConnection.GetDefaultSchemaName` &rarr; `CurrentSchema`
*   `TSQLConnection.MultipleTransactionsSupported` &rarr; `ConnectionMetaDataIntf.TxSavepoints`
*   `TSQLConnection.DBXConnection` &rarr; `ConnectionIntf`
*   `TSQLConnection.TransactionsSupported` &rarr; `ConnectionMetaDataIntf.TxSupported`
*   `TSQLTable.DeleteRecords` &rarr; `ServerDeleteAll`
*   `GetConnectionAdmin.*` &rarr; `FDManager.*`
*   `PrepareStatement` &rarr; `Prepare`

### Propriedades Obsoletas a Remover (Código e DFM):
*   `AutoClone`
*   `LocaleCode`
*   `UniqueID`
*   `GetDriverFunc`
*   `LibraryName` (o FireDAC gerencia DLLs de banco centralizadamente via componentes `TFDPhysXXXDriverLink`).
*   `VendorLib` (removido, gerenciado pelos Driver Links).
*   `ValidatePeerCertificate`
*   `MaxBlobSize`
*   `SchemaName`
*   Propriedade `Origin` nos campos persistentes no `.dfm`.

---

## 4. Substituição de Driver Units (Uses)
O dbExpress usa units de driver de banco de dados específicas que devem ser substituídas pelas units de drivers físicos do FireDAC correspondentes na seção `uses`:

| Unit de Driver dbExpress | Nova Unit de Driver FireDAC |
| :--- | :--- |
| `Data.DbxDb2` | `FireDAC.Phys.DB2` |
| `Data.DbxFirebird` | `FireDAC.Phys.FB` |
| `Data.DbxInformix` | `FireDAC.Phys.Infx` |
| `Data.DbxInterbase` | `FireDAC.Phys.IB` |
| `Data.DbxMSSQL` | `FireDAC.Phys.MSSQL` |
| `Data.DbxMySql` | `FireDAC.Phys.MySQL` |
| `Data.DbxOdbc` | `FireDAC.Phys.ODBC` |
| `Data.DbxOracle` | `FireDAC.Phys.Oracle` |
| `Data.DbxSqlite` | `FireDAC.Phys.SQLite` |
| `Data.DbxSybaseASA` | `FireDAC.Phys.ASA` |
| `Data.DbxSybaseASE` | `FireDAC.Phys.ODBC` |

---

## 5. Tipos, Constantes e Enumerados

### Isolamento de Transação:
*   `TDBXIsolation` / `TTransIsolationLevel` &rarr; `TFDTxIsolation` (em `FireDAC.Stan.Option`)
*   `TDBXIsolations.ReadCommitted` / `xilREADCOMMITTED` &rarr; `xiReadCommitted`
*   `TDBXIsolations.RepeatableRead` / `xilREPEATABLEREAD` &rarr; `xiRepeatableRead`
*   `TDBXIsolations.DirtyRead` / `xilDIRTYREAD` &rarr; `xiDirtyRead`
*   `TDBXIsolations.Serializable` &rarr; `xiSerializible`
*   `TDBXIsolations.SnapShot` &rarr; `xiSnapshot`
*   `xilCUSTOM` &rarr; `xiReadCommitted`

### Estado de Conexão:
*   `TConnectionState` &rarr; `TFDPhysConnectionState` (em `FireDAC.Phys.Intf`)
*   `csStateClosed` &rarr; `csDisconnected`
*   `csStateOpen` &rarr; `csConnected`
*   `csStateConnecting` &rarr; `csConnecting`
*   `csStateDisconnecting` &rarr; `csDisconnecting`

### Tipos de Esquema de Metadados:
*   `TSchemaType` &rarr; `TFDPhysMetaInfoKind` (em `FireDAC.Phys.Intf`)
*   `stNoSchema` &rarr; `mkNone`
*   `stTables` / `stSysTables` &rarr; `mkTables`
*   `stProcedures` &rarr; `mkProcs`
*   `stColumns` &rarr; `mkTableFields`
*   `stProcedureParams` &rarr; `mkProcArgs`
*   `stIndexes` &rarr; `mkIndexes`
*   `stPackages` &rarr; `mkPackages`
*   `stUserNames` &rarr; `mkSchemas`

---

## 6. Limpeza de Cláusulas Uses (Units dbExpress)
Remova as seguintes units obsoletas do dbExpress da cláusula `uses`:
*   `Data.SqlExpr`, `SqlExpr`
*   `Data.DBXCommon`, `DBXCommon`
*   `Data.DBConnAdmin`, `DBConnAdmin`
*   `Data.DBXDynalink`, `DBXDynalink`
