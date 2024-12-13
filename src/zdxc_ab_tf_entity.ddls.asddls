@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Create entity on top of table function'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDXC_AB_TF_ENTITY as select from ZDXC_AB_TF(p_clnt: $session.client)
{
    company_name,
    @Semantics.amount.currencyCode: 'currency_code'
    total_sales,
    currency_code,
//    @Semantics.amount.currencyCode: 'ConvertedCurrency'
//    currency_conversion( amount => total_sales, 
//    source_currency => currency_code, 
//    target_currency => cast('USD' as abap.cuky), 
//    exchange_rate_date => $session.system_date ) as AmountUSD,
//    cast('USD' as abap.cuky) as ConvertedCurrency,
    customer_rank,
    zget_mrp( category => cast('PCs' as abap.char(120)), 
              price => cast(total_sales as abap.curr(10,2))           
     ) as updated_sales
}
