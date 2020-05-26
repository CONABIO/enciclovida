/*
CREATE INDEX idx_snib_grupobio
  ON public.snib
  USING btree
  (grupobio COLLATE pg_catalog."default");

CREATE INDEX idx_snib_comentarioscatvalido
  ON public.snib
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default");

  CREATE SCHEMA conteos
  AUTHORIZATION postgres;

CREATE TABLE conteos.estados
(
  idedo character varying,
  grupo character varying,
  total integer
)
*/  

-- INSERT INTO conteos.estados SELECT entid AS idedo, grupobio AS grupo, COUNT(*) AS total FROM (SELECT grupobio, entid, spid FROM snib WHERE especievalidabusqueda <> '' AND entid IS NOT NULL AND comentarioscatvalido LIKE 'Validado completamente con CAT.%' AND grupobio IN ('Anfibios','Aves','Bacterias','Hongos','Invertebrados','Mamíferos','Peces','Plantas','Protoctistas','Reptiles') GROUP BY grupobio, entid, spid) AS resp GROUP BY grupobio, entid;

-- ALTER TABLE estados RENAME COLUMN gid TO entid;
-- ALTER TABLE municipios RENAME COLUMN gid TO munid;




-- SELECT entid,claveestadomapa,idestadomapa,estadomapa,munid,clavemunicipiomapa,idmunicipiomapa,municipiomapa,anpid,idanpfederal1,idanpfederal2,anp,region FROM snib WHERE entid=20 ORDER BY entid ASC LIMIT 10;
-- SELECT entid,claveestadomapa,idestadomapa,estadomapa,munid,clavemunicipiomapa,idmunicipiomapa,municipiomapa,anpid,idanpfederal1,idanpfederal2,anp,region,latitud,longitud FROM snib WHERE entid=18 AND entid !=idestadomapa ORDER BY entid ASC LIMIT 10;

-- SELECT ST_Extent(geom) as bbox FROM estados WHERE entid=1;

SELECT entid AS region_id, nom_ent AS nombre_region, st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat, ST_AsGeoJSON(geom) AS geojson, ST_Extent(geom) AS bbox FROM "estados" GROUP BY entid;
