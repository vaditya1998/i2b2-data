/* ===============================================================
   Trigger : trg_prune_pm_user_session
   Purpose : Archive & prune pm_user_session (keep 100 newest)
   ===============================================================*/

CREATE OR REPLACE FUNCTION fn_prune_pm_user_session()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $sql$
BEGIN
    /* Skip pruning until the table grows past 1 000 rows */
    IF (SELECT COUNT(*) FROM pm_user_session) > 1000 THEN

        /* ------------------------------------------------------------
           One statement:
           ➊ build to_delete   ➋ insert archive rows   ➌ delete live rows
           ------------------------------------------------------------ */
        WITH to_delete AS (
                /* ➊ keys older than the newest 100 expired sessions */
                SELECT user_id, session_id
                FROM (
                    SELECT user_id,
                           session_id,
                           ROW_NUMBER() OVER (ORDER BY expired_date DESC) AS rn
                    FROM   pm_user_session
                    WHERE  expired_date IS NOT NULL
                ) x
                WHERE rn > 100
        ), ins AS (
                /* ➋ archive them */
                INSERT INTO pm_user_session_arc
                SELECT p.*, CURRENT_TIMESTAMP
                FROM   pm_user_session p
                JOIN   to_delete       t USING (user_id, session_id)
        )
        /* ➌ delete them from the live table */
        DELETE FROM pm_user_session p
        USING to_delete t
        WHERE p.user_id    = t.user_id
          AND p.session_id = t.session_id;

    END IF;
    RETURN NULL;           -- statement‑level trigger
END;
$sql$;
/

CREATE OR REPLACE TRIGGER trg_prune_pm_user_session
AFTER INSERT ON pm_user_login
FOR EACH STATEMENT
EXECUTE FUNCTION fn_prune_pm_user_session();
/
