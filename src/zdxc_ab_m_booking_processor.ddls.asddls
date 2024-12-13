@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking processor projection'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZDXC_AB_M_BOOKING_PROCESSOR
  as projection on ZDXC_AB_M_BOOKING
{
    key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    ConnectionId,
    FlightDate,
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _Carrier,
    _Connection,
    _Customer,
    _Flight,
    _Supplement: redirected to composition child ZDXC_AB_M_BOOKSUPPL_PROCESSOR,
    _Travel: redirected to parent ZDXC_AB_M_TRAVEL_PROCESSOR
}
