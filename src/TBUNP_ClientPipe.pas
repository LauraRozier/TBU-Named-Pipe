unit TBUNP_ClientPipe;

interface

uses
  SysUtils, Classes, ExtCtrls,
  Pipes,
  TBUNP_Utils;

type
  TOwnState       = (ownsConnected, ownsDisconnected);
  TPCDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  TPCErrorCb      = procedure(aPipe: Cardinal;
                              aPipeContext: ShortInt;
                              aErrorCode: Integer) of object; stdcall;
  TPCMessageCb    = procedure(aPipe: Cardinal;
                              aMsg: PWideChar) of object; stdcall;
  TPCSentCb       = procedure(aPipe: Cardinal;
                              aSize: Cardinal) of object; stdcall;

  TTBUNP_ClientPipe = class(TObject)
    private
      FPipeClient:   TPipeClient;
      FOwnState:     TOwnState;
      FCleanupTimer: TTimer;
      procedure OPCDCB(aSender: TObject; aPipe: HPIPE);
      procedure OPCECB(aSender: TObject; aPipe: HPIPE;
                       aPipeContext: TPipeContext; aErrorCode: Integer);
      procedure OPCMCB(aSender: TObject; aPipe: HPIPE; aStream: TStream);
      procedure OPCSCB(aSender: TObject; aPipe: HPIPE; aSize: Cardinal);
      procedure FCleanupTimerTick(aSender: TObject);
    public
      OnPipeClientDisconnectCallback: TPCDisconnectCb;
      OnPipeClientErrorCallback:      TPCErrorCb;
      OnPipeClientMessageCallback:    TPCMessageCb;
      OnPipeClientSentCallback:       TPCSentCb;
      constructor Create;
      destructor Destroy; override;
      function Connect: Boolean; overload;
      function Connect(aPipeName: PWideChar): Boolean; overload;
      function ConnectRemote(aServername: PWideChar): Boolean; overload;
      function ConnectRemote(aServername, aPipeName: PWideChar): Boolean; overload;
      procedure Disconnect;
      function Send(aMsg: PWideChar): Boolean;
      function GetPipeId: HPIPE;
  end;

var
  gClientPipe: TTBUNP_ClientPipe;

implementation

constructor TTBUNP_ClientPipe.Create;
begin
  FOwnState              := ownsDisconnected;

  FCleanupTimer          := TTimer.Create(nil);
  FCleanupTimer.Enabled  := False;
  FCleanupTimer.Interval := 100;
  FCleanupTimer.OnTimer  := FCleanupTimerTick;
end;

destructor TTBUNP_ClientPipe.Destroy;
begin
  // Call local method Disconnect, as it disconnects and frees the resource
  Disconnect;
  FreeThenNil(FCleanupTimer);
  inherited;
end;

procedure TTBUNP_ClientPipe.FCleanupTimerTick(aSender: TObject);
begin
  if FPipeClient <> nil then
  begin
    try
      FreeThenNil(FPipeClient);
      // Disable the timer after successfull cleanup
      FCleanupTimer.Enabled := False;
      FOwnState             := ownsDisconnected;
    except
      Exit;
    end;
  end;
end;

function TTBUNP_ClientPipe.Connect: Boolean;
begin
  if FOwnState = ownsConnected then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result    := FPipeClient.Connect(2000, True);
  FOwnState := ownsConnected;

  // We must manually cleanup to prevent unexpected behaviour
  if not Result then
    Disconnect;
end;

function TTBUNP_ClientPipe.Connect(aPipeName: PWideChar): Boolean;
begin
  if FOwnState = ownsConnected then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.PipeName         := StrPas(aPipeName);
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result    := FPipeClient.Connect(2000, True);
  FOwnState := ownsConnected;

  // We must manually cleanup to prevent unexpected behaviour
  if not Result then
    Disconnect;
end;

function TTBUNP_ClientPipe.ConnectRemote(aServername: PWideChar): Boolean;
begin
  if FOwnState = ownsConnected then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.ServerName       := StrPas(aServerName);
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result    := FPipeClient.Connect(2000, True);
  FOwnState := ownsConnected;

  // We must manually cleanup to prevent unexpected behaviour
  if not Result then
    Disconnect;
end;

function TTBUNP_ClientPipe.ConnectRemote(aServername, aPipeName: PWideChar): Boolean;
begin
  if FOwnState = ownsConnected then
  begin
    Result := False;
    Exit;
  end;

  FPipeClient                  := TPipeClient.CreateUnowned;
  FPipeClient.ServerName       := StrPas(aServerName);
  FPipeClient.PipeName         := StrPas(aPipeName);
  FPipeClient.OnPipeDisconnect := OPCDCB;
  FPipeClient.OnPipeError      := OPCECB;
  FPipeClient.OnPipeMessage    := OPCMCB;
  FPipeClient.OnPipeSent       := OPCSCB;

  Result    := FPipeClient.Connect(2000, True);
  FOwnState := ownsConnected;

  // We must manually cleanup to prevent unexpected behaviour
  if not Result then
    Disconnect;
end;

procedure TTBUNP_ClientPipe.Disconnect;
begin
  if FOwnState = ownsConnected then
    FPipeClient.Disconnect;

  while FPipeClient <> nil do
    FreeThenNil(FPipeClient);

  FOwnState := ownsDisconnected;
end;

function TTBUNP_ClientPipe.Send(aMsg: PWideChar): Boolean;
begin
  if (FOwnState = ownsDisconnected) or
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
  if (FOwnState = ownsDisconnected) or
     (not FPipeClient.Connected) then
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

  FCleanupTimer.Enabled := True;
end;

procedure TTBUNP_ClientPipe.OPCECB(aSender: TObject; aPipe: HPIPE;
                                   aPipeContext: TPipeContext;
                                   aErrorCode: Integer);
begin
  if Assigned(OnPipeClientErrorCallback) then
    OnPipeClientErrorCallback(Cardinal(aPipe),
                              ShortInt(aPipeContext),
                              aErrorCode);
end;

procedure TTBUNP_ClientPipe.OPCMCB(aSender: TObject; aPipe: HPIPE;
                                   aStream: TStream);
var
  msg: WideString;
begin
  if Assigned(OnPipeClientMessageCallback) then
  begin
    SetLength(msg, aStream.Size div SizeOf(Char));
    aStream.Position := 0;
    aStream.Read(msg[1], aStream.Size);

    OnPipeClientMessageCallback(Cardinal(aPipe), PWideChar(msg));
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
