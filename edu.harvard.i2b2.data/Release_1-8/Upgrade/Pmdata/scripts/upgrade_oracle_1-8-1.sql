--==============================================================
-- ORACLE Database Script to upgrade PM from 1.8.1 to 1.8.2  
-- This adds a periodic archiving of pm_user_session to improve performance.                
--==============================================================

CREATE TABLE pm_user_session_arc AS
SELECT USER_ID,
       SESSION_ID,
       EXPIRED_DATE,
       CHANGE_DATE,
       ENTRY_DATE,
       CHANGEBY_CHAR,
       STATUS_CD,
       CAST(NULL AS DATE) AS archived_at
FROM   pm_user_session
/

ALTER TABLE pm_user_session_arc
  ADD CONSTRAINT pm_user_session_arc_pk
      PRIMARY KEY (SESSION_ID, USER_ID)
/

ALTER TABLE pm_user_session_arc
  MODIFY archived_at DATE DEFAULT SYSDATE NOT NULL
/
  
TRUNCATE TABLE pm_user_session
/

/* ============================================================
   Trigger : trg_prune_pm_user_session
   Purpose : When pm_user_login gets an INSERT, archive & prune
             pm_user_session so it never has more than
             the 100 newest expired rows.
   ============================================================ */
CREATE OR REPLACE TRIGGER trg_prune_pm_user_session
AFTER INSERT ON pm_user_login          -- <-- nothing after this line
DECLARE
    v_total  INTEGER;
BEGIN
    /* Short‑circuit if the table is still small */
    SELECT COUNT(*) INTO v_total
    FROM   pm_user_session;

    IF v_total <= 1000 THEN
        RETURN;
    END IF;

    /* ----------------------------------------------------------------
       1. Archive rows older than the 100 newest with EXPIRED_DATE
       ---------------------------------------------------------------- */
    INSERT INTO pm_user_session_arc (
        user_id, session_id,
        expired_date, change_date, entry_date,
        changeby_char, status_cd,
        archived_at
    )
    SELECT  user_id, session_id,
            expired_date, change_date, entry_date,
            changeby_char, status_cd,
            SYSDATE
    FROM (
        SELECT ps.*,
               ROW_NUMBER() OVER (ORDER BY expired_date DESC) AS rn
        FROM   pm_user_session ps
        WHERE  expired_date IS NOT NULL
    )
    WHERE rn > 100;   -- keep the 100 freshest expired sessions

    /* ----------------------------------------------------------------
       2. Delete the same rows from the live table
       ---------------------------------------------------------------- */
    DELETE FROM pm_user_session p
    WHERE (p.user_id, p.session_id) IN (
        SELECT user_id, session_id
        FROM (
            SELECT  user_id,
                    session_id,
                    ROW_NUMBER() OVER (ORDER BY expired_date DESC) AS rn
            FROM   pm_user_session
            WHERE  expired_date IS NOT NULL
        )
        WHERE rn > 100
    );
END;
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

