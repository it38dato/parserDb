<p>
    <strong>Task:</strong><br>
    В проекте 4GCell_DataBuild_.xlsm Не загружает таблицу из БД с таким запросом:<br>
    SELECT b.cellName as NSector<br>
    &nbsp; &nbsp; &nbsp;,SUBSTRING(CAST(b.cellName as CHAR),1,6) as SiteName<br>
    &nbsp; &nbsp; &nbsp;,bt.enbName as SystemModule<br>
    &nbsp; &nbsp; &nbsp;, ROUND(POWER(10, e.pMAX/100)/1000,0) as Pmax &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
    &nbsp; &nbsp; &nbsp;,CAST((CAST(CAST(l.ulChBw AS CHAR) AS INT)/10) AS INT) AS Bandwidth &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;<br>
    &nbsp; &nbsp; &nbsp;,l.LNCEL as CID &nbsp; &nbsp; &nbsp;<br>
    &nbsp; &nbsp; &nbsp;,l.earfcnDL<br>
    &nbsp; &nbsp; &nbsp;,e.phyCellId AS PCI &nbsp; &nbsp;<br>
    &nbsp; &nbsp; &nbsp;,l.rootSeqIndex &nbsp; &nbsp; <br>
    &nbsp; &nbsp; &nbsp;,(CASE WHEN CAST(l.prachCS as CHAR) = '14' THEN '35(область)' ELSE '15(город)' END) AS CellRange<br>
    &nbsp; &nbsp; &nbsp;,e.tac as TAC <br>
    &nbsp; &nbsp; &nbsp;,(CASE WHEN l.dlMimoMode = 0 THEN 'SingleTx' ELSE '' END) as SingleTx&nbsp;&nbsp;&nbsp;&nbsp; <br>
    FROM YOURDB1.LNCEL_begin b<br>
    &nbsp;LEFT OUTER JOIN<br>
    &nbsp;(SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    &nbsp; UNION<br>
    &nbsp; SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) l ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    &nbsp;LEFT OUTER JOIN YOURDB1.LNCEL_end e ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL <br>
    &nbsp;LEFT OUTER JOIN YOURDB1.LNBTS_begin bt ON b.NetActNo = bt.NetActNo AND b.MRBTS = bt.MRBTS AND b.LNBTS = bt.LNBTS<br>
    WHERE SUBSTRING(CAST(b.cellName as CHAR),1,2) IN ('IR','KM','MD','SA','AN','BI','HB','IO')<br>
    ORDER BY b.MRBTS, b.LNCEL<br>
    <strong>Decision:</strong><br>
    Перед запуском необходимо проверить настройки листа:<br>
    - Excel - Рецензирование - Снять защиту с листа - пробовать обновить лист тем же запросом - за 25 минут загрузил и 26845 строк стало в таблице LIST - в LIST отобразились недостающие довесы<br>
    Алгортим:<br>
    - два вложенных запроса, проверьте сначала их по отдельности:<br>
    SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD<br>
    - UNION Проверьте:<br>
    SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD<br>
    - Составьте таблицу, которая получится после выполнения всех JOIN (можно проверять не все сразу, а добавлять по одному):<br>
    SELECT * FROM YOURDB1.LNCEL_begin AS b<br>
    - Запрос не выдал результат. командой show tables определил что изменилось название таблицы:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1.LNCEL_end AS e<br>
    - Запрос не выдал результат. командой show tables определил что изменилось название таблицы:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_end AS e<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    LEFT OUTER JOIN YOURDB1.LNCEL_end AS e<br>
    ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    LEFT OUTER JOIN YOURDB1_LNCEL.LNCEL_end AS e<br>
    ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1.LNBTS_begin AS bt<br>
    - следующий запрос:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    LEFT OUTER JOIN YOURDB1_LNCEL.LNCEL_end AS e<br>
    ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    LEFT OUTER JOIN YOURDB1.LNBTS_begin AS bt<br>
    ON b.NetActNo = bt.NetActNo AND b.MRBTS = bt.MRBTS AND b.LNBTS = bt.LNBTS<br>
    - Посмотрите, есть ли в выводе поле b.cellName, соответствует ли оно вашему фильтру Where. Примените фильтр к запросу:<br>
    SELECT * FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    LEFT OUTER JOIN YOURDB1_LNCEL.LNCEL_end AS e<br>
    ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    LEFT OUTER JOIN YOURDB1.LNBTS_begin AS bt<br>
    ON b.NetActNo = bt.NetActNo AND b.MRBTS = bt.MRBTS AND b.LNBTS = bt.LNBTS<br>
    WHERE SUBSTRING(CAST(b.cellName as CHAR),1,2) IN ('IR','KM','MD','SA','AN','BI','HB','IO')<br>
    ORDER BY b.MRBTS, b.LNCEL<br>
    - Уберите звёздочку, добавляйте по одному полю в выражение SELECT:<br>
    SELECT<br>
    &nbsp; &nbsp;l.LNCEL AS CID,<br>
    &nbsp; &nbsp;l.earfcnDL, l.rootSeqIndex,<br>
    &nbsp; &nbsp;CAST((CAST(CAST(l.ulChBw AS CHAR) AS INT)/10) AS INT) AS Bandwidth,<br>
    &nbsp; &nbsp;(CASE WHEN CAST(l.prachCS as CHAR) = '14' THEN '35(область)' ELSE '15(город)' END) AS CellRange,<br>
    &nbsp; &nbsp;(CASE WHEN l.dlMimoMode = 0 THEN 'SingleTx' ELSE '' END) AS SingleTx,<br>
    &nbsp; &nbsp;b.cellName AS NSector,<br>
    &nbsp; &nbsp;SUBSTRING(CAST(b.cellName as CHAR),1,6) AS SiteName,<br>
    &nbsp; &nbsp;e.phyCellId AS PCI,<br>
    &nbsp; &nbsp;e.tac,<br>
    &nbsp; &nbsp;ROUND(POWER(10, e.pMAX/100)/1000,0) AS Pmax,<br>
    &nbsp; &nbsp;bt.enbName AS SystemModule<br>
    FROM YOURDB1_LNCEL.LNCEL_begin AS b<br>
    LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    LEFT OUTER JOIN YOURDB1_LNCEL.LNCEL_end AS e<br>
    ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    LEFT OUTER JOIN YOURDB1.LNBTS_begin AS bt<br>
    ON b.NetActNo = bt.NetActNo AND b.MRBTS = bt.MRBTS AND b.LNBTS = bt.LNBTS<br>
    WHERE SUBSTRING(CAST(b.cellName as CHAR),1,2) IN ('IR','KM','MD','SA','AN','BI','HB','IO')<br>
    ORDER BY b.MRBTS, b.LNCEL<br>
    - Общий результат по проверке запроса:<br>
    +SELECT<br>
    +l.LNCEL,<br>
    +l.earfcnDL,<br>
    +l.rootSeqIndex,<br>
    +CAST((CAST(CAST(l.ulChBw AS CHAR) AS INT)/10) AS INT),<br>
    +(CASE WHEN CAST(l.prachCS as CHAR) = '14' THEN '35(область)' ELSE '15(город)' END),<br>
    +(CASE WHEN l.dlMimoMode = 0 THEN 'SingleTx' ELSE '' END),<br>
    +b.cellName,<br>
    +SUBSTRING(CAST(b.cellName as CHAR),1,6),<br>
    +e.phyCellId,<br>
    +e.tac,<br>
    +ROUND(POWER(10, e.pMAX/100)/1000,0),<br>
    +bt.enbName<br>
    -FROM YOURDB1.LNCEL_begin AS b<br>
    +LEFT OUTER JOIN (SELECT NetActNo, MRBTS, LNBTS, LNCEL, ulChBw, earfcnDL, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_FDD<br>
    +UNION SELECT NetActNo, MRBTS, LNBTS, LNCEL, ChBw, earfcn, rootSeqIndex, prachCS, dlMimoMode FROM YOURDB1.LNCEL_TDD) AS l<br>
    +ON b.NetActNo = l.NetActNo AND b.MRBTS = l.MRBTS AND b.LNBTS = l.LNBTS AND b.LNCEL = l.LNCEL<br>
    -LEFT OUTER JOIN YOURDB1.LNCEL_end AS e<br>
    +ON b.MRBTS = e.MRBTS AND b.LNBTS = e.LNBTS AND b.LNCEL = e.LNCEL<br>
    +LEFT OUTER JOIN YOURDB1.LNBTS_begin bt<br>
    +ON b.NetActNo = bt.NetActNo AND b.MRBTS = bt.MRBTS AND b.LNBTS = bt.LNBTS<br>
    +WHERE SUBSTRING(CAST(b.cellName as CHAR),1,2) IN ('IR','KM','MD','SA','AN','BI','HB','IO')<br>
    +ORDER BY b.MRBTS, b.LNCEL<br>
    - Убрал order BY для быстрого выполнения запроса
</p>