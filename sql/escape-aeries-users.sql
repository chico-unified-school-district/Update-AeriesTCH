SELECT 
   vwHREmploymentList.empID,
   vwHREmploymentList.EmailWork,
   vwHREmploymentList.NameLast,
   vwHREmploymentList.NameFirst,
   vwHREmploymentList.BargUnitId,
   vwHREmploymentList.emailHome,
   vwHREmploymentList.homeAddrCity AS CY,
   vwHREmploymentList.homeAddrStateCode AS ST,
   vwHREmploymentList.homeAddrStreet AS AD,
   vwHREmploymentList.homeAddrZip AS ZC,
   vwHREmploymentList.homePhone AS TL,
   vwHREmploymentList.homePhoneMobile AS CP,
   CASE 
 WHEN vwHREmploymentList.BargUnitId = 'CSEA' THEN 'C'
 WHEN vwHREmploymentList.BargUnitId = 'CUTA' THEN 'T'
 WHEN vwHREmploymentList.BargUnitId = 'CUMA' THEN 'A'
   ELSE NULL END AS U8 -- Aeries User defined field 8 - Tag Identification of Job Category 
  FROM vwHREmploymentList
   LEFT JOIN HREmployment ON HREmployment.EmpID = vwHREmploymentList.EmpID
  WHERE
   HREmployment.PersonTypeId IN (1,2,4)
   AND vwHREmploymentList.BargUnitId IN ('CUTA','CUMA','CSEA','CHRT')
   AND HREmployment.EmploymentStatusCode IN ('A','I','L','W')
   AND HREmployment.DateTimeEdited > DATEADD(day,-7,getdate())
  ORDER BY vwHREmploymentList.empID DESC