@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection on travel entity for processor'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define root view entity ZDXC_AB_M_TRAVEL_PROCESSOR
  as projection on ZDXC_AB_M_TRAVEL
{
    key TravelId,
    AgencyId,
    AgencyName,
    CustomerId,
    CustomerName,
    BeginDate,
    EndDate,
    BookingFee,
    TotalPrice,
    CurrencyCode,
    Description,
    OverallStatus,
    StatusText,
    Criticality,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Agency,
    _Bookings : redirected to composition child ZDXC_AB_M_BOOKING_PROCESSOR,
    _Currency,
    _Customer,
    _Status,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_DXC_AB_VE_CALC'
    @EndUserText.label: 'CO2 Tax'
    virtual CO2Tax : abap.int4,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_DXC_AB_VE_CALC'
    @EndUserText.label: 'Week Day'
    virtual dayOfTheFlight : abap.char( 9 )
}
