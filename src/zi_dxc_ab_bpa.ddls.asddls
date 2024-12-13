@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Basic interface, Business partner'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
@Analytics.dataCategory: #DIMENSION
define view entity ZI_DXC_AB_BPA as select from zats_ab_bpa
{
    key bp_id as BpId,
    company_name as CompanyName,
    country as Country
}
