# Manual de Migração dbExpress para FireDAC no Delphi

Este manual apresenta as diretrizes técnicas e o passo a passo prático para a migração e modernização de bases de código Delphi baseadas na tecnologia dbExpress (DBX) antiga para o framework de alto desempenho **FireDAC**.

---

## 1. Automatização da Tradução (reFind.exe)
O RAD Studio fornece o utilitário de console **`reFind.exe`** (localizado no diretório `bin` da instalação do Delphi). Ele permite processar em lote todo o projeto legando, substituindo as classes, propriedades e cláusulas `uses` via expressões regulares baseadas em um script de regras oficial.

### Linha de Comando Recomendada
No prompt de comando do Windows, execute o seguinte comando a partir da pasta raiz do seu projeto para iniciar a migração por lote de forma recursiva:

```cmd
"C:\Program Files (x86)\Embarcadero\Studio\<VERSAO>\bin\reFind.exe" /s /d:*.pas /d:*.dfm "C:\Users\Public\Documents\Embarcadero\Studio\<VERSAO>\Samples\Object Pascal\Database\FireDAC\Tool\reFind\DBX2FDMigration\FireDAC_Migrate_DBX.txt"
```
*(Substitua `<VERSAO>` pela versão do Delphi em sua máquina, ex: `22.0` para o Delphi 11, `23.0` para o Delphi 12, ou `37.0` para o Delphi 13)*.

---

## 2. Equivalência de Componentes e Mapeamento

Ao refatorar manualmente ou validar o processamento do `reFind.exe`, substitua as classes do dbExpress pelas equivalentes no FireDAC:

| Componente Legado dbExpress | Componente Equivalente FireDAC |
| :--- | :--- |
| `TSQLConnection` | `TFDConnection` |
| `TSQLDataSet` / `TSQLQuery` | `TFDQuery` |
| `TSQLTable` | `TFDTable` |
| `TSQLStoredProc` | `TFDStoredProc` |
| `TSQLBlobStream` | `TFDBlobStream` |
| `TTransactionDesc` | `TFDDBXTransactionDesc` (com a unit `FireDAC.DBX.Migrate`) |
| `TDBXTransaction` | `TFDDBXTransaction` (com a unit `FireDAC.DBX.Migrate`) |
| `TDBXError` | `EFDDBEngineException` |

---

## 3. Substituição de Drivers de Banco (Uses)
O dbExpress faz uso de units de driver de banco de dados específicas que devem ser substituídas pelas respectivas units de drivers físicos do FireDAC na seção `uses`:

*   `Data.DbxMySql` &rarr; `FireDAC.Phys.MySQL`
*   `Data.DbxFirebird` &rarr; `FireDAC.Phys.FB`
*   `Data.DbxInterbase` &rarr; `FireDAC.Phys.IB`
*   `Data.DbxMSSQL` &rarr; `FireDAC.Phys.MSSQL`
*   `Data.DbxSqlite` &rarr; `FireDAC.Phys.SQLite`
*   `Data.DbxOracle` &rarr; `FireDAC.Phys.Oracle`

---

## 4. Ajustes de Propriedades e Métodos
*   **SQLConnection**: Substitua pela propriedade `Connection` apontando para o seu componente `TFDConnection`.
*   **KeepConnection**: Traduzido para `ResourceOptions.KeepConnection`.
*   **SQLHourGlass**: Traduzido para `ResourceOptions.SilentMode`.
*   **Propriedades a Remover**: Remova do código e dos arquivos `.dfm` as propriedades obsoletas específicas de carregamento de DLLs e configurações internas do DBX, como: `LibraryName`, `VendorLib`, `GetDriverFunc`, `AutoClone` e `LocaleCode`.
