SELECT Catalog.Name, Catalog.Path, Users.UserName
FROM Catalog INNER JOIN
Policies ON Catalog.PolicyID = Policies.PolicyID INNER JOIN
PolicyUserRole ON PolicyUserRole.PolicyID = Policies.PolicyID INNER JOIN
Users ON PolicyUserRole.UserID = Users.UserID
WHERE (Catalog.ParentID =
(SELECT ItemID
FROM Catalog
WHERE (ParentID IS NULL)))
ORDER BY Catalog.Path, Users.UserName