-- import as segbc_kde_contours in 4283 SRID (specify in import)
alter table segbc_kde_contours_50
    drop column fid;
-- define centroid
alter table segbc_kde_contours_50
add geom_centroid geometry(Point, 4283);
UPDATE segbc_kde_contours_50
SET geom_centroid = ST_Centroid(geom);

-- define contour ranks and labels
alter table segbc_kde_contours_50
    add kde_contour_rank integer;
alter table segbc_kde_contours_50
    add kde_contour_label varchar(50);
UPDATE segbc_kde_contours_50
SET kde_contour_label = CONCAT(segbc_kde_contours_50.density_min, '-', segbc_kde_contours_50.density_max)
;
UPDATE segbc_kde_contours_50
SET kde_contour_rank = order_value.kde_contour
FROM
  (SELECT
    row_number() over () AS kde_contour,
    sub.kde_contour_label,
    sub.value
  FROM
    (SELECT DISTINCT
      density_min AS value,
      segbc_kde_contours_50.kde_contour_label
    FROM segbc_kde_contours_50
    ORDER BY
      density_min
    )sub
  )order_value
WHERE
  segbc_kde_contours_50.kde_contour_label = order_value.kde_contour_label
;

-- add kde centroids to points table
alter table segbc_habitat_points
  drop column kde_contour_label;
alter table segbc_habitat_points
    drop column geom_kde_centroid;
alter table segbc_habitat_points
    drop column kde_contour_rank;

alter table segbc_habitat_points
    add kde_contour_label varchar(50);
alter table segbc_habitat_points
    add kde_contour_rank integer;
alter table segbc_habitat_points
    add geom_kde_centroid geometry(Point, 4283);
UPDATE segbc_habitat_points
SET
  kde_contour_rank = segbc_kde_contours_50.kde_contour_rank,
  kde_contour_label = segbc_kde_contours_50.kde_contour_label,
  geom_kde_centroid = segbc_kde_contours_50.geom_centroid
FROM segbc_kde_contours_50
WHERE ST_Intersects(segbc_habitat_points.geom, segbc_kde_contours_50.geom)
;

-- view contours and select appropriate kde contour from which to dissolve to centroids
  -- in this case density 3-6 and above - i.e. all but the lowest KDE contour at 50m
-- select and dissolve selected features
-- edit selected features as Multiparts to singleparts and split any very large kde clusters
-- re-attribute FID so is unique