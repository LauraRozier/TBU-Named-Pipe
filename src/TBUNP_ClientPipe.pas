unit TBUNP_ClientPipe;

interface

uses
  SysUtils, Classes, Pipes;

type
  TPipeClientDisconnectCallback = procedure(aPipe: Cardinal); stdcall;
  TPipeClientErrorCallback      = procedure(aPipe: Cardinal;
                                            aPipeContext: ShortInt;
                                            aErrorCode: Integer); stdcall;
  TPipeClientMessageCallback    = procedure(aPipe: Cardinal;
                                            aMsg: PChar); stdcall;
  TPipeClientSentCallback       = procedure(aPipe: Cardinal;
                                            aSize: Cardinal); stdcall;

  TTBUNP_ClientPipe = class(TObject)
    private
      FPipeClient: TPipeClient;
      procedure OPCDCB(aSender: TObject; aPipe: HPIPE);
      procedure OPCECB(aSender: TObject; aPipe: HPIPE;
                       aPipeContext: TPipeContext; aErrorCode: Integer);
      procedure OPCMCB(aSender: TObject; aPipe: HPIPE; aStream: TStream);
      procedure OPCSCB(aSender: TObject; aPipe: HPIPE; aSize: Cardinal);
    public
      OnPipeClientDisconnectCallback: TPipeClientDisconnectCallback;
      OnPipeClientErrorCallback:      TPipeClientErrorCallback;
      OnPipeClientMessageCallback:    TPipeClientMessageCallback;
      OnPipeClientSentCallback:       TPipeClientSentCallback;
      constructor Create;
      destructor Destroy; override;
      function Connect: Boolean; overload;
      function Connect(aPipeName: string): Boolean; overload;
      function ConnectRemote(aServername: string): Boolean; overload;
      function ConnectRemote(aServername, aPipeName: string): Boolean; overload;
      procedure Disconnect;
      function Send(const aMsg: PChar): Boolean;
      function GetPipeId: HPIPE;
  end;

var
  gClientPipe: TTBUNP_ClientPipe;

implementation

constructor TTBUNP_ClientPipe.Create;
begin
  //
end;

destructor TTBUNP_ClientPipe.Destroy;
begin
  Disconnect;
end;

function TTBUNP_ClientPipe.Connect: Boolean;
begin
  if FPipeClient <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result := FPipeClient.Connect(2000, True);

  if not Result then
  begin
    FPipeClient.Disconnect;
    FreeAndNil(FPipeClient);
  end;
end;

function TTBUNP_ClientPipe.Connect(aPipeName: string): Boolean;
begin
  if FPipeClient <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.PipeName         := aPipeName;
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result := FPipeClient.Connect(2000, True);

  if not Result then
  begin
    FPipeClient.Disconnect;
    FreeAndNil(FPipeClient);
  end;
end;

function TTBUNP_ClientPipe.ConnectRemote(aServername: string): Boolean;
begin
  if FPipeClient <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.ServerName       := aServerName;
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result := FPipeClient.Connect(2000, True);

  if not Result then
  begin
    FPipeClient.Disconnect;
    FreeAndNil(FPipeClient);
  end;
end;

function TTBUNP_ClientPipe.ConnectRemote(aServername, aPipeName: string): Boolean;
begin
  if FPipeClient <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.ServerName       := aServerName;
  FPipeClient.PipeName         := aPipeName;
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result := FPipeClient.Connect(2000, True);

  if not Result then
  begin
    FPipeClient.Disconnect;
    FreeAndNil(FPipeClient);
  end;
end;

procedure TTBUNP_ClientPipe.Disconnect;
begin
  if FPipeClient = nil then
    Exit;

  FPipeClient.Disconnect;
  FreeAndNil(FPipeClient);
end;

function TTBUNP_ClientPipe.Send(const aMsg: PChar): Boolean;
begin
  if (FPipeClient = nil) or
     (not FPipeClient.Connected) or
     (Length(aMsg) <= 0) then
  begin
    Result := False;
    Exit;
  end;

  Result := FPipeClient.Write(aMsg^, Length(aMsg) * SizeOf(Char));
end;

function TTBUNP_ClientPipe.GetPipeId: HPIPE;
begin
  if (FPipeClient = nil) or (not FPipeClient.Connected) then
  begin
    Result := 0;
    Exit;
  end;

  Result := FPipeClient.Pipe;
end;

procedure TTBUNP_ClientPipe.OPCDCB(aSender: TObject; aPipe: HPIPE);
begin
  if Assigned(OnPipeClientDisconnectCallback) then
    OnPipeClientDisconnectCallback(Cardinal(aPipe));
end;

procedure TTBUNP_ClientPipe.OPCECB(aSender: TObject; aPipe: HPIPE;
                                   aPipeContext: TPipeContext;
                                   aErrorCode: Integer);
begin
  if Assigned(OnPipeClientErrorCallback) then
    OnPipeClientErrorCallback(
      Cardinal(aPipe),
      ShortInt(aPipeContext),
      aErrorCode
    );
end;

procedure TTBUNP_ClientPipe.OPCMCB(aSender: TObject; aPipe: HPIPE;
                                   aStream: TStream);
var
  msg: string;
begin
  if Assigned(OnPipeClientMessageCallback) then
  begin
    SetLength(msg, aStream.Size div SizeOf(Char));
    aStream.Position := 0;
    aStream.Read(msg[1], aStream.Size);

    OnPipeClientMessageCallback(Cardinal(aPipe), PChar(msg));
  end;
end;

procedure TTBUNP_ClientPipe.OPCSCB(aSender: TObject; aPipe: HPIPE;
                                   aSize: Cardinal);
begin
  if Assigned(OnPipeClientSentCallback) then
    OnPipeClientSentCallback(Cardinal(aPipe), aSize);
end;

initialization

finalization

end.
