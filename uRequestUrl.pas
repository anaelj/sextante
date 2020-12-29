unit uRequestUrl;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, REST.Types, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope;

type
  TFormRequestUrl = class(TForm)
    RESTClientUrl: TRESTClient;
    RESTRequestUrl: TRESTRequest;
    RESTResponseUrl: TRESTResponse;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormRequestUrl: TFormRequestUrl;

implementation

{$R *.fmx}

end.

