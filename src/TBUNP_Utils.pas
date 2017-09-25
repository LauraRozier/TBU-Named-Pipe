unit TBUNP_Utils;

interface

procedure FreeThenNil(var Obj);

implementation

{ By: Krom Stern }
procedure FreeThenNil(var Obj);
begin
  TObject(Obj).Free;
  Pointer(Obj) := nil;
end;

end.
