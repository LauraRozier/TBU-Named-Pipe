unit TBUNP_ServerPipe;

interface

uses
  SysUtils, Classes, Pipes;

type
  TPSConnectCb    = procedure(aPipe: Cardinal) of object; stdcall;
  TPSDisconnectCb = procedure(aPipe: Cardinal) of object; stdcall;
  TPSErrorCb      = procedure(aPipe: Cardinal;
                              aPipeContext: ShortInt;
                              aErrorCode: Integer) of object; stdcall;
  TPSMessageCb    = procedure(aPipe: Cardinal;
                              aMsg: PWideChar) of object; stdcall;
  TPSSentCb       = procedure(aPipe: Cardinal;
                              aSize: Cardinal) of object; stdcall;

  TTBUNP_ServerPipe = class(TObject)
    private
      FPipeServer: TPipeServer;
      procedure OPSCCB(aSender: TObject; aPipe: HPIPE);
      procedure OPSDCB(aSender: TObject; aPipe: HPIPE);
      procedure OPSECB(aSender: TObject; aPipe: HPIPE;
                       aPipeContext: TPipeContext; aErrorCode: Integer);
      procedure OPSMCB(aSender: TObject; aPipe: HPIPE; aStream: TStream);
      procedure OPSSCB(aSender: TObject; aPipe: HPIPE; aSize: Cardinal);
    public
      OnPipeServerConnectCallback:    TPSConnectCb;
      OnPipeServerDisconnectCallback: TPSDisconnectCb;
      OnPipeServerErrorCallback:      TPSErrorCb;
      OnPipeServerMessageCallback:    TPSMessageCb;
      OnPipeServerSentCallback:       TPSSentCb;
      constructor Create;
      destructor Destroy; override;
      function Start: Boolean; overload;
      function Start(aPipeName: PWideChar): Boolean; overload;
      procedure Stop;
      function Broadcast(aMsg: PWideChar): Boolean;
      function Send(aPipe: HPIPE; aMsg: PWideChar): Boolean;
      function Disconnect(aPipe: HPIPE): Boolean;
      function GetClientCount: Integer;
  end;

var
  gServerPipe: TTBUNP_ServerPipe;

implementation

constructor TTBUNP_ServerPipe.Create;
begin
  // Place-holder
end;

destructor TTBUNP_ServerPipe.Destroy;
begin
  Stop;
  inherited;
end;

function TTBUNP_ServerPipe.Start: Boolean;
begin
  if FPipeServer <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeServer                  := TPipeServer.CreateUnowned;
  FPipeServer.Active           := False;
  FPipeServer.OnPipeConnect    := OPSCCB;
  FPipeServer.OnPipeDisconnect := OPSDCB;
  FPipeServer.OnPipeError      := OPSECB;
  FPipeServer.OnPipeMessage    := OPSMCB;
  FPipeServer.OnPipeSent       := OPSSCB;

  FPipeServer.Active := True;
  sleep(100);
  Result := FPipeServer.Active;

  if not Result then
    FreeAndNil(FPipeServer);
end;

function TTBUNP_ServerPipe.Start(aPipeName: PWideChar): Boolean;
begin
  if FPipeServer <> nil then
  begin
    Result := False;
    Exit;
  end;

  FPipeServer                  := TPipeServer.CreateUnowned;
  FPipeServer.Active           := False;
  FPipeServer.PipeName         := StrPas(aPipeName);
  FPipeServer.OnPipeConnect    := OPSCCB;
  FPipeServer.OnPipeDisconnect := OPSDCB;
  FPipeServer.OnPipeError      := OPSECB;
  FPipeServer.OnPipeMessage    := OPSMCB;
  FPipeServer.OnPipeSent       := OPSSCB;

  FPipeServer.Active := True;
  sleep(100);
  Result := FPipeServer.Active;

  if not Result then
    FreeAndNil(FPipeServer);
end;

procedure TTBUNP_ServerPipe.Stop;
begin
  if FPipeServer = nil then
    Exit;

  FPipeServer.Active := False;
  sleep(100);
  FreeAndNil(FPipeServer);
end;

function TTBUNP_ServerPipe.Broadcast(aMsg: PWideChar): Boolean;
begin
  if (FPipeServer = nil) or
     (not FPipeServer.Active) or
     (Length(aMsg) <= 0) then
  begin
    Result := False;
    Exit;
  end;

  Result := FPipeServer.Broadcast(aMsg^, Length(aMsg) * SizeOf(WideChar));
end;

function TTBUNP_ServerPipe.Send(aPipe: HPIPE; aMsg: PWideChar): Boolean;
begin
  if (FPipeServer = nil) or
     (not FPipeServer.Active) or
     (Length(aMsg) <= 0) then
  begin
    Result := False;
    Exit;
  end;

  Result := FPipeServer.Write(aPipe, aMsg^, Length(aMsg) * SizeOf(WideChar));
end;

function TTBUNP_ServerPipe.Disconnect(aPipe: HPIPE): Boolean;
begin
  if (FPipeServer = nil) or (not FPipeServer.Active) then
  begin
    Result := False;
    Exit;
  end;

  Result := FPipeServer.Disconnect(aPipe);
end;

function TTBUNP_ServerPipe.GetClientCount: Integer;
begin
  if (FPipeServer = nil) or (not FPipeServer.Active) then
  begin
    Result := 0;
    Exit;
  end;

  Result := FPipeServer.ClientCount;
end;

{
  Callback handling
}
procedure TTBUNP_ServerPipe.OPSCCB(aSender: TObject; aPipe: HPIPE);
begin
  if Assigned(OnPipeServerConnectCallback) then
    OnPipeServerConnectCallback(Cardinal(aPipe));
end;

procedure TTBUNP_ServerPipe.OPSDCB(aSender: TObject; aPipe: HPIPE);
begin
  if Assigned(OnPipeServerDisconnectCallback) then
    OnPipeServerDisconnectCallback(Cardinal(aPipe));
end;

procedure TTBUNP_ServerPipe.OPSECB(aSender: TObject; aPipe: HPIPE;
                                   aPipeContext: TPipeContext;
                                   aErrorCode: Integer);
begin
  if Assigned(OnPipeServerErrorCallback) then
    OnPipeServerErrorCallback(Cardinal(aPipe),
                              ShortInt(aPipeContext),
                              aErrorCode);
end;

procedure TTBUNP_ServerPipe.OPSMCB(aSender: TObject; aPipe: HPIPE;
                                   aStream: TStream);
var
  msg: WideString;
begin
  if Assigned(OnPipeServerMessageCallback) then
  begin
    SetLength(msg, aStream.Size div SizeOf(Char));
    aStream.Position := 0;
    aStream.Read(msg[1], aStream.Size);

    OnPipeServerMessageCallback(Cardinal(aPipe), PWideChar(msg));
  end;
end;

procedure TTBUNP_ServerPipe.OPSSCB(aSender: TObject; aPipe: HPIPE;
                                   aSize: Cardinal);
begin
  if Assigned(OnPipeServerSentCallback) then
    OnPipeServerSentCallback(Cardinal(aPipe), aSize);
end;

initialization

finalization

end.
