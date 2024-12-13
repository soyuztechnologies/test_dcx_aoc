@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Aggregation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDXC_AB_AGG as select from ZDXC_AB_ASSOCIATION
{
    key CompanyName,
    key Country,
    key _Salesorder.currency_code as CurrencyCode,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    sum( _Salesorder.gross_amount ) as TotalAmount    
} group by CompanyName, Country, _Salesorder.currency_code
 