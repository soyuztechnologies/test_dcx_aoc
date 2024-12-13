@AbapCatalog.viewEnhancementCategory: [#PROJECTION_LIST]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View on view'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@AbapCatalog.extensibility.extensible: true
define view entity ZDXC_AB_VOV as select from ZDXC_AB_BPA( p_ctry : 'US' )
{
    key BpId,
    BpRole,
    CompanyName,
    Street,
    Region
}
