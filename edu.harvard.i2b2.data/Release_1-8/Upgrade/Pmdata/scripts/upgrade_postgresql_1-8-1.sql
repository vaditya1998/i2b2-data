--==============================================================
-- POSTGRES Database Script to upgrade PM from 1.8.1 to 1.8.2  
-- This adds a periodic archiving of pm_user_session to improve performance.                
--==============================================================

CREATE TABLE pm_user_session_arc AS
SELECT * FROM pm_user_session
/

ALTER TABLE pm_user_session_arc
    ADD COLUMN archived_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP
/
    
ALTER TABLE pm_user_session_arc
ADD CONSTRAINT PK_pm_user_session_arc PRIMARY KEY (SESSION_ID, USER_ID)
/

TRUNCATE TABLE pm_user_session
/
    
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
            build to_delete    insert archive rows    delete live rows
           ------------------------------------------------------------ */
        WITH to_delete AS (
                /* keys older than the newest 100 expired sessions */
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
$sql$
/


/* ===============================================================
   Drop old trigger safely (table may or may not exist)
   ===============================================================*/
DO $sql$
BEGIN
  BEGIN
    EXECUTE 'DROP TRIGGER IF EXISTS trg_prune_pm_user_session ON pm_user_login';
  EXCEPTION WHEN undefined_table THEN
    -- pm_user_login not present yet; ignore
    NULL;
  END;
END $sql$ 
/

/* =======================================================================
   PostgreSQL 10 compatibility notes

   1) Change the trigger creation to use EXECUTE PROCEDURE (PG11+ uses EXECUTE FUNCTION):
        -- PG10:
        CREATE TRIGGER trg_prune_pm_user_session
        AFTER INSERT ON pm_user_login
        FOR EACH STATEMENT
        EXECUTE PROCEDURE fn_prune_pm_user_session();

        -- PG11+:
        -- EXECUTE FUNCTION fn_prune_pm_user_session();

   ======================================================================= */

/* ===============================================================
   Create trigger (PG 11+: EXECUTE FUNCTION; PG 10-: use PROCEDURE)
   ===============================================================*/
CREATE TRIGGER trg_prune_pm_user_session
AFTER INSERT ON pm_user_login
FOR EACH STATEMENT
EXECUTE FUNCTION fn_prune_pm_user_session()
/
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE, CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Template', 'This user {{{USER_NAME}}} in project {{{PROJECT_ID}}} requested i2b2 request
 entitled - "{{{QUERY_NAME}}}", submitted on {{{QUERY_STARTDATE}}}, with the query master of {{{QUERY_MASTER_ID}}}.
Check the status of the Data Request using the Data Request Manager plugin.', 'i2b2', 'H');
/
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE,  CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Email Address', 'email@site.org', 'i2b2', 'H');
/
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE,  CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Subject', 'i2b2 Data Request', 'i2b2', 'H');
/
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE, CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Letter', '"Results of the i2b2 request entitled - "{{{QUERY_NAME}}}", submitted on {{{QUERY_STARTDATE}}}, are available.

Important notes about your data:
	- Total number of patients returned in your data request: {{{PATIENT_COUNT}}}
	- i2b2 reviewer:

Only persons specifically authorized and selected (as listed at the top of this letter) can download these files. If additional user access is needed, please ensure the person is listed on your project IRB protocol and contact the i2b2 team.

Specifically:
	- Remove all PHI from computer, laptop, or mobile device after analysis is completed.
	- Do NOT share PHI or PII with anyone who is not listed on the IRB protocol.

Your guideline for the storage of Protected Health Information can be found at: https://www.site.com/guidelines_for_protecting_and_storing_phi.pdf

*To download these files*
- You must be logged onto your site

These results are the data that was requested under the authority of the Institutional Review Board.  The query resulting in this identified patient data is included at the end of this letter.  A copy of this letter is kept on file and is available to the IRB in the event of an audit.

Thank you,

The i2b2 Team "', 'i2b2', 'H');
/

