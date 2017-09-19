unit TBUNP_Exports;

interface

uses
  SysUtils, Classes, Pipes,
  TBUNP_ServerPipe, TBUNP_ClientPipe;

{ Declare Pipe Server Procedures }
procedure PipeServerInitialize; stdcall; export;
procedure PipeServerDestroy; stdcall; export;
function PipeServerStart: WordBool; stdcall; export;
function PipeServerStartNamed(aPipeName: PWideChar): WordBool; stdcall; export;
procedure PipeServerStop; stdcall; export;
function PipeServerBroadcast(aMsg: PWideChar): WordBool; stdcall; export;
function PipeServerSend(aPipe: Cardinal; aMsg: PWideChar): WordBool; stdcall; export;
function PipeServerDisconnect(aPipe: Cardinal): WordBool; stdcall; export;
function PipeServerGetClientCount: Integer; stdcall; export;
{ Declare Pipe Server Callback Registration Procedures }
procedure RegisterOnPipeServerConnectCallback(const aCallback: TPSConnectCb); stdcall; export;
procedure RegisterOnPipeServerDisconnectCallback(const aCallback: TPSDisconnectCb); stdcall; export;
procedure RegisterOnPipeServerErrorCallback(const aCallback: TPSErrorCb); stdcall; export;
procedure RegisterOnPipeServerMessageCallback(const aCallback: TPSMessageCb); stdcall; export;
procedure RegisterOnPipeServerSentCallback(const aCallback: TPSSentCb); stdcall; export;
{ Declare Pipe Client Procedures }
procedure PipeClientInitialize; stdcall; export;
procedure PipeClientDestroy; stdcall; export;
function PipeClientConnect: WordBool; stdcall; export;
function PipeClientConnectNamed(aPipeName: PWideChar): WordBool; stdcall; export;
function PipeClientConnectRemote(aServerName: PWideChar): WordBool; stdcall; export;
function PipeClientConnectRemoteNamed(aServerName, aPipeName: PWideChar): WordBool; stdcall; export;
function PipeClientSend(aMsg: PWideChar): WordBool; stdcall; export;
procedure PipeClientDisconnect; stdcall; export;
function PipeClientGetPipeId: Cardinal; stdcall; export;
{ Declare Pipe Client Callback Registration Procedures }
procedure RegisterOnPipeClientDisconnectCallback(const aCallback: TPCDisconnectCb); stdcall; export;
procedure RegisterOnPipeClientErrorCallback(const aCallback: TPCErrorCb); stdcall; export;
procedure RegisterOnPipeClientMessageCallback(const aCallback: TPCMessageCb); stdcall; export;
procedure RegisterOnPipeClientSentCallback(const aCallback: TPCSentCb); stdcall; export;

exports
  { Declare Pipe Server Procedures }
  PipeServerInitialize,
  PipeServerDestroy,
  PipeServerStart,
  PipeServerStartNamed,
  PipeServerStop,
  PipeServerBroadcast,
  PipeServerSend,
  PipeServerDisconnect,
  PipeServerGetClientCount,
  { Declare Pipe Server Callback Registration Procedures }
  RegisterOnPipeServerConnectCallback,
  RegisterOnPipeServerDisconnectCallback,
  RegisterOnPipeServerErrorCallback,
  RegisterOnPipeServerMessageCallback,
  RegisterOnPipeServerSentCallback,
  { Declare Pipe Client Procedures }
  PipeClientInitialize,
  PipeClientDestroy,
  PipeClientConnect,
  PipeClientConnectNamed,
  PipeClientConnectRemote,
  PipeClientConnectRemoteNamed,
  PipeClientSend,
  PipeClientDisconnect,
  PipeClientGetPipeId,
  { Declare Pipe Client Callback Registration Procedures }
  RegisterOnPipeClientDisconnectCallback,
  RegisterOnPipeClientErrorCallback,
  RegisterOnPipeClientMessageCallback,
  RegisterOnPipeClientSentCallback;

implementation

{ Declare Pipe Server Procedures }
procedure PipeServerInitialize; stdcall; export;
begin
  gServerPipe := TTBUNP_ServerPipe.Create;
end;

procedure PipeServerDestroy; stdcall; export;
begin
  FreeAndNil(gServerPipe);
end;

function PipeServerStart: WordBool; stdcall; export;
begin
  Result := WordBool(gServerPipe.Start);
end;

function PipeServerStartNamed(aPipeName: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gServerPipe.Start(aPipeName));
end;

procedure PipeServerStop; stdcall; export;
begin
  gServerPipe.Stop;
end;

function PipeServerBroadcast(aMsg: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gServerPipe.Broadcast(aMsg));
end;

function PipeServerSend(aPipe: Cardinal; aMsg: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gServerPipe.Send(HPIPE(aPipe), aMsg));
end;

function PipeServerDisconnect(aPipe: Cardinal): WordBool; stdcall; export;
begin
  Result := WordBool(gServerPipe.Disconnect(HPIPE(aPipe)));
end;

function PipeServerGetClientCount: Integer; stdcall; export;
begin
  Result := gServerPipe.GetClientCount;
end;

{ Declare Pipe Server Callback Registration Procedures }
procedure RegisterOnPipeServerConnectCallback(const aCallback: TPSConnectCb); stdcall; export;
begin
  gServerPipe.OnPipeServerConnectCallback := aCallback;
end;

procedure RegisterOnPipeServerDisconnectCallback(const aCallback: TPSDisconnectCb); stdcall; export;
begin
  gServerPipe.OnPipeServerDisconnectCallback := aCallback;
end;

procedure RegisterOnPipeServerErrorCallback(const aCallback: TPSErrorCb); stdcall; export;
begin
  gServerPipe.OnPipeServerErrorCallback := aCallback;
end;

procedure RegisterOnPipeServerMessageCallback(const aCallback: TPSMessageCb); stdcall; export;
begin
  gServerPipe.OnPipeServerMessageCallback := aCallback;
end;

procedure RegisterOnPipeServerSentCallback(const aCallback: TPSSentCb); stdcall; export;
begin
  gServerPipe.OnPipeServerSentCallback := aCallback;
end;

{ Declare Pipe Client Procedures }
procedure PipeClientInitialize; stdcall; export;
begin
  gClientPipe := TTBUNP_ClientPipe.Create;
end;

procedure PipeClientDestroy; stdcall; export;
begin
  FreeAndNil(gClientPipe);
end;

function PipeClientConnect: WordBool; stdcall; export;
begin
  Result := WordBool(gClientPipe.Connect);
end;

function PipeClientConnectNamed(aPipeName: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gClientPipe.Connect(aPipeName));
end;

function PipeClientConnectRemote(aServerName: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gClientPipe.ConnectRemote(aServerName));
end;

function PipeClientConnectRemoteNamed(aServerName, aPipeName: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gClientPipe.ConnectRemote(aServerName, aPipeName));
end;

function PipeClientSend(aMsg: PWideChar): WordBool; stdcall; export;
begin
  Result := WordBool(gClientPipe.Send(aMsg));
end;

procedure PipeClientDisconnect; stdcall; export;
begin
  gClientPipe.Disconnect;
end;

function PipeClientGetPipeId: Cardinal; stdcall; export;
begin
  Result := Cardinal(gClientPipe.GetPipeId);
end;

{ Declare Pipe Server Callback Registration Procedures }
procedure RegisterOnPipeClientDisconnectCallback(const aCallback: TPCDisconnectCb); stdcall; export;
begin
  gClientPipe.OnPipeClientDisconnectCallback := aCallback;
end;

procedure RegisterOnPipeClientErrorCallback(const aCallback: TPCErrorCb); stdcall; export;
begin
  gClientPipe.OnPipeClientErrorCallback := aCallback;
end;

procedure RegisterOnPipeClientMessageCallback(const aCallback: TPCMessageCb); stdcall; export;
begin
  gClientPipe.OnPipeClientMessageCallback := aCallback;
end;

procedure RegisterOnPipeClientSentCallback(const aCallback: TPCSentCb); stdcall; export;
begin
  gClientPipe.OnPipeClientSentCallback := aCallback;
end;

initialization

finalization

end.
