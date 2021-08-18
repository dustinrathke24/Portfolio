SELECT *
FROM dbo.topcollege


--Most populous universities
SELECT TOP 15 [name], [rank], [undergraduate population], [student population] 
FROM dbo.topcollege
ORDER BY [undergraduate population] desc, [student population] desc


--Top colleges in Texas
SELECT *
FROM dbo.topcollege
WHERE [state] = 'TX'
ORDER BY [rank]


--Most expensive states for college
SELECT [state], ROUND(AVG([net price]), 0) AS averagecost
FROM dbo.topcollege
GROUP BY [state]
ORDER BY averagecost desc

--Number of universities per state
SELECT [state], COUNT([name]) AS numofuniversities
FROM dbo.topcollege
GROUP BY [state]
ORDER BY numofuniversities desc


--Acceptance rates at Top 5 hardest colleges to get accepted to
SELECT TOP 5 [name], [acceptance rate]
FROM dbo.topcollege
WHERE [acceptance rate] IS NOT NULL
ORDER BY [acceptance rate] asc


--Tuition revenue from top 10 schools
SELECT TOP 10 [name], [city], [state], [acceptance rate], [student population], [total annual cost], ([total annual cost] * [student population]) AS tuitionrevenue
FROM dbo.topcollege
ORDER BY tuitionrevenue desc

--Total United States student population
SELECT SUM([student population]) AS [total students]
FROM dbo.topcollege