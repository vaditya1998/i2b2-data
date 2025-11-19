--==============================================================
-- SQLSERVER Database Script to upgrade PM from 1.8.1 to 1.8.2  
-- This adds a periodic archiving of pm_user_session to improve performance.                
--==============================================================
SELECT
       USER_ID,
       SESSION_ID,
       EXPIRED_DATE,
       CHANGE_DATE,
       ENTRY_DATE,
       CHANGEBY_CHAR,
       STATUS_CD
INTO PM_USER_SESSION_ARC
FROM PM_USER_SESSION
/

ALTER TABLE PM_USER_SESSION_ARC
  ADD ARCHIVED_AT datetime2 NOT NULL
      CONSTRAINT DF_PM_USER_SESSION_ARC_ARCHIVED
      DEFAULT (SYSUTCDATETIME())
/

ALTER TABLE PM_USER_SESSION_ARC
  ADD CONSTRAINT PK_PM_USER_SESSION_ARC
      PRIMARY KEY (SESSION_ID, USER_ID);
TRUNCATE TABLE pm_user_session
/

/* ===============================================================
   Trigger : trg_prune_pm_user_session
   Purpose : Archive & prune pm_user_session (keep 100 newest)
   ===============================================================*/
CREATE TRIGGER trg_prune_pm_user_session
ON dbo.pm_user_login
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* ------------------------------------------------------------------
       Exit early if the table is still small
       ------------------------------------------------------------------ */
    IF (SELECT COUNT(*) FROM dbo.pm_user_session) <= 1000
        RETURN;

    /* ------------------------------------------------------------------
       1. Identify rows to archive / delete
       ------------------------------------------------------------------ */
    DECLARE @to_delete TABLE (
        USER_ID    varchar(50) NOT NULL,
        SESSION_ID varchar(50) NOT NULL
        --PRIMARY KEY (SESSION_ID, USER_ID) -- doesn't work in some versions, not really necessary
    );

    INSERT INTO @to_delete (USER_ID, SESSION_ID)
    SELECT USER_ID, SESSION_ID
    FROM (
        SELECT USER_ID,
               SESSION_ID,
               ROW_NUMBER() OVER (ORDER BY EXPIRED_DATE DESC) AS rn
        FROM   dbo.pm_user_session
        WHERE  EXPIRED_DATE IS NOT NULL
    ) d
    WHERE rn > 100;              -- keep the 100 newest expired sessions

    /* ------------------------------------------------------------------
       2. Archive
       ------------------------------------------------------------------ */
    INSERT INTO dbo.PM_USER_SESSION_ARC (
        USER_ID, SESSION_ID,
        EXPIRED_DATE, CHANGE_DATE, ENTRY_DATE,
        CHANGEBY_CHAR, STATUS_CD,
        ARCHIVED_AT
    )
    SELECT  s.USER_ID,  s.SESSION_ID,
            s.EXPIRED_DATE, s.CHANGE_DATE, s.ENTRY_DATE,
            s.CHANGEBY_CHAR, s.STATUS_CD,
            SYSUTCDATETIME()
    FROM    dbo.pm_user_session AS s
    JOIN    @to_delete         AS t
      ON    t.USER_ID = s.USER_ID
      AND   t.SESSION_ID = s.SESSION_ID;

    /* ------------------------------------------------------------------
       3. Delete from live table
       ------------------------------------------------------------------ */
    DELETE  s
    FROM    dbo.pm_user_session AS s
    JOIN    @to_delete         AS t
      ON    t.USER_ID = s.USER_ID
      AND   t.SESSION_ID = s.SESSION_ID;
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
