@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement projection layer'
@Metadata.ignorePropagatedAnnotations: false
@Metadata.allowExtensions: true
define view entity ZDXC_AB_M_BOOKSUPPL_PROCESSOR
  as projection on ZDXC_AB_M_BOOKING_SUPPL
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Booking: redirected to parent ZDXC_AB_M_BOOKING_PROCESSOR,
    _Travel: redirected to ZDXC_AB_M_TRAVEL_PROCESSOR,
    _Supplements
}
