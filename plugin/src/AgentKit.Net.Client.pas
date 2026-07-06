unit AgentKit.Net.Client;

interface

uses
  System.SysUtils, System.Classes, System.Net.HttpClient, AgentKit.Common.Interfaces;

type
  TAgentKitNetClient = class(TInterfacedObject, IAgentKitNetClient)
  private
    const BASE_URL = 'https://raw.githubusercontent.com/regyssilveira/AgentKit4D/main/';
    const TIMEOUT_MS = 2000;
    function GetClient: THttpClient;
  public
    function DownloadTemplate(const AFileName: string; out AContent: string): Boolean;
    function CreateSonarProject(const AServerUrl, AToken, AProjectKey, AProjectName: string; out AErrorMsg: string): Boolean;
  end;

implementation

uses
  System.NetEncoding;

{ TAgentKitNetClient }

function TAgentKitNetClient.GetClient: THttpClient;
begin
  Result := THttpClient.Create;
  Result.ConnectionTimeout := TIMEOUT_MS;
  Result.ResponseTimeout := TIMEOUT_MS;
end;

function TAgentKitNetClient.DownloadTemplate(const AFileName: string; out AContent: string): Boolean;
var
  LClient: THttpClient;
  LResponse: IHTTPResponse;
  LUrl: string;
begin
  AContent := '';
  LClient := GetClient;
  try
    try
      LUrl := BASE_URL + AFileName;
      LResponse := LClient.Get(LUrl);
      if LResponse.StatusCode = 200 then
      begin
        AContent := LResponse.ContentAsString(TEncoding.UTF8);
        Result := True;
      end
      else
      begin
        Result := False;
      end;
    except
      Result := False;
    end;
  finally
    LClient.Free;
  end;
end;

// O SonarQube aceita autenticação via Token de duas formas:
// 1. Enviando o token codificado em Base64 no header 'Authorization: Basic <token_base64_com_colon>'
// onde o formato é 'Token:' (sem senha).
// 2. Usando CredentialsProvider com Username = Token e Password = ''.
function TAgentKitNetClient.CreateSonarProject(const AServerUrl, AToken, AProjectKey, AProjectName: string; out AErrorMsg: string): Boolean;
var
  LClient: THttpClient;
  LResponse: IHTTPResponse;
  LParams: TStringList;
  LUrl: string;
begin
  AErrorMsg := '';
  LClient := GetClient;
  LParams := TStringList.Create;
  try
    try
      LClient.CustomHeaders['Authorization'] := 'Basic ' + TNetEncoding.Base64.Encode(AToken + ':').Trim;

      LUrl := IncludeTrailingPathDelimiter(AServerUrl) + 'api/projects/create';
      
      LParams.Values['project'] := AProjectKey;
      LParams.Values['name'] := AProjectName;

      LResponse := LClient.Post(LUrl, LParams, nil, TEncoding.UTF8);
      
      if LResponse.StatusCode = 200 then
      begin
        Result := True;
      end
      else
      begin
        AErrorMsg := LResponse.ContentAsString(TEncoding.UTF8);
        if AErrorMsg.IsEmpty then
          AErrorMsg := 'HTTP Error ' + LResponse.StatusCode.ToString;
        Result := False;
      end;
    except
      on E: Exception do
      begin
        AErrorMsg := E.Message;
        Result := False;
      end;
    end;
  finally
    LParams.Free;
    LClient.Free;
  end;
end;

end.
