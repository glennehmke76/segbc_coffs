-- filter points via KDE point reduction as view
DROP TABLE IF EXISTS segbc_habitat_sightings_selected CASCADE;
CREATE TABLE segbc_habitat_sightings_selected AS
(SELECT DISTINCT
  row_number() over () AS id,
  CASE
    WHEN geom_kde_centroid IS NULL OR kde_contour_rank = 1
      -- return original sighting points in NSW lambert
      THEN ST_Transform(geom, 3308)
    WHEN kde_contour_rank > 1
      -- return kde centroid points based on threshold in NSW lambert
      THEN ST_Transform(geom_kde_centroid, 3308)
  ELSE NULL
  END AS geom,
  CASE
    WHEN geom_kde_centroid IS NULL OR kde_contour_rank = 1
      THEN 'original point'
    WHEN kde_contour_rank > 1
      -- return kde centroid points based on threshold in NSW lambert
      THEN 'KDE centroid'
  ELSE NULL
  END AS point_source
  FROM segbc_habitat_points
  WHERE
   -- this will only filter out sightings points with a date - nulls are not affected
   extract(year from date) > 1998
   AND -- data source is not priority point
    data_source <> 'nest trees'
    AND data_source <> 'drinking sites'
);

alter table segbc_habitat_sightings_selected
    add high_survey_effort_cluster boolean default false;

UPDATE segbc_habitat_sightings_selected
SET
  high_survey_effort_cluster = true
FROM segbc_high_surv_effort_kde_contours
WHERE ST_Intersects(segbc_habitat_sightings_selected.geom, ST_Transform(segbc_high_surv_effort_kde_contours.geom, 3308))
;
