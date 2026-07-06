program AgentKitTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
  DUnitX.TestFramework,
  DUnitX.Loggers.Console,
  AgentKit.Common.Interfaces in '..\src\AgentKit.Common.Interfaces.pas',
  AgentKit.Mocks.NetClient in 'AgentKit.Mocks.NetClient.pas',
  AgentKit.Mocks.FileSystem in 'AgentKit.Mocks.FileSystem.pas',
  AgentKit.Service.Init in '..\src\AgentKit.Service.Init.pas',
  AgentKit.Tests.Service.Init in 'AgentKit.Tests.Service.Init.pas';

var
  Runner: ITestRunner;
  Results: IRunResults;
  Logger: ITestLogger;
begin
  try
    Runner := TDUnitX.CreateRunner;
    Runner.UseRTTI := True;

    Logger := TDUnitXConsoleLogger.Create(True);
    Runner.AddLogger(Logger);

    Results := Runner.Execute;
    if not Results.AllPassed then
      System.ExitCode := 1;

    {$IFNDEF CI}
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Pressione [Enter] para sair...');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
end.
