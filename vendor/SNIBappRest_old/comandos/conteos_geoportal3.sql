/*
CREATE INDEX idx_snib_grupobio
  ON public.snib
  USING btree
  (grupobio COLLATE pg_catalog."default");

CREATE INDEX idx_snib_comentarioscatvalido
  ON public.snib
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default");

CREATE INDEX idx_snib_idnombrecatvalido
  ON public.snib
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default");  

-- Index de idnombrecat valido en los 10 grupos

CREATE INDEX idx_snibanfigw_idnombrecatvalido
  ON public.snibanfigw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibavesgw_idnombrecatvalido
  ON public.snibavesgw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibbactgw_idnombrecatvalido
  ON public.snibbactgw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibhonggw_idnombrecatvalido
  ON public.snibanfigw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibinvegw_idnombrecatvalido
  ON public.snibinvegw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibmamigw_idnombrecatvalido
  ON public.snibmamigw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibpecegw_idnombrecatvalido
  ON public.snibpecegw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibplangw_idnombrecatvalido
  ON public.snibplangw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibprotgw_idnombrecatvalido
  ON public.snibprotgw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibreptgw_idnombrecatvalido
  ON public.snibreptgw
  USING btree
  (idnombrecatvalido COLLATE pg_catalog."default");  

-- Index de comentarioscatvalido valido en los 10 grupos
 CREATE INDEX idx_snibanfigw_comentarioscatvalido
  ON public.snibanfigw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibavesgw_comentarioscatvalido
  ON public.snibavesgw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibbactgw_comentarioscatvalido
  ON public.snibbactgw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibhonggw_comentarioscatvalido
  ON public.snibanfigw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibinvegw_comentarioscatvalido
  ON public.snibinvegw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibmamigw_comentarioscatvalido
  ON public.snibmamigw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibpecegw_comentarioscatvalido
  ON public.snibpecegw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibplangw_comentarioscatvalido
  ON public.snibplangw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibprotgw_comentarioscatvalido
  ON public.snibprotgw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibreptgw_comentarioscatvalido
  ON public.snibreptgw
  USING btree
  (comentarioscatvalido COLLATE pg_catalog."default");

-- Index de idnombrecatvalido en los 10 grupos
 CREATE INDEX idx_snibanfigw_especievalidabusqueda
  ON public.snibanfigw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibavesgw_especievalidabusqueda
  ON public.snibavesgw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibbactgw_especievalidabusqueda
  ON public.snibbactgw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibhonggw_especievalidabusqueda
  ON public.snibanfigw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibinvegw_especievalidabusqueda
  ON public.snibinvegw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibmamigw_especievalidabusqueda
  ON public.snibmamigw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibpecegw_especievalidabusqueda
  ON public.snibpecegw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibplangw_especievalidabusqueda
  ON public.snibplangw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibprotgw_especievalidabusqueda
  ON public.snibprotgw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default"); 

  CREATE INDEX idx_snibreptgw_especievalidabusqueda
  ON public.snibreptgw
  USING btree
  (especievalidabusqueda COLLATE pg_catalog."default");
      
-- Esquema de conteos
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

-- SELECT entid AS region_id, nom_ent AS nombre_region, st_x(st_centroid(geom)) AS long, st_y(st_centroid(geom)) AS lat, ST_AsGeoJSON(geom) AS geojson, ST_Extent(geom) AS bbox FROM "estados" GROUP BY entid;



/*select a.spid
from snibanfigw as a
join municipios as b
on ST_WITHIN(a.the_geom, b.geom)*/

SELECT COUNT (*) AS COUNT FROM snib WHERE munid=36 AND idnombrecatvalido <> '' GROUP BY idnombrecatvalido


