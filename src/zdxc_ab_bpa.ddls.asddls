@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Business partners CDS entity'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZDXC_AB_BPA
 with parameters p_ctry: land1
 as select from zats_ab_bpa
{
    key bp_id as BpId,
    --cds expression language
    case bp_role 
        when '01' then 'Customer'
        else 'Supplier' end
    as BpRole,
    company_name as CompanyName,
    street as Street,
    country as Country,
    region as Region,
    city as City
} where country = $parameters.p_ctry
