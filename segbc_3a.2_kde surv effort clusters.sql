-- ... from xxxxxx import as segbc_kde_contours in 4283 SRID (specify in import)

-- define contour ranks and labels
alter table segbc_high_surv_effort_kde_contours
    drop column fid;
alter table segbc_high_surv_effort_kde_contours
    drop column density_min;
alter table segbc_high_surv_effort_kde_contours
    drop column density_max;

-- count surveys in kde clusters
alter table segbc_high_surv_effort_kde_contours
  drop column if exists num_surveys;
alter table segbc_high_surv_effort_kde_contours
    add num_surveys integer;
alter table segbc_high_surv_effort_kde_contours
  drop column if exists num_sightings;
alter table segbc_high_surv_effort_kde_contours
    add num_sightings integer;

UPDATE segbc_high_surv_effort_kde_contours
SET num_sightings = sub.num_sightings
FROM
  (SELECT
    segbc_high_surv_effort_kde_contours.id,
    COUNT(segbc_habitat_points.id) AS num_sightings
  FROM segbc_habitat_points
  JOIN segbc_high_surv_effort_kde_contours ON ST_Intersects(segbc_habitat_points.geom, segbc_high_surv_effort_kde_contours.geom)
  GROUP BY
    segbc_high_surv_effort_kde_contours.id
  )sub
WHERE segbc_high_surv_effort_kde_contours.id = sub.id
;

UPDATE segbc_high_surv_effort_kde_contours
SET num_surveys = sub.num_surveys
FROM
  (SELECT
    segbc_high_surv_effort_kde_contours.id,
    COUNT(survey.id) + segbc_high_surv_effort_kde_contours.num_sightings AS num_surveys
  FROM survey
  JOIN survey_point ON survey.survey_point_id = survey_point.id
  JOIN segbc_high_surv_effort_kde_contours ON ST_Intersects(survey_point.geom, segbc_high_surv_effort_kde_contours.geom)
  GROUP BY
    segbc_high_surv_effort_kde_contours.id
  )sub
WHERE segbc_high_surv_effort_kde_contours.id = sub.id
;

UPDATE segbc_high_surv_effort_kde_contours
SET num_surveys = COALESCE(num_surveys, 0) + COALESCE(num_sightings, 0);

-- add reporting rate
alter table segbc_high_surv_effort_kde_contours
    add rr numeric;
UPDATE segbc_high_surv_effort_kde_contours
SET rr = num_sightings / num_surveys :: numeric * 100;

-- add high survey effort cluster ids to points table
alter table segbc_habitat_points
  drop column if exists high_survey_effort_cluster;
alter table segbc_habitat_points
    add high_survey_effort_cluster boolean;
UPDATE segbc_habitat_points
SET
  high_survey_effort_cluster = true
FROM segbc_high_surv_effort_kde_contours
WHERE ST_Intersects(segbc_habitat_points.geom, segbc_high_surv_effort_kde_contours.geom)
;

-- test effect
SELECT
  ST_Union
    (ST_Buffer
      (ST_Transform
        (ST_Intersection(segbc_high_surv_effort_kde_contours.geom,
          ST_Transform(segbc_habitat_sightings_selected.geom, 4283)), 3308), 1000)) AS geom_1000_buffer,
  ST_Union
    (ST_Buffer
      (ST_Transform
        (ST_Intersection(segbc_high_surv_effort_kde_contours.geom,
          ST_Transform(segbc_habitat_sightings_selected.geom, 4283)), 3308), 500)) AS geom_500_buffer
FROM segbc_habitat_sightings_selected
JOIN segbc_high_surv_effort_kde_contours ON ST_Intersects(segbc_high_surv_effort_kde_contours.geom,
                                                          ST_Transform(segbc_habitat_sightings_selected.geom, 4283))
