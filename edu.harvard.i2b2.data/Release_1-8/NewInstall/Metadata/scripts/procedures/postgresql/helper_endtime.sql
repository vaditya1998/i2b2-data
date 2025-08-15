CREATE OR REPLACE FUNCTION endtime(startime timestamp, label text, label2 text)
RETURNS void
LANGUAGE plpgsql
AS $sql$
BEGIN
  RAISE NOTICE '(BENCH) % , % , %', label, label2, EXTRACT(SECOND FROM (now() - startime));
END;
$sql$;
