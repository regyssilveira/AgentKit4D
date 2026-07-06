# Manual de Compilação Multiplataforma e Builds no Delphi

Este manual descreve as diretrizes para compilar projetos Delphi em múltiplos alvos (Win32 e Win64), estruturar scripts de compilação em lote (`.bat`) estáveis e gerar relatórios de cobertura de testes no Windows.

---

## 1. Scripts de Automação Estáveis (Regra do Call)
No terminal Windows (cmd.exe), executar um script em lote de dentro de outro script sem usar a palavra-chave **`call`** faz com que o script pai seja encerrado imediatamente ao término do script filho, interrompendo qualquer comando subsequente.

*   **Incorreto**:
    ```cmd
    rsvars.bat
    dcc32.exe MyProject.dpr
    ```
*   **Correto (Sempre use CALL para outros arquivos .bat/.cmd)**:
    ```cmd
    call rsvars.bat
    dcc32.exe MyProject.dpr
    ```

---

## 2. Compilação Condicional por Plataforma
Ao lidar com APIs específicas do Windows ou chamadas de sistema nativas de tamanho de ponteiro (32-bit vs 64-bit), utilize as diretivas de compilação condicional nativas do Delphi:

```delphi
procedure RegisterPlatformAPI;
begin
  {$IFDEF WIN64}
  // Código específico para plataforma Windows 64-bit
  Load64BitLibrary;
  {$ELSE}
  // Código de fallback para Windows 32-bit (ou outras plataformas)
  Load32BitLibrary;
  {$ENDIF}
end;
```

*   **Ponteiros**: Nunca assuma que ponteiros e handles de memória possuem tamanho de `Integer` (4 bytes). Utilize sempre o tipo genérico **`NativeInt`** ou **`NativeUInt`**, que se redimensiona automaticamente entre 4 bytes (32-bit) e 8 bytes (64-bit).

---

## 3. Geração de Relatórios de Cobertura (Coverage XML)
Para que o SonarQube exiba a cobertura de código de testes unitários do seu projeto, você precisa gerar um arquivo de relatório em formato compatível (Generic Coverage XML).

### O Script generate_coverage.ps1
O kit disponibiliza o script PowerShell `scripts/generate_coverage.ps1` que automatiza a instrumentação de código, execução dos testes unitários e normalização do relatório de cobertura para processamento do SonarQube.

### Executando em Pipelines CI/CD
Para rodar a compilação e testes não interativos em esteiras automáticas (como Jenkins, GitHub Actions ou GitLab CI), configure a diretiva de compilação `CI` para pular pausas manuais no terminal (`Readln`):

```cmd
dcc32.exe -DCI -E.\bin MyTestsProject.dpr
.\bin\MyTestsProject.exe
```
