unit TBUNamedPipe;

interface

uses
  SysUtils;

const
  /// <summary>
  /// The file name of the lib to load
  /// </summary>
  libName = 'TBUNamedPipe.dll';

{ PipeUtils }
/// <summary>
/// Translates a context ID to it's string value
/// </summary>
/// <param name="aPipe">[ Cardinal ] The context ID</param>
/// <returns>[ string ] The name of the context</returns>
function PipeContextToString(aPipeContext: ShortInt): string;

type
  { Pipe Server Callbacks }
  /// <summary>
  /// OnConnect callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  TPSConnectCb    = procedure(aPipe: Cardinal) of object; stdcall;
  /// <summary>
  /// OnDisconnect callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  TPSDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  /// <summary>
  /// OnError callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aPipeContext">[ ShortInt ] The error context</param>
  /// <param name="aErrorCode">[ Integer ] The error code</param>
  TPSErrorCb      = procedure(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer) of object; stdcall;
  /// <summary>
  /// OnMessage callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aMsg">[ PWideChar ] The message</param>
  TPSMessageCb    = procedure(aPipe: Cardinal; aMsg: PWideChar) of object; stdcall;
  /// <summary>
  /// OnSent callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aSize">[ Cardinal ] The size in bytes</param>
  TPSSentCb       = procedure(aPipe: Cardinal; aSize: Cardinal) of object; stdcall;

  { Pipe Client Callbacks }
  /// <summary>
  /// OnDisconnect callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  TPCDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  /// <summary>
  /// OnError callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aPipeContext">[ ShortInt ] The error context</param>
  /// <param name="aErrorCode">[ Integer ] The error code</param>
  TPCErrorCb      = procedure(aPipe: Cardinal; aPipeContext: ShortInt; aErrorCode: Integer) of object; stdcall;
  /// <summary>
  /// OnMessage callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aMsg">[ PWideChar ] The message</param>
  TPCMessageCb    = procedure(aPipe: Cardinal; aMsg: PWideChar) of object; stdcall;
  /// <summary>
  /// OnSent callback
  /// </summary>
  /// <param name="aPipe">[ Cardinal ] The pipe ID</param>
  /// <param name="aSize">[ Cardinal ] The size in bytes</param>
  TPCSentCb       = procedure(aPipe: Cardinal; aSize: Cardinal) of object; stdcall;

{ Pipe Server }
// Methods
/// <summary>
/// Initialize the pipe server class
/// </summary>
procedure PipeServerInitialize;                                      stdcall;
/// <summary>
/// Destroy the pipe server class
/// </summary>
procedure PipeServerDestroy;                                         stdcall;
/// <summary>
/// Start the pipe server listener thread
/// </summary>
/// <returns>[ WordBool ] True on success</returns>
function PipeServerStart: WordBool;                                  stdcall;
/// <summary>
/// Start the pipe server listener thread
/// </summary>
/// <param name="aPipeName">[ PWideChar ] The pipe name</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeServerStartNamed(aPipeName: PWideChar): WordBool;       stdcall;
/// <summary>
/// Stop the pipe server listener thread
/// </summary>
procedure PipeServerStop;                                            stdcall;
/// <summary>
/// Broadcast a message to all connected pipes
/// </summary>
/// <param name="aMsg">[ PWideChar ] The message</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeServerBroadcast(aMsg: PWideChar): WordBool;             stdcall;
/// <summary>
/// Send a message to the specified pipe
/// </summary>
/// <param name="aPipe">[ Cardinal ] Pipe ID</param>
/// <param name="aMsg">[ PWideChar ] The message</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeServerSend(aPipe: Cardinal; aMsg: PWideChar): WordBool; stdcall;
/// <summary>
/// Disconnect a specific pipe ( Use 0 [zero] for all connected pipes )
/// </summary>
/// <param name="aPipe">[ Cardinal ] Pipe ID</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeServerDisconnect(aPipe: Cardinal): WordBool;            stdcall;
/// <summary>
/// Retrieve the amount of connected pipes
/// </summary>
/// <returns>[ Integer ] The amount of pipes that are currently connected</returns>
function PipeServerGetClientCount: Integer;                          stdcall;
// Callback registration
/// <summary>
/// Register the OnConnect callback method
/// </summary>
/// <param name="aCallback">[ TPSConnectCb ] The callback method</param>
procedure RegisterOnPipeServerConnectCallback(const aCallback: TPSConnectCb);       stdcall;
/// <summary>
/// Register the OnDisconnect callback method
/// </summary>
/// <param name="aCallback">[ TPSDisconnectCb ] The callback method</param>
procedure RegisterOnPipeServerDisconnectCallback(const aCallback: TPSDisconnectCb); stdcall;
/// <summary>
/// Register the OnError callback method
/// </summary>
/// <param name="aCallback">[ TPSErrorCb ] The callback method</param>
procedure RegisterOnPipeServerErrorCallback(const aCallback: TPSErrorCb);           stdcall;
/// <summary>
/// Register the OnMessage callback method
/// </summary>
/// <param name="aCallback">[ TPSMessageCb ] The callback method</param>
procedure RegisterOnPipeServerMessageCallback(const aCallback: TPSMessageCb);       stdcall;
/// <summary>
/// Register the OnSent callback method
/// </summary>
/// <param name="aCallback">[ TPSSentCb ] The callback method</param>
procedure RegisterOnPipeServerSentCallback(const aCallback: TPSSentCb);             stdcall;

{ Pipe Client }
// Methods
/// <summary>
/// Initialize the pipe client class
/// </summary>
procedure PipeClientInitialize;                                                     stdcall;
/// <summary>
/// Destroy the pipe client class
/// </summary>
procedure PipeClientDestroy;                                                        stdcall;
/// <summary>
/// Connect to the local pipe server
/// </summary>
/// <returns>[ WordBool ] True on success</returns>
function PipeClientConnect: WordBool;                                               stdcall;
/// <summary>
/// Connect to the local pipe server
/// </summary>
/// <param name="aPipeName">[ PWideChar ] The pipe name</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeClientConnectNamed(aPipeName: PWideChar): WordBool;                    stdcall;
/// <summary>
/// Connect to a remote pipe server
/// </summary>
/// <param name="aServerName">[ PWideChar ] The server name ( Hostname )</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeClientConnectRemote(aServerName: PWideChar): WordBool;                 stdcall;
/// <summary>
/// Connect to a remote pipe server
/// </summary>
/// <param name="aServerName">[ PWideChar ] The server name ( Hostname )</param>
/// <param name="aPipeName">[ PWideChar ] The pipe name</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeClientConnectRemoteNamed(aServerName, aPipeName: PWideChar): WordBool; stdcall;
/// <summary>
/// Send a message to the pipe server
/// </summary>
/// <param name="aMsg">[ PWideChar ] The message</param>
/// <returns>[ WordBool ] True on success</returns>
function PipeClientSend(aMsg: PWideChar): WordBool;                                 stdcall;
/// <summary>
/// Disconnect from the pipe server
/// </summary>
procedure PipeClientDisconnect;                                                     stdcall;
/// <summary>
/// Get the ID of the current pipe
/// </summary>
/// <returns>[ Cardinal ] The pipe ID</returns>
function PipeClientGetPipeId: Cardinal;                                             stdcall;
// Callback registration
/// <summary>
/// Register the OnDisconnect callback method
/// </summary>
/// <param name="aCallback">[ TPCDisconnectCb ] The callback method</param>
procedure RegisterOnPipeClientDisconnectCallback(const aCallback: TPCDisconnectCb); stdcall;
/// <summary>
/// Register the OnError callback method
/// </summary>
/// <param name="aCallback">[ TPCErrorCb ] The callback method</param>
procedure RegisterOnPipeClientErrorCallback(const aCallback: TPCErrorCb);           stdcall;
/// <summary>
/// Register the OnMessage callback method
/// </summary>
/// <param name="aCallback">[ TPCMessageCb ] The callback method</param>
procedure RegisterOnPipeClientMessageCallback(const aCallback: TPCMessageCb);       stdcall;
/// <summary>
/// Register the OnSent callback method
/// </summary>
/// <param name="aCallback">[ TPCSentCb ] The callback method</param>
procedure RegisterOnPipeClientSentCallback(const aCallback: TPCSentCb);             stdcall;

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
