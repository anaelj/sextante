unit uPopup;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls;

type
  TFormPopup = class(TForm)
    Rectangle1: TRectangle;
    btnPLDividaLiquida: TSpeedButton;
    btnCotacao: TSpeedButton;
    btnTodos: TSpeedButton;
    btnDividendos: TSpeedButton;
    btnBeta: TSpeedButton;
    btnClose: TSpeedButton;
    StyleBook1: TStyleBook;
    procedure btnPLDividaLiquidaClick(Sender: TObject);
    procedure btnBetaClick(Sender: TObject);
    procedure btnCotacaoClick(Sender: TObject);
    procedure btnDividendosClick(Sender: TObject);
    procedure btnTodosClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormPopup: TFormPopup;

implementation

{$R *.fmx}


uses uDataModule, uDividendos, Loading;

procedure TFormPopup.btnPLDividaLiquidaClick(Sender: TObject);
begin

  TLoading.Show(FormDividendos, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormDividendos.cargaPLeDividaLiquida;

      TThread.Synchronize(nil,
        procedure
        begin
          TLoading.Hide;
        end);

    end).Start;

  close;
end;

procedure TFormPopup.btnCloseClick(Sender: TObject);
begin
  close;
end;

procedure TFormPopup.btnCotacaoClick(Sender: TObject);
begin
  TLoading.Show(FormDividendos, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      try
        FormDividendos.AtualizaPapeis;
      except
      end;

      TThread.Synchronize(nil,
        procedure
        begin
          TLoading.Hide;
        end);

    end).Start;
  close;
end;

procedure TFormPopup.btnTodosClick(Sender: TObject);
begin
  TLoading.Show(FormDividendos, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormDividendos.AtualizaPapeis;
      FormDividendos.cargaInicialDividendos;
      FormDividendos.cargaBeta;
      FormDividendos.cargaPLeDividaLiquida;
      DataModule.FDQueryPapelCadastro.Open;

      TThread.Synchronize(nil,
        procedure
        begin
          TLoading.Hide;
        end);

    end).Start;
  close;

end;

procedure TFormPopup.btnDividendosClick(Sender: TObject);
begin
  TLoading.Show(FormDividendos, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormDividendos.cargaInicialDividendos;

      TThread.Synchronize(nil,
        procedure
        begin
          TLoading.Hide;
        end);

    end).Start;
  close;
end;

procedure TFormPopup.btnBetaClick(Sender: TObject);
begin
  TLoading.Show(FormDividendos, 'Buscando dados...');

  TThread.CreateAnonymousThread(
    procedure
    begin
      FormDividendos.cargaBeta;

      TThread.Synchronize(nil,
        procedure
        begin
          TLoading.Hide;
        end);

    end).Start;

  close;
end;

end.
