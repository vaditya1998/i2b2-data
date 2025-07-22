--==============================================================
-- SQLSERVER Database Script to upgrade PM from 1.8.1 to 1.8.2  
-- This adds a periodic archiving of pm_user_session to improve performance.                
--==============================================================
SELECT TOP 0
       USER_ID,
       SESSION_ID,
       EXPIRED_DATE,
       CHANGE_DATE,
       ENTRY_DATE,
       CHANGEBY_CHAR,
       STATUS_CD
INTO PM_USER_SESSION_ARC
FROM PM_USER_SESSION;
ALTER TABLE PM_USER_SESSION_ARC
  ADD ARCHIVED_AT datetime2 NOT NULL
      CONSTRAINT DF_PM_USER_SESSION_ARC_ARCHIVED
      DEFAULT (SYSUTCDATETIME());
ALTER TABLE PM_USER_SESSION_ARC
  ADD CONSTRAINT PK_PM_USER_SESSION_ARC
      PRIMARY KEY (SESSION_ID, USER_ID);

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
        SESSION_ID varchar(50) NOT NULL,
        PRIMARY KEY (SESSION_ID, USER_ID)
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