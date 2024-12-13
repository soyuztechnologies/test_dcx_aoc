@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement child (lowest)'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZDXC_AB_M_BOOKING_SUPPL as select from /dmo/booksuppl_m
association to ZDXC_AB_M_TRAVEL as _Travel
on $projection.TravelId = _Travel.TravelId 
association to parent ZDXC_AB_M_BOOKING as _Booking
on $projection.TravelId = _Booking.TravelId and
    $projection.BookingId = _Booking.BookingId
association to /DMO/I_Supplement as _Supplements
on $projection.SupplementId = _Supplements.SupplementID    
--composition of target_data_source_name as _association_name
{
  key travel_id as TravelId,
  key booking_id as BookingId,
  key booking_supplement_id as BookingSupplementId,
  supplement_id as SupplementId,
  @Semantics.amount.currencyCode: 'CurrencyCode'
  price as Price,
  currency_code as CurrencyCode,
  last_changed_at as LastChangedAt,
  _Travel,
  _Booking,
  _Supplements
}
