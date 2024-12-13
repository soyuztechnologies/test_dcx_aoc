@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'private view product data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
---warning : dont use this in your viws - ONLY Anubhav can reuse it
@VDM.private: true
---respresnts that its master data
@Analytics.dataCategory: #DIMENSION
define view entity ZP_DXC_AB_PRODUCT as select from zats_ab_product
{
    key product_id as ProductId,
    name as Name,
    category as Category    
}
