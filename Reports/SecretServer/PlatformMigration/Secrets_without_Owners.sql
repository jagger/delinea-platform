SELECT ISNULL(f.FolderPath, 'No folder assigned') AS [Folder Path]
    ,s.SecretID AS [SecretID]
    ,s.SecretName AS [Secret Name]
    ,st.SecretTypeName AS [Template]
    ,aus.DateRecorded AS [Last Accessed]
    ,concat(u.displayName,' (UserID: ',u.userid,')') as [Accessed By]
    ,ISNULL(s.PasswordChangeStatusLastChanged, s.Created) AS [Password Last Set]
FROM tbSecret s
LEFT JOIN tbFolder f ON s.FolderId = f.FolderID
LEFT JOIN tbSecretType st ON s.SecretTypeId = st.SecretTypeId
JOIN tbAuditSecret aus ON aus.SecretID = s.SecretID
join vUserAccess u on aus.userid = u.UserId
JOIN (
    SELECT SecretID, MAX(DateRecorded) AS MaxDate
    FROM tbAuditSecret
    WHERE Action = 'VIEW'
    GROUP BY SecretID
) latest ON aus.SecretID = latest.SecretID AND aus.DateRecorded = latest.MaxDate
WHERE s.Active = 1 
    AND s.SecretId NOT IN (
        SELECT gsp.SecretId
        FROM vGroupSecretPermissions gsp
        WHERE gsp.OwnerPermission = 1
    )
    AND aus.Action = 'VIEW'
