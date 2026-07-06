unit AgentKit.Tests.Service.Init;

interface

uses
  DUnitX.TestFramework, System.Classes, System.SysUtils,
  AgentKit.Common.Interfaces,
  AgentKit.Mocks.NetClient,
  AgentKit.Mocks.FileSystem,
  AgentKit.Service.Init;

type
  [TestFixture]
  TAgentKitTestsServiceInit = class
  private
    FMockNetClient: TAgentKitMockNetClient;
    FMockFileSystem: TAgentKitMockFileSystem;
    FService: IAgentKitInitService;
    FLogs: TStringBuilder;
    procedure LogMessage(const AMsg: string);
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure TestInitializeOnlyAgent;
    [Test]
    procedure TestInitializeCompleteOnline;
    [Test]
    procedure TestInitializeCompleteOfflineFallback;
    [Test]
    procedure TestSonarProjectCreateSuccess;
    [Test]
    procedure TestSonarProjectCreateAlreadyExists;
    [Test]
    procedure TestSonarProjectCreateFailure;
  end;

implementation

{$R '..\resources\AgentKit.Common.Resources.res'}

{ TAgentKitTestsServiceInit }

procedure TAgentKitTestsServiceInit.Setup;
begin
  FLogs := TStringBuilder.Create;
  FMockNetClient := TAgentKitMockNetClient.Create;
  FMockFileSystem := TAgentKitMockFileSystem.Create;
  FService := TAgentKitInitService.Create(
    FMockNetClient,
    FMockFileSystem,
    procedure(const AMsg: string)
    begin
      LogMessage(AMsg);
    end
  );
end;

procedure TAgentKitTestsServiceInit.TearDown;
begin
  FService := nil;
  FMockFileSystem := nil;
  FMockNetClient := nil;
  FLogs.Free;
end;

procedure TAgentKitTestsServiceInit.LogMessage(const AMsg: string);
begin
  FLogs.AppendLine(AMsg);
end;

procedure TAgentKitTestsServiceInit.TestInitializeOnlyAgent;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
begin
  LConfig.ProjectKey := 'TestKey';
  LConfig.ProjectName := 'Test Name';
  LConfig.ProjectVersion := '1.0.0';
  LConfig.ConfigureSonar := False;
  LConfig.CreateProjectOnServer := False;
  LConfig.ProjectPath := 'C:\TestProject';

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsTrue(LWarnings.IsEmpty);

  Assert.IsTrue(FMockFileSystem.DirectoryExists('C:\TestProject\.agents'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\.agents\AGENTS.md'));
  
  Assert.IsFalse(FMockFileSystem.FileExists('C:\TestProject\sonar-project.properties'));
  Assert.IsFalse(FMockFileSystem.FileExists('C:\TestProject\run_sonar.bat'));
  Assert.IsFalse(FMockFileSystem.FileExists('C:\TestProject\scripts\generate_coverage.ps1'));
end;

procedure TAgentKitTestsServiceInit.TestInitializeCompleteOnline;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
  LPropsContent: string;
  LGitIgnore: string;
  LNewGitIgnore: string;
  LStrings: TStringList;
  LCount: Integer;
begin
  LConfig.ProjectKey := 'MyTestKey';
  LConfig.ProjectName := 'My Test Name';
  LConfig.ProjectVersion := '1.2.3';
  LConfig.ConfigureSonar := True;
  LConfig.CreateProjectOnServer := False;
  LConfig.SonarToken := 'my_secret_token';
  LConfig.ProjectPath := 'C:\TestProject';

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsTrue(LWarnings.IsEmpty, 'Nao deve haver warnings no modo online');

  Assert.IsTrue(FMockFileSystem.DirectoryExists('C:\TestProject\.agents'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\.agents\AGENTS.md'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\sonar-project.properties'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\run_sonar.bat'));
  Assert.IsTrue(FMockFileSystem.DirectoryExists('C:\TestProject\scripts'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\scripts\generate_coverage.ps1'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\sonar_token.txt'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\TestProject\.gitignore'));

  LPropsContent := FMockFileSystem.ReadAllText('C:\TestProject\sonar-project.properties');
  Assert.IsTrue(LPropsContent.Contains('sonar.projectKey=MyTestKey'), 'Key nao substituida corretamente');
  Assert.IsTrue(LPropsContent.Contains('sonar.projectName=My Test Name'), 'Name nao substituido corretamente');
  Assert.IsTrue(LPropsContent.Contains('sonar.projectVersion=1.2.3'), 'Version nao substituida corretamente');

  LGitIgnore := FMockFileSystem.ReadAllText('C:\TestProject\.gitignore');
  Assert.IsTrue(LGitIgnore.Contains('sonar_token.txt'), 'Regra nao inserida no .gitignore');
  
  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  LNewGitIgnore := FMockFileSystem.ReadAllText('C:\TestProject\.gitignore');
  
  LStrings := TStringList.Create;
  try
    LStrings.Text := LNewGitIgnore;
    LCount := 0;
    for var i := 0 to LStrings.Count - 1 do
      if LStrings[i].Trim = 'sonar_token.txt' then
        Inc(LCount);
    Assert.AreEqual(1, LCount, 'A entrada do sonar_token.txt foi duplicada no .gitignore');
  finally
    LStrings.Free;
  end;
end;

procedure TAgentKitTestsServiceInit.TestInitializeCompleteOfflineFallback;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
  LPropsContent: string;
begin
  LConfig.ProjectKey := 'OfflineKey';
  LConfig.ProjectName := 'Offline Name';
  LConfig.ProjectVersion := '2.0.0';
  LConfig.ConfigureSonar := True;
  LConfig.CreateProjectOnServer := False;
  LConfig.ProjectPath := 'C:\OfflineProject';

  FMockNetClient.SimulateNetworkFailure := True;

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsTrue(LWarnings.Contains('Utilizando templates locais de fallback'), 'Aviso de fallback nao retornado');

  Assert.IsTrue(FMockFileSystem.FileExists('C:\OfflineProject\.agents\AGENTS.md'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\OfflineProject\sonar-project.properties'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\OfflineProject\run_sonar.bat'));
  Assert.IsTrue(FMockFileSystem.FileExists('C:\OfflineProject\scripts\generate_coverage.ps1'));
  
  LPropsContent := FMockFileSystem.ReadAllText('C:\OfflineProject\sonar-project.properties');
  Assert.IsTrue(LPropsContent.Contains('sonar.projectKey=OfflineKey'), 'Key nao substituida no fallback');
end;

procedure TAgentKitTestsServiceInit.TestSonarProjectCreateSuccess;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
begin
  LConfig.ProjectKey := 'SonarSuccessKey';
  LConfig.ProjectName := 'Sonar Success';
  LConfig.ProjectVersion := '1.0.0';
  LConfig.ConfigureSonar := True;
  LConfig.CreateProjectOnServer := True;
  LConfig.SonarServerUrl := 'http://localhost:9000';
  LConfig.SonarToken := 'valid_token';
  LConfig.ProjectPath := 'C:\SonarSuccess';

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsTrue(LWarnings.IsEmpty, 'Nao deve retornar warnings em caso de sucesso');
  Assert.IsTrue(FLogs.ToString.Contains('Projeto criado com sucesso'), 'Log de sucesso ausente');
end;

procedure TAgentKitTestsServiceInit.TestSonarProjectCreateAlreadyExists;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
begin
  LConfig.ProjectKey := 'ExistingKey';
  LConfig.ProjectName := 'Existing Project';
  LConfig.ProjectVersion := '1.0.0';
  LConfig.ConfigureSonar := True;
  LConfig.CreateProjectOnServer := True;
  LConfig.SonarServerUrl := 'http://localhost:9000';
  LConfig.SonarToken := 'valid_token';
  LConfig.ProjectPath := 'C:\SonarExisting';

  FMockNetClient.SimulateProjectExists := True;

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsTrue(LWarnings.IsEmpty, 'Erro de projeto existente nao deve ser reportado como warning');
  Assert.IsTrue(FLogs.ToString.Contains('Projeto ja existe no servidor SonarQube'), 'Log de projeto existente ausente');
  Assert.IsTrue(FMockFileSystem.FileExists('C:\SonarExisting\sonar-project.properties'), 'Arquivos locais nao gerados');
end;

procedure TAgentKitTestsServiceInit.TestSonarProjectCreateFailure;
var
  LConfig: TProjectInitConfig;
  LWarnings: string;
begin
  LConfig.ProjectKey := 'FailedKey';
  LConfig.ProjectName := 'Failed Project';
  LConfig.ProjectVersion := '1.0.0';
  LConfig.ConfigureSonar := True;
  LConfig.CreateProjectOnServer := True;
  LConfig.SonarServerUrl := 'http://localhost:9000';
  LConfig.SonarToken := 'invalid_token';
  LConfig.ProjectPath := 'C:\SonarFailed';

  FMockNetClient.SimulateInvalidToken := True;

  Assert.IsTrue(FService.InitializeProject(LConfig, LWarnings));
  Assert.IsFalse(LWarnings.IsEmpty, 'Deve retornar aviso de erro');
  Assert.IsTrue(LWarnings.Contains('Nao foi possivel criar o projeto automaticamente no servidor SonarQube'), 'Aviso esperado nao encontrado');
  Assert.IsTrue(FMockFileSystem.FileExists('C:\SonarFailed\sonar-project.properties'), 'Arquivos locais devem ser gerados mesmo com falha do SonarQube');
end;

initialization
  TDUnitX.RegisterTestFixture(TAgentKitTestsServiceInit);
end.
