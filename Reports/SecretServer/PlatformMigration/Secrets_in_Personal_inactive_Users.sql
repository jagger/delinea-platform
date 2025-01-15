SELECT    
    f.folderpath AS [Location]
    ,s.secretid AS [SecretId]
    ,s.secretname AS [Secret Name]
    ,u.LastLogin as [Owner Last Login]
    ,CASE 
        WHEN u.DisabledByAutomaticADUserDisabling = 1 
        THEN 'Temporarily: Us' +'er Inactive More Than ' + 
            CAST((SELECT AutomaticADUserDisablingIntervalMonths FROM tbconfiguration) AS VARCHAR(10)) + ' months'
        ELSE 'True'
    END AS [Account Disabled]
FROM   tbfolder f 
    INNER JOIN tbsecret s ON s.FolderId = f.FolderID
    INNER JOIN tbUser u ON f.UserId = u.UserId
WHERE 
    f.FolderPath LIKE '%'+ (SELECT PersonalFolderName FROM tbConfiguration)+ '\%' 
    AND s.Active = 1 
    AND u.Enabled = 0

/*
.PURPOSE
Pulls a list of Active secrets in Personal Folders belonging to Inactive users. These will error on migration as the Personal Folders will not exist for inactive users on the target. 

Either deactivate secrets in this report, or move them to a separate folder, pre-migration. 
*/
