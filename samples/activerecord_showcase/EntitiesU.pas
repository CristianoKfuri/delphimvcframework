// *************************************************************************** }
//
// Delphi MVC Framework
//
// Copyright (c) 2010-2019 Daniele Teti and the DMVCFramework Team
//
// https://github.com/danieleteti/delphimvcframework
//
// ***************************************************************************
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// ***************************************************************************

unit EntitiesU;

interface

uses
  MVCFramework.Serializer.Commons,
  MVCFramework.ActiveRecord,
  System.Generics.Collections,
  System.Classes;

type

  [MVCNameCase(ncLowerCase)]
  [MVCTable('articles')]
  TArticle = class(TMVCActiveRecord)
  private
    [MVCTableField('ID')]
    fID: Integer;
    [MVCTableField('code')]
    fCodice: string;
    [MVCTableField('description')]
    fDescrizione: string;
    [MVCTableField('price')]
    fPrezzo: Currency;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ID: Integer read fID write fID;
    property Code: string read fCodice write fCodice;
    property Description: string read fDescrizione write fDescrizione;
    property Price: Currency read fPrezzo write fPrezzo;
  end;

  TOrder = class;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('customers')]
  TCustomer = class(TMVCActiveRecord)
  private
    [MVCTableField('id', [foPrimaryKey, foAutoGenerated])]
    fID: Integer;
    [MVCTableField('code')]
    fCode: string;
    [MVCTableField('description')]
    fCompanyName: string;
    [MVCTableField('city')]
    fCity: string;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ID: Integer read fID write fID;
    property Code: string read fCode write fCode;
    property CompanyName: string read fCompanyName write fCompanyName;
    property City: string read fCity write fCity;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('customers')]
  TCustomerWithTransient = class(TMVCActiveRecord)
  private
    [MVCTableField('id', [foPrimaryKey, foAutoGenerated])]
    fID: Integer;
    [MVCTableField('code', [foTransient])]
    fCode: string;
    [MVCTableField('description')]
    fCompanyName: string;
    [MVCTableField('city', [foTransient])]
    fCity: string;
  public
    property ID: Integer read fID write fID;
    property Code: string read fCode write fCode;
    property CompanyName: string read fCompanyName write fCompanyName;
    property City: string read fCity write fCity;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('order_details')]
  TOrderDetail = class(TMVCActiveRecord)
  private
    [MVCTableField('id', [foPrimaryKey, foAutoGenerated])]
    fID: Integer;
    [MVCTableField('id_order')]
    fOrderID: Integer;
    [MVCTableField('id_article')]
    fArticleID: Integer;
    [MVCTableField('unit_price')]
    fPrice: Currency;
    [MVCTableField('discount')]
    fDiscount: Integer;
    [MVCTableField('quantity')]
    fQuantity: Integer;
    [MVCTableField('description')]
    fDescription: string;
    [MVCTableField('total')]
    fTotal: Currency;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ID: Integer read fID write fID;
    property OrderID: Integer read fOrderID write fOrderID;
    property ArticleID: Integer read fArticleID write fArticleID;
    property Price: Currency read fPrice write fPrice;
    property Discount: Integer read fDiscount write fDiscount;
    property Quantity: Integer read fQuantity write fQuantity;
    property Description: string read fDescription write fDescription;
    property Total: Currency read fTotal write fTotal;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('orders')]
  TOrder = class(TMVCActiveRecord)
  private
    [MVCTableField('id', [foPrimaryKey, foAutoGenerated])]
    fID: Integer;
    [MVCTableField('id_customer')]
    fCustomerID: Integer;
    [MVCTableField('order_date')]
    fOrderDate: TDate;
    [MVCTableField('total')]
    fTotal: Currency;
  public
    constructor Create; override;
    destructor Destroy; override;
    property ID: Integer read fID write fID;
    property CustomerID: Integer read fCustomerID write fCustomerID;
    property OrderDate: TDate read fOrderDate write fOrderDate;
    property Total: Currency read fTotal write fTotal;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('customers')]
  TCustomerEx = class(TCustomer)
  private
    fOrders: TObjectList<TOrder>;
  protected
    procedure OnAfterLoad; override;
  public
    destructor Destroy; override;
    property Orders: TObjectList<TOrder> read fOrders;
  end;

  [MVCNameCase(ncLowerCase)]
  [MVCTable('customers')]
  TCustomerWithLogic = class(TCustomer)
  private
    fIsLocatedInRome: Boolean;
  protected
    procedure OnAfterLoad; override;
    procedure OnBeforeInsertOrUpdate; override;
    procedure OnValidation; override;
  public
    property IsLocatedInRome: Boolean read fIsLocatedInRome;
  end;

implementation

uses
  System.SysUtils;

constructor TArticle.Create;
begin
  inherited Create;
end;

destructor TArticle.Destroy;
begin
  inherited;
end;

constructor TCustomer.Create;
begin
  inherited Create;
end;

destructor TCustomer.Destroy;
begin

  inherited;
end;

constructor TOrderDetail.Create;
begin
  inherited Create;
end;

destructor TOrderDetail.Destroy;
begin
  inherited;
end;

constructor TOrder.Create;
begin
  inherited Create;
end;

destructor TOrder.Destroy;
begin
  inherited;
end;

{ TCustomerEx }

destructor TCustomerEx.Destroy;
begin
  fOrders.Free;
  inherited;
end;

procedure TCustomerEx.OnAfterLoad;
begin
  inherited;
  fOrders.Free;
  fOrders := TOrder.Where<TOrder>('id_customer = ?', [Self.ID]);
end;

{ TCustomerWithLogic }

procedure TCustomerWithLogic.OnAfterLoad;
begin
  inherited;
  fIsLocatedInRome := fCity = 'ROME';
end;

procedure TCustomerWithLogic.OnBeforeInsertOrUpdate;
begin
  inherited;
  fCompanyName := fCompanyName.ToUpper;
  fCity := fCity.ToUpper;
end;

procedure TCustomerWithLogic.OnValidation;
begin
  inherited;
  if fCompanyName.Trim.IsEmpty or fCity.Trim.IsEmpty or fCode.Trim.IsEmpty then
    raise Exception.Create('CompanyName, City and Code are required');
end;

end.
