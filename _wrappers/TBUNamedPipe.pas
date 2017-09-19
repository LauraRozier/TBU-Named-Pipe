unit TBUNamedPipe;

interface

uses
  SysUtils;

const
  libName = 'TBUNamedPipe.dll';

type
  { Pipe Server Callbacks }
  TPSConnectCb    = procedure(aPipe: Cardinal) of object; stdcall;
  TPSDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  TPSErrorCb      = procedure(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer) of object; stdcall;
  TPSMessageCb    = procedure(aPipe: Cardinal; aMsg: PWideChar) of object; stdcall;
  TPSSentCb       = procedure(aPipe: Cardinal; aSize: Cardinal) of object; stdcall;

  { Pipe Client Callbacks }
  TPCDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  TPCErrorCb      = procedure(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer) of object; stdcall;
  TPCMessageCb    = procedure(aPipe: Cardinal; aMsg: PWideChar) of object; stdcall;
  TPCSentCb       = procedure(aPipe: Cardinal; aSize: Cardinal) of object; stdcall;

  { Pipe Server }
  // Methods
  procedure PipeServerInitialize;                                      stdcall;
  procedure PipeServerDestroy;                                         stdcall;
  function PipeServerStart: WordBool;                                  stdcall;
  function PipeServerStartNamed(aPipeName: PWideChar): WordBool;       stdcall;
  procedure PipeServerStop;                                            stdcall;
  function PipeServerBroadcast(aMsg: PWideChar): WordBool;             stdcall;
  function PipeServerSend(aPipe: Cardinal; aMsg: PWideChar): WordBool; stdcall;
  function PipeServerDisconnect(aPipe: Cardinal): WordBool;            stdcall;
  function PipeServerGetClientCount: Integer;                          stdcall;
  // Callback registration
  procedure RegisterOnPipeServerConnectCallback(const aCallback: TPSConnectCb);       stdcall;
  procedure RegisterOnPipeServerDisconnectCallback(const aCallback: TPSDisconnectCb); stdcall;
  procedure RegisterOnPipeServerErrorCallback(const aCallback: TPSErrorCb);           stdcall;
  procedure RegisterOnPipeServerMessageCallback(const aCallback: TPSMessageCb);       stdcall;
  procedure RegisterOnPipeServerSentCallback(const aCallback: TPSSentCb);             stdcall;

  { Pipe Client }
  // Methods
  procedure PipeClientInitialize;                                                     stdcall;
  procedure PipeClientDestroy;                                                        stdcall;
  function PipeClientConnect: WordBool;                                               stdcall;
  function PipeClientConnectNamed(aPipeName: PWideChar): WordBool;                    stdcall;
  function PipeClientConnectRemote(aServerName: PWideChar): WordBool;                 stdcall;
  function PipeClientConnectRemoteNamed(aServerName, aPipeName: PWideChar): WordBool; stdcall;
  function PipeClientSend(aMsg: PWideChar): WordBool;                                 stdcall;
  procedure PipeClientDisconnect;                                                     stdcall;
  function PipeClientGetPipeId: Cardinal;                                             stdcall;
  // Callback registration
  procedure RegisterOnPipeClientDisconnectCallback(const aCallback: TPCDisconnectCb); stdcall;
  procedure RegisterOnPipeClientErrorCallback(const aCallback: TPCErrorCb);           stdcall;
  procedure RegisterOnPipeClientMessageCallback(const aCallback: TPCMessageCb);       stdcall;
  procedure RegisterOnPipeClientSentCallback(const aCallback: TPCSentCb);             stdcall;

  { PipeUtils }
  function PipeContextToString(aPipeContext: ShortInt): string;

implementation

{ Pipe Server }
// Methods
procedure PipeServerInitialize;    external libName;
procedure PipeServerDestroy;       external libName;
function PipeServerStart;          external libName;
function PipeServerStartNamed;     external libName;
procedure PipeServerStop;          external libName;
function PipeServerBroadcast;      external libName;
function PipeServerSend;           external libName;
function PipeServerDisconnect;     external libName;
function PipeServerGetClientCount; external libName;
// Callback registration
procedure RegisterOnPipeServerConnectCallback;    external libName;
procedure RegisterOnPipeServerDisconnectCallback; external libName;
procedure RegisterOnPipeServerErrorCallback;      external libName;
procedure RegisterOnPipeServerMessageCallback;    external libName;
procedure RegisterOnPipeServerSentCallback;       external libName;

{ Pipe Client }
// Methods
procedure PipeClientInitialize;        external libName;
procedure PipeClientDestroy;           external libName;
function PipeClientConnect;            external libName;
function PipeClientConnectNamed;       external libName;
function PipeClientConnectRemote;      external libName;
function PipeClientConnectRemoteNamed; external libName;
function PipeClientSend;               external libName;
procedure PipeClientDisconnect;        external libName;
function PipeClientGetPipeId;          external libName;
// Callback registration
procedure RegisterOnPipeClientDisconnectCallback; external libName;
procedure RegisterOnPipeClientErrorCallback;      external libName;
procedure RegisterOnPipeClientMessageCallback;    external libName;
procedure RegisterOnPipeClientSentCallback;       external libName;

{ PipeUtils }
function PipeContextToString(aPipeContext: ShortInt): string;
begin
  case aPipeContext of
    0: Result := 'Listener';
    1: Result := 'Worker';
    else raise Exception.Create('Unknown Pipe Context ID');
  end;
end;

initialization

finalization

end.
