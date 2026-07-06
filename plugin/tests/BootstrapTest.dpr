program BootstrapTest;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.IOUtils,
  AgentKit.Common.Interfaces in '..\src\AgentKit.Common.Interfaces.pas',
  AgentKit.Net.Client in '..\src\AgentKit.Net.Client.pas',
  AgentKit.Service.Init in '..\src\AgentKit.Service.Init.pas';

{$R '..\resources\AgentKit.Common.Resources.res'}

var
  LNetClient: IAgentKitNetClient;
  LFileSystem: IAgentKitFileSystem;
  LService: IAgentKitInitService;
  LConfig: TProjectInitConfig;
  LWarnings: string;
  LSuccess: Boolean;
  LTestDir: string;
begin
  try
    LTestDir := TPath.Combine(GetCurrentDir, 'bootstrap_test_output');
    Writeln('=== INICIANDO TESTE DE BOOTSTRAP REAL (E2E) ===');
    Writeln('Diretorio de teste: ', LTestDir);

    if TDirectory.Exists(LTestDir) then
    begin
      Writeln('Limpando diretorio de teste anterior...');
      TDirectory.Delete(LTestDir, True);
    end;

    LNetClient := TAgentKitNetClient.Create;
    LFileSystem := TAgentKitRealFileSystem.Create;
    LService := TAgentKitInitService.Create(
      LNetClient,
      LFileSystem,
      procedure(const AMsg: string)
      begin
        Writeln('[LOG] ', AMsg);
      end
    );

    LConfig.ProjectKey := 'BootstrapProject';
    LConfig.ProjectName := 'Bootstrap Project E2E';
    LConfig.ProjectVersion := '1.0.0';
    LConfig.ConfigureSonar := True;
    LConfig.CreateProjectOnServer := False;
    LConfig.SonarToken := 'token_secreto_e2e';
    LConfig.ProjectPath := LTestDir;

    Writeln('Executando InitializeProject...');
    LSuccess := LService.InitializeProject(LConfig, LWarnings);

    if LSuccess then
    begin
      Writeln('Inicializacao concluida com sucesso.');
      if not LWarnings.IsEmpty then
        Writeln('Avisos reportados: ', LWarnings);

      Writeln('Validando criacao de arquivos no disco...');
      
      if not TDirectory.Exists(TPath.Combine(LTestDir, '.agents')) then
        raise Exception.Create('Pasta .agents nao criada');
      if not TFile.Exists(TPath.Combine(LTestDir, '.agents\AGENTS.md')) then
        raise Exception.Create('AGENTS.md nao criado');
      if not TFile.Exists(TPath.Combine(LTestDir, 'sonar-project.properties')) then
        raise Exception.Create('sonar-project.properties nao criado');
      if not TFile.Exists(TPath.Combine(LTestDir, 'run_sonar.bat')) then
        raise Exception.Create('run_sonar.bat nao criado');
      if not TDirectory.Exists(TPath.Combine(LTestDir, 'scripts')) then
        raise Exception.Create('Pasta scripts nao criada');
      if not TFile.Exists(TPath.Combine(LTestDir, 'scripts\generate_coverage.ps1')) then
        raise Exception.Create('generate_coverage.ps1 nao criado');
      if not TFile.Exists(TPath.Combine(LTestDir, 'sonar_token.txt')) then
        raise Exception.Create('sonar_token.txt nao criado');
      if not TFile.Exists(TPath.Combine(LTestDir, '.gitignore')) then
        raise Exception.Create('.gitignore nao criado');

      var LGitIgnoreContent := TFile.ReadAllText(TPath.Combine(LTestDir, '.gitignore')).Trim;
      if not LGitIgnoreContent.Contains('sonar_token.txt') then
        raise Exception.Create('.gitignore nao contem sonar_token.txt');

      var LPropsContent := TFile.ReadAllText(TPath.Combine(LTestDir, 'sonar-project.properties'));
      if not LPropsContent.Contains('sonar.projectKey=BootstrapProject') then
        raise Exception.Create('Key nao alterada no properties');
      if not LPropsContent.Contains('sonar.projectName=Bootstrap Project E2E') then
        raise Exception.Create('Name nao alterado no properties');

      Writeln('=== TESTE DE BOOTSTRAP REAL FINALIZADO COM SUCESSO! ===');
    end
    else
    begin
      Writeln('[ERRO] Falha ao inicializar o projeto.');
      ExitCode := 1;
    end;
  except
    on E: Exception do
    begin
      Writeln('[ERRO EXCEÇÃO] ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
