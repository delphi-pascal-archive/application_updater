object FrmDemo: TFrmDemo
  Left = 210
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Application Updater'
  ClientHeight = 282
  ClientWidth = 665
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 120
  TextHeight = 16
  object Image: TImage
    Left = 8
    Top = 8
    Width = 329
    Height = 265
    Stretch = True
  end
  object LblInfo: TLabel
    Left = 344
    Top = 257
    Width = 33
    Height = 16
    Caption = 'Info ...'
  end
  object Label1: TLabel
    Left = 344
    Top = 8
    Width = 71
    Height = 16
    Caption = 'Description:'
  end
  object memoDescription: TMemo
    Left = 344
    Top = 32
    Width = 313
    Height = 129
    Lines.Strings = (
      'No picture is available.'
      'Made by bets has day to acquire from it (several '
      'available modeles aleatoirement)!')
    ReadOnly = True
    TabOrder = 0
  end
  object BtnCheckMAJ: TButton
    Left = 344
    Top = 168
    Width = 313
    Height = 25
    Caption = 'Check to update ...'
    TabOrder = 1
    OnClick = BtnCheckMAJClick
  end
end
