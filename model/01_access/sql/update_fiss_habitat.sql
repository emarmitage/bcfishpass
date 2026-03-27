with fiss_source_wscode as (
    select distinct v.wscode from bcfishpass.streams_vw v
    join bcfishpass.observations o on o.linear_feature_id = v.linear_feature_id
    where v.access_st = 1 and o.species_code = 'CT' and o.source ILIKE '%FISS%' and o.obs_dt > date('1990-01-01')
    and not exists (
        select 1
        from bcfishpass.streams_upstr_observations ou
        where ou.segmented_stream_id = v.segmented_stream_id
        and 'CT' = any(coalesce(ou.obsrvtn_species_codes_upstr, ARRAY[]::text[]))
    )
)
update bcfishpass.streams_access base
set access_st = 2
from bcfishpass.streams_vw v
where v.segmented_stream_id = base.segmented_stream_id
  and base.access_st = 1
  and v.wscode IN (
    SELECT wscode from fiss_source_wscode
);