@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Root entity for bo'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZDXC_AB_M_TRAVEL as select from /dmo/travel_m
composition of exact one to many ZDXC_AB_M_BOOKING as _Bookings
association[1] to /DMO/I_Agency as _Agency on
$projection.AgencyId = _Agency.AgencyID
association[1] to /DMO/I_Customer as _Customer on
$projection.CustomerId = _Customer.CustomerID
association[1] to /DMO/I_Overall_Status_VH as _Status on
$projection.OverallStatus = _Status.OverallStatus
association[1] to I_Currency as _Currency on
$projection.CurrencyCode = _Currency.Currency
{
    @ObjectModel.text.element: [ 'Description' ]
    key travel_id as TravelId,
    @ObjectModel.text.element: [ 'AgencyName' ]
    @Consumption.valueHelpDefinition: [{ 
            entity.name: '/DMO/I_Agency',
            entity.element: 'AgencyID'
     }]
    agency_id as AgencyId,
    @Semantics.text: true
    _Agency.Name as AgencyName,
    @ObjectModel.text.element: [ 'CustomerName' ]
    @Consumption.valueHelpDefinition: [{ 
            entity.name: '/DMO/I_Customer',
            entity.element: 'CustomerID'
     }]
    customer_id as CustomerId,
    @Semantics.text: true
    _Customer.LastName as CustomerName,
    begin_date as BeginDate,
    end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_price as TotalPrice,
    currency_code as CurrencyCode,
    @Semantics.text: true
    description as Description,
    @Consumption.valueHelpDefinition: [{ 
            entity.name: '/DMO/I_Overall_Status_VH',
            entity.element: 'OverallStatus'
     }]
    @ObjectModel.text.element: [ 'StatusText' ] 
    overall_status as OverallStatus,
    @Semantics.text: true
    _Status._Text[Language = $session.system_language].Text as StatusText,
    case overall_status
        when 'A' then 3
        when 'O' then 2
        else 1 end as Criticality,
    @Semantics.user.createdBy: true
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    @Semantics.user.lastChangedBy: true
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.lastChangedAt: true
    //work like eTag
    last_changed_at as LastChangedAt,
     _Agency,
     _Customer,
     _Status,
     _Currency,
     _Bookings
    --_association_name // Make association public
}
