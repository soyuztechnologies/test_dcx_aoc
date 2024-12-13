@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Joining data using view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDXC_AB_JOIN as select from ZDXC_AB_BPA( p_ctry : 'US' ) as bpa
inner join zats_ab_so_hdr as so on
bpa.BpId = so.buyer
{
    key so.order_id as OrderId,
    key bpa.BpId,
    so.order_no as OrderNo,
    so.buyer as Buyer,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    so.gross_amount as GrossAmount,
    so.currency_code as CurrencyCode,
    bpa.CompanyName,
    bpa.Country
}
