program Sextante;

uses
  System.StartUpCopy,
  FMX.Forms,
  uDividendos in 'uDividendos.pas' {FormDividendos},
  uDataModule in 'uDataModule.pas' {DataModule},
  uPopup in 'uPopup.pas' {FormPopup},
  Loading in '..\comum\Loading.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDataModule, DataModule);
  Application.CreateForm(TFormDividendos, FormDividendos);
  Application.CreateForm(TFormPopup, FormPopup);
  Application.Run;
end.
