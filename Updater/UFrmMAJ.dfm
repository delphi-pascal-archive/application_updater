object FrmMAJ: TFrmMAJ
  Left = 223
  Top = 131
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Updater'
  ClientHeight = 297
  ClientWidth = 530
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 16
  object pTop: TPanel
    Left = 0
    Top = 0
    Width = 530
    Height = 35
    Align = alTop
    Alignment = taLeftJustify
    Color = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
    object Fond: TShape
      Left = 1
      Top = 1
      Width = 528
      Height = 33
      Align = alClient
      Pen.Style = psClear
    end
    object LblTopInfo: TLabel
      Left = 1
      Top = 1
      Width = 528
      Height = 33
      Align = alClient
      AutoSize = False
      Caption = '  Installation'
      Color = clWhite
      ParentColor = False
      Layout = tlCenter
    end
  end
  object pCenter: TPanel
    Left = 0
    Top = 35
    Width = 530
    Height = 224
    Align = alClient
    TabOrder = 1
    object LblInfo: TLabel
      Left = 8
      Top = 8
      Width = 485
      Height = 65
      AutoSize = False
      Caption = 'Aucune mise a jour n'#39'a ete trouvee.'
      WordWrap = True
    end
    object LblInfo2: TLabel
      Left = 8
      Top = 136
      Width = 513
      Height = 73
      AutoSize = False
      Layout = tlBottom
      WordWrap = True
    end
    object PB: TProgressBar
      Left = 8
      Top = 79
      Width = 513
      Height = 23
      TabOrder = 0
    end
    object PB2: TProgressBar
      Left = 8
      Top = 109
      Width = 513
      Height = 23
      TabOrder = 1
    end
  end
  object pBottom: TPanel
    Left = 0
    Top = 259
    Width = 530
    Height = 38
    Align = alBottom
    TabOrder = 2
    object BtnNext: TButton
      Left = 312
      Top = 6
      Width = 97
      Height = 27
      Caption = 'Next >'
      TabOrder = 0
      OnClick = BtnNextClick
    end
    object BtnCancel: TButton
      Left = 208
      Top = 6
      Width = 97
      Height = 27
      Caption = 'Exit'
      TabOrder = 1
      OnClick = BtnCancelClick
    end
    object BtnHide: TButton
      Left = 416
      Top = 8
      Width = 105
      Height = 25
      Caption = 'Hide'
      TabOrder = 2
      OnClick = BtnHideClick
    end
  end
end
