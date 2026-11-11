-- is_citable: urn:nir urns and the Slovak /akn/sk/ anchors are citable, an attachment URI is not
SELECT starts_with('urn:nir:stato:legge:2000;1~art1', 'urn:nir:') AS nir,
       starts_with('/akn/sk/act/2005/300/art1', '/akn/sk/') AS sk,
       starts_with('/it/act/legge/2000/1/attachment/a1', 'urn:nir:') OR starts_with('/it/act/legge/2000/1/attachment/a1', '/akn/sk/') AS attachment
 INTO TEMP t034;

SELECT (SELECT nir AND sk AND NOT attachment FROM t034) AS ok
