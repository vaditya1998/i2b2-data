INSERT INTO PM_USER_DATA (USER_ID, FULL_NAME, PASSWORD, STATUS_CD)
VALUES('act', 'i2b2 User', '9117d59a69dc49807671a51f10ab7f', 'A');
INSERT INTO PM_PROJECT_DATA (PROJECT_ID, PROJECT_NAME, PROJECT_WIKI, PROJECT_PATH, STATUS_CD)
VALUES('ACT', 'i2b2 ACT', 'http://www.i2b2.org', '/ACT', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'AGG_SERVICE_ACCOUNT', 'USER', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'AGG_SERVICE_ACCOUNT', 'MANAGER', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'AGG_SERVICE_ACCOUNT', 'DATA_OBFSC', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'AGG_SERVICE_ACCOUNT', 'DATA_AGG', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'USER', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'DATA_DEID', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'DATA_OBFSC', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'DATA_AGG', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'DATA_LDS', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'EDITOR', 'A');
INSERT INTO PM_PROJECT_USER_ROLES (PROJECT_ID, USER_ID, USER_ROLE_CD, STATUS_CD)
VALUES('ACT', 'act', 'DATA_PROT', 'A');
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE, CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Template', 'This user {{{USER_NAME}}} in project {{{PROJECT_ID}}} requested i2b2 request
 entitled - "{{{QUERY_NAME}}}", submitted on {{{QUERY_STARTDATE}}}, with the query master of {{{QUERY_MASTER_ID}}}.
Check the status of the Data Request using the Data Request Manager plugi', 'i2b2', 'A');
INSERT INTO PM_PROJECT_PARAMS (DATATYPE_CD, PROJECT_ID, PARAM_NAME_CD, VALUE,  CHANGEBY_CHAR, STATUS_CD) VALUES ('T', 'ACT', 'Data Request Email Address', 'mmendis@partners.org', 'i2b2', 'A');
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

The i2b2 Team "', 'i2b2', 'A');
