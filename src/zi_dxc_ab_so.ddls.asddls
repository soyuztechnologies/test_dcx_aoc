@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales View, Interface, basic'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
--represents the transactional data in prespective of analytics
@Analytics.dataCategory: #FACT
define view entity ZI_DXC_AB_SO as select from zats_ab_so_hdr as hdr
inner join zats_ab_so_item as itm on
hdr.order_id = itm.order_id
{
    key hdr.order_id as OrderId,
    key itm.item_id as ItemId,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    itm.amount as GrossAmount,
    itm.currency as CurrencyCode,
    @Semantics.quantity.unitOfMeasure: 'Unit'
    itm.qty as Quantity,
    itm.uom as Unit    
    
}
