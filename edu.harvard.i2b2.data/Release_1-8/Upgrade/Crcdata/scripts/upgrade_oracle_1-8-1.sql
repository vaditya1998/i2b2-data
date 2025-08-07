--==============================================================
-- Database Script to upgrade CRC from 1.8.1 to 1.8.2                  
--==============================================================
-- Note that the rpdo tables must also be created. The ant target runs this for you:
--   "../../NewInstall/Crcdata/scripts/crc_create_rpdo_${db.type}.sql"

ALTER TABLE QT_BREAKDOWN_PATH
ADD GROUP_ID VARCHAR2(50)
;

update QT_QUERY_RESULT_TYPE set VISUAL_ATTRIBUTE_TYPE_ID = 'LH' where DESCRIPTION = 'Timeline'
;
