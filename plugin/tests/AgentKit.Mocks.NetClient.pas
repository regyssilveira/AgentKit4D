unit AgentKit.Mocks.NetClient;

interface

uses
  System.SysUtils, AgentKit.Common.Interfaces;

type
  TAgentKitMockNetClient = class(TInterfacedObject, IAgentKitNetClient)
  private
    FSimulateNetworkFailure: Boolean;
    FSimulateProjectExists: Boolean;
    FSimulateInvalidToken: Boolean;
  public
    constructor Create(ASimulateNetworkFailure: Boolean = False;
      ASimulateProjectExists: Boolean = False;
      ASimulateInvalidToken: Boolean = False);

    function DownloadTemplate(const AFileName: string; out AContent: string): Boolean;
    function CreateSonarProject(const AServerUrl, AToken, AProjectKey, AProjectName: string; out AErrorMsg: string): Boolean;

    property SimulateNetworkFailure: Boolean read FSimulateNetworkFailure write FSimulateNetworkFailure;
    property SimulateProjectExists: Boolean read FSimulateProjectExists write FSimulateProjectExists;
    property SimulateInvalidToken: Boolean read FSimulateInvalidToken write FSimulateInvalidToken;
  end;

implementation

{ TAgentKitMockNetClient }

constructor TAgentKitMockNetClient.Create(ASimulateNetworkFailure, ASimulateProjectExists, ASimulateInvalidToken: Boolean);
begin
  inherited Create;
  FSimulateNetworkFailure := ASimulateNetworkFailure;
  FSimulateProjectExists := ASimulateProjectExists;
  FSimulateInvalidToken := ASimulateInvalidToken;
end;

function TAgentKitMockNetClient.DownloadTemplate(const AFileName: string; out AContent: string): Boolean;
begin
  AContent := '';
  if FSimulateNetworkFailure then
    Exit(False);

  if AFileName.EndsWith('.agents/AGENTS.md') then
    AContent := '# MOCK AGENTS TEMPLATE'
  else if AFileName.EndsWith('sonar-project.properties.template') then
    AContent := 'sonar.projectKey=MeuProjetoDelphi' + #13#10 +
                'sonar.projectName=Meu Projeto Delphi' + #13#10 +
                'sonar.projectVersion=1.0.0'
  else if AFileName.EndsWith('run_sonar.bat.template') then
    AContent := '@echo off' + #13#10 + 'echo MOCK RUN SONAR'
  else if AFileName.EndsWith('scripts/generate_coverage.ps1') then
    AContent := '# MOCK GENERATE COVERAGE'
  else if AFileName.EndsWith('SKILL.md') then
    AContent := '---' + #13#10 + 'name: MockSkill' + #13#10 + 'description: Mock description' + #13#10 + '---' + #13#10 + '# Mock Skill Content'
  else
    Exit(False);

  Result := True;
end;

function TAgentKitMockNetClient.CreateSonarProject(const AServerUrl, AToken, AProjectKey, AProjectName: string; out AErrorMsg: string): Boolean;
begin
  AErrorMsg := '';
  if FSimulateNetworkFailure then
  begin
    AErrorMsg := 'Connection refused or server offline';
    Exit(False);
  end;

  if FSimulateInvalidToken then
  begin
    AErrorMsg := 'Invalid credentials / token';
    Exit(False);
  end;

  if FSimulateProjectExists then
  begin
    AErrorMsg := 'Could not create Project, key already exists';
    Exit(False);
  end;

  Result := True;
end;

end.
