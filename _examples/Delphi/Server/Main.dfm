object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 350
  ClientWidth = 635
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    635
    350)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 322
    Width = 97
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Broadcast Message:'
  end
  object Label2: TLabel
    Left = 8
    Top = 20
    Width = 21
    Height = 13
    Anchors = [akLeft, akBottom]
    Caption = 'Log:'
  end
  object Button1: TButton
    Left = 552
    Top = 317
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Send'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 111
    Top = 319
    Width = 435
    Height = 21
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 1
  end
  object Memo1: TMemo
    Left = 8
    Top = 39
    Width = 619
    Height = 272
    Anchors = [akLeft, akTop, akRight, akBottom]
    ReadOnly = True
    TabOrder = 2
  end
  object Button2: TButton
    Left = 552
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Stop Server'
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 463
    Top = 8
    Width = 75
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Start Server'
    TabOrder = 4
    OnClick = Button3Click
  end
end
